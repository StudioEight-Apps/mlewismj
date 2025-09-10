import Foundation
import FirebaseAuth

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
                DispatchQueue.main.async {
                    completion(.failure(error))
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
                DispatchQueue.main.async {
                    completion(.failure(error))
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
    
    private func saveUserInfo(firstName: String, lastName: String) {
        UserDefaults.standard.set(firstName, forKey: "firstName")
        UserDefaults.standard.set(lastName, forKey: "lastName")
    }
    
    private func loadUserInfo() {
        self.firstName = UserDefaults.standard.string(forKey: "firstName") ?? ""
        self.lastName = UserDefaults.standard.string(forKey: "lastName") ?? ""
    }
}
