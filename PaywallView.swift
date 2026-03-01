import SwiftUI
import RevenueCat

struct CustomPaywallView: View {
    @ObservedObject var revenueCatManager = RevenueCatManager.shared
    @State private var selectedPackage: Package?
    @State private var navigateToWidgetSetup = false
    @State private var navigateToWelcome = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedPlan: PlanType = .annual
    @Environment(\.dismiss) var dismiss

    enum PlanType {
        case annual, weekly
    }

    private let bg = Color(hex: "#F5F2EE")

    var body: some View {
        ZStack {
            // Single unified background
            bg.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {

                        // MARK: - Header
                        VStack(spacing: 10) {
                            Image(systemName: "text.book.closed.fill")
                                .font(.system(size: 36))
                                .foregroundColor(Color(hex: "#C4A574"))

                            Text("Your journal is ready")
                                .font(.system(size: 28, weight: .bold, design: .serif))
                                .foregroundColor(Color(hex: "#1A1A1A"))

                            Text("Start journaling. It learns as you do.")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(Color(hex: "#7A7A7A"))
                        }
                        .padding(.top, 48)
                        .padding(.bottom, 16)
                        .frame(maxWidth: .infinity)

                        // MARK: - Social proof
                        HStack(spacing: 6) {
                            HStack(spacing: 2) {
                                ForEach(0..<5, id: \.self) { _ in
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 11))
                                        .foregroundColor(Color(hex: "#D4A853"))
                                }
                            }
                            Text("\"Built for people who think too much\"")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color(hex: "#9A9A9A"))
                        }
                        .padding(.top, 2)

                        // MARK: - Plan toggle
                        HStack(spacing: 0) {
                            planTab(title: "Annual", subtitle: "Save 67%", type: .annual)
                            planTab(title: "Weekly", subtitle: " ", type: .weekly)
                        }
                        .background(Color(hex: "#EBE7E2"))
                        .cornerRadius(12)
                        .padding(.horizontal, 24)
                        .padding(.top, 24)

