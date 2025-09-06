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
                // Logo - IMPROVED: More prominent and higher
                Text("mantra")
                    .font(.system(size: 56, weight: .semibold, design: .serif)) // Increased from 48 to 56
                    .foregroundColor(Color(hex: "#2A2A2A"))
                    .padding(.top, 80) // Increased from 60 to 80
                
                // IMPROVED: Added spacer to push form fields much lower
                Spacer()
                    .frame(height: 100) // Reduced from 140 to 100 to balance
                
                // Form Fields - Now positioned much lower
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
                
                // IMPROVED: Better spacing before login link
                Spacer()
                    .frame(height: 40)
                
                // Login Link - Better positioned at bottom
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
                .padding(.bottom, 50) // Increased bottom padding
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
                    // Success handled by AuthViewModel
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
                    // Success handled by AuthViewModel
                    break
                case .failure(let error):
                    // Make error messages more user-friendly
                    let userFriendlyMessage = self.getUserFriendlyErrorMessage(error)
                    self.errorMessage = userFriendlyMessage
                    self.showingError = true
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func getUserFriendlyErrorMessage(_ error: Error) -> String {
        let errorMessage = error.localizedDescription.lowercased()
        
        if errorMessage.contains("canceled") || errorMessage.contains("cancelled") {
            return "Sign in was cancelled. Please try again if you'd like to continue."
        } else if errorMessage.contains("network") {
            return "Please check your internet connection and try again."
        } else if errorMessage.contains("invalid") {
            return "There was an issue with your account. Please try a different sign-in method."
        } else {
            return "Something went wrong. Please try again."
        }
    }
    
    func handleAppleSignIn() {
        authViewModel.signInWithApple { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // Success handled by AuthViewModel
                    break
                case .failure(let error):
                    // Make error messages more user-friendly
                    let userFriendlyMessage = self.getUserFriendlyErrorMessage(error)
                    self.errorMessage = userFriendlyMessage
                    self.showingError = true
                }
            }
        }
    }
}
