import SwiftUI

struct BackgroundSelectorModal: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    private var colors: AppColors { AppColors(colorScheme) }
    let mantra: String
    let currentBackground: BackgroundConfig
    let onSelect: (BackgroundConfig) -> Void

    @State private var selectedCategory: BackgroundCategory = .color
    @State private var currentPage: Int = 0

    // iOS systemMedium widget: 360 × 169 pt, corner radius 16
    private let widgetCorner: CGFloat = 16
    private var widgetWidth: CGFloat {
        UIScreen.main.bounds.width - 48 // 24pt padding each side
    }
    private var widgetHeight: CGFloat {
        widgetWidth * (169.0 / 360.0) // Maintain exact medium widget ratio
    }

    private var cleanedMantra: String {
        let terminalPunctuation = CharacterSet(charactersIn: ".,;:!?…")
        var cleaned = mantra.trimmingCharacters(in: .whitespacesAndNewlines)
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

    private var filteredBackgrounds: [BackgroundConfig] {
        BackgroundConfig.backgrounds(for: selectedCategory)
    }

    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: Date())
    }

    /// The background for the currently visible page
    private var activeBackground: BackgroundConfig {
        let bgs = filteredBackgrounds
        guard currentPage >= 0, currentPage < bgs.count else {
            return bgs.first ?? currentBackground
        }
        return bgs[currentPage]
    }

    var body: some View {
        ZStack {
            // Depth background — subtle radial glow in dark mode
            modalBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Drag indicator
                Capsule()
                    .fill(colors.divider)
                    .frame(width: 36, height: 5)
                    .padding(.top, 10)
                    .padding(.bottom, 12)

                // Close button
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(colors.secondaryText)
                            .frame(width: 28, height: 28)
                            .background(
                                Circle().fill(colorScheme == .dark ? Color(hex: "#1E1E24") : colors.card)
                            )
                            .overlay(
                                Circle().stroke(colorScheme == .dark ? Color.white.opacity(0.08) : colors.cardBorder, lineWidth: 0.5)
                            )
                    }
                    .buttonStyle(.plain)

                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 18)

                // Title
                Text("Widget Style")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(colors.primaryText)
                    .padding(.bottom, 6)

                // Subtitle
                Text("Swipe to preview each style")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(colors.secondaryText)
                    .padding(.bottom, 20)

                // Filter chips
                filterChipsView
                    .padding(.bottom, 24)

                // Centered carousel zone
                Spacer()

                // Page counter — "1 of 8"
                Text("\(currentPage + 1) of \(filteredBackgrounds.count)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(colors.secondaryText)
                    .padding(.bottom, 14)

                // Swipeable widget carousel
                TabView(selection: $currentPage) {
                    ForEach(Array(filteredBackgrounds.enumerated()), id: \.element.imageName) { index, background in
                        widgetCard(background: background)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: widgetHeight + 40) // extra room for shadow

                // Custom page dots
                pageDots
                    .padding(.top, 14)

                Spacer()

                // Apply button
                applyButton
                    .padding(.horizontal, 28)
                    .padding(.bottom, 36)
            }
        }
        .onAppear {
            if let index = filteredBackgrounds.firstIndex(where: { $0.imageName == currentBackground.imageName }) {
                currentPage = index
            }
        }
        .onChange(of: selectedCategory) { _, _ in
            currentPage = 0
        }
    }

    // MARK: - Modal Background — warm charcoal with depth
    private var modalBackground: some View {
        ZStack {
            if colorScheme == .dark {
                // Warm charcoal base — NOT black
                Color(hex: "#161619")

                // Top-to-bottom gradient for dimension
                LinearGradient(
                    colors: [
                        Color(hex: "#1E1E24"),
                        Color(hex: "#161619"),
                        Color(hex: "#111114")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // Soft center glow behind the card area
                RadialGradient(
                    colors: [
                        Color(hex: "#1F1F26").opacity(0.6),
                        Color.clear
                    ],
                    center: .init(x: 0.5, y: 0.55),
                    startRadius: 40,
                    endRadius: UIScreen.main.bounds.width * 0.7
                )
            } else {
                colors.screenFade
            }
        }
    }

    // MARK: - Filter Chips
    private var filterChipsView: some View {
        HStack(spacing: 10) {
            ForEach(BackgroundCategory.allCases, id: \.self) { category in
                filterChip(category: category)
            }
        }
    }

    private func filterChip(category: BackgroundCategory) -> some View {
        let isActive = selectedCategory == category

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedCategory = category
            }
        } label: {
            HStack(spacing: 6) {
                Image(category.icon)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 14, height: 14)
                Text(category.rawValue)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(isActive ? colors.filterChipActiveText : colors.filterChipInactiveText)
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isActive ? colors.filterChipActive : colors.filterChipInactive)
            )
            .overlay(
                Capsule()
                    .stroke(isActive ? Color.clear : colors.cardBorder, lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Widget Card — Medium widget (360×169 ratio)
    private func widgetCard(background: BackgroundConfig) -> some View {
        let textColor = Color(hex: background.textColor)

        return ZStack {
            // Background image
            Image(background.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: widgetWidth, height: widgetHeight)
                .clipped()

            // Widget content — centered preview layout
            VStack(spacing: 0) {
                // Logo — top center
                Image("whisper-logo")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 10)
                    .foregroundColor(textColor.opacity(0.6))
                    .padding(.top, 12)

                Spacer()

                // Text — centered
                Text(cleanedMantra)
                    .font(.system(size: 15, weight: .semibold, design: .serif))
                    .foregroundColor(textColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .lineSpacing(4)
                    .tracking(-0.3)
                    .minimumScaleFactor(0.65)
                    .padding(.horizontal, 20)

                Spacer()
            }
            .frame(width: widgetWidth, height: widgetHeight)
        }
        .frame(width: widgetWidth, height: widgetHeight)
        .clipShape(RoundedRectangle(cornerRadius: widgetCorner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: widgetCorner, style: .continuous)
                .stroke(colorScheme == .dark ? Color.white.opacity(0.08) : colors.cardBorder, lineWidth: 0.5)
        )
        // Floating shadow — visible against charcoal bg
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.5 : 0.18), radius: 4, x: 0, y: 3)
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.4 : 0.14), radius: 20, x: 0, y: 12)
        .padding(.horizontal, 24)
    }

    // MARK: - Page Dots
    private var pageDots: some View {
        HStack(spacing: 6) {
            ForEach(0..<filteredBackgrounds.count, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? colors.primaryText : colors.primaryText.opacity(0.2))
                    .frame(width: index == currentPage ? 7 : 5, height: index == currentPage ? 7 : 5)
                    .animation(.easeInOut(duration: 0.2), value: currentPage)
            }
        }
    }

    // MARK: - Apply Button
    private var applyButton: some View {
        Button {
            onSelect(activeBackground)
            dismiss()
        } label: {
            Text("Apply")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(colors.buttonText)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(colors.buttonBackground)
                .cornerRadius(26)
        }
        .buttonStyle(.plain)
    }
}
