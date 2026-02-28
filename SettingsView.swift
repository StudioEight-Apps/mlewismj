import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject var themeManager = ThemeManager.shared
    @ObservedObject var notificationManager = NotificationManager.shared
    @Environment(\.colorScheme) var colorScheme
    @State private var showingPrivacyPolicy = false
    @State private var showingEditProfile = false
    @State private var showingSubscriptionInfo = false
    @State private var showingWidgetSetup = false
    @State private var showTimePicker = false

    // Delete account flow - 3 confirmations
    @State private var showingFirstConfirmation = false
    @State private var showingSecondConfirmation = false
    @State private var showingFinalConfirmation = false
    @State private var isDeleting = false
    @State private var showingError = false
    @State private var errorMessage = ""

    private var colors: AppColors { AppColors(colorScheme) }

    var body: some View {
        ZStack {
            colors.secondaryBackground
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Settings Options
                VStack(spacing: 12) {
                    // Appearance toggle
                    appearanceRow

                    // Daily reminder
                    notificationRow

                    Button(action: {
                        showingWidgetSetup = true
                    }) {
                        settingsRow(icon: "rectangle.on.rectangle.angled", title: "Set Up Your Widget")
                    }
                    .buttonStyle(BounceButtonStyle())

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
                        showingSubscriptionInfo = true
                    }) {
                        settingsRow(icon: "info.circle.fill", title: "Subscription Information")
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

                    // Delete Account Button
                    Button(action: {
                        showingFirstConfirmation = true
                    }) {
                        settingsRow(icon: "trash", title: "Delete Account")
                    }
                    .buttonStyle(BounceButtonStyle())
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                Spacer()
                
                // Log Out Button
                Button(action: {
                    authViewModel.signOut()
                }) {
                    Text("Log Out")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(colors.buttonText)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(colors.buttonBackground)
                        .cornerRadius(12)
                        .shadow(color: colors.cardShadow, radius: 6, x: 0, y: 3)
                }
                .buttonStyle(BounceButtonStyle())
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            
            // Loading overlay when deleting
            if isDeleting {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                    Text("Deleting account...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
            }
        }
        .tint(colorScheme == .dark ? .blue : colors.navTint)
        .accentColor(colorScheme == .dark ? .blue : colors.navTint)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Settings")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(colors.primaryText)
            }
        }
        .sheet(isPresented: $showingWidgetSetup) {
            WidgetSetupHomeScreen(isFromSettings: true)
        }
        .sheet(isPresented: $showingPrivacyPolicy) {
            PrivacyPolicyView()
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView()
        }
        .sheet(isPresented: $showingSubscriptionInfo) {
            SubscriptionInfoView()
        }
        // FIRST CONFIRMATION: Are you sure?
        .alert("Delete Account?", isPresented: $showingFirstConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("I'm Sure", role: .destructive) {
                showingSecondConfirmation = true
            }
        } message: {
            Text("Are you sure you want to delete your account?")
        }
        // SECOND CONFIRMATION: Data warning
        .alert("Warning", isPresented: $showingSecondConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("I'm Sure", role: .destructive) {
                showingFinalConfirmation = true
            }
        } message: {
            Text("All of your journal entries will be permanently removed and gone forever.")
        }
        // FINAL CONFIRMATION: Click delete
        .alert("Final Confirmation", isPresented: $showingFinalConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteAccount()
            }
        } message: {
            Text("Click Delete to remove this account forever.")
        }
        // Error alert if deletion fails
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    // MARK: - Appearance Toggle Row
    private var appearanceRow: some View {
        HStack {
            HStack {
                Image(systemName: "moon.fill")
                    .foregroundColor(colors.primaryText)
                    .font(.system(size: 18))
                Text("Appearance")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(colors.primaryText)
            }

            Spacer()

            // Three-segment capsule picker
            HStack(spacing: 0) {
                ForEach(["light", "dark", "system"], id: \.self) { mode in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            themeManager.appearanceRaw = mode
                        }
                    } label: {
                        Text(mode == "system" ? "Auto" : mode.capitalized)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(themeManager.appearanceRaw == mode ? colors.buttonText : colors.secondaryText)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(themeManager.appearanceRaw == mode ? colors.buttonBackground : Color.clear)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(3)
            .background(
                Capsule()
                    .fill(colors.card)
                    .overlay(Capsule().stroke(colors.cardBorder, lineWidth: 0.5))
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(colors.settingsRow)
        .cornerRadius(12)
        .shadow(color: colors.cardShadow, radius: 8, x: 0, y: 4)
        .shadow(color: colors.cardShadowLight, radius: 2, x: 0, y: 1)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(colors.cardBorder, lineWidth: 0.5)
        )
    }

    // MARK: - Notification Row
    private var notificationRow: some View {
        VStack(spacing: 0) {
            HStack {
                HStack {
                    Image(systemName: "bell.fill")
                        .foregroundColor(colors.primaryText)
                        .font(.system(size: 18))
                    Text("Daily Reminder")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(colors.primaryText)
                }

                Spacer()

                Toggle("", isOn: Binding(
                    get: { notificationManager.isEnabled },
                    set: { newValue in
                        if newValue {
                            notificationManager.requestPermission { granted in
                                if granted {
                                    notificationManager.isEnabled = true
                                } else {
                                    // Permission denied — open Settings
                                    if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                                        UIApplication.shared.open(settingsURL)
                                    }
                                }
                            }
                        } else {
                            notificationManager.isEnabled = false
                        }
                    }
                ))
                .tint(AppColors.gold)
                .labelsHidden()
            }

            // Time picker row — only visible when enabled
            if notificationManager.isEnabled {
                Divider()
                    .background(colors.divider)
                    .padding(.vertical, 10)

                HStack {
                    Text("Remind me at")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(colors.secondaryText)

                    Spacer()

                    DatePicker(
                        "",
                        selection: Binding(
                            get: { notificationManager.reminderDate },
                            set: { notificationManager.reminderDate = $0 }
                        ),
                        displayedComponents: .hourAndMinute
                    )
                    .labelsHidden()
                    .tint(AppColors.gold)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(colors.settingsRow)
        .cornerRadius(12)
        .shadow(color: colors.cardShadow, radius: 8, x: 0, y: 4)
        .shadow(color: colors.cardShadowLight, radius: 2, x: 0, y: 1)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(colors.cardBorder, lineWidth: 0.5)
        )
        .animation(.easeInOut(duration: 0.2), value: notificationManager.isEnabled)
    }

    private func settingsRow(icon: String, title: String, subtitle: String? = nil) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(colors.primaryText)
                        .font(.system(size: 18))
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(colors.primaryText)
                }

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(colors.secondaryText)
                        .lineLimit(2)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(colors.secondaryText)
                .font(.system(size: 14))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(colors.settingsRow)
        .cornerRadius(12)
        .shadow(color: colors.cardShadow, radius: 8, x: 0, y: 4)
        .shadow(color: colors.cardShadowLight, radius: 2, x: 0, y: 1)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(colors.cardBorder, lineWidth: 0.5)
        )
    }
    
    private func openAppStoreSubscriptions() {
        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openSupportEmail() {
        let subject = "Whisper App Support"
        let body = "Hi Whisper team,\n\nI need help with:\n\n"
        
        if let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: "mailto:support@whisper-app.com?subject=\(encodedSubject)&body=\(encodedBody)") {
            
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                return
            }
        }
        
        if let simpleURL = URL(string: "mailto:support@whisper-app.com") {
            if UIApplication.shared.canOpenURL(simpleURL) {
                UIApplication.shared.open(simpleURL)
                return
            }
        }
        
        if let mailURL = URL(string: "message://") {
            UIApplication.shared.open(mailURL)
        }
    }
    
    private func deleteAccount() {
        isDeleting = true
        
        authViewModel.deleteAccount { success, error in
            isDeleting = false
            
            if !success {
                errorMessage = error ?? "Failed to delete account. Please try again."
                showingError = true
            }
            // If success, user is automatically signed out and sent to signup screen
        }
    }
}

