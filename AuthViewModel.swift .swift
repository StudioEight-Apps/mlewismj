import Foundation
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var isSignedIn: Bool = false
    @Published var user: User?
    @Published var firstName: String = ""
    @Published var lastName: String = ""

    var currentUser: User? {
        return user
    }

    init() {
        self.user = Auth.auth().currentUser
        self.isSignedIn = self.user != nil
        loadUserInfo()
    }

    func signUp(email: String, password: String, firstName: String, lastName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            // 🔥 FIX: Wrap UI updates in main queue
            DispatchQueue.main.async {
                self.user = result?.user
                self.isSignedIn = true
                self.firstName = firstName
                self.lastName = lastName
                self.saveUserInfo(firstName: firstName, lastName: lastName)
            }
            
            // Save to Firestore
            if let userId = result?.user.uid {
                let fullName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
                FirestoreManager.shared.saveUserName(uid: userId, name: fullName) { error in
                    if let error = error {
                        print("Failed to save name to Firestore: \(error)")
                    }
                }
            }
            
            completion(.success(()))
        }
    }

    func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            // 🔥 FIX: Wrap UI updates in main queue
            DispatchQueue.main.async {
                self.user = result?.user
                self.isSignedIn = true
                self.loadUserInfo()
            }
            completion(.success(()))
        }
    }
    
    // MARK: - Google Sign-In
    func signInWithGoogle(completion: @escaping (Result<Void, Error>) -> Void) {
        print("🚀 DEBUG: AuthViewModel.signInWithGoogle called!")
        
        GoogleAuthManager.shared.signInWithGoogle { result in
            print("📱 DEBUG: GoogleAuthManager callback received")
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    print("✅ DEBUG: Google sign-in successful for user: \(user.uid)")
                    self.user = user
                    self.isSignedIn = true
                    self.loadUserInfo()
                    completion(.success(()))
                case .failure(let error):
                    print("❌ DEBUG: Google sign-in failed with error: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Apple Sign-In
    func signInWithApple(completion: @escaping (Result<Void, Error>) -> Void) {
        print("🍎 DEBUG: AuthViewModel.signInWithApple called!")
        
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
            self.user = nil
            self.isSignedIn = false
            self.firstName = ""
            self.lastName = ""
            UserDefaults.standard.removeObject(forKey: "firstName")
            UserDefaults.standard.removeObject(forKey: "lastName")
        } catch {
            print("Failed to sign out: \(error.localizedDescription)")
        }
    }
    
    // ✅ FIXED: Updated deprecated Firebase Auth methods
    func updateProfile(firstName: String, lastName: String, email: String, newPassword: String?, completion: @escaping (Bool, String?) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(false, "No authenticated user")
            return
        }
        
        let group = DispatchGroup()
        var errors: [String] = []
        
        // ✅ FIXED: Update email using new async method
        if email != currentUser.email {
            group.enter()
            Task {
                do {
                    try await currentUser.sendEmailVerification(beforeUpdatingEmail: email)
                    // Email verification sent, user needs to verify before email is updated
                } catch {
                    errors.append("Email update failed: \(error.localizedDescription)")
                }
                group.leave()
            }
        }
        
        // ✅ FIXED: Update password using new async method
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
        
        // Update name in Firestore and local storage
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
            if errors.isEmpty {
                completion(true, nil)
            } else {
                completion(false, errors.joined(separator: "; "))
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
