import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    // Form fields
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    
    // Animation states
    @State private var signUpPressed = false
    @State private var applePressed = false
    @State private var googlePressed = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Whisper Logo Image - 20% larger
                Image("whisper-logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 48)
                    .foregroundColor(Color(hex: "#2A2A2A"))
                    .padding(.top, 100)
                
                // Form Fields - moved down more
                VStack(spacing: 16) {
                    // First Name / Last Name Row
                    HStack(spacing: 16) {
                        TextField("First Name", text: $firstName)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color(hex: "#2A2A2A"))
                            .padding(.horizontal, 12)
                            .frame(height: 52)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(hex: "#E4E4E4"), lineWidth: 1)
                            )
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                            .shadow(color: Color.black.opacity(0.02), radius: 2, x: 0, y: 1)
                            .autocapitalization(.words)
                        
                        TextField("Last Name", text: $lastName)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color(hex: "#2A2A2A"))
                            .padding(.horizontal, 12)
                            .frame(height: 52)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(hex: "#E4E4E4"), lineWidth: 1)
                            )
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                            .shadow(color: Color.black.opacity(0.02), radius: 2, x: 0, y: 1)
                            .autocapitalization(.words)
                    }
                    
                    // Email Field
                    TextField("Email", text: $email)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color(hex: "#2A2A2A"))
                        .padding(.horizontal, 12)
                        .frame(height: 52)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: "#E4E4E4"), lineWidth: 1)
                        )
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                        .shadow(color: Color.black.opacity(0.02), radius: 2, x: 0, y: 1)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    // Password Field
                    SecureField("Password", text: $password)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color(hex: "#2A2A2A"))
                        .padding(.horizontal, 12)
                        .frame(height: 52)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: "#E4E4E4"), lineWidth: 1)
                        )
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                        .shadow(color: Color.black.opacity(0.02), radius: 2, x: 0, y: 1)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                .padding(.top, 100)
                .padding(.horizontal, 24)
                
                // Sign Up Button - 32px from fields
                Button(action: {
                    signUpPressed = true
                    handleSignUp()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        signUpPressed = false
                    }
                }) {
                    Text("Sign Up")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "#FFFFFF"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color(hex: "#A6B8FA"))
                        .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
                .scaleEffect(signUpPressed ? 0.96 : 1.0)
                .shadow(color: Color(hex: "#A6B8FA").opacity(signUpPressed ? 0.15 : 0.25), radius: signUpPressed ? 4 : 8, x: 0, y: signUpPressed ? 2 : 4)
                .shadow(color: Color.black.opacity(signUpPressed ? 0.03 : 0.06), radius: signUpPressed ? 2 : 4, x: 0, y: signUpPressed ? 1 : 2)
                .animation(.easeInOut(duration: 0.1), value: signUpPressed)
                .padding(.top, 32)
                .padding(.horizontal, 24)
                
                // Social Auth Buttons - 24px from Sign Up button
                VStack(spacing: 12) {
                    // Apple Sign In
                    Button(action: {
                        applePressed = true
                        handleAppleSignIn()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            applePressed = false
                        }
                    }) {
                        HStack {
                            Image(systemName: "applelogo")
                                .font(.system(size: 16, weight: .medium))
                            Text("Continue with Apple")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(Color(hex: "#2A2A2A"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: "#E4E4E4"), lineWidth: 1)
                        )
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .scaleEffect(applePressed ? 0.97 : 1.0)
                    .shadow(color: Color.black.opacity(applePressed ? 0.005 : 0.015), radius: applePressed ? 1 : 3, x: 0, y: applePressed ? 0 : 1)
                    .animation(.easeInOut(duration: 0.1), value: applePressed)
                    
                    // Google Sign In
                    Button(action: {
                        googlePressed = true
                        handleGoogleSignIn()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            googlePressed = false
                        }
                    }) {
                        HStack {
                            Text("G")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.red)
                            Text("Continue with Google")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(Color(hex: "#2A2A2A"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: "#E4E4E4"), lineWidth: 1)
                        )
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .scaleEffect(googlePressed ? 0.97 : 1.0)
                    .shadow(color: Color.black.opacity(googlePressed ? 0.005 : 0.015), radius: googlePressed ? 1 : 3, x: 0, y: googlePressed ? 0 : 1)
                    .animation(.easeInOut(duration: 0.1), value: googlePressed)
                }
                .padding(.top, 24)
                .padding(.horizontal, 24)
                
                // Login Link - 32px from last button
                NavigationLink(destination: LoginView()) {
                    HStack(spacing: 4) {
                        Text("Already have an account?")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color(hex: "#2A2A2A"))
                        Text("Log In")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "#A6B8FA"))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.clear)
                }
                .buttonStyle(PlainButtonStyle())
                .shadow(radius: 0)
                .padding(.top, 32)
                .padding(.bottom, 40)
            }
        }
        .background(Color(hex: "#FFFCF5"))
        .ignoresSafeArea()
        .navigationBarHidden(true)
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
