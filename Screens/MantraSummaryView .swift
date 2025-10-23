import SwiftUI
import WidgetKit

struct MantraSummaryView: View {
    var mood: String
    var prompt1: String
    var prompt2: String
    var prompt3: String
    var mantra: String
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject var journalManager = JournalManager.shared
    
    @State private var currentEntry: JournalEntry?
    @State private var shareImage: UIImage?
    
    // Animation states
    @State private var heartScale: CGFloat = 1.0
    @State private var heartRotation: Double = 0
    @State private var pinScale: CGFloat = 1.0
    @State private var pinOffsetY: CGFloat = 0
    @State private var shareScale: CGFloat = 1.0
    @State private var shareRotation: Double = 0
    
    // Particle states for heart burst
    @State private var particles: [HeartParticle] = []
    
    // Use centralized BackgroundConfig
    @State private var selectedBackground: BackgroundConfig = BackgroundConfig.random()
    
    // Strip terminal punctuation from mantra
    private var cleanedMantra: String {
        let terminalPunctuation = CharacterSet(charactersIn: ".,;:!?…")
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
                    Image(selectedBackground.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.width * 0.68, height: UIScreen.main.bounds.width * 0.68)
                        .clipped()
                    
                    VStack(spacing: 24) {
                        Text(cleanedMantra)
                            .font(.system(size: 26, weight: .bold, design: .serif))
                            .foregroundColor(Color(hex: selectedBackground.textColor))
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
                            .foregroundColor(Color(hex: selectedBackground.textColor))
                            .opacity(0.82)
                    }
                }
                .frame(width: UIScreen.main.bounds.width * 0.68, height: UIScreen.main.bounds.width * 0.68)
                .cornerRadius(24)
                .shadow(color: Color.black.opacity(0.12), radius: 20, x: 0, y: 10)
                
                Spacer().frame(height: 24)
                
