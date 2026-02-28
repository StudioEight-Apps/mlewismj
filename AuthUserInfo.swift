import Foundation
import FirebaseAuth

/// Struct to hold user authentication info including whether this is a new user
/// Used by GoogleAuthManager and AppleAuthManager to communicate new user status
struct AuthUserInfo {
    let user: User
    let isNewUser: Bool
}
