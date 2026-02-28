import SwiftUI

struct SignUpView: View {
    var showBackButton: Bool = true
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss

    // Form fields
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    @FocusState private var focusedField: Field?

    enum Field {
        case firstName, lastName, email, password
    }
    
    var body: some View {
        ZStack {
            // Background - matches onboarding theme
            OnboardingTheme.background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Back Button - top left (hidden when root view)
                    if showBackButton {
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
                    }
                    
                    // Whisper Logo
                    Image("whisper-logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 40)
                        .padding(.top, 32)
                    
                    // Title
                    Text("Create your account")
                        .font(.system(size: 28, weight: .regular, design: .serif))
                        .italic()
                        .foregroundColor(OnboardingTheme.foreground)
                        .padding(.top, 16)
                    
                    // Form Fields
                    VStack(spacing: 12) {
                        // First Name / Last Name Row
                        HStack(spacing: 12) {
                            TextField("", text: $firstName, prompt: Text("First Name").foregroundColor(OnboardingTheme.placeholder))
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
                                .autocapitalization(.words)
                                .contentShape(Rectangle())
                                .focused($focusedField, equals: .firstName)

                            TextField("", text: $lastName, prompt: Text("Last Name").foregroundColor(OnboardingTheme.placeholder))
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
                                .autocapitalization(.words)
                                .contentShape(Rectangle())
                                .focused($focusedField, equals: .lastName)
                        }

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
                            .focused($focusedField, equals: .email)

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
                            .focused($focusedField, equals: .password)
                    }
                    .padding(.horizontal, OnboardingTheme.screenPadding)
                    .padding(.top, 48)
                    
                    // Sign Up Button
                    Button(action: {
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                        handleSignUp()
                    }) {
                        Text("Sign Up")
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
                    
                    // Login Link
                    HStack(spacing: 4) {
                        Text("Already have an account?")
                            .font(OnboardingTheme.caption())
                            .foregroundColor(OnboardingTheme.muted)
                        NavigationLink(destination: LoginView()) {
                            Text("Log In")
                                .font(OnboardingTheme.caption())
                                .fontWeight(.medium)
                                .foregroundColor(OnboardingTheme.accent)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.top, 32)
                    .padding(.bottom, 48)
                }
            }
        }
        .navigationBarHidden(true)
        .onChange(of: focusedField) { _, newField in
            if newField != nil {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - Actions
    
    func handleSignUp() {
        guard !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty && !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            showingError = true
            return
        }
        
        authViewModel.signUp(
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            password: password,
            firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
            lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        ) { result in
            DispatchQueue.main.async {
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
    
    func handleGoogleSignIn() {
        authViewModel.signInWithGoogle { result in
            DispatchQueue.main.async {
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
    
    func handleAppleSignIn() {
        authViewModel.signInWithApple { result in
            DispatchQueue.main.async {
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
}
