import SwiftUI

struct OnboardingAuthScreen: View {
    @ObservedObject var state: OnboardingState
    let onComplete: () -> Void
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingEmailAuth = false
    @State private var showingLogin = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            OnboardingTheme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header section - positioned higher (reduced top padding)
                VStack(spacing: 14) {
                    Text("Your voice is ready.")
                        .font(.system(size: 40, weight: .regular, design: .serif))
                        .italic()
                        .foregroundColor(OnboardingTheme.foreground)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)

                    Text("Sign up to start journaling.")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(OnboardingTheme.muted)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                }
                .padding(.horizontal, OnboardingTheme.screenPadding)
                .padding(.top, 60) // Reduced from 80 to position higher
                
                Spacer()
                
                // Auth buttons - centered in middle
                VStack(spacing: 12) {
                    // Sign up with Apple
                    Button(action: handleAppleSignIn) {
                        HStack(spacing: 10) {
                            Image(systemName: "applelogo")
                                .font(.system(size: 18, weight: .medium))
                            Text("Sign up with Apple")
                                .font(.system(size: 17, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60) // Increased from 56
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(hex: "#1A1A1A"))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(isLoading)
                    
                    // Sign up with Google
                    Button(action: handleGoogleSignIn) {
                        HStack(spacing: 10) {
                            Image("google-logo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                            Text("Sign up with Google")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(OnboardingTheme.foreground)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 60) // Increased from 56
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(hex: "#E8E0D5"), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(isLoading)
                    
                    // Email and Password
                    Button(action: { showingEmailAuth = true }) {
                        HStack(spacing: 10) {
                            Image(systemName: "envelope")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(OnboardingTheme.foreground)
                            Text("Email and Password")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(OnboardingTheme.foreground)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 60) // Increased from 56
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(OnboardingTheme.card)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(isLoading)
                }
                .padding(.horizontal, OnboardingTheme.screenPadding)
                
                Spacer()
                
                // Footer
                VStack(spacing: 20) {
                    // Already have account - pill button style
                    Button(action: { showingLogin = true }) {
                        Text("I already have an account")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(OnboardingTheme.muted)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(OnboardingTheme.card)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(isLoading)
                    
                    // Terms and Privacy - tappable links
                    HStack(spacing: 0) {
                        Text("By signing up to this app you agree with our ")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(OnboardingTheme.muted)
                    }
                    HStack(spacing: 4) {
                        Button(action: {
                            if let url = URL(string: "https://www.studioeight.app/whisper/terms") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Text("Terms of Use")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(OnboardingTheme.muted)
                                .underline()
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Text("and")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(OnboardingTheme.muted)
                        
                        Button(action: {
                            if let url = URL(string: "https://www.studioeight.app/whisper/privacy") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Text("Privacy Policy")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(OnboardingTheme.muted)
                                .underline()
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Text(".")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(OnboardingTheme.muted)
                    }
                }
                .padding(.bottom, 50)
            }
            
            // Loading overlay
            if isLoading {
                Color.black.opacity(0.1)
                    .ignoresSafeArea()
                ProgressView()
                    .scaleEffect(1.2)
            }
        }
        .sheet(isPresented: $showingEmailAuth) {
            NavigationStack {
                SignUpView()
            }
        }
        .sheet(isPresented: $showingLogin) {
            NavigationStack {
                LoginView()
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .onChange(of: authViewModel.isSignedIn) { oldValue, newValue in
            if newValue {
                saveOnboardingDataAndComplete()
            }
        }
    }
    
    // MARK: - Auth Actions
    
    private func handleAppleSignIn() {
        isLoading = true
        authViewModel.signInWithApple { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success:
                    break
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    showingError = true
                }
            }
        }
    }
    
    private func handleGoogleSignIn() {
        isLoading = true
        authViewModel.signInWithGoogle { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success:
                    break
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    showingError = true
                }
            }
        }
    }
    
    private func saveOnboardingDataAndComplete() {
        guard let userId = authViewModel.user?.uid else {
            onComplete()
            return
        }
        
        state.saveOnboardingData(userId: userId) { success in
            DispatchQueue.main.async {
                onComplete()
            }
        }
    }
}

#Preview {
    OnboardingAuthScreen(
        state: OnboardingState(),
        onComplete: {}
    )
    .environmentObject(AuthViewModel.shared)
}
