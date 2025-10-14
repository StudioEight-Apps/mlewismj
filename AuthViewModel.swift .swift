import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    static let shared = AuthViewModel()
    
    @Published var isSignedIn: Bool = false
    @Published var user: User?
    @Published var firstName: String = ""
    @Published var lastName: String = ""

    var currentUser: User? {
        return user
    }

    private init() {
        self.user = Auth.auth().currentUser
        self.isSignedIn = self.user != nil
        loadUserInfo()
    }

    func signUp(email: String, password: String, firstName: String, lastName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                // Handle specific Firebase error codes with custom messages
                let nsError = error as NSError
                
                var customError: Error
                switch nsError.code {
                case AuthErrorCode.emailAlreadyInUse.rawValue:
                    customError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "This email is already registered. Please log in instead."])
                case AuthErrorCode.invalidEmail.rawValue:
                    customError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Please enter a valid email address."])
                case AuthErrorCode.weakPassword.rawValue:
                    customError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Password must be at least 6 characters."])
                case AuthErrorCode.networkError.rawValue:
                    customError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Network error. Please check your connection."])
                default:
                    customError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Sign up failed. Please try again."])
                }
                
                DispatchQueue.main.async {
                    completion(.failure(customError))
                }
                return
            }

            if let userId = result?.user.uid {
                let fullName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
                FirestoreManager.shared.saveUserName(uid: userId, name: fullName) { error in
                    if let error = error {
                        print("Failed to save name to Firestore: \(error)")
                    }
                }
            }

            DispatchQueue.main.async {
                self.user = result?.user
                self.isSignedIn = true
                self.firstName = firstName
                self.lastName = lastName
                self.saveUserInfo(firstName: firstName, lastName: lastName)
                completion(.success(()))
            }
        }
    }

    func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                // Handle specific Firebase error codes with custom messages
                let nsError = error as NSError
                
                var customError: Error
                switch nsError.code {
                case AuthErrorCode.userNotFound.rawValue:
                    customError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "This user actually does not exist. Please sign up first."])
                case AuthErrorCode.wrongPassword.rawValue:
                    customError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Incorrect password. Please try again."])
                case AuthErrorCode.invalidEmail.rawValue:
                    customError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Please enter a valid email address."])
                case AuthErrorCode.userDisabled.rawValue:
                    customError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "This account has been disabled."])
                case AuthErrorCode.networkError.rawValue:
                    customError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Network error. Please check your connection."])
                case AuthErrorCode.invalidCredential.rawValue:
                    customError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid credentials. Please check your email and password."])
                default:
                    customError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Login failed. Please try again."])
                }
                
                DispatchQueue.main.async {
                    completion(.failure(customError))
                }
                return
            }

            DispatchQueue.main.async {
                self.user = result?.user
                self.isSignedIn = true
                self.loadUserInfo()
                completion(.success(()))
            }
        }
    }
    
    func signInWithGoogle(completion: @escaping (Result<Void, Error>) -> Void) {
        GoogleAuthManager.shared.signInWithGoogle { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self.user = user
                    self.isSignedIn = true
                    self.loadUserInfo()
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func signInWithApple(completion: @escaping (Result<Void, Error>) -> Void) {
        AppleAuthManager.shared.signInWithApple { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self.user = user
                    self.isSignedIn = true
                    self.loadUserInfo()
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.user = nil
                self.isSignedIn = false
                self.firstName = ""
                self.lastName = ""
                UserDefaults.standard.removeObject(forKey: "firstName")
                UserDefaults.standard.removeObject(forKey: "lastName")
            }
        } catch {
            print("Failed to sign out: \(error.localizedDescription)")
        }
    }
    
    func updateProfile(firstName: String, lastName: String, email: String, newPassword: String?, completion: @escaping (Bool, String?) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(false, "No authenticated user")
            return
        }
        
        let group = DispatchGroup()
        var errors: [String] = []
        
        if email != currentUser.email {
            group.enter()
            Task {
                do {
                    try await currentUser.sendEmailVerification(beforeUpdatingEmail: email)
                } catch {
                    errors.append("Email update failed: \(error.localizedDescription)")
                }
                group.leave()
            }
        }
        
        if let newPassword = newPassword, !newPassword.isEmpty {
            group.enter()
            Task {
                do {
                    try await currentUser.updatePassword(to: newPassword)
                } catch {
                    errors.append("Password update failed: \(error.localizedDescription)")
                }
                group.leave()
            }
        }
        
        group.enter()
        let fullName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
        FirestoreManager.shared.saveUserName(uid: currentUser.uid, name: fullName) { error in
            if let error = error {
                errors.append("Name update failed: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self.firstName = firstName
                    self.lastName = lastName
                    self.saveUserInfo(firstName: firstName, lastName: lastName)
                }
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            completion(errors.isEmpty, errors.isEmpty ? nil : errors.joined(separator: "; "))
        }
    }
    
    // MARK: - Delete Account
    /// Permanently deletes the user's account and ALL associated data
    /// This includes: Firebase Auth account, Firestore user data, all journal entries, and local data
    /// After deletion, user is automatically signed out and returned to signup screen
    func deleteAccount(completion: @escaping (Bool, String?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            DispatchQueue.main.async {
                completion(false, "No user is currently signed in")
            }
            return
        }
        
        let userId = user.uid
        let db = Firestore.firestore()
        
        print("🗑️ Starting account deletion for user: \(userId)")
        
        // STEP 1: Delete all journal entries from database
        db.collection("users").document(userId).collection("journalEntries").getDocuments { snapshot, error in
            if let error = error {
                print("❌ Error fetching journal entries for deletion: \(error.localizedDescription)")
            } else {
                print("📝 Found \(snapshot?.documents.count ?? 0) journal entries to delete")
            }
            
            // Delete entries in batch
            if let documents = snapshot?.documents, !documents.isEmpty {
                let batch = db.batch()
                documents.forEach { document in
                    batch.deleteDocument(document.reference)
                }
                batch.commit { error in
                    if let error = error {
                        print("❌ Error deleting journal entries: \(error.localizedDescription)")
                    } else {
                        print("✅ All journal entries deleted from database")
                    }
                }
            }
            
            // STEP 2: Delete user document from database
            db.collection("users").document(userId).delete { error in
                if let error = error {
                    print("❌ Error deleting user document: \(error.localizedDescription)")
                } else {
                    print("✅ User document deleted from database")
                }
                
                // STEP 3: Delete Firebase Auth account
                Task {
                    do {
                        try await user.delete()
                        print("✅ Firebase Auth account deleted")
                        
                        // STEP 4: Clear all local data and sign out
                        DispatchQueue.main.async {
                            print("🧹 Clearing local data...")
                            
                            // Clear AuthViewModel state
                            self.user = nil
                            self.isSignedIn = false
                            self.firstName = ""
                            self.lastName = ""
                            
                            // Clear UserDefaults
                            UserDefaults.standard.removeObject(forKey: "firstName")
                            UserDefaults.standard.removeObject(forKey: "lastName")
                            UserDefaults.standard.removeObject(forKey: "currentStreak")
                            UserDefaults.standard.removeObject(forKey: "lastEntryDate")
                            
                            // Clear journal manager (removes all entries and widget data)
                            JournalManager.shared.clearAllEntries()
                            
                            print("✅ Account deletion complete - user will return to signup screen")
                            completion(true, nil)
                        }
                    } catch {
                        // Check if re-authentication is needed
                        let nsError = error as NSError
                        if nsError.code == AuthErrorCode.requiresRecentLogin.rawValue {
                            print("⚠️ Re-authentication required for account deletion")
                            DispatchQueue.main.async {
                                completion(false, "For security reasons, please log out and log back in, then try deleting your account again.")
                            }
                        } else {
                            print("❌ Failed to delete Firebase Auth account: \(error.localizedDescription)")
                            DispatchQueue.main.async {
                                completion(false, "Failed to delete account: \(error.localizedDescription)")
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func saveUserInfo(firstName: String, lastName: String) {
        UserDefaults.standard.set(firstName, forKey: "firstName")
        UserDefaults.standard.set(lastName, forKey: "lastName")
    }
    
    private func loadUserInfo() {
        self.firstName = UserDefaults.standard.string(forKey: "firstName") ?? ""
        self.lastName = UserDefaults.standard.string(forKey: "lastName") ?? ""
    }
}
