import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    // Form fields
    @State private var email = ""
    @State private var password = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    
    // Forgot password
    @State private var showingResetPassword = false
    @State private var resetEmail = ""
    
    var body: some View {
        ZStack {
            // Background - matches onboarding theme
            OnboardingTheme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Back Button - top left
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(OnboardingTheme.foreground)
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(PlainButtonStyle())
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)
                
                // Whisper Logo
                Image("whisper-logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 40)
                    .padding(.top, 32)
                
                // Title
                Text("Welcome back")
                    .font(.system(size: 28, weight: .regular, design: .serif))
                    .italic()
                    .foregroundColor(OnboardingTheme.foreground)
                    .padding(.top, 16)
                
                // Form Fields
                VStack(spacing: 12) {
                    // Email Field
                    TextField("", text: $email, prompt: Text("Email").foregroundColor(OnboardingTheme.placeholder))
                        .font(OnboardingTheme.body())
                        .foregroundColor(OnboardingTheme.foreground)
                        .padding(.horizontal, 16)
                        .frame(height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(OnboardingTheme.inputBackground)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(OnboardingTheme.inputBorder, lineWidth: 1)
                        )
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .contentShape(Rectangle())

                    // Password Field
                    SecureField("", text: $password, prompt: Text("Password").foregroundColor(OnboardingTheme.placeholder))
                        .font(OnboardingTheme.body())
                        .foregroundColor(OnboardingTheme.foreground)
                        .padding(.horizontal, 16)
                        .frame(height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(OnboardingTheme.inputBackground)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(OnboardingTheme.inputBorder, lineWidth: 1)
                        )
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .contentShape(Rectangle())

                    // Forgot Password Link
                    HStack {
                        Spacer()
                        Button(action: {
                            resetEmail = email
                            showingResetPassword = true
                        }) {
                            Text("Forgot Password?")
                                .font(OnboardingTheme.caption())
                                .foregroundColor(OnboardingTheme.accent)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, OnboardingTheme.screenPadding)
                .padding(.top, 48)
                
                // Log In Button
                Button(action: handleLogin) {
                    Text("Log In")
                        .font(OnboardingTheme.button())
                        .foregroundColor(OnboardingTheme.buttonText)
                        .frame(maxWidth: .infinity)
                        .frame(height: OnboardingTheme.buttonHeight)
                        .background(
                            RoundedRectangle(cornerRadius: OnboardingTheme.buttonRadius)
                                .fill(OnboardingTheme.accent)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, OnboardingTheme.screenPadding)
                .padding(.top, 32)
                
                // Divider
                HStack(spacing: 16) {
                    Rectangle()
                        .fill(OnboardingTheme.muted.opacity(0.3))
                        .frame(height: 1)
                    Text("or")
                        .font(OnboardingTheme.caption())
                        .foregroundColor(OnboardingTheme.muted)
                    Rectangle()
                        .fill(OnboardingTheme.muted.opacity(0.3))
                        .frame(height: 1)
                }
                .padding(.horizontal, OnboardingTheme.screenPadding)
                .padding(.top, 24)
                
                // Social Auth Buttons
                VStack(spacing: 12) {
                    // Apple Sign In
                    Button(action: handleAppleSignIn) {
                        HStack(spacing: 12) {
                            Image(systemName: "applelogo")
                                .font(.system(size: 18, weight: .medium))
                            Text("Continue with Apple")
                                .font(OnboardingTheme.button())
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: OnboardingTheme.buttonHeight)
                        .background(
                            RoundedRectangle(cornerRadius: OnboardingTheme.buttonRadius)
                                .fill(OnboardingTheme.buttonBlack)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Google Sign In
                    Button(action: handleGoogleSignIn) {
                        HStack(spacing: 12) {
                            Image("google-logo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 18, height: 18)
                            Text("Continue with Google")
                                .font(OnboardingTheme.button())
                                .foregroundColor(OnboardingTheme.foreground)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: OnboardingTheme.buttonHeight)
                        .background(
                            RoundedRectangle(cornerRadius: OnboardingTheme.buttonRadius)
                                .fill(OnboardingTheme.card)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, OnboardingTheme.screenPadding)
                .padding(.top, 16)
                
                Spacer()
                
                // Sign Up Link
                HStack(spacing: 4) {
                    Text("Don't have an account?")
                        .font(OnboardingTheme.caption())
                        .foregroundColor(OnboardingTheme.muted)
                    NavigationLink(destination: SignUpView()) {
                        Text("Sign Up")
                            .font(OnboardingTheme.caption())
                            .fontWeight(.medium)
                            .foregroundColor(OnboardingTheme.accent)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.bottom, 48)
            }
        }
        .navigationBarHidden(true)
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .alert("Reset Password", isPresented: $showingResetPassword) {
            TextField("Email", text: $resetEmail)
            Button("Send Reset Link") {
                handleResetPassword()
            }
            Button("Cancel", role: .cancel) {
                resetEmail = ""
            }
        } message: {
            Text("Enter your email address to receive a password reset link.")
        }
    }
    
    // MARK: - Actions
    
    func handleLogin() {
        guard !email.isEmpty && !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            showingError = true
            return
        }
        
        authViewModel.signIn(
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            password: password
        ) { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                self.showingError = true
            }
        }
    }
    
    func handleResetPassword() {
        guard !resetEmail.isEmpty else {
            errorMessage = "Please enter your email address"
            showingError = true
            return
        }
        
        authViewModel.resetPassword(email: resetEmail.trimmingCharacters(in: .whitespacesAndNewlines)) { result in
            switch result {
            case .success:
                errorMessage = "Password reset email sent! Check your inbox."
                showingError = true
                resetEmail = ""
            case .failure(let error):
                errorMessage = error.localizedDescription
                showingError = true
            }
        }
    }
    
    func handleGoogleSignIn() {
        authViewModel.signInWithGoogle { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                self.showingError = true
            }
        }
    }
    
    func handleAppleSignIn() {
        authViewModel.signInWithApple { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                self.showingError = true
            }
        }
    }
}
