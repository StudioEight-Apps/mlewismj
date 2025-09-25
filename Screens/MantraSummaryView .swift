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
    
    var body: some View {
        ZStack {
            // Enhanced gradient background (keeping this intentionally different for special screen)
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 1.0, green: 0.9, blue: 0.51),  // #FFE683
                    Color(red: 0.96, green: 0.85, blue: 0.51), // #F5D982
                    Color(red: 0.91, green: 0.78, blue: 0.94), // #E8C8F0
                    Color(red: 0.85, green: 0.8, blue: 0.96)   // #D8CCF6
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(.all)
            
            // Main content
            VStack(spacing: 0) {
                Spacer()
                
                // Enhanced Whisper Card
                VStack(spacing: 24) {
                    // Whisper logo centered at top of card
                    Image("whisper-logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 32) // Adjust height as needed
                        .foregroundColor(Color(red: 0.17, green: 0.16, blue: 0.2))
                    
                    Text(mantra)
                        .font(.system(size: 24, weight: .semibold, design: .serif))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(red: 0.17, green: 0.16, blue: 0.2))
                        .lineLimit(nil)
                        .lineSpacing(6)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, 48)
                .padding(.horizontal, 36)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white.opacity(0.95))
                        .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 8)
                        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
                )
                .padding(.horizontal, 28)
                
                Spacer().frame(height: 48)
                
                // Enhanced action buttons
                HStack(spacing: 16) {
                    Button(action: {
                        updateWidget()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "pin.circle.fill")
                                .font(.system(size: 16, weight: .medium))
                            Text("Pin to Widget")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(Color(red: 0.17, green: 0.16, blue: 0.2))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white.opacity(0.9))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        shareMantra()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.up.fill")
                                .font(.system(size: 16, weight: .medium))
                            Text("Share")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(Color(red: 0.17, green: 0.16, blue: 0.2))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white.opacity(0.9))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Spacer()
            }
            
            // Enhanced floating completion button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        completeJournalingSession()
                    }) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 64, height: 64)
                            .background(
                                Circle()
                                    .fill(Color(hex: "#A6B4FF"))
                                    .shadow(color: Color(hex: "#A6B4FF").opacity(0.4), radius: 12, x: 0, y: 6)
                                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.trailing, 32)
                    .padding(.bottom, 48)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            // Force hide navigation bar completely
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
        // Updated to use the correct App Group for Studio Eight LLC
        if let sharedDefaults = UserDefaults(suiteName: "group.com.studioeight.mantra") {
            sharedDefaults.set(mantra, forKey: "latestMantra")
            sharedDefaults.set(mood, forKey: "latestMood")
            sharedDefaults.set(Date(), forKey: "lastUpdated")
            sharedDefaults.synchronize()
            
            // Reload widget timelines
            WidgetCenter.shared.reloadAllTimelines()
            WidgetCenter.shared.reloadTimelines(ofKind: "MantraWidget")
            
            // Additional reload after delay to ensure update
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                WidgetCenter.shared.reloadTimelines(ofKind: "MantraWidget")
            }
            
            // Haptic feedback for success
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            print("✅ Widget updated with mantra: \(mantra)")
        } else {
            print("❌ Failed to access App Group: group.com.studioeight.mantra")
        }
    }
    
    private func shareMantra() {
        // Create the beautiful mantra card image
        let cardImage = MantraCardGenerator.createMantraCard(mantra: mantra, mood: mood)
        
        // Include both image and text for better sharing options
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
    
    // Helper function to find navigation controller
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

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) -> Void {}
}
