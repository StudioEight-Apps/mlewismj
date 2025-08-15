import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    // Form fields
    @State private var email = ""
    @State private var password = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    
    // Animation states
    @State private var loginPressed = false
    @State private var applePressed = false
    @State private var googlePressed = false
    @State private var backPressed = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Custom Back Arrow - positioned below status bar
                HStack {
                    Button(action: {
                        backPressed = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            backPressed = false
                        }
                        // Navigate back to SignUpView
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            dismiss()
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(Color(hex: "#A6B8FA"))
                            .frame(width: 44, height: 44)
                            .background(Color.clear)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .scaleEffect(backPressed ? 0.85 : 1.0)
                    .animation(.easeInOut(duration: 0.1), value: backPressed)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 50)
                
                // Logo - proper spacing from back button
                Text("mantra")
                    .font(.system(size: 36, weight: .semibold, design: .serif))
                    .foregroundColor(Color(hex: "#2A2A2A"))
                    .padding(.top, 10)
                
                // Form Fields - 48px from logo
                VStack(spacing: 16) {
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
                .padding(.top, 48)
                .padding(.horizontal, 24)
                
                // Log In Button - 32px from fields
                Button(action: {
                    loginPressed = true
                    handleLogin()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        loginPressed = false
                    }
                }) {
                    Text("Log In")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "#FFFFFF"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color(hex: "#A6B8FA"))
                        .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
                .scaleEffect(loginPressed ? 0.96 : 1.0)
                .shadow(color: Color(hex: "#A6B8FA").opacity(loginPressed ? 0.15 : 0.25), radius: loginPressed ? 4 : 8, x: 0, y: loginPressed ? 2 : 4)
                .shadow(color: Color.black.opacity(loginPressed ? 0.03 : 0.06), radius: loginPressed ? 2 : 4, x: 0, y: loginPressed ? 1 : 2)
                .animation(.easeInOut(duration: 0.1), value: loginPressed)
                .padding(.top, 32)
                .padding(.horizontal, 24)
                
                // Social Auth Buttons - 24px from Log In button
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
                
                // Sign Up Link - 32px from last button
                NavigationLink(destination: SignUpView()) {
                    HStack(spacing: 4) {
                        Text("Don't have an account?")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color(hex: "#2A2A2A"))
                        Text("Sign Up")
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
    
    func handleLogin() {
        print("🔥 LOGIN BUTTON TAPPED ON DEVICE")
        print("🔥 AuthViewModel.isSignedIn BEFORE: \(authViewModel.isSignedIn)")
        print("🔥 Email: \(email)")
        print("🔥 Password length: \(password.count)")
        
        guard !email.isEmpty && !password.isEmpty else {
            print("🔥 GUARD FAILED - Empty fields")
            errorMessage = "Please fill in all fields"
            showingError = true
            return
        }
        
        print("🔥 CALLING authViewModel.signIn")
        authViewModel.signIn(
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            password: password
        ) { result in
            print("🔥 AUTH CALLBACK RECEIVED")
            print("🔥 AuthViewModel.isSignedIn AFTER: \(self.authViewModel.isSignedIn)")
            // ✅ FIXED: Removed DispatchQueue.main.async wrapper
            // AuthViewModel already handles main thread updates
            switch result {
            case .success:
                print("🔥 AUTH SUCCESS")
                // Success handled by AuthViewModel
                break
            case .failure(let error):
                print("🔥 AUTH FAILED: \(error.localizedDescription)")
                self.errorMessage = error.localizedDescription
                self.showingError = true
            }
        }
    }
    
    func handleGoogleSignIn() {
        authViewModel.signInWithGoogle { result in
            // ✅ FIXED: Removed DispatchQueue.main.async wrapper
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
    
    func handleAppleSignIn() {
        authViewModel.signInWithApple { result in
            // ✅ FIXED: Removed DispatchQueue.main.async wrapper
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
