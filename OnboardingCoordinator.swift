import SwiftUI

struct OnboardingCoordinator: View {
    @State private var currentPage = 0
    @State private var navigateToAuth = false
    
    var body: some View {
        ZStack {
            // Page content with TabView
            TabView(selection: $currentPage) {
                OnboardingPage1()
                    .tag(0)
                
                OnboardingPage2()
                    .tag(1)
                
                OnboardingPage3()
                    .tag(2)
                
                OnboardingPage5()
                    .tag(3)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            .ignoresSafeArea()
            
            // CTA Button Layer - overlays on top
            VStack {
                Spacer()
                
                if currentPage < 3 {
                    // Pages 1-3: Bottom-right "Continue ›"
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentPage += 1
                            }
                        }) {
                            Text("Continue ›")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(Color(hex: "#2A2A2A"))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 12)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.trailing, 24)
                    }
                } else {
                    // Page 4 (OnboardingPage5): Centered "Start Journaling"
                    HStack {
                        Spacer()
                        Button(action: {
                            completeOnboarding()
                        }) {
                            Text("Start Journaling")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(Color(hex: "#2A2A2A"))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 12)
                        }
                        .buttonStyle(PlainButtonStyle())
                        Spacer()
                    }
                }
                
                // Space for pagination dots
                Spacer()
                    .frame(height: 60)
            }
        }
        .fullScreenCover(isPresented: $navigateToAuth) {
            NavigationView {
                SignUpView()
            }
        }
    }
    
    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            navigateToAuth = true
        }
    }
}
