import SwiftUI
import WidgetKit
import FirebaseAuth
import FirebaseFirestore

struct MantraSummaryView: View {
    var mood: String
    var prompt1: String
    var prompt2: String
    var prompt3: String
    var mantra: String
    var journalType: JournalType = .guided
    var promptQuestions: [String] = []

    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    private var colors: AppColors { AppColors(colorScheme) }
    @ObservedObject var journalManager = JournalManager.shared

    @State private var currentEntry: JournalEntry?
    @State private var shareImage: UIImage?
    @State private var showBackgroundSelector = false

    // Animation states
    @State private var heartScale: CGFloat = 1.0
    @State private var heartRotation: Double = 0
    @State private var pinScale: CGFloat = 1.0
    @State private var pinOffsetY: CGFloat = 0
    @State private var shareScale: CGFloat = 1.0
    @State private var shareRotation: Double = 0
    @State private var shuffleRotation: Double = 0

    // Particle states for heart burst
    @State private var particles: [HeartParticle] = []

    // Use centralized BackgroundConfig
    @State private var selectedBackground: BackgroundConfig = BackgroundConfig.random()

    // Card dimensions - square aspect ratio, ~80% width
    private var cardSize: CGFloat {
        UIScreen.main.bounds.width * 0.80
    }

    // Strip terminal punctuation from mantra
    private var cleanedMantra: String {
        let terminalPunctuation = CharacterSet(charactersIn: ".,;:!?…")
        var cleaned = mantra.trimmingCharacters(in: .whitespacesAndNewlines)

        // Remove leading and trailing quotation marks
        if cleaned.hasPrefix("\"") && cleaned.hasSuffix("\"") {
            cleaned = String(cleaned.dropFirst().dropLast())
        }
        if cleaned.hasPrefix("'") && cleaned.hasSuffix("'") {
            cleaned = String(cleaned.dropFirst().dropLast())
        }

        // Remove terminal punctuation
        while let last = cleaned.last, terminalPunctuation.contains(String(last).unicodeScalars.first!) {
            cleaned = String(cleaned.dropLast())
        }
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // Formatted timestamp
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: Date())
    }

    // Mood label (uppercased)
    private var moodLabel: String {
        mood.uppercased()
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Screen background
                summaryPageBackground
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    // Card + Action Menu cluster
                    VStack(spacing: 16) {
                        // The Card
                        mantraCard

                        // Action menu - directly below card
                        actionMenu
                    }

                    Spacer()
                }

                // Continue button - bottom right
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            completeJournalingSession()
                        }) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 18))
                                .foregroundColor(colors.continueCircleIcon)
                                .frame(width: 52, height: 52)
                                .background(
                                    Circle()
                                        .fill(colors.continueCircle)
                                )
                                .overlay(
                                    Circle()
                                        .stroke(colors.continueCircleBorder, lineWidth: 0.5)
                                )
                                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                        }
                        .buttonStyle(.plain)
                        .padding(.trailing, 24)
                        .padding(.bottom, 32)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            saveJournalEntry()
        }
        .sheet(isPresented: $showBackgroundSelector) {
            BackgroundSelectorModal(
                mantra: cleanedMantra,
                currentBackground: selectedBackground,
                onSelect: { newBackground in
                    selectedBackground = newBackground
                    updateEntryBackground(newBackground)
                }
            )
        }
    }

    // MARK: - Deep Background
    @ViewBuilder
    private var summaryPageBackground: some View {
        if colorScheme == .dark {
            ZStack {
                // Deep base — slight blue undertone
                Color(hex: "#08080E")

                // Vertical gradient — lifted top, darker bottom
                LinearGradient(
                    colors: [
                        Color(hex: "#0E0E16").opacity(0.8),
                        Color(hex: "#08080E"),
                        Color(hex: "#050508")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // Soft radial glow from center — card sits here
                RadialGradient(
                    colors: [
                        Color(hex: "#14141E").opacity(0.45),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 30,
                    endRadius: UIScreen.main.bounds.height * 0.45
                )

                // Edge vignette for depth
                RadialGradient(
                    colors: [
                        Color.clear,
                        Color.black.opacity(0.25)
                    ],
                    center: .center,
                    startRadius: UIScreen.main.bounds.width * 0.4,
                    endRadius: UIScreen.main.bounds.height * 0.7
                )
            }
        } else {
            Color(hex: selectedBackground.screenBackgroundHex)
        }
    }

    // MARK: - Mantra Card
    private var mantraCard: some View {
        ZStack {
            // Card background - paper asset image
            Image(selectedBackground.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: cardSize, height: cardSize)
                .clipped()

            // Card content
            VStack(spacing: 0) {
                Spacer()

                // Mantra text - centered
                Text(cleanedMantra)
                    .font(.system(size: 22, weight: .semibold, design: .serif))
                    .foregroundColor(Color(hex: selectedBackground.textColor))
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .tracking(-0.3)
                    .minimumScaleFactor(0.75)
                    .padding(.horizontal, 24)

                Spacer()

                // Bottom row: timestamp + mood label
                HStack {
                    Text(formattedTime)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(hex: selectedBackground.textColor).opacity(0.6))

                    Spacer()

                    Text(moodLabel)
                        .font(.system(size: 11, weight: .medium))
                        .tracking(0.5)
                        .foregroundColor(Color(hex: selectedBackground.textColor).opacity(0.6))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .frame(width: cardSize, height: cardSize)
        }
        .frame(width: cardSize, height: cardSize)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
    }

    // MARK: - Action Menu
    private var actionMenu: some View {
        HStack(spacing: 0) {
            Spacer()

            // Shuffle/Background selector
            Button {
                animateShuffle()
                showBackgroundSelector = true
            } label: {
                Image(systemName: "sparkles")
                    .font(.system(size: 16))
                    .foregroundColor(colors.actionIconInactive)
                    .frame(width: 44, height: 44)
                    .rotationEffect(.degrees(shuffleRotation))
            }
            .buttonStyle(.plain)

            Spacer()

            // Pin
            Button {
                togglePin()
            } label: {
                Image(systemName: currentEntry?.isPinned == true ? "pin.fill" : "pin")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(currentEntry?.isPinned == true ? (colorScheme == .dark ? AppColors.gold : colors.primaryText) : colors.actionIconInactive)
                    .frame(width: 44, height: 44)
                    .scaleEffect(pinScale)
                    .offset(y: pinOffsetY)
            }
            .buttonStyle(.plain)

            Spacer()

            // Share
            Button {
                shareMantra()
            } label: {
                Image("icon-paper-plane")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(colors.actionIconInactive)
                    .frame(width: 44, height: 44)
                    .scaleEffect(shareScale)
                    .rotationEffect(.degrees(shareRotation))
            }
            .buttonStyle(.plain)

            Spacer()

            // Heart/Favorite
            ZStack {
                Button {
                    toggleFavorite()
                } label: {
                    Image(systemName: currentEntry?.isFavorited == true ? "heart.fill" : "heart")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(currentEntry?.isFavorited == true ? AppColors.gold : colors.actionIconInactive)
                        .frame(width: 44, height: 44)
                        .scaleEffect(heartScale)
                        .rotationEffect(.degrees(heartRotation))
                }
                .buttonStyle(.plain)

                ForEach(particles) { particle in
                    Circle()
                        .fill(Color(hex: "#C4A574"))
                        .frame(width: particle.size, height: particle.size)
                        .offset(x: particle.x, y: particle.y)
                        .opacity(particle.opacity)
                        .scaleEffect(particle.scale)
                }
            }

            Spacer()
        }
        .frame(width: cardSize * 0.75, height: 44)
        .background(colors.actionBarBackground)
        .overlay(
            Capsule()
                .stroke(colors.actionBarBorder, lineWidth: 0.5)
        )
        .shadow(color: colors.cardShadow, radius: 8, x: 0, y: 4)
    }

    // MARK: - Background Update
    private func updateEntryBackground(_ background: BackgroundConfig) {
        guard let entry = currentEntry,
              let userId = Auth.auth().currentUser?.uid else { return }

        // Update local entry
        if let index = journalManager.entries.firstIndex(where: { $0.id == entry.id }) {
            journalManager.entries[index].backgroundImage = background.imageName
            journalManager.entries[index].textColor = background.textColor
            currentEntry = journalManager.entries[index]
        }

        // Update in Firebase
        let db = Firestore.firestore()
        db.collection("users")
            .document(userId)
            .collection("journalEntries")
            .document(entry.id)
            .updateData([
                "backgroundImage": background.imageName,
                "textColor": background.textColor
            ]) { error in
                if let error = error {
                    print("❌ Failed to update background: \(error.localizedDescription)")
                } else {
                    print("✅ Background updated successfully")
                    // Sync to widget
                    self.journalManager.syncEntriesToWidget()
                }
            }
    }

    // MARK: - Animations
    private func animateShuffle() {
        withAnimation(.interpolatingSpring(stiffness: 200, damping: 10)) {
            shuffleRotation += 180
        }

        Task { @MainActor in
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
    }

    private func togglePin() {
        guard let entry = currentEntry else { return }

        let isPinning = !entry.isPinned

        withAnimation(.interpolatingSpring(stiffness: 400, damping: 15)) {
            pinScale = 1.25
            pinOffsetY = isPinning ? -8 : 0
        }

        withAnimation(.interpolatingSpring(stiffness: 300, damping: 12).delay(0.1)) {
            pinScale = 1.0
            pinOffsetY = 0
        }

        journalManager.togglePin(entry)

        if let index = journalManager.entries.firstIndex(where: { $0.id == entry.id }) {
            currentEntry = journalManager.entries[index]
        }

        Task { @MainActor in
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
    }

    private func toggleFavorite() {
        guard let entry = currentEntry else { return }

        let isFavoriting = !entry.isFavorited

        withAnimation(.interpolatingSpring(stiffness: 400, damping: 15)) {
            heartScale = 1.3
            heartRotation = isFavoriting ? -15 : 0
        }

        withAnimation(.interpolatingSpring(stiffness: 300, damping: 12).delay(0.1)) {
            heartScale = 1.0
            heartRotation = 0
        }

        if isFavoriting {
            createParticleBurst()
        }

        journalManager.toggleFavorite(entry)

        if let index = journalManager.entries.firstIndex(where: { $0.id == entry.id }) {
            currentEntry = journalManager.entries[index]
        }

        Task { @MainActor in
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
    }

    private func createParticleBurst() {
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

        withAnimation(.easeOut(duration: 0.6)) {
            for i in 0..<particles.count {
                let angle = particles[i].angle * .pi / 180
                particles[i].x = cos(angle) * particles[i].distance
                particles[i].y = sin(angle) * particles[i].distance
                particles[i].opacity = 0
                particles[i].scale = 0.3
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            particles.removeAll()
        }
    }

    private func shareMantra() {
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 15)) {
            shareScale = 1.2
            shareRotation = 10
        }

        withAnimation(.interpolatingSpring(stiffness: 300, damping: 10).delay(0.1)) {
            shareScale = 1.0
            shareRotation = 0
        }

        Task { @MainActor in
            let cardView = ZStack {
                Image(selectedBackground.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 1080, height: 1080)
                    .clipped()

                VStack(spacing: 24) {
                    Text(cleanedMantra)
                        .font(.system(size: 80, weight: .heavy, design: .serif))
                        .foregroundColor(Color(hex: selectedBackground.textColor))
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .lineSpacing(10)
                        .tracking(-0.4)
                        .minimumScaleFactor(0.75)
                        .allowsTightening(true)
                        .frame(maxWidth: 820)
                        .shadow(color: Color.black.opacity(0.15), radius: 3, x: 0, y: 2)

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
        let existingEntry = journalManager.entries.first { entry in
            entry.mood == mood &&
            entry.text == mantra &&
            Calendar.current.isDate(entry.date, inSameDayAs: Date())
        }

        if let existing = existingEntry {
            currentEntry = existing
            selectedBackground = BackgroundConfig(
                imageName: existing.backgroundImage,
                textColor: existing.textColor
            )
        } else {
            journalManager.saveEntry(
                mood: mood,
                response1: prompt1,
                response2: prompt2,
                response3: prompt3,
                mantra: mantra,
                journalType: journalType,
                backgroundImage: selectedBackground.imageName,
                textColor: selectedBackground.textColor,
                promptQuestions: promptQuestions
            )

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

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
