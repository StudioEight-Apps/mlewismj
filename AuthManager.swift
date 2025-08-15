import Foundation
import FirebaseAuth

final class AuthManager {
    static let shared = AuthManager()
    
    private init() {}
    
    // MARK: - Sign Up
    func signUp(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let user = result?.user {
                completion(.success(user))
            } else if let error = error {
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Sign In
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let user = result?.user {
                completion(.success(user))
            } else if let error = error {
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Sign Out
    func signOut(completion: @escaping (Bool) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(true)
        } catch {
            completion(false)
        }
    }
    
    // MARK: - Current User
    func getCurrentUser() -> User? {
        return Auth.auth().currentUser
    }
}

import FirebaseFirestore

struct FirestoreManager {
    static let shared = FirestoreManager()
    
    private let db = Firestore.firestore()
    
    func saveUserName(uid: String, name: String, completion: @escaping (Error?) -> Void) {
        let userRef = db.collection("users").document(uid)
        userRef.setData(["name": name], merge: true) { error in
            completion(error)
        }
    }
    
    func fetchUserName(uid: String, completion: @escaping (String?) -> Void) {
        let userRef = db.collection("users").document(uid)
        userRef.getDocument { document, error in
            if let doc = document, doc.exists {
                let name = doc.data()?["name"] as? String
                completion(name)
            } else {
                completion(nil)
            }
        }
    }
}
