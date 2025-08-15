import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingPrivacyPolicy = false
    @State private var showingEditProfile = false

    var body: some View {
        ZStack {
            Color(hex: "#FFFCF5") // ✅ Consistent background
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Settings Options
                VStack(spacing: 12) {
                    Button(action: {
                        showingEditProfile = true
                    }) {
                        settingsRow(icon: "person.fill", title: "Edit Profile")
                    }
                    .buttonStyle(BounceButtonStyle())
                    
                    Button(action: {
                        openAppStoreSubscriptions()
                    }) {
                        settingsRow(icon: "creditcard.fill", title: "Manage Membership")
                    }
                    .buttonStyle(BounceButtonStyle())
                    
                    Button(action: {
                        showingPrivacyPolicy = true
                    }) {
                        settingsRow(icon: "doc.text.fill", title: "Terms & Privacy Policy")
                    }
                    .buttonStyle(BounceButtonStyle())
                    
                    Button(action: {
                        openSupportEmail()
                    }) {
                        settingsRow(icon: "questionmark.circle.fill", title: "Help & Support")
                    }
                    .buttonStyle(BounceButtonStyle())
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                Spacer()
                
                // Log Out Button - FIXED: Consistent styling
                Button(action: {
                    authViewModel.signOut()
                }) {
                    Text("Log Out")
                        .font(.system(size: 16, weight: .semibold)) // ✅ Consistent button font
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52) // ✅ Consistent button height
                        .background(Color(hex: "#A6B4FF")) // ✅ Consistent primary color
                        .cornerRadius(12) // ✅ Consistent button radius
                        .shadow(color: Color(hex: "#A6B4FF").opacity(0.3), radius: 6, x: 0, y: 3)
                }
                .buttonStyle(BounceButtonStyle())
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingPrivacyPolicy) {
            PrivacyPolicyView()
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView()
        }
    }

    private func settingsRow(icon: String, title: String, subtitle: String? = nil) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(Color(hex: "#A6B4FF")) // ✅ Consistent primary color
                        .font(.system(size: 18))
                    Text(title)
                        .font(.system(size: 16, weight: .semibold)) // ✅ System sans-serif
                        .foregroundColor(Color(hex: "#2A2A2A")) // ✅ Consistent text color
                }

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 14)) // ✅ System sans-serif
                        .foregroundColor(Color(hex: "#5B5564")) // ✅ Consistent secondary text
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(Color(hex: "#A6B4FF")) // ✅ Consistent primary color
                .font(.system(size: 14))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(12) // ✅ Consistent card radius
        .shadow(color: Color(hex: "#A6B4FF").opacity(0.15), radius: 8, x: 0, y: 4)
        .shadow(color: Color(hex: "#A6B4FF").opacity(0.08), radius: 2, x: 0, y: 1)
    }
    
    private func openAppStoreSubscriptions() {
        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openSupportEmail() {
        let subject = "Mantra App Support"
        let body = "Hi Mantra team,\n\nI need help with:\n\n"
        
        // Try with encoded parameters first
        if let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: "mailto:support@mantra-app.com?subject=\(encodedSubject)&body=\(encodedBody)") {
            
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                return
            }
        }
        
        // Fallback to simple mailto
        if let simpleURL = URL(string: "mailto:support@mantra-app.com") {
            if UIApplication.shared.canOpenURL(simpleURL) {
                UIApplication.shared.open(simpleURL)
                return
            }
        }
        
        // Last resort - try opening Mail app directly
        if let mailURL = URL(string: "message://") {
            UIApplication.shared.open(mailURL)
        }
    }
}