                        // MARK: - Price display
                        VStack(spacing: 4) {
                            if selectedPlan == .annual {
                                Text("$4.99 Monthly")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(Color(hex: "#1A1A1A"))
                                if let annual = revenueCatManager.availablePackages.first(where: { $0.packageType == .annual }) {
                                    Text("Charged once annually at \(annual.localizedPriceString) after 3 day free trial")
                                        .font(.system(size: 13, weight: .regular))
                                        .foregroundColor(Color(hex: "#9A9A9A"))
                                        .multilineTextAlignment(.center)
                                } else {
                                    Text("Charged once annually at $59.99 after 3 day free trial")
                                        .font(.system(size: 13, weight: .regular))
                                        .foregroundColor(Color(hex: "#9A9A9A"))
                                        .multilineTextAlignment(.center)
                                }
                            } else {
                                if let weekly = revenueCatManager.availablePackages.first(where: { $0.packageType == .weekly }) {
                                    Text("\(weekly.localizedPriceString) Weekly")
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(Color(hex: "#1A1A1A"))
                                } else {
                                    Text("$2.99 Weekly")
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(Color(hex: "#1A1A1A"))
                                }
                                Text("Billed weekly after 3 day free trial")
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundColor(Color(hex: "#9A9A9A"))
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 18)
                        .animation(.easeInOut(duration: 0.2), value: selectedPlan)

                        // MARK: - Feature list
                        VStack(spacing: 0) {
                            featureRow(
                                assetIcon: "paywall-icon-brain",
                                title: "Smart Prompts",
                                description: "Questions that adapt to your mood and voice"
                            )
                            divider
                            featureRow(
                                assetIcon: "paywall-icon-repeat",
                                title: "Responsive Widgets",
                                description: "Personally tailored reflections delivered to your widgets"
                            )
                            divider
                            featureRow(
                                assetIcon: "paywall-icon-waveform",
                                title: "Deeper Journaling",
                                description: "A journal that learns you the more you vent"
                            )
                            divider
                            featureRow(
                                assetIcon: "paywall-icon-chat",
                                title: "Unlimited Entries",
                                description: "Journal as often as you need, no limits"
                            )
                        }
                        .padding(.vertical, 4)
                        .background(Color(hex: "#FEFDFB"))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(hex: "#E5E0DA"), lineWidth: 1)
                        )
                        .padding(.horizontal, 24)
                        .padding(.top, 20)

                        // MARK: - Error
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .font(.system(size: 13))
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                                .padding(.top, 12)
                        }

                    }
                }
                .scrollContentBackground(.hidden)
                .scrollBounceBehavior(.basedOnSize)

                // MARK: - Sticky CTA
                VStack(spacing: 8) {
                    Button(action: handlePurchase) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(Color(hex: "#1A1A1A"))
                                .cornerRadius(27)
                        } else {
                            Text("Start Free Trial")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(Color(hex: "#1A1A1A"))
                                .cornerRadius(27)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(isLoading)

                    Text("No payment now · Cancel anytime")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Color(hex: "#ABABAB"))

                    HStack(spacing: 16) {
                        Button(action: handleRestore) {
                            Text("Restore")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color(hex: "#ABABAB"))
                        }
                        .buttonStyle(.plain)
                        .disabled(isLoading)

                        Button(action: handleRedeemCode) {
                            Text("Promo Code")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color(hex: "#ABABAB"))
                        }
                        .buttonStyle(.plain)
                        .disabled(isLoading)

                        Button(action: {
                            if let url = URL(string: "https://www.studioeight.app/whisper/terms") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Text("Terms")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color(hex: "#ABABAB"))
                        }
                        .buttonStyle(.plain)

                        Button(action: {
                            if let url = URL(string: "https://www.studioeight.app/whisper/privacy") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Text("Privacy")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color(hex: "#ABABAB"))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 28)
                .background(
                    bg
                        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: -4)
                )
            }
        }
        .fullScreenCover(isPresented: $navigateToWidgetSetup) {
            WidgetSetupHomeScreen()
        }
        .fullScreenCover(isPresented: $navigateToWelcome) {
            WelcomeView()
        }
        .onChange(of: selectedPlan) { _, newPlan in
            AnalyticsService.shared.trackPaywallPlanSelected(plan: newPlan == .annual ? "annual" : "weekly")
            selectPackageForPlan(newPlan)
        }
        .onChange(of: revenueCatManager.availablePackages) { _, packages in
            if selectedPackage == nil {
                selectPackageForPlan(selectedPlan)
            }
        }
        .onAppear {
            AnalyticsService.shared.trackPaywallShown(source: "post_onboarding")
            selectPackageForPlan(.annual)
            if revenueCatManager.availablePackages.isEmpty {
                Task {
                    do {
                        try await revenueCatManager.fetchOfferings()
                    } catch {
                        errorMessage = "Unable to load subscription options"
                    }
                }
            }
        }
    }

    // MARK: - Plan Tab

    private func planTab(title: String, subtitle: String, type: PlanType) -> some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedPlan = type
            }
        }) {
            VStack(spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: selectedPlan == type ? .semibold : .regular))
                    .foregroundColor(selectedPlan == type ? Color(hex: "#1A1A1A") : Color(hex: "#9A9A9A"))
                Text(subtitle)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(selectedPlan == type ? Color(hex: "#C4A574") : Color(hex: "#B5B5B5"))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(
                selectedPlan == type
                    ? Color(hex: "#FEFDFB")
                    : Color.clear
            )
            .cornerRadius(10)
            .shadow(color: selectedPlan == type ? .black.opacity(0.06) : .clear, radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(3)
    }

    // MARK: - Feature Row

    private func featureRow(assetIcon: String, title: String, description: String) -> some View {
        HStack(spacing: 14) {
            Image(assetIcon)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 22)
                .foregroundColor(Color(hex: "#C4A574"))
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "#1A1A1A"))
                Text(description)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color(hex: "#8A8A8A"))
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private var divider: some View {
        Rectangle()
            .fill(Color(hex: "#F2F2F2"))
            .frame(height: 1)
            .padding(.leading, 62)
    }

    // MARK: - Package Selection

    private func selectPackageForPlan(_ plan: PlanType) {
        let type: PackageType = plan == .annual ? .annual : .weekly
        if let pkg = revenueCatManager.availablePackages.first(where: { $0.packageType == type }) {
            selectedPackage = pkg
        }
    }

    // MARK: - Actions

    private func handlePurchase() {
        guard let selectedPackage = selectedPackage else { return }
        let planName = selectedPlan == .annual ? "annual" : "weekly"
        AnalyticsService.shared.trackPaywallPurchaseStarted(plan: planName)

        Task {
            isLoading = true
            errorMessage = nil

            do {
                try await revenueCatManager.purchase(packageIdentifier: selectedPackage.identifier)

                if revenueCatManager.hasActiveSubscription {
                    AnalyticsService.shared.trackPaywallPurchaseCompleted(plan: planName)
                    let hasSeenWidgetSetup = UserDefaults.standard.bool(forKey: "hasSeenWidgetSetup")
                    if hasSeenWidgetSetup {
                        navigateToWelcome = true
                    } else {
                        navigateToWidgetSetup = true
                    }
                }
            } catch {
                errorMessage = error.localizedDescription
            }

            isLoading = false
        }
    }

    private func handleRedeemCode() {
        Purchases.shared.presentCodeRedemptionSheet()
    }

    private func handleRestore() {
        Task {
            isLoading = true
            errorMessage = nil

            do {
                try await revenueCatManager.restorePurchases()

                AnalyticsService.shared.trackPaywallRestored(success: revenueCatManager.hasActiveSubscription)
                if revenueCatManager.hasActiveSubscription {
                    let hasSeenWidgetSetup = UserDefaults.standard.bool(forKey: "hasSeenWidgetSetup")
                    if hasSeenWidgetSetup {
                        navigateToWelcome = true
                    } else {
                        navigateToWidgetSetup = true
                    }
                }
            } catch {
                AnalyticsService.shared.trackPaywallRestored(success: false)
                errorMessage = "No previous purchases found"
            }

            isLoading = false
        }
    }
}

// MARK: - Preview
struct CustomPaywallView_Previews: PreviewProvider {
    static var previews: some View {
        CustomPaywallView()
    }
}
