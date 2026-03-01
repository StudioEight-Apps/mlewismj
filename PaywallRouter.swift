import SwiftUI
import RevenueCat
import RevenueCatUI

/// Routes between your custom paywall and RevenueCat's template paywall.
/// Reads pre-fetched data from RevenueCatManager — no extra network calls.
struct PaywallRouter: View {
    @ObservedObject var revenueCatManager = RevenueCatManager.shared
    @State private var navigateToWelcome = false

    var body: some View {
        ZStack {
            if revenueCatManager.hasPaywallTemplate {
                rcTemplatePaywall
            } else {
                CustomPaywallView()
            }
        }
        .fullScreenCover(isPresented: $navigateToWelcome) {
            WelcomeView()
        }
    }

    // MARK: - RevenueCatUI Template Paywall

    private var rcTemplatePaywall: some View {
        VStack(spacing: 0) {
            RevenueCatUI.PaywallView(displayCloseButton: false)
                .onPurchaseCompleted { _, customerInfo in
                    if customerInfo.entitlements["premium"]?.isActive == true {
                        AnalyticsService.shared.trackPaywallPurchaseCompleted(plan: "rc_template")
                        Task { @MainActor in
                            revenueCatManager.hasActiveSubscription = true
                            navigateToWelcome = true
                        }
                    }
                }
                .onRestoreCompleted { customerInfo in
                    if customerInfo.entitlements["premium"]?.isActive == true {
                        AnalyticsService.shared.trackPaywallRestored(success: true)
                        Task { @MainActor in
                            revenueCatManager.hasActiveSubscription = true
                            navigateToWelcome = true
                        }
                    }
                }

            // Promo code footer
            HStack(spacing: 16) {
                Button(action: {
                    Purchases.shared.presentCodeRedemptionSheet()
                }) {
                    Text("Promo Code")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(hex: "#2C2C2C"))
                }
                .buttonStyle(.plain)

                Button(action: {
                    if let url = URL(string: "https://www.studioeight.app/whisper/terms") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("Terms")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(hex: "#2C2C2C"))
                }
                .buttonStyle(.plain)

                Button(action: {
                    if let url = URL(string: "https://www.studioeight.app/whisper/privacy") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("Privacy")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(hex: "#2C2C2C"))
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 12)
            .background(Color(hex: "#F5EFE7"))
        }
    }
}
