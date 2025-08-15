import SwiftUI

struct RootView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isShowingSplash = true
    @State private var shouldShowOnboarding = false
    @State private var hasCheckedOnboarding = false
    
    var body: some View {
        let _ = print("🔥 RootView - authViewModel.isSignedIn: \(authViewModel.isSignedIn)")
        let _ = print("🔥 RootView - authViewModel.user: \(authViewModel.user?.uid ?? "nil")")
        let _ = print("🔥 RootView - isShowingSplash: \(isShowingSplash)")
        let _ = print("🔥 RootView - shouldShowOnboarding: \(shouldShowOnboarding)")
        
        Group {
            if isShowingSplash {
                SplashScreenView(isShowingSplash: $isShowingSplash)
            } else if shouldShowOnboarding && !authViewModel.isSignedIn {
                // ✅ FIX: Only show onboarding if user is NOT signed in
                OnboardingCoordinator()
            } else {
                // Your existing auth logic
                if authViewModel.isSignedIn {
                    WelcomeView()
                } else {
                    NavigationView {
                        SignUpView()
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
            print("🔥 RootView - authViewModel.isSignedIn CHANGED from \(oldValue) to: \(newValue)")
        }
    }
    
    private func checkOnboardingStatus() {
        hasCheckedOnboarding = true
        
        print("🔥 RootView - checkOnboardingStatus called")
        
        // Check if user has completed onboarding
        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
        print("🔥 RootView - hasSeenOnboarding: \(hasSeenOnboarding)")
        
        // Small delay for smooth transition
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            shouldShowOnboarding = !hasSeenOnboarding
            print("🔥 RootView - shouldShowOnboarding set to: \(shouldShowOnboarding)")
        }
    }
}
