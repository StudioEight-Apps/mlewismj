import Foundation
import GoogleSignIn
import Firebase
import FirebaseAuth

class GoogleAuthManager: ObservableObject {
    static let shared = GoogleAuthManager()
    
    private init() {}
    
    func signInWithGoogle(completion: @escaping (Result<User, Error>) -> Void) {
        print("🔍 DEBUG: Starting Google Sign-In")
        print("🔍 DEBUG: FirebaseApp.app() = \(FirebaseApp.app() != nil ? "initialized" : "nil")")
        print("🔍 DEBUG: FirebaseApp.app()?.options = \(FirebaseApp.app()?.options != nil ? "present" : "nil")")
        print("🔍 DEBUG: clientID = \(FirebaseApp.app()?.options.clientID ?? "nil")")
        
        // Get the client ID from Firebase configuration
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("❌ DEBUG: No client ID found!")
            completion(.failure(NSError(domain: "GoogleAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "No client ID found"])))
            return
        }
        
        print("✅ DEBUG: Found client ID: \(clientID)")
        
        // Configure Google Sign-In
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Get the presenting view controller
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let presentingViewController = windowScene.windows.first?.rootViewController else {
            completion(.failure(NSError(domain: "GoogleAuth", code: -2, userInfo: [NSLocalizedDescriptionKey: "No presenting view controller"])))
            return
        }
        
        // Start sign-in flow (Updated for GoogleSignIn 9.0.0)
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                completion(.failure(NSError(domain: "GoogleAuth", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to get ID token"])))
                return
            }
            
            let accessToken = user.accessToken.tokenString
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            
            // Sign in to Firebase with Google credential
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let firebaseUser = authResult?.user else {
                    completion(.failure(NSError(domain: "GoogleAuth", code: -4, userInfo: [NSLocalizedDescriptionKey: "Failed to get Firebase user"])))
                    return
                }
                
                // Save user info to Firestore if it's a new user
                if authResult?.additionalUserInfo?.isNewUser == true {
                    let displayName = firebaseUser.displayName ?? ""
                    let nameParts = displayName.split(separator: " ")
                    let firstName = nameParts.first.map(String.init) ?? ""
                    let lastName = nameParts.dropFirst().joined(separator: " ")
                    
                    let fullName = displayName.isEmpty ? "Google User" : displayName
                    FirestoreManager.shared.saveUserName(uid: firebaseUser.uid, name: fullName) { error in
                        if let error = error {
                            print("Failed to save Google user name: \(error.localizedDescription)")
                        }
                    }
                    
                    // Save to UserDefaults for AuthViewModel
                    UserDefaults.standard.set(firstName, forKey: "firstName")
                    UserDefaults.standard.set(lastName, forKey: "lastName")
                }
                
                completion(.success(firebaseUser))
            }
        }
    }
}
