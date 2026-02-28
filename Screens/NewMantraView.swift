import SwiftUI

struct NewMantraView: View {
    @State private var selectedMood: String? = nil
    @Environment(\.colorScheme) var colorScheme
    private var colors: AppColors { AppColors(colorScheme) }

    // Journal type - defaults to .guided for backward compatibility
    var journalType: JournalType = .guided

    // 32 moods - alphabetical order
    let moods: [String] = [
        "Angry", "Anxious", "Bored", "Calm",
        "Confused", "Content", "Drained", "Empty",
        "Energized", "Excited", "Fine", "Frustrated",
        "Grateful", "Happy", "Hopeful", "Inspired",
        "Insecure", "Lonely", "Lost", "Loving",
        "Motivated", "Nervous", "Nostalgic", "Numb",
        "Overwhelmed", "Peaceful", "Proud", "Reflective",
        "Restless", "Sad", "Stressed", "Tired"
    ]

    // Uses the single source of truth from MoodColor.swift
    func getColorForMood(_ mood: String) -> Color {
        guard mood == selectedMood else { return colors.moodPillUnselected }
        return Color(hex: colorForMood(mood))
    }

    func getBorderColorForMood(_ mood: String) -> Color {
        guard mood == selectedMood else { return Color.clear }
        return Color(hex: borderColorForMood(mood))
    }

    var body: some View {
        ZStack {
            // Background
            colors.secondaryBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header section
                VStack(spacing: 8) {
                    Text("How are you feeling?")
                        .font(.system(size: 24, weight: .medium, design: .serif))
                        .foregroundColor(colors.primaryText)

                    Text("Take a second to check in with yourself.")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(colors.descriptionText)
                }
                .padding(.top, 24)
                .padding(.bottom, 32)

                // Mood pills - flow layout
                ScrollView(showsIndicators: false) {
                    FlowLayout(spacing: 10) {
                        ForEach(moods, id: \.self) { mood in
                            MoodPill(
                                mood: mood,
                                isSelected: selectedMood == mood,
                                backgroundColor: getColorForMood(mood),
                                borderColor: getBorderColorForMood(mood),
                                textColor: selectedMood == mood ? Color(hex: "#2A2A2A") : colors.moodPillText,
                                unselectedBorderColor: colors.moodPillBorder,
                                action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedMood = mood
                                    }
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                    impactFeedback.impactOccurred()
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 160)
                }
            }

            // Continue button - floating at bottom
            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 12) {
                    // Hint text
                    Text("Not sure? Pick what's closest.")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(colors.hintText.opacity(0.7))

                    NavigationLink(destination: Group {
                        if journalType == .guided {
                            Prompt1View(mood: selectedMood ?? "")
                        } else {
                            FreeJournalPromptView(mood: selectedMood ?? "")
                        }
                    }) {
                        Text("Continue")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(selectedMood != nil ? colors.buttonText : colors.buttonDisabledText)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(selectedMood != nil ? colors.buttonBackground : colors.buttonDisabled)
                            )
                    }
                    .disabled(selectedMood == nil)
                    .buttonStyle(PlainButtonStyle())
                    .animation(.easeInOut(duration: 0.2), value: selectedMood)
                    .simultaneousGesture(TapGesture().onEnded {
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                    })
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
                .padding(.top, 16)
                .background(
                    LinearGradient(
                        colors: [
                            colors.backgroundFade.opacity(0),
                            colors.backgroundFade
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 140)
                    .allowsHitTesting(false)
                )
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton()
            }
        }
    }
}

// MARK: - Mood Pill Component

struct MoodPill: View {
    let mood: String
    let isSelected: Bool
    let backgroundColor: Color
    let borderColor: Color
    var textColor: Color = Color(hex: "#2C2C2C")
    var unselectedBorderColor: Color = Color.black.opacity(0.04)
    let action: () -> Void

    private let pillRadius: CGFloat = 12

    var body: some View {
        Button(action: action) {
            Text(mood)
                .font(.system(size: 15, weight: isSelected ? .semibold : .medium))
                .foregroundColor(textColor)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: pillRadius)
                        .fill(backgroundColor)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: pillRadius)
                        .stroke(isSelected ? borderColor : unselectedBorderColor, lineWidth: isSelected ? 1.5 : 0.5)
                )
        }
        .buttonStyle(MoodPillButtonStyle())
    }
}

// MARK: - Button Style

struct MoodPillButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 10

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)

        for (index, subview) in subviews.enumerated() {
            let frame = result.frames[index]
            // Center each row by offsetting from bounds
            subview.place(
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                proposal: ProposedViewSize(frame.size)
            )
        }
    }

    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, frames: [CGRect]) {
        let containerWidth = proposal.width ?? .infinity

        var frames: [CGRect] = []
        var rows: [[Int]] = [[]]
        var rowWidths: [CGFloat] = [0]
        var currentRow = 0
        var x: CGFloat = 0
        var y: CGFloat = 0
        var maxHeight: CGFloat = 0

        // First pass: determine which items go in which row
        for (index, subview) in subviews.enumerated() {
            let size = subview.sizeThatFits(.unspecified)

            if x + size.width > containerWidth && x > 0 {
                // Move to next row
                currentRow += 1
                rows.append([])
                rowWidths.append(0)
                x = 0
                y += maxHeight + spacing
                maxHeight = 0
            }

            rows[currentRow].append(index)
            rowWidths[currentRow] = x + size.width

            frames.append(CGRect(x: x, y: y, width: size.width, height: size.height))

            x += size.width + spacing
            maxHeight = max(maxHeight, size.height)
        }

        // Second pass: center each row
        for (rowIndex, row) in rows.enumerated() {
            let rowWidth = rowWidths[rowIndex]
            let offsetX = (containerWidth - rowWidth) / 2

            for itemIndex in row {
                frames[itemIndex].origin.x += offsetX
            }
        }

        let totalHeight = y + maxHeight
        return (CGSize(width: containerWidth, height: totalHeight), frames)
    }
}
