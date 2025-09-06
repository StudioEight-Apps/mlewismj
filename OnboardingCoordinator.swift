import SwiftUI

struct OnboardingCoordinator: View {
    @State private var currentPage = 0
    @State private var navigateToAuth = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#FFFCF5")
                    .ignoresSafeArea()
                
                // Page content
                TabView(selection: $currentPage) {
                    OnboardingPage1()
                        .tag(0)
                    
                    OnboardingPage2()
                        .tag(1)
                    
                    OnboardingPage3()
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                
                // Navigation controls
                VStack {
                    Spacer()
                    
                    // Continue/Get Started Button
                    Button(action: {
                        if currentPage < 2 {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentPage += 1
                            }
                        } else {
                            completeOnboarding()
                        }
                    }) {
                        Text(currentPage == 2 ? "Get Started" : "Continue")
                            .font(.system(size: 16, weight: .semibold, design: .default))
                            .foregroundColor(.white)
                            .frame(width: UIScreen.main.bounds.width * 0.8)
                            .frame(height: 52)
                            .background(Color(hex: "#A6B4FF"))
                            .cornerRadius(26)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.bottom, 60)
                }
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $navigateToAuth) {
            // Navigate directly to auth (signup/login) - paywall comes after auth
            NavigationView {
                SignUpView()
            }
        }
    }
    
    private func completeOnboarding() {
        // Mark onboarding as completed
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        
        // Navigate to authentication
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            navigateToAuth = true
        }
    }
}