                // Floating translucent action bar
                ZStack {
                    HStack(spacing: 0) {
                        Spacer()
                        
                        // Pin button
                        Button {
                            togglePin()
                        } label: {
                            Image(systemName: currentEntry?.isPinned == true ? "pin.fill" : "pin")
                                .font(.system(size: 18, weight: .light))
                                .foregroundColor(currentEntry?.isPinned == true ? Color(hex: "#A6B4FF") : Color(hex: "#8A8A8A").opacity(0.7))
                                .frame(width: 44, height: 44)
                                .scaleEffect(pinScale)
                                .offset(y: pinOffsetY)
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                        
                        // Share button
                        Button {
                            shareMantra()
                        } label: {
                            Image(systemName: "paperplane")
                                .font(.system(size: 18, weight: .light))
                                .foregroundColor(Color(hex: "#8A8A8A").opacity(0.7))
                                .frame(width: 44, height: 44)
                                .scaleEffect(shareScale)
                                .rotationEffect(.degrees(shareRotation))
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                        
                        // Favorite button with particles
                        ZStack {
                            Button {
                                toggleFavorite()
                            } label: {
                                Image(systemName: currentEntry?.isFavorited == true ? "heart.fill" : "heart")
                                    .font(.system(size: 20, weight: .light))
                                    .foregroundColor(currentEntry?.isFavorited == true ? Color(hex: "#A6B4FF") : Color(hex: "#8A8A8A").opacity(0.7))
                                    .frame(width: 44, height: 44)
                                    .scaleEffect(heartScale)
                                    .rotationEffect(.degrees(heartRotation))
                            }
                            .buttonStyle(.plain)
                            
                            // Particle burst overlay
                            ForEach(particles) { particle in
                                Circle()
                                    .fill(Color(hex: "#A6B4FF"))
                                    .frame(width: particle.size, height: particle.size)
                                    .offset(x: particle.x, y: particle.y)
                                    .opacity(particle.opacity)
                                    .scaleEffect(particle.scale)
                            }
                        }
                        
                        Spacer()
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.68)
                    .frame(height: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(.ultraThinMaterial)
                    )
                }
                
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
            // Random background selection using BackgroundConfig
            selectedBackground = BackgroundConfig.random()
            
            // Save entry immediately when view appears
            saveJournalEntry()
            
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
    
    private func togglePin() {
        guard let entry = currentEntry else { return }
        
        // Twitter-style bounce animation
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 15)) {
            pinScale = 1.3
            pinOffsetY = -3
        }
        
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 10).delay(0.1)) {
            pinScale = 1.0
            pinOffsetY = 0
        }
        
        journalManager.togglePin(entry)
        
        // Update local state to reflect the change
        if let index = journalManager.entries.firstIndex(where: { $0.id == entry.id }) {
            currentEntry = journalManager.entries[index]
        }
        
        Task { @MainActor in
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
        }
    }
    
    private func toggleFavorite() {
        guard let entry = currentEntry else { return }
        
        // Only create particles when favoriting (not unfavoriting)
        let isFavoriting = !(currentEntry?.isFavorited ?? false)
        
        // Twitter heart animation - scale + wiggle
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 12)) {
            heartScale = 1.3
            heartRotation = -8
        }
        
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 10).delay(0.1)) {
            heartScale = 1.0
            heartRotation = 0
        }
        
        // Create particle burst
        if isFavoriting {
            createParticleBurst()
        }
        
        journalManager.toggleFavorite(entry)
        
        // Update local state to reflect the change
        if let index = journalManager.entries.firstIndex(where: { $0.id == entry.id }) {
            currentEntry = journalManager.entries[index]
        }
        
        Task { @MainActor in
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
    }
    
    private func createParticleBurst() {
        // Create 6-8 particles in random directions
        let particleCount = Int.random(in: 6...8)
        var newParticles: [HeartParticle] = []
        
        for i in 0..<particleCount {
            let angle = (Double(i) / Double(particleCount)) * 360.0 + Double.random(in: -20...20)
            let distance = Double.random(in: 30...50)
            
            let particle = HeartParticle(
                id: UUID(),
                x: 0,
                y: 0,
                size: CGFloat.random(in: 4...7),
                opacity: 1.0,
                scale: 1.0,
                angle: angle,
                distance: distance
            )
            newParticles.append(particle)
        }
        
        particles = newParticles
        
        // Animate particles outward and fade
        withAnimation(.easeOut(duration: 0.6)) {
            for i in 0..<particles.count {
                let angle = particles[i].angle * .pi / 180
                particles[i].x = cos(angle) * particles[i].distance
                particles[i].y = sin(angle) * particles[i].distance
                particles[i].opacity = 0
                particles[i].scale = 0.3
            }
        }
        
        // Clean up particles after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            particles.removeAll()
        }
    }
    
    private func shareMantra() {
        // Twitter-style share animation - scale + rotate
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 15)) {
            shareScale = 1.2
            shareRotation = 10
        }
        
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 10).delay(0.1)) {
            shareScale = 1.0
            shareRotation = 0
        }
        
        Task { @MainActor in
            // Use the current selected background
            let cardView = ZStack {
                // Background image
                Image(selectedBackground.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 1080, height: 1080)
                    .clipped()
                
                VStack(spacing: 24) {
                    // Hero quote text
                    Text(cleanedMantra)
                        .font(.system(size: 80, weight: .bold, design: .serif))
                        .foregroundColor(Color(hex: selectedBackground.textColor))
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
                        .foregroundColor(Color(hex: selectedBackground.textColor))
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
        Task { @MainActor in
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
        
        resetToWelcomeView()
    }
    
    func saveJournalEntry() {
        // Check if entry already exists
        let existingEntry = journalManager.entries.first { entry in
            entry.mood == mood &&
            entry.text == mantra &&
            Calendar.current.isDate(entry.date, inSameDayAs: Date())
        }
        
        if let existing = existingEntry {
            currentEntry = existing
        } else {
            journalManager.saveEntry(
                mood: mood,
                response1: prompt1,
                response2: prompt2,
                response3: prompt3,
                mantra: mantra
            )
            
            // Find the newly created entry
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                currentEntry = journalManager.entries.first { entry in
                    entry.mood == mood &&
                    entry.text == mantra &&
                    Calendar.current.isDate(entry.date, inSameDayAs: Date())
                }
            }
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
