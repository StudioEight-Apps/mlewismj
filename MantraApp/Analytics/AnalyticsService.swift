import Foundation
import FirebaseAnalytics

/// Centralized analytics service wrapping Firebase Analytics.
/// Usage: `AnalyticsService.shared.trackMoodSelected(mood: "Calm")`
final class AnalyticsService {
    static let shared = AnalyticsService()
    private init() {}

    // MARK: - Onboarding Funnel

    func trackOnboardingScreenViewed(screen: String, stepIndex: Int) {
        Analytics.logEvent("onboarding_screen_viewed", parameters: [
            "screen_name": screen,
            "step_index": stepIndex
        ])
    }

    func trackOnboardingQuestionAnswered(questionKey: String, selectedVoiceId: Int, stepIndex: Int) {
        Analytics.logEvent("onboarding_question_answered", parameters: [
            "question_key": questionKey,
            "selected_voice_id": selectedVoiceId,
            "step_index": stepIndex
        ])
    }

    func trackOnboardingVoiceRevealed(voiceId: Int, archetypeName: String) {
        Analytics.logEvent("onboarding_voice_revealed", parameters: [
            "voice_id": voiceId,
            "archetype_name": archetypeName
        ])
    }

    func trackOnboardingCompleted(voiceId: Int) {
        Analytics.logEvent("onboarding_completed", parameters: [
            "voice_id": voiceId
        ])
    }

    // MARK: - Auth

    func trackSignUp(method: String) {
        Analytics.logEvent(AnalyticsEventSignUp, parameters: [
            AnalyticsParameterMethod: method
        ])
    }

    func trackSignIn(method: String) {
        Analytics.logEvent(AnalyticsEventLogin, parameters: [
            AnalyticsParameterMethod: method
        ])
    }

    // MARK: - Paywall

    func trackPaywallShown(source: String) {
        Analytics.logEvent("paywall_shown", parameters: [
            "source": source
        ])
    }

    func trackPaywallPlanSelected(plan: String) {
        Analytics.logEvent("paywall_plan_selected", parameters: [
            "plan": plan
        ])
    }

    func trackPaywallPurchaseStarted(plan: String) {
        Analytics.logEvent("paywall_purchase_started", parameters: [
            "plan": plan
        ])
    }

    func trackPaywallPurchaseCompleted(plan: String) {
        Analytics.logEvent("paywall_purchase_completed", parameters: [
            "plan": plan
        ])
    }

    func trackPaywallSkipped() {
        Analytics.logEvent("paywall_skipped", parameters: nil)
    }

    func trackPaywallRestored(success: Bool) {
        Analytics.logEvent("paywall_restored", parameters: [
            "success": success
        ])
    }

    // MARK: - Journal Flow

    func trackJournalModeSelected(mode: String) {
        Analytics.logEvent("journal_mode_selected", parameters: [
            "mode": mode
        ])
    }

    func trackMoodSelected(mood: String) {
        Analytics.logEvent("mood_selected", parameters: [
            "mood": mood
        ])
    }

    func trackJournalSessionCompleted(mood: String, journalType: String) {
        Analytics.logEvent("journal_session_completed", parameters: [
            "mood": mood,
            "journal_type": journalType
        ])
    }

    // MARK: - Entry Actions

    func trackEntryFavorited(isFavoriting: Bool) {
        Analytics.logEvent("entry_favorited", parameters: [
            "action": isFavoriting ? "favorite" : "unfavorite"
        ])
    }

    func trackEntryPinned(isPinning: Bool) {
        Analytics.logEvent("entry_pinned", parameters: [
            "action": isPinning ? "pin" : "unpin"
        ])
    }

    func trackEntryShared() {
        Analytics.logEvent("entry_shared", parameters: nil)
    }

    func trackBackgroundChanged() {
        Analytics.logEvent("background_changed", parameters: nil)
    }

    // MARK: - App Lifecycle

    func trackAppOpened() {
        Analytics.logEvent("app_opened", parameters: nil)
    }

    // MARK: - User Properties

    func setUserId(_ userId: String) {
        Analytics.setUserID(userId)
    }

    func setUserProperties(voiceId: Int, hasSubscription: Bool) {
        Analytics.setUserProperty(String(voiceId), forName: "voice_id")
        Analytics.setUserProperty(hasSubscription ? "premium" : "free", forName: "subscription_status")
    }
}
