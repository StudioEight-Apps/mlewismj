import Foundation
import AuthenticationServices
import Firebase
import FirebaseAuth
import CryptoKit

class AppleAuthManager: NSObject, ObservableObject {
    static let shared = AppleAuthManager()
    
    private var currentNonce: String?
    private var completion: ((Result<User, Error>) -> Void)?
    
    private override init() {
        super.init()
    }
    
    func signInWithApple(completion: @escaping (Result<User, Error>) -> Void) {
        self.completion = completion
        
        let nonce = randomNonceString()
        currentNonce = nonce
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

extension AppleAuthManager: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                completion?(.failure(NSError(domain: "AppleAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid state: A login callback was received, but no login request was sent."])))
                return
            }
            
            guard let appleIDToken = appleIDCredential.identityToken else {
                completion?(.failure(NSError(domain: "AppleAuth", code: -2, userInfo: [NSLocalizedDescriptionKey: "Unable to fetch identity token"])))
                return
            }
            
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                completion?(.failure(NSError(domain: "AppleAuth", code: -3, userInfo: [NSLocalizedDescriptionKey: "Unable to serialize token string from data"])))
                return
            }
            
            let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                          rawNonce: nonce,
                                                          fullName: appleIDCredential.fullName)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    self.completion?(.failure(error))
                    return
                }
                
                guard let user = authResult?.user else {
                    self.completion?(.failure(NSError(domain: "AppleAuth", code: -4, userInfo: [NSLocalizedDescriptionKey: "Failed to get Firebase user"])))
                    return
                }
                
                // Save user info if it's a new user
                if authResult?.additionalUserInfo?.isNewUser == true {
                    let firstName = appleIDCredential.fullName?.givenName ?? ""
                    let lastName = appleIDCredential.fullName?.familyName ?? ""
                    let fullName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
                    let displayName = fullName.isEmpty ? "Apple User" : fullName
                    
                    FirestoreManager.shared.saveUserName(uid: user.uid, name: displayName) { error in
                        if let error = error {
                            print("Failed to save Apple user name: \(error.localizedDescription)")
                        }
                    }
                    
                    // Save to UserDefaults for AuthViewModel
                    UserDefaults.standard.set(firstName, forKey: "firstName")
                    UserDefaults.standard.set(lastName, forKey: "lastName")
                }
                
                self.completion?(.success(user))
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        completion?(.failure(error))
    }
}

extension AppleAuthManager: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return UIWindow()
        }
        return window
    }
}
