import SwiftUI

struct NewMantraView: View {
    @State private var selectedMood: String? = nil
    @State private var navigateToPrompt = false

    // Exactly 24 moods - now in alphabetical order
    let moods: [String] = [
        "Angry", "Anxious", "Calm", "Content",
        "Drained", "Empty", "Energized", "Excited",
        "Fine", "Frustrated", "Grateful", "Happy",
        "Hopeful", "Inspired", "Insecure", "Lonely",
        "Lost", "Motivated", "Nervous", "Peaceful",
        "Reflective", "Sad", "Stressed", "Tired"
    ]
    
    // 3-column grid for better proportions
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    // Get color for selected mood based on groupings
    func getColorForMood(_ mood: String) -> Color {
        guard mood == selectedMood else { return Color(hex: "#F8F4F1") }
        
        switch mood {
        // Red Group
        case "Anxious", "Stressed", "Frustrated", "Nervous":
            return Color(hex: "#F5A5A5")
        // Blue Group
        case "Sad", "Lonely", "Empty", "Lost":
            return Color(hex: "#AECDEB")
        // Green Group
        case "Happy", "Grateful", "Hopeful", "Calm", "Motivated",
             "Peaceful", "Content", "Inspired", "Energized", "Excited":
            return Color(hex: "#B5D6BA")
        // Purple Group
        case "Angry", "Insecure", "Drained", "Tired", "Fine", "Reflective":
            return Color(hex: "#A6B4FF")
        default:
            return Color(hex: "#F8F4F1")
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "#FFFCF5"),
                        Color(hex: "#FBF8F2")
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // Single unified ScrollView
                ScrollView {
                    VStack(spacing: 0) {
                        // Increased spacing to move moods down
                        Spacer().frame(height: 40)
                        
                        // Mood grid - flows naturally with content
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(moods, id: \.self) { mood in
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                        selectedMood = mood
                                    }
                                    
                                    // Haptic feedback
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                    impactFeedback.impactOccurred()
                                }) {
                                    Text(mood)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(Color(hex: "#2A2A2A"))
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 48)
                                        .background(
                                            RoundedRectangle(cornerRadius: 24)
                                                .fill(getColorForMood(mood))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 24)
                                                        .stroke(
                                                            selectedMood == mood
                                                            ? Color(hex: "#A6B4FF").opacity(0.8)
                                                            : Color(hex: "#E5E5E5"),
                                                            lineWidth: selectedMood == mood ? 3 : 1
                                                        )
                                                )
                                                .shadow(
                                                    color: Color.black.opacity(0.05),
                                                    radius: selectedMood == mood ? 8 : 2,
                                                    x: 0,
                                                    y: selectedMood == mood ? 4 : 1
                                                )
                                        )
                                }
                                .buttonStyle(MoodButtonStyle())
                                .scaleEffect(selectedMood == mood ? 1.05 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedMood)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 140)
                    }
                }
                
                // Continue button - floating at bottom
                VStack {
                    Spacer()
                    
                    Button(action: {
                        navigateToPrompt = true
                        
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                    }) {
                        Text("Continue")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(selectedMood != nil ? .white : Color(hex: "#9B9B9B"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(selectedMood != nil ? Color(hex: "#A6B4FF") : Color(hex: "#F0F0F0"))
                                    .shadow(
                                        color: selectedMood != nil ? Color(hex: "#A6B4FF").opacity(0.3) : Color.clear,
                                        radius: selectedMood != nil ? 12 : 0,
                                        x: 0,
                                        y: selectedMood != nil ? 6 : 0
                                    )
                            )
                    }
                    .disabled(selectedMood == nil)
                    .buttonStyle(PlainButtonStyle())
                    .scaleEffect(selectedMood != nil ? 1.0 : 0.98)
                    .opacity(selectedMood != nil ? 1.0 : 0.6)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedMood)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("How are you feeling?")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(Color(hex: "#2A2A2A"))
                }
            }
            .navigationDestination(isPresented: $navigateToPrompt) {
                Prompt1View(mood: selectedMood ?? "")
            }
        }
    }
}

// Custom button style with press animation
struct MoodButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
