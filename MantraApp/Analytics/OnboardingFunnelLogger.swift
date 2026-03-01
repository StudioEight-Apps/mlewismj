import Foundation
import FirebaseFirestore
import FirebaseAuth

/// Logs onboarding funnel steps to Firestore so the admin panel can query them.
/// Each step is a separate document: `onboarding_funnel/{sessionId}_{step}`
final class OnboardingFunnelLogger {
    static let shared = OnboardingFunnelLogger()

    /// Unique session ID — created fresh each time onboarding starts.
    /// Tracks drop-off even for users who never sign up.
    private(set) var sessionId: String = UUID().uuidString

    private let db = Firestore.firestore()
    private init() {}

    /// Call at the start of onboarding to generate a new session.
    func resetSession() {
        sessionId = UUID().uuidString
    }

    /// Log an onboarding step.
    func logStep(step: String, stepIndex: Int, metadata: [String: Any] = [:]) {
        var data: [String: Any] = [
            "step": step,
            "step_index": stepIndex,
            "timestamp": Timestamp(date: Date()),
            "session_id": sessionId
        ]

        for (key, value) in metadata {
            data[key] = value
        }

        // Attach userId if already authenticated
        if let userId = Auth.auth().currentUser?.uid {
            data["user_id"] = userId
        }

        db.collection("onboarding_funnel")
            .document("\(sessionId)_\(step)")
            .setData(data) { error in
                if let error = error {
                    print("Failed to log onboarding step '\(step)': \(error.localizedDescription)")
                }
            }
    }

    /// Called after auth completes — writes session summary with userId.
    func attachUserId(_ userId: String) {
        db.collection("onboarding_sessions").document(sessionId).setData([
            "session_id": sessionId,
            "user_id": userId,
            "completed": true,
            "completed_at": Timestamp(date: Date())
        ], merge: true)
    }
}
