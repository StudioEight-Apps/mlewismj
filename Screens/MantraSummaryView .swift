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
    
    // Authoritative background â†’ text color mapping (using whisper backgrounds)
    private let backgroundPairings: [(background: String, textColor: String, logoDark: Bool)] = [
        ("whisper_bg_01_bone", "#1E1B19", false),
        ("whisper_bg_02_sand", "#1E1B19", false),
        ("whisper_bg_03_taupe", "#1E1B19", false),
        ("whisper_bg_04_clay", "#EAD8C9", true),
        ("whisper_bg_05_terracotta", "#F2E2D6", true),
        ("whisper_bg_06_olive", "#E6EAD9", true),
        ("whisper_bg_07_sage", "#DDE7DC", true),
        ("whisper_bg_08_moss", "#DFE7D6", true),
        ("whisper_bg_09_cacao", "#ECDDC7", true),
        ("whisper_bg_10_charcoal", "#E8DEC9", true)
    ]
    
    @State private var selectedPairing: (background: String, textColor: String, logoDark: Bool) = ("whisper_bg_01_bone", "#1E1B19", false)
    
    // Strip terminal punctuation from mantra
    private var cleanedMantra: String {
        let terminalPunctuation = CharacterSet(charactersIn: ".,;:!?â€¦")
        var cleaned = mantra.trimmingCharacters(in: .whitespacesAndNewlines)
        while let last = cleaned.last, terminalPunctuation.contains(String(last).unicodeScalars.first!) {
            cleaned = String(cleaned.dropLast())
        }
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var body: some View {
        ZStack {
            // Subtle gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "#FFFCF5"),
                    Color(hex: "#F5EFE6")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(.all)
            
            VStack(spacing: 0) {
                Spacer()
                
                // Instagram-style quote card
                ZStack {
                    Image(selectedPairing.background)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.width * 0.68, height: UIScreen.main.bounds.width * 0.68)
                        .clipped()
                    
                    VStack(spacing: 24) {
                        Text(cleanedMantra)
                            .font(.system(size: 26, weight: .bold, design: .serif))
                            .foregroundColor(Color(hex: selectedPairing.textColor))
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                            .lineSpacing(4)
                            .tracking(-0.4)
                            .minimumScaleFactor(0.75)
                            .allowsTightening(true)
                            .frame(maxWidth: UIScreen.main.bounds.width * 0.68 - 56)
                        
                        Image("whisper-logo")
                            .resizable()
                            .renderingMode(.template)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: UIScreen.main.bounds.width * 0.68 * 0.13)
                            .foregroundColor(Color(hex: selectedPairing.textColor))
                            .opacity(0.82)
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
            
            // Logo positioned absolutely at top
            VStack {
                Image("whisper-logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 24)
                    .foregroundColor(Color(hex: "#2A2A2A"))
                    .padding(.top, 60)
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
            Task { @MainActor in
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first,
                   let navController = findNavigationController(in: window.rootViewController) {
                    navController.setNavigationBarHidden(true, animated: false)
                }
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
            
            Task { @MainActor in
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
            }
            
            print("Widget updated with mantra: \(mantra)")
        }
    }
    
    private func shareMantra() {
        Task { @MainActor in
            // Use the current selected pairing instead of random
            let currentPairing = (
                background: selectedPairing.background,
                textColor: selectedPairing.textColor
            )
            
            let cardView = ZStack {
                // Background image
                Image(currentPairing.background)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 1080, height: 1080)
                    .clipped()
                
                VStack(spacing: 24) {
                    // Hero quote text
                    Text(cleanedMantra)
                        .font(.system(size: 80, weight: .bold, design: .serif))
                        .foregroundColor(Color(hex: currentPairing.textColor))
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .lineSpacing(10)
                        .tracking(-0.4)
                        .minimumScaleFactor(0.75)
                        .allowsTightening(true)
                        .frame(maxWidth: 820)
                    
                    // Whisper logo
                    Image("whisper-logo")
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 140)
                        .foregroundColor(Color(hex: currentPairing.textColor))
                        .opacity(0.82)
                }
            }
            .frame(width: 1080, height: 1080)
            
            let image = ShareRenderer.image(
                for: cardView,
                size: CGSize(width: 1080, height: 1080),
                colorScheme: .light
            )
            
            ShareManager.presentFromTopController(
                image: image,
                caption: nil
            )
            
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
    }
    
    private func completeJournalingSession() {
        saveJournalEntry()
        
        Task { @MainActor in
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
        
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
        Task { @MainActor in
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootViewController = window.rootViewController {
                
                if let navController = findNavigationController(in: rootViewController) {
                    navController.popToRootViewController(animated: true)
                } else {
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
