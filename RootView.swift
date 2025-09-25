import SwiftUI

struct RootView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var isShowingSplash = true
    @State private var shouldShowOnboarding = false
    @State private var hasCheckedOnboarding = false
    @State private var isStoreKitReady = false
    
    // Development bypass - remove before App Store submission
    #if DEBUG
    @State private var bypassSubscription = false
    #endif
    
    var body: some View {
        Group {
            if isShowingSplash {
                SplashScreenView(isShowingSplash: $isShowingSplash)
            } else if shouldShowOnboarding {
                // Show onboarding only for truly new users (never seen onboarding AND not signed in)
                OnboardingCoordinator()
            } else if authViewModel.isSignedIn && isStoreKitReady && !subscriptionManager.hasActiveSubscription {
                #if DEBUG
                if bypassSubscription {
                    WelcomeView()
                } else {
                    ZStack {
                        PaywallView()
                        
                        // Development bypass button
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Button("DEV: Skip Paywall") {
                                    bypassSubscription = true
                                }
                                .padding(8)
                                .background(Color.red.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .padding()
                            }
                        }
                    }
                }
                #else
                PaywallView()
                #endif
            } else if authViewModel.isSignedIn && subscriptionManager.hasActiveSubscription {
                WelcomeView()
            } else if authViewModel.isSignedIn && !isStoreKitReady {
                ZStack {
                    Color(hex: "#FFFCF5").ignoresSafeArea()
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Loading...")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(hex: "#2A2A2A"))
                        
                        #if DEBUG
                        Button("DEV: Skip Loading") {
                            bypassSubscription = true
                        }
                        .padding()
                        .background(Color.red.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        #endif
                    }
                }
            } else {
                // User is not signed in - go directly to auth screen (no onboarding for returning users)
                NavigationView {
                    SignUpView()
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
                // Reset onboarding state when user signs in during onboarding flow
                if shouldShowOnboarding {
                    print("RootView - User signed in during onboarding, resetting shouldShowOnboarding")
                    shouldShowOnboarding = false
                    UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                }
                Task {
                    await initializeStoreKit()
                }
            } else {
                isStoreKitReady = false
            }
        }
        .task {
            if authViewModel.isSignedIn {
                await initializeStoreKit()
            }
        }
    }
    
    private func initializeStoreKit() async {
        print("Initializing StoreKit...")
        await subscriptionManager.initialize()
        await subscriptionManager.checkSubscriptionStatus()
        
        await MainActor.run {
            isStoreKitReady = true
            print("StoreKit ready, hasActiveSubscription: \(subscriptionManager.hasActiveSubscription)")
        }
    }
    
    private func checkOnboardingStatus() {
        hasCheckedOnboarding = true
        print("RootView - checkOnboardingStatus called")
        
        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
        let isUserSignedIn = authViewModel.isSignedIn
        
        print("RootView - hasSeenOnboarding: \(hasSeenOnboarding)")
        print("RootView - isUserSignedIn: \(isUserSignedIn)")
        
        // Only show onboarding if:
        // 1. User has NEVER seen onboarding before AND
        // 2. User is NOT currently signed in (truly new user)
        let shouldShow = !hasSeenOnboarding && !isUserSignedIn
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            shouldShowOnboarding = shouldShow
            print("RootView - shouldShowOnboarding set to: \(shouldShow)")
        }
    }
}
