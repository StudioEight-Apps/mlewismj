import SwiftUI
import WidgetKit

struct MantraSummaryView: View {
    var mood: String
    var prompt1: String
    var prompt2: String
    var prompt3: String
    var mantra: String
    
    @Environment(\.dismiss) var dismiss
    @State private var showingShareSheet = false
    @State private var shareImage: UIImage?
    
    // Authoritative background → text color mapping
    private let backgroundPairings: [(background: String, textColor: String, logoDark: Bool)] = [
        ("bg_black", "#F6EFE6", true),        // Changed to beige
        ("bg_deepred", "#F6EFE6", true),
        ("bg_indigo", "#F4F0F5", true),
        ("bg_orange", "#F6EFE6", false),      // Changed to beige
        ("bg_purple", "#F6EFE6", true),
        ("bg_rose", "#F6EFE6", true),
        ("bg_sage", "#FDFCF9", false),
        ("bg_olive", "#F6EFE6", true)
    ]
    
    @State private var selectedPairing: (background: String, textColor: String, logoDark: Bool) = ("bg_black", "#F6EFE6", true)
    
    // Strip terminal punctuation from mantra
    private var cleanedMantra: String {
        let terminalPunctuation = CharacterSet(charactersIn: ".,;:!?…")
        var cleaned = mantra.trimmingCharacters(in: .whitespacesAndNewlines)
        while let last = cleaned.last, terminalPunctuation.contains(String(last).unicodeScalars.first!) {
            cleaned = String(cleaned.dropLast())
        }
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // Logo opacity based on background darkness
    private var logoOpacity: Double {
        selectedPairing.logoDark ? 0.70 : 0.55
    }
    
    // Logo color - use text color for consistency
    private var logoColor: Color {
        Color(hex: selectedPairing.textColor)
    }
    
    var body: some View {
        ZStack {
            // Clean background matching app
            Color(hex: "#FFFCF5")
                .ignoresSafeArea(.all)
            
            VStack(spacing: 0) {
                Spacer()
                
                // Instagram-style quote card
                ZStack {
                    // Background image
                    Image(selectedPairing.background)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.width * 0.68, height: UIScreen.main.bounds.width * 0.68)
                        .clipped()
                    
                    // Content overlay
                    VStack(spacing: 0) {
                        // Logo watermark at top center
                        Image("whisper-logo")
                            .resizable()
                            .renderingMode(.template)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: UIScreen.main.bounds.width * 0.68 * 0.09)
                            .foregroundColor(logoColor)
                            .opacity(logoOpacity)
                            .padding(.top, 28)
                            .padding(.bottom, 20)
                        
                        Spacer()
                        
                        // Hero quote text - cleaned and fitted
                        Text(cleanedMantra)
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(Color(hex: selectedPairing.textColor))
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                            .lineSpacing(4)
                            .tracking(0.4)
                            .minimumScaleFactor(0.75)
                            .allowsTightening(true)
                            .truncationMode(.tail)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 28)
                        
                        Spacer()
                        
                        // Bottom metadata row
                        HStack {
                            Text(Date().formatted(date: .omitted, time: .shortened))
                                .font(.system(size: 11, weight: .regular))
                                .foregroundColor(Color(hex: selectedPairing.textColor))
                                .opacity(0.6)
                            
                            Spacer()
                            
                            Text(mood.uppercased())
                                .font(.system(size: 11, weight: .regular))
                                .foregroundColor(Color(hex: selectedPairing.textColor))
                                .opacity(0.6)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 20)
                    }
                }
                .frame(width: UIScreen.main.bounds.width * 0.68, height: UIScreen.main.bounds.width * 0.68)
                .cornerRadius(24)
                .shadow(color: Color.black.opacity(0.12), radius: 20, x: 0, y: 10)
                
                Spacer().frame(height: 48)
                
                // Action buttons
                HStack(spacing: 16) {
                    Button(action: {
                        updateWidget()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "pin.circle.fill")
                                .font(.system(size: 16, weight: .medium))
                            Text("Pin to Widget")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.black)
                        )
                    }
                    .buttonStyle(ScaleButtonStyle())
                    
                    Button(action: {
                        shareMantra()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 16, weight: .medium))
                            Text("Share")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundColor(Color(hex: "#2A2A2A"))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: "#E5E5E5"), lineWidth: 1)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white)
                                )
                        )
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
                .padding(.horizontal, 28)
                
                Spacer()
            }
            
            // Floating completion button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        completeJournalingSession()
                    }) {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 64, height: 64)
                            .background(
                                Circle()
                                    .fill(Color.black)
                                    .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                            )
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .padding(.trailing, 32)
                    .padding(.bottom, 48)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            // Random background selection every time
            let index = Int.random(in: 0..<backgroundPairings.count)
            selectedPairing = backgroundPairings[index]
            
            // Hide navigation bar
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let navController = findNavigationController(in: window.rootViewController) {
                navController.setNavigationBarHidden(true, animated: false)
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let shareImage = shareImage {
                ShareSheet(items: [shareImage])
            }
        }
    }
    
    private func updateWidget() {
        if let sharedDefaults = UserDefaults(suiteName: "group.com.studioeight.mantra") {
            sharedDefaults.set(mantra, forKey: "latestMantra")
            sharedDefaults.set(mood, forKey: "latestMood")
            sharedDefaults.set(Date(), forKey: "lastUpdated")
            sharedDefaults.synchronize()
            
            WidgetCenter.shared.reloadAllTimelines()
            WidgetCenter.shared.reloadTimelines(ofKind: "MantraWidget")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                WidgetCenter.shared.reloadTimelines(ofKind: "MantraWidget")
            }
            
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            print("Widget updated with mantra: \(mantra)")
        }
    }
    
    private func shareMantra() {
        let cardImage = MantraCardGenerator.createMantraCard(mantra: mantra, mood: mood)
        let shareText = "Today's Whisper: \"\(mantra)\""
        
        let shareSheet = UIActivityViewController(
            activityItems: [shareText, cardImage],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootViewController = window.rootViewController {
            
            var topController = rootViewController
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            if let popover = shareSheet.popoverPresentationController {
                popover.sourceView = window
                popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            
            topController.present(shareSheet, animated: true)
        }
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    private func completeJournalingSession() {
        saveJournalEntry()
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        resetToWelcomeView()
    }
    
    func saveJournalEntry() {
        let existingEntry = JournalManager.shared.entries.first { entry in
            entry.mood == mood &&
            entry.text == mantra &&
            Calendar.current.isDate(entry.date, inSameDayAs: Date())
        }
        
        if existingEntry == nil {
            JournalManager.shared.saveEntry(
                mood: mood,
                response1: prompt1,
                response2: prompt2,
                response3: prompt3,
                mantra: mantra
            )
        }
    }
    
    func resetToWelcomeView() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootViewController = window.rootViewController {
            
            if let navController = findNavigationController(in: rootViewController) {
                DispatchQueue.main.async {
                    navController.popToRootViewController(animated: true)
                }
            } else {
                DispatchQueue.main.async {
                    dismiss()
                }
            }
        }
    }
    
    private func findNavigationController(in viewController: UIViewController?) -> UINavigationController? {
        guard let viewController = viewController else { return nil }
        
        if let navController = viewController as? UINavigationController {
            return navController
        }
        for child in viewController.children {
            if let navController = findNavigationController(in: child) {
                return navController
            }
        }
        return nil
    }
}

// Scale button style for micro-interactions
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