// MARK: - Edit Profile View
struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    private var colors: AppColors { AppColors(colorScheme) }
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
        NavigationStack {
            ZStack {
                colors.secondaryBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("First Name")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(colors.primaryText)
                            
                            TextField("Enter your first name", text: $firstName)
                                .font(.system(size: 16))
                                .padding(12)
                                .background(colors.settingsRow)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(colors.cardBorder, lineWidth: 1)
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Last Name")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(colors.primaryText)
                            
                            TextField("Enter your last name", text: $lastName)
                                .font(.system(size: 16))
                                .padding(12)
                                .background(colors.settingsRow)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(colors.cardBorder, lineWidth: 1)
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(colors.primaryText)
                            
                            TextField("Enter your email", text: $email)
                                .font(.system(size: 16))
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .padding(12)
                                .background(colors.settingsRow)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(colors.cardBorder, lineWidth: 1)
                                )
                        }
                    }
                    
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("New Password (optional)")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(colors.primaryText)
                            
                            SecureField("Enter new password", text: $newPassword)
                                .font(.system(size: 16))
                                .padding(12)
                                .background(colors.settingsRow)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(colors.cardBorder, lineWidth: 1)
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirm Password")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(colors.primaryText)
                            
                            SecureField("Confirm new password", text: $confirmPassword)
                                .font(.system(size: 16))
                                .padding(12)
                                .background(colors.settingsRow)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(colors.cardBorder, lineWidth: 1)
                                )
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Edit Profile")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(colors.primaryText)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(colors.secondaryText)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProfile()
                    }
                    .foregroundColor(colors.primaryText)
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

