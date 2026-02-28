import SwiftUI

struct JournalEntryDetailView: View {
    let entryId: String
    @ObservedObject var journalManager = JournalManager.shared
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    private var colors: AppColors { AppColors(colorScheme) }

    // Animation states
    @State private var heartScale: CGFloat = 1.0
    @State private var heartRotation: Double = 0
    @State private var pinScale: CGFloat = 1.0
    @State private var pinOffsetY: CGFloat = 0
    @State private var shareScale: CGFloat = 1.0
    @State private var shareRotation: Double = 0
    @State private var particles: [HeartParticle] = []

    // Always read LIVE from journalManager so pin/favorite state is reactive
    private var entry: JournalEntry? {
        journalManager.entries.first(where: { $0.id == entryId })
    }

    private var moodColor: Color {
        guard let entry = entry else { return Color(hex: "#B8C8D8") }
        return Color(hex: colorForMood(entry.mood))
    }

    private var formattedDate: String {
        guard let entry = entry else { return "" }
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMMM d"
        return f.string(from: entry.date)
    }

    private var navTitleDate: String {
        guard let entry = entry else { return "" }
        let f = DateFormatter()
        f.dateFormat = "MMMM"
        let month = f.string(from: entry.date)
        let cal = Calendar.current
        let day = cal.component(.day, from: entry.date)
        let year = cal.component(.year, from: entry.date)
        let suffix: String
        switch day {
        case 1, 21, 31: suffix = "st"
        case 2, 22: suffix = "nd"
        case 3, 23: suffix = "rd"
        default: suffix = "th"
        }
        return "\(month) \(day)\(suffix), \(year)"
    }

    private var formattedTime: String {
        guard let entry = entry else { return "" }
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f.string(from: entry.date)
    }

