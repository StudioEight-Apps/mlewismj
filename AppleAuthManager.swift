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
        print("DEBUG: Starting Apple Sign-In process")
        
        // Comprehensive environment and configuration check
        var diagnosticInfo: [String] = []
        
        // Check 1: Device type
        #if targetEnvironment(simulator)
        diagnosticInfo.append("⚠️ Running in iOS Simulator (Apple Sign-In requires physical device)")
        #else
        diagnosticInfo.append("✅ Running on physical device")
        #endif
        
        // Check 2: iOS Version
        let systemVersion = UIDevice.current.systemVersion
        diagnosticInfo.append("📱 iOS Version: \(systemVersion)")
        
        // Check 3: Bundle Identifier
        let bundleId = Bundle.main.bundleIdentifier ?? "UNKNOWN"
        diagnosticInfo.append("📦 Bundle ID: \(bundleId)")
        diagnosticInfo.append("🎯 Expected: com.mantraapp.MantraApp")
        if bundleId != "com.mantraapp.MantraApp" {
            diagnosticInfo.append("⚠️ Bundle ID MISMATCH - This will cause Apple Sign-In to fail")
        }
        
        // Check 4: Entitlements
        if let entitlements = Bundle.main.object(forInfoDictionaryKey: "com.apple.developer.applesignin") {
            diagnosticInfo.append("✅ Apple Sign-In entitlement found: \(entitlements)")
        } else {
            diagnosticInfo.append("⚠️ Apple Sign-In entitlement MISSING - Add 'Sign in with Apple' capability in Xcode")
        }
        
        // Check 5: Team ID
        if let teamId = Bundle.main.object(forInfoDictionaryKey: "AppIdentifierPrefix") as? String {
            diagnosticInfo.append("👥 Team ID: \(teamId)")
            if !teamId.contains("6ZHGPD8274") {
                diagnosticInfo.append("⚠️ Team ID doesn't match expected: 6ZHGPD8274")
            }
        } else {
            diagnosticInfo.append("⚠️ Team ID not found in bundle")
        }
        
        // Check 6: Firebase configuration
        if let firebaseApp = FirebaseApp.app() {
            if let clientId = firebaseApp.options.clientID {
                diagnosticInfo.append("🔥 Firebase Client ID: \(clientId)")
            } else {
                diagnosticInfo.append("⚠️ Firebase Client ID MISSING")
            }
            
            if let projectId = firebaseApp.options.projectID {
                diagnosticInfo.append("🔥 Firebase Project: \(projectId)")
            } else {
                diagnosticInfo.append("⚠️ Firebase Project ID MISSING")
            }
        } else {
            diagnosticInfo.append("⚠️ Firebase NOT INITIALIZED")
        }
        
        // Check 7: Network connectivity (basic check)
        diagnosticInfo.append("🌐 Network check: Will attempt connection during auth")
        
        print("=== APPLE SIGN-IN DIAGNOSTIC REPORT ===")
        for info in diagnosticInfo {
            print(info)
        }
        print("=====================================")
        
        self.completion = completion
        
        let nonce = randomNonceString()
        currentNonce = nonce
        print("🔐 Generated nonce: \(nonce)")
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        print("🔐 Created Apple ID request with scopes: \(request.requestedScopes ?? [])")
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        
        print("🚀 Performing Apple Sign-In request...")
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
        print("🎉 DEBUG: Apple authorization completed successfully")
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            print("🎉 DEBUG: Received Apple ID credential")
            print("🎉 DEBUG: User ID: \(appleIDCredential.user)")
            print("🎉 DEBUG: Email: \(appleIDCredential.email ?? "nil")")
            print("🎉 DEBUG: Full Name: \(appleIDCredential.fullName?.debugDescription ?? "nil")")
            
            guard let nonce = currentNonce else {
                print("🚨 DEBUG: ERROR - No current nonce available")
                let error = NSError(domain: "AppleAuth", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Invalid state: A login callback was received, but no login request was sent."
                ])
                completion?(.failure(error))
                return
            }
            
            print("🎉 DEBUG: Using nonce: \(nonce)")
            
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("🚨 DEBUG: ERROR - Unable to fetch identity token")
                let error = NSError(domain: "AppleAuth", code: -2, userInfo: [
                    NSLocalizedDescriptionKey: "Unable to fetch identity token"
                ])
                completion?(.failure(error))
                return
            }
            
            print("🎉 DEBUG: Got identity token (length: \(appleIDToken.count) bytes)")
            
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("🚨 DEBUG: ERROR - Unable to serialize token string from data")
                let error = NSError(domain: "AppleAuth", code: -3, userInfo: [
                    NSLocalizedDescriptionKey: "Unable to serialize token string from data"
                ])
                completion?(.failure(error))
                return
            }
            
            print("🎉 DEBUG: Converted token to string (length: \(idTokenString.count) characters)")
            print("🎉 DEBUG: Creating Firebase credential...")
            
            let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                          rawNonce: nonce,
                                                          fullName: appleIDCredential.fullName)
            
            print("🎉 DEBUG: Firebase credential created, signing in...")
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("🚨 DEBUG: Firebase sign-in failed: \(error.localizedDescription)")
                    print("🚨 DEBUG: Error code: \((error as NSError).code)")
                    print("🚨 DEBUG: Error domain: \((error as NSError).domain)")
                    print("🚨 DEBUG: Error userInfo: \((error as NSError).userInfo)")
                    self.completion?(.failure(error))
                    return
                }
                
                guard let user = authResult?.user else {
                    print("🚨 DEBUG: ERROR - Failed to get Firebase user from authResult")
                    let error = NSError(domain: "AppleAuth", code: -4, userInfo: [
                        NSLocalizedDescriptionKey: "Failed to get Firebase user"
                    ])
                    self.completion?(.failure(error))
                    return
                }
                
                print("🎉 DEBUG: Firebase sign-in successful!")
                print("🎉 DEBUG: Firebase User ID: \(user.uid)")
                print("🎉 DEBUG: Firebase User Email: \(user.email ?? "nil")")
                print("🎉 DEBUG: Is new user: \(authResult?.additionalUserInfo?.isNewUser ?? false)")
                
                // Save user info if it's a new user
                if authResult?.additionalUserInfo?.isNewUser == true {
                    print("🎉 DEBUG: Saving new user info...")
                    let firstName = appleIDCredential.fullName?.givenName ?? ""
                    let lastName = appleIDCredential.fullName?.familyName ?? ""
                    let fullName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
                    let displayName = fullName.isEmpty ? "" : fullName
                    
                    print("🎉 DEBUG: Saving name to Firestore: '\(displayName)'")
                    
                    FirestoreManager.shared.saveUserName(uid: user.uid, name: displayName) { error in
                        if let error = error {
                            print("🚨 DEBUG: Failed to save Apple user name: \(error.localizedDescription)")
                        } else {
                            print("🎉 DEBUG: Successfully saved user name to Firestore")
                        }
                    }
                    
                    // Save to UserDefaults for AuthViewModel
                    UserDefaults.standard.set(firstName, forKey: "firstName")
                    UserDefaults.standard.set(lastName, forKey: "lastName")
                    print("🎉 DEBUG: Saved to UserDefaults - First: '\(firstName)', Last: '\(lastName)'")
                }
                
                print("🎉 DEBUG: Calling completion with success")
                self.completion?(.success(user))
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("APPLE SIGN-IN FAILED")
        
        // Create comprehensive error message
        var errorDetails: [String] = []
        errorDetails.append("=== APPLE SIGN-IN FAILURE REPORT ===")
        errorDetails.append("Primary Error: \(error.localizedDescription)")
        errorDetails.append("Error Code: \((error as NSError).code)")
        errorDetails.append("Error Domain: \((error as NSError).domain)")
        
        // Detailed Apple-specific error analysis
        if let authError = error as? ASAuthorizationError {
            switch authError.code {
            case .canceled:
                errorDetails.append("⚠️ CAUSE: User canceled Apple Sign-In")
                errorDetails.append("💡 SOLUTION: User needs to complete the sign-in process")
            case .failed:
                errorDetails.append("⚠️ CAUSE: Apple Sign-In system failure")
                errorDetails.append("💡 CHECK: Bundle ID must match Apple Developer Console")
                errorDetails.append("💡 CHECK: App must have 'Sign in with Apple' capability")
                errorDetails.append("💡 CHECK: Device must be signed into iCloud")
            case .invalidResponse:
                errorDetails.append("⚠️ CAUSE: Invalid response from Apple servers")
                errorDetails.append("💡 CHECK: Internet connection")
                errorDetails.append("💡 CHECK: Apple Developer configuration")
            case .notHandled:
                errorDetails.append("⚠️ CAUSE: Apple Sign-In request not properly handled")
                errorDetails.append("💡 CHECK: ASAuthorizationControllerDelegate implementation")
            case .unknown:
                errorDetails.append("⚠️ CAUSE: Unknown Apple Sign-In error")
                errorDetails.append("💡 CHECK: All Apple Developer Console settings")
                errorDetails.append("💡 CHECK: Firebase Apple configuration")
            @unknown default:
                errorDetails.append("⚠️ CAUSE: New/unrecognized Apple Sign-In error")
            }
        }
        
        // Network-related checks (basic)
        errorDetails.append("🌐 NETWORK STATUS:")
        errorDetails.append("  💡 CHECK: Ensure device has internet connectivity")
        errorDetails.append("  💡 CHECK: Try connecting to WiFi if using cellular")
        
        // Configuration checks
        errorDetails.append("🔧 CONFIGURATION CHECKLIST:")
        errorDetails.append("  1. Bundle ID: \(Bundle.main.bundleIdentifier ?? "MISSING")")
        errorDetails.append("     Expected: com.mantraapp.MantraApp")
        errorDetails.append("  2. Apple Developer Console:")
        errorDetails.append("     - App ID has 'Sign in with Apple' enabled")
        errorDetails.append("     - Services ID configured with Firebase domains")
        errorDetails.append("     - Key created and downloaded")
        errorDetails.append("  3. Firebase Console:")
        errorDetails.append("     - Apple provider enabled")
        errorDetails.append("     - Team ID: 6ZHGPD8274")
        errorDetails.append("     - Key ID: PWZC4ZFW2G")
        errorDetails.append("     - Services ID: com.studioeight.mantra.services")
        errorDetails.append("  4. Xcode Project:")
        errorDetails.append("     - 'Sign in with Apple' capability added")
        errorDetails.append("     - Bundle ID matches Apple Developer")
        errorDetails.append("     - Team ID matches Apple Developer")
        
        // Device checks
        errorDetails.append("📱 DEVICE REQUIREMENTS:")
        errorDetails.append("  - iOS 13+ (Current: \(UIDevice.current.systemVersion))")
        errorDetails.append("  - Physical device (simulators don't support Apple Sign-In)")
        errorDetails.append("  - Signed into iCloud in Settings")
        errorDetails.append("  - Apple ID has 2FA enabled")
        
        errorDetails.append("=====================================")
        
        // Print all details
        for detail in errorDetails {
            print(detail)
        }
        
        // Create user-friendly error with technical details
        let technicalInfo = errorDetails.joined(separator: "\n")
        let comprehensiveError = NSError(
            domain: "AppleSignInDetailed",
            code: (error as NSError).code,
            userInfo: [
                NSLocalizedDescriptionKey: "Apple Sign-In failed. Check console logs for detailed diagnostic information.",
                NSLocalizedFailureReasonErrorKey: error.localizedDescription,
                "TechnicalDetails": technicalInfo,
                "DiagnosticInfo": errorDetails
            ]
        )
        
        completion?(.failure(comprehensiveError))
    }
}

extension AppleAuthManager: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        print("🎉 DEBUG: Providing presentation anchor...")
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            print("🚨 DEBUG: WARNING - No window found for presentation, using default")
            return UIWindow()
        }
        
        print("🎉 DEBUG: Using main window for presentation")
        return window
    }
}