// MARK: - Bounce Button Style
struct BounceButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Privacy Policy View
struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    private var colors: AppColors { AppColors(colorScheme) }

    var body: some View {
        NavigationStack {
            ZStack {
                colors.secondaryBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Terms & Privacy Policy")
                                .font(.system(size: 32, weight: .bold, design: .serif))
                                .foregroundColor(colors.primaryText)
                            
                            Text("Last updated: January 16, 2025")
                                .font(.system(size: 14))
                                .foregroundColor(colors.secondaryText)
                        }
                        
                        VStack(alignment: .leading, spacing: 20) {
                            privacySection(title: "Welcome", content: "Welcome to Whisper. This Privacy Policy explains how we collect, use, and protect your information when you use our mobile application.")
                            
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
                            By using Whisper, you agree to:
                            • Use the app for personal journaling purposes
                            • Not share your account with others
                            • Respect our intellectual property
                            • Follow our community guidelines
                            """)
                            
                            privacySection(title: "Subscription Terms", content: "Subscription payments are processed through the App Store. You can manage or cancel your subscription through your App Store account settings. Subscriptions auto-renew unless cancelled.")
                            
                            privacySection(title: "Contact Us", content: "If you have any questions about this Privacy Policy or our Terms of Service, please contact us at support@whisper-app.com")
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
                    .foregroundColor(colors.primaryText)
                    .font(.system(size: 16, weight: .semibold))
                }
            }
        }
    }
    
    private func privacySection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 20, weight: .semibold, design: .serif))
                .foregroundColor(colors.primaryText)
            
            Text(content)
                .font(.system(size: 16))
                .foregroundColor(colors.primaryText)
                .lineSpacing(4)
        }
    }
}

// MARK: - Subscription Info View
struct SubscriptionInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    private var colors: AppColors { AppColors(colorScheme) }

    var body: some View {
        NavigationStack {
            ZStack {
                colors.secondaryBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Subscription Plans")
                                .font(.system(size: 32, weight: .bold, design: .serif))
                                .foregroundColor(colors.primaryText)
                            
                            Text("All plans include full access to Whisper")
                                .font(.system(size: 14))
                                .foregroundColor(colors.secondaryText)
                        }
                        
                        // Pricing Cards
                        VStack(spacing: 16) {
                            pricingCard(title: "Weekly", price: "$2.99", period: "per week")
                            pricingCard(title: "Annual", price: "$59.99", period: "per year", badge: "BEST VALUE")
                        }
                        
                        // Details Section
                        VStack(alignment: .leading, spacing: 20) {
                            infoSection(title: "Free Trial", content: "All plans include a 3-day free trial. You won't be charged until the trial ends.")
                            
                            infoSection(title: "Auto-Renewal", content: "Subscriptions automatically renew unless cancelled at least 24 hours before the end of the current period.")
                            
                            infoSection(title: "Cancellation", content: "Cancel anytime in your Apple ID settings. No refunds for partial periods.")
                            
                            infoSection(title: "Content Access", content: "Full access to journal entries, AI-powered mantras, widgets, and all premium features.")
                        }
                        
                        // Links Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Legal")
                                .font(.system(size: 20, weight: .semibold, design: .serif))
                                .foregroundColor(colors.primaryText)
                            
                            Link(destination: URL(string: "https://www.studioeight.app/whisper/privacy")!) {
                                HStack {
                                    Text("Privacy Policy")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(colors.primaryText)
                                    Spacer()
                                    Image(systemName: "arrow.up.right")
                                        .font(.system(size: 12))
                                        .foregroundColor(colors.primaryText)
                                }
                                .padding(16)
                                .background(colors.settingsRow)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                            }

                            Link(destination: URL(string: "https://www.studioeight.app/whisper/terms")!) {
                                HStack {
                                    Text("Terms of Use")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(colors.primaryText)
                                    Spacer()
                                    Image(systemName: "arrow.up.right")
                                        .font(.system(size: 12))
                                        .foregroundColor(colors.primaryText)
                                }
                                .padding(16)
                                .background(colors.settingsRow)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                            }
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
                    .foregroundColor(colors.primaryText)
                    .font(.system(size: 16, weight: .semibold))
                }
            }
        }
    }
    
    private func pricingCard(title: String, price: String, period: String, badge: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 24, weight: .semibold, design: .serif))
                        .foregroundColor(colors.primaryText)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(price)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(colors.primaryText)
                        Text(period)
                            .font(.system(size: 14))
                            .foregroundColor(colors.secondaryText)
                    }
                }
                
                Spacer()
                
                if let badge = badge {
                    Text(badge)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.black)
                        .cornerRadius(12)
                }
            }
        }
        .padding(20)
        .background(colors.settingsRow)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
    
    private func infoSection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 18, weight: .semibold, design: .serif))
                .foregroundColor(colors.primaryText)
            
            Text(content)
                .font(.system(size: 15))
                .foregroundColor(colors.secondaryText)
                .lineSpacing(4)
        }
    }
}