    private var cleanedMantra: String {
        guard let entry = entry, !entry.text.isEmpty else { return "" }
        let terminalPunctuation = CharacterSet(charactersIn: ".,;:!?…")
        var cleaned = entry.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.hasPrefix("\"") && cleaned.hasSuffix("\"") {
            cleaned = String(cleaned.dropFirst().dropLast())
        }
        if cleaned.hasPrefix("'") && cleaned.hasSuffix("'") {
            cleaned = String(cleaned.dropFirst().dropLast())
        }
        while let last = cleaned.last, terminalPunctuation.contains(String(last).unicodeScalars.first!) {
            cleaned = String(cleaned.dropLast())
        }
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var cardWidth: CGFloat {
        UIScreen.main.bounds.width - 40
    }

    private var cardHeight: CGFloat {
        cardWidth * 0.72 // Editorial card ratio — taller for floating text
    }

    var body: some View {
        ZStack {
            detailPageBackground.ignoresSafeArea()

            if let entry = entry {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        mantraCard(entry: entry)
                            .padding(.bottom, 24)

                        actionBar(entry: entry)
                            .padding(.bottom, 20)

                        entryInfo(entry: entry)
                            .padding(.bottom, 20)

                        if hasReflections(entry: entry) {
                            reflectionSection(entry: entry)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 28)
                    .padding(.bottom, 40)
                }
            }
        }
        .tint(colors.navTint)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(navTitleDate)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(colors.primaryText)
            }
        }
    }

    // MARK: - Deep Background
    @ViewBuilder
    private var detailPageBackground: some View {
        if colorScheme == .dark {
            ZStack {
                // Deep base — not pure black, slight blue undertone
                Color(hex: "#08080E")

                // Vertical gradient — darker bottom, slightly lifted top
                LinearGradient(
                    colors: [
                        Color(hex: "#0E0E16").opacity(0.8),
                        Color(hex: "#08080E"),
                        Color(hex: "#050508")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // Soft radial glow from upper center — like distant light
                RadialGradient(
                    colors: [
                        Color(hex: "#14141E").opacity(0.5),
                        Color.clear
                    ],
                    center: .init(x: 0.5, y: 0.15),
                    startRadius: 20,
                    endRadius: UIScreen.main.bounds.height * 0.5
                )

                // Very subtle warm edge vignette
                RadialGradient(
                    colors: [
                        Color.clear,
                        Color.black.opacity(0.3)
                    ],
                    center: .center,
                    startRadius: UIScreen.main.bounds.width * 0.4,
                    endRadius: UIScreen.main.bounds.height * 0.7
                )
            }
        } else {
            colors.detailBackground
        }
    }

    // MARK: - Mantra Card

    private func mantraCard(entry: JournalEntry) -> some View {
        let textColor = Color(hex: entry.textColor)

        return ZStack {
            Image(entry.backgroundImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: cardWidth, height: cardHeight)
                .clipped()

            VStack(alignment: .leading, spacing: 0) {
                // Top 55% is pure negative space — lets the image breathe
                Spacer()
                    .frame(minHeight: cardHeight * 0.45)

                Text(cleanedMantra.isEmpty ? "A moment of reflection" : cleanedMantra)
                    .font(.system(size: 20, weight: .semibold, design: .serif))
                    .foregroundColor(textColor)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                    .lineSpacing(6)
                    .tracking(-0.3)
                    .minimumScaleFactor(0.7)
                    .padding(.trailing, 44)

                Spacer()

                HStack {
                    Text(formattedTime)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(textColor.opacity(0.4))

                    Spacer()

                    Text(entry.mood.uppercased())
                        .font(.system(size: 9, weight: .medium))
                        .tracking(0.5)
                        .foregroundColor(textColor.opacity(0.4))
                }
            }
            .padding(.leading, 20)
            .padding(.trailing, 16)
            .padding(.bottom, 14)
            .padding(.top, 14)
            .frame(width: cardWidth, height: cardHeight)
        }
        .frame(width: cardWidth, height: cardHeight)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(colors.cardBorder, lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.9 : 0.12), radius: 3, x: 0, y: 2)
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.6 : 0.16), radius: 24, x: 0, y: 16)
    }

    // MARK: - Action Bar

    private func actionBar(entry: JournalEntry) -> some View {
        HStack(spacing: 0) {
            Spacer()

            // Pin
            Button {
                animatePin()
                journalManager.togglePin(entry)
            } label: {
                Image(systemName: entry.isPinned ? "pin.fill" : "pin")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(entry.isPinned ? (colorScheme == .dark ? AppColors.gold : colors.primaryText) : colors.actionIconInactive)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
                    .scaleEffect(pinScale)
                    .offset(y: pinOffsetY)
            }
            .buttonStyle(.plain)

            Spacer()

            // Share
            Button {
                animateShare()
                shareEntry(entry: entry)
            } label: {
                Image("icon-paper-plane")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .foregroundColor(colors.actionIconInactive)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
                    .scaleEffect(shareScale)
                    .rotationEffect(.degrees(shareRotation))
            }
            .buttonStyle(.plain)

            Spacer()

            // Heart
            ZStack {
                Button {
                    animateFavorite(entry: entry)
                    journalManager.toggleFavorite(entry)
                } label: {
                    Image(systemName: entry.isFavorited ? "heart.fill" : "heart")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(entry.isFavorited ? AppColors.gold : colors.actionIconInactive)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
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
        .frame(height: 36)
        .frame(maxWidth: 200)
        .background(actionBarFrost)
        .clipShape(Capsule())
        .overlay(
            Capsule().stroke(
                colorScheme == .dark ? Color.white.opacity(0.12) : Color.black.opacity(0.06),
                lineWidth: 0.5
            )
        )
        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
    }

    private var actionBarFrost: some View {
        ZStack {
            Capsule().fill(.ultraThinMaterial)
            Capsule().fill(
                colorScheme == .dark
                    ? Color.white.opacity(0.08)
                    : Color.white.opacity(0.6)
            )
        }
    }

    // MARK: - Entry Info

    private func entryInfo(entry: JournalEntry) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(formattedDate)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(colors.primaryText)
                Text(formattedTime)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(colors.secondaryText)
            }

            Spacer()

            Text(entry.mood.capitalized)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color(hex: "#2A2A2A"))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(moodColor)
                .clipShape(Capsule())
        }
        .padding(.horizontal, 4)
    }

    // MARK: - Reflection Section

    private func hasReflections(entry: JournalEntry) -> Bool {
        entry.prompts.contains(where: { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty })
    }

    private func reflectionSection(entry: JournalEntry) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Reflection")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(colors.primaryText)
                .padding(.horizontal, 4)
                .padding(.top, 2)

            ForEach(Array(entry.prompts.enumerated()), id: \.offset) { i, answer in
                if !answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(getPromptLabel(for: i, entry: entry))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(colors.secondaryText)

                        Text(answer)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(colors.primaryText)
                            .lineSpacing(4)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(reflectionCardBackground)
                    .overlay(reflectionCardBorder)
                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.06), radius: 8, x: 0, y: 4)
                }
            }
        }
    }

    private var reflectionCardBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
            RoundedRectangle(cornerRadius: 14)
                .fill(colorScheme == .dark ? Color.white.opacity(0.06) : Color.white.opacity(0.7))
        }
    }

    private var reflectionCardBorder: some View {
        RoundedRectangle(cornerRadius: 14)
            .stroke(
                colorScheme == .dark ? Color.white.opacity(0.1) : Color.white.opacity(0.6),
                lineWidth: 0.5
            )
    }

    // MARK: - Prompt Labels
    // Show the actual question from the journaling flow if saved, otherwise fall back to phase labels for old entries.

    private func getPromptLabel(for index: Int, entry: JournalEntry) -> String {
        // Use saved question if available
        if index < entry.promptQuestions.count,
           !entry.promptQuestions[index].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return entry.promptQuestions[index]
        }
        // Fallback for old entries without saved questions
        if entry.journalType == .free {
            return "Free Journal"
        }
        switch index {
        case 0: return "Opening Up"
        case 1: return "Going Deeper"
        case 2: return "Looking Forward"
        default: return "Reflection"
        }
    }

    // MARK: - Animations

    private func animatePin() {
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 15)) {
            pinScale = 1.3
            pinOffsetY = -3
        }
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 10).delay(0.1)) {
            pinScale = 1.0
            pinOffsetY = 0
        }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    private func animateFavorite(entry: JournalEntry) {
        let isFavoriting = !entry.isFavorited
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 12)) {
            heartScale = 1.3
            heartRotation = -8
        }
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 10).delay(0.1)) {
            heartScale = 1.0
            heartRotation = 0
        }
        if isFavoriting { createParticleBurst() }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func animateShare() {
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 15)) {
            shareScale = 1.2
            shareRotation = 10
        }
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 10).delay(0.1)) {
            shareScale = 1.0
            shareRotation = 0
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
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

    private func shareEntry(entry: JournalEntry) {
        Task { @MainActor in
            let background = BackgroundConfig(
                imageName: entry.backgroundImage,
                textColor: entry.textColor
            )

            let text = cleanedMantra.isEmpty ? "A moment of reflection" : cleanedMantra

            let card = ZStack {
                Image(background.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 1080, height: 1080)
                    .clipped()

                VStack(alignment: .leading, spacing: 24) {
                    Spacer()

                    Text(text)
                        .font(.system(size: 72, weight: .semibold, design: .serif))
                        .foregroundColor(Color(hex: background.textColor))
                        .multilineTextAlignment(.leading)
                        .lineLimit(4)
                        .lineSpacing(8)
                        .tracking(-0.4)
                        .minimumScaleFactor(0.75)
                        .allowsTightening(true)
                        .frame(maxWidth: 820, alignment: .leading)

                    Image("whisper-logo")
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120)
                        .foregroundColor(Color(hex: background.textColor))
                        .opacity(0.6)

                    Spacer()
                        .frame(height: 60)
                }
                .padding(.leading, 70)
                .padding(.trailing, 100)
            }
            .frame(width: 1080, height: 1080)

            let image = ShareRenderer.image(
                for: card,
                size: CGSize(width: 1080, height: 1080),
                colorScheme: .light
            )
            ShareManager.presentFromTopController(image: image, caption: nil)
        }
    }
}
