import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct UnifiedAuthView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isSignUpMode = true // Start with Sign Up
    
    // Form fields
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Logo
                Text("mantra")
                    .font(.system(size: 36, weight: .semibold, design: .serif))
                    .foregroundColor(Color(hex: "#2A2A2A"))
                    .padding(.top, 80)
                
                // Form Fields
                VStack(spacing: 16) {
                    if isSignUpMode {
                        // First Name / Last Name Row
                        HStack(spacing: 16) {
                            CustomTextField(
                                placeholder: "First Name",
                                text: $firstName
                            )
                            
                            CustomTextField(
                                placeholder: "Last Name",
                                text: $lastName
                            )
                        }
                    }
                    
                    // Email Field
                    CustomTextField(
                        placeholder: "Email",
                        text: $email,
                        keyboardType: .emailAddress
                    )
                    
                    // Password Field
                    CustomSecureField(
                        placeholder: "Password",
                        text: $password
                    )
                }
                .padding(.top, 48)
                .padding(.horizontal, 24)
                
                // Primary Button
                Button(action: {
                    if isSignUpMode {
                        handleSignUp()
                    } else {
                        handleLogin()
                    }
                }) {
                    Text(isSignUpMode ? "Sign Up" : "Log In")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color(hex: "#A6B8FA"))
                        .cornerRadius(12)
                }
                .padding(.top, 32)
                .padding(.horizontal, 24)
                
                // Social Auth Buttons
                VStack(spacing: 12) {
                    // Apple Sign In
                    Button(action: {
                        // TODO: Implement Apple Sign In
                        print("Apple Sign In tapped")
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
                    
                    // Google Sign In
                    Button(action: {
                        // TODO: Implement Google Sign In
                        print("Google Sign In tapped")
                    }) {
                        HStack {
                            // Google "G" placeholder - you can replace with actual Google icon
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
                }
                .padding(.top, 24)
                .padding(.horizontal, 24)
                
                // Toggle Link
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isSignUpMode.toggle()
                        clearFields()
                    }
                }) {
                    Text(isSignUpMode ? "Already have an account? Log In" : "Don't have an account? Sign Up")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color(hex: "#2A2A2A"))
                }
                .padding(.top, 32)
                .padding(.bottom, 40)
            }
        }
        .background(Color(hex: "#FFFCF5"))
        .ignoresSafeArea()
    }
    
    // MARK: - Actions
    
    func handleSignUp() {
        let fullName = "\(firstName.trimmingCharacters(in: .whitespacesAndNewlines)) \(lastName.trimmingCharacters(in: .whitespacesAndNewlines))"
        
        authViewModel.signUp(
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            password: password,
            name: fullName
        )
    }
    
    func handleLogin() {
        authViewModel.signIn(
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            password: password
        )
    }
    
    func clearFields() {
        firstName = ""
        lastName = ""
        email = ""
        password = ""
    }
}

// MARK: - Custom Text Fields

struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        TextField(placeholder, text: $text)
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
            .keyboardType(keyboardType)
            .autocapitalization(.none)
            .disableAutocorrection(true)
    }
}

struct CustomSecureField: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        SecureField(placeholder, text: $text)
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
            .autocapitalization(.none)
            .disableAutocorrection(true)
    }
}

// MARK: - Preview

#Preview {
    UnifiedAuthView()
        .environmentObject(AuthViewModel())
}
