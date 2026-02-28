import SwiftUI

struct RootView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var revenueCatManager = RevenueCatManager.shared
    @Environment(\.colorScheme) var colorScheme
    private var colors: AppColors { AppColors(colorScheme) }
    @State private var isShowingSplash = true
    @State private var shouldShowOnboarding = false
    @State private var hasCheckedOnboarding = false
    @State private var isStoreKitReady = false

    var body: some View {
        ZStack(alignment: .top) {
            Group {
                if isShowingSplash || !hasCheckedOnboarding {
                    SplashScreenView(isShowingSplash: $isShowingSplash)
                } else if shouldShowOnboarding {
                    OnboardingCoordinatorNew()
                } else if authViewModel.isSignedIn && isStoreKitReady && !revenueCatManager.hasActiveSubscription {
                    #if targetEnvironment(simulator) && DEBUG
                    WelcomeView()
                    #else
                    PaywallRouter()
                    #endif
                } else if authViewModel.isSignedIn && revenueCatManager.hasActiveSubscription {
                    WelcomeView()
                } else if authViewModel.isSignedIn && !isStoreKitReady {
                    ZStack {
                        colors.screenBackground.ignoresSafeArea()
                        VStack(spacing: 20) {
                            ProgressView()
                                .scaleEffect(1.2)
                            Text("Loading...")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(colors.primaryText)
                        }
                    }
                } else {
                    NavigationStack {
                        SignUpView(showBackButton: false)
                    }
                }
            }
        }
        .onChange(of: isShowingSplash) { oldValue, newValue in
            if !newValue && !hasCheckedOnboarding {
                checkOnboardingStatus()
            }
        }
        .onChange(of: authViewModel.isSignedIn) { oldValue, newValue in
            print("RootView - authViewModel.isSignedIn CHANGED from \(oldValue) to: \(newValue)")
            if newValue {
                if shouldShowOnboarding {
                    print("RootView - User signed in during onboarding, resetting shouldShowOnboarding")
                    shouldShowOnboarding = false
                    UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                }
                Task {
                    await initializeRevenueCat()
                }
            } else {
                isStoreKitReady = false
            }
        }
        .task {
            if authViewModel.isSignedIn {
                await initializeRevenueCat()
            }
        }
    }
    
    private func initializeRevenueCat() async {
        print("Initializing RevenueCat...")
        
        // CRITICAL FIX: Ensure RevenueCat is logged in as the correct Firebase user
        // BEFORE checking subscription status. This prevents the race condition where
        // checkSubscriptionStatus() runs for an anonymous user and returns false.
        if let userId = authViewModel.user?.uid {
            print("Setting RevenueCat user: \(userId)")
            do {
                try await revenueCatManager.setUser(userId: userId)
                // setUser() already calls checkSubscriptionStatus() internally,
                // so we don't need to call it again here
            } catch {
                print("Failed to set RevenueCat user: \(error.localizedDescription)")
                // Fall back to checking status anyway
                await revenueCatManager.checkSubscriptionStatus()
            }
        } else {
            print("No Firebase user ID available, checking subscription status directly")
            await revenueCatManager.checkSubscriptionStatus()
        }
        
        // Pre-fetch offerings so paywall loads instantly
        if !revenueCatManager.hasActiveSubscription {
            do {
                try await revenueCatManager.fetchOfferings()
            } catch {
                print("Failed to pre-fetch offerings: \(error.localizedDescription)")
            }
        }

        await MainActor.run {
            isStoreKitReady = true
            print("RevenueCat ready, hasActiveSubscription: \(revenueCatManager.hasActiveSubscription)")
        }
    }
    
    private func checkOnboardingStatus() {
        hasCheckedOnboarding = true
        print("RootView - checkOnboardingStatus called")

        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
        let isUserSignedIn = authViewModel.isSignedIn

        print("RootView - hasSeenOnboarding: \(hasSeenOnboarding)")
        print("RootView - isUserSignedIn: \(isUserSignedIn)")

        let shouldShow = !hasSeenOnboarding && !isUserSignedIn
        shouldShowOnboarding = shouldShow
        print("RootView - shouldShowOnboarding set to: \(shouldShow)")
    }
}