// MARK: - Edit Profile View - FIXED: Consistent styling
struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#FFFCF5") // ✅ Consistent background
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("First Name")
                                .font(.system(size: 16, weight: .medium)) // ✅ System sans-serif
                                .foregroundColor(Color(hex: "#2A2A2A")) // ✅ Consistent text color
                            
                            TextField("Enter your first name", text: $firstName)
                                .font(.system(size: 16)) // ✅ System sans-serif
                                .padding(12)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(hex: "#A6B4FF").opacity(0.3), lineWidth: 1) // ✅ Consistent primary color
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Last Name")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(hex: "#2A2A2A"))
                            
                            TextField("Enter your last name", text: $lastName)
                                .font(.system(size: 16))
                                .padding(12)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(hex: "#A6B4FF").opacity(0.3), lineWidth: 1)
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(hex: "#2A2A2A"))
                            
                            TextField("Enter your email", text: $email)
                                .font(.system(size: 16))
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .padding(12)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(hex: "#A6B4FF").opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                    
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("New Password (optional)")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(hex: "#2A2A2A"))
                            
                            SecureField("Enter new password", text: $newPassword)
                                .font(.system(size: 16))
                                .padding(12)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(hex: "#A6B4FF").opacity(0.3), lineWidth: 1)
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirm Password")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(hex: "#2A2A2A"))
                            
                            SecureField("Confirm new password", text: $confirmPassword)
                                .font(.system(size: 16))
                                .padding(12)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(hex: "#A6B4FF").opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "#5B5564")) // ✅ Consistent secondary text
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProfile()
                    }
                    .foregroundColor(Color(hex: "#A6B4FF")) // ✅ Consistent primary color
                    .font(.system(size: 16, weight: .semibold))
                    .disabled(isLoading)
                }
            }
            .onAppear {
                loadCurrentUserData()
            }
            .alert("Profile Update", isPresented: $showingAlert) {
                Button("OK") {
                    if alertMessage.contains("successfully") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func loadCurrentUserData() {
        if let currentUser = authViewModel.currentUser {
            email = currentUser.email ?? ""
        }
        firstName = authViewModel.firstName
        lastName = authViewModel.lastName
    }
    
    private func saveProfile() {
        isLoading = true
        
        // Validate password match if changing password
        if !newPassword.isEmpty {
            guard newPassword == confirmPassword else {
                alertMessage = "Passwords do not match"
                showingAlert = true
                isLoading = false
                return
            }
            
            guard newPassword.count >= 6 else {
                alertMessage = "Password must be at least 6 characters"
                showingAlert = true
                isLoading = false
                return
            }
        }
        
        // Update profile
        authViewModel.updateProfile(
            firstName: firstName,
            lastName: lastName,
            email: email,
            newPassword: newPassword.isEmpty ? nil : newPassword
        ) { success, error in
            isLoading = false
            if success {
                alertMessage = "Profile updated successfully"
            } else {
                alertMessage = error ?? "Failed to update profile"
            }
            showingAlert = true
        }
    }
}

// MARK: - Bounce Button Style (unchanged)
struct BounceButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Privacy Policy View - FIXED: Consistent styling
struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#FFFCF5") // ✅ Consistent background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Terms & Privacy Policy")
                                .font(.system(size: 32, weight: .bold, design: .serif)) // ✅ System serif for headers
                                .foregroundColor(Color(hex: "#2A2A2A"))
                            
                            Text("Last updated: January 16, 2025")
                                .font(.system(size: 14)) // ✅ System sans-serif
                                .foregroundColor(Color(hex: "#5B5564")) // ✅ Consistent secondary text
                        }
                        
                        VStack(alignment: .leading, spacing: 20) {
                            privacySection(title: "Welcome", content: "Welcome to Mantra. This Privacy Policy explains how we collect, use, and protect your information when you use our mobile application.")
                            
                            privacySection(title: "Information We Collect", content: """
                            • Account information (name, email address)
                            • Journal entries and mood data
                            • Usage analytics and app performance data
                            • Device information for app functionality
                            """)
                            
                            privacySection(title: "How We Use Your Information", content: """
                            • To provide and improve our services
                            • To personalize your journaling experience
                            • To communicate with you about your account
                            • To analyze usage patterns and improve the app
                            """)
                            
                            privacySection(title: "Data Security", content: "We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. Your journal entries are encrypted and stored securely.")
                            
                            privacySection(title: "Your Rights", content: "You have the right to access, update, or delete your personal information at any time through the app settings. You can also export your journal data or request account deletion.")
                            
                            privacySection(title: "Terms of Service", content: """
                            By using Mantra, you agree to:
                            • Use the app for personal journaling purposes
                            • Not share your account with others
                            • Respect our intellectual property
                            • Follow our community guidelines
                            """)
                            
                            privacySection(title: "Subscription Terms", content: "Subscription payments are processed through the App Store. You can manage or cancel your subscription through your App Store account settings. Subscriptions auto-renew unless cancelled.")
                            
                            privacySection(title: "Contact Us", content: "If you have any questions about this Privacy Policy or our Terms of Service, please contact us at support@mantra-app.com")
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "#A6B4FF")) // ✅ Consistent primary color
                    .font(.system(size: 16, weight: .semibold))
                }
            }
        }
    }
    
    private func privacySection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 20, weight: .semibold, design: .serif)) // ✅ System serif for section headers
                .foregroundColor(Color(hex: "#2A2A2A"))
            
            Text(content)
                .font(.system(size: 16)) // ✅ System sans-serif for body
                .foregroundColor(Color(hex: "#2A2A2A")) // ✅ Consistent text color
                .lineSpacing(4)
        }
    }
}
