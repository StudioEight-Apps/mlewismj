import SwiftUI

struct NewMantraView: View {
    @State private var selectedMood: String? = nil
    
    // Journal type - defaults to .guided for backward compatibility
    var journalType: JournalType = .guided

    // Exactly 24 moods - now in alphabetical order
    let moods: [String] = [
        "Angry", "Anxious", "Calm", "Content",
        "Drained", "Empty", "Energized", "Excited",
        "Fine", "Frustrated", "Grateful", "Happy",
        "Hopeful", "Inspired", "Insecure", "Lonely",
        "Lost", "Motivated", "Nervous", "Peaceful",
        "Reflective", "Sad", "Stressed", "Tired"
    ]
    
    // 3-column grid with tighter spacing
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
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
    
    // Get border color that matches the mood's background color
    func getBorderColorForMood(_ mood: String) -> Color {
        guard mood == selectedMood else { return Color(hex: "#E5E5E5") }
        
        switch mood {
        // Red Group - darker red border
        case "Anxious", "Stressed", "Frustrated", "Nervous":
            return Color(hex: "#E38A8A")
        // Blue Group - darker blue border
        case "Sad", "Lonely", "Empty", "Lost":
            return Color(hex: "#8DB8D8")
        // Green Group - darker green border
        case "Happy", "Grateful", "Hopeful", "Calm", "Motivated",
             "Peaceful", "Content", "Inspired", "Energized", "Excited":
            return Color(hex: "#9BC4A0")
        // Purple Group - darker purple border
        case "Angry", "Insecure", "Drained", "Tired", "Fine", "Reflective":
            return Color(hex: "#8A9AE8")
        default:
            return Color(hex: "#E5E5E5")
        }
    }

    var body: some View {
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
                    // Header section
                    VStack(spacing: 8) {
                        Text("How are you feeling?")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(Color(hex: "#2A2A2A"))
                        
                        Text("Take a second to check in with yourself.")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color(hex: "#6C6C6C"))
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                    
                    // Mood grid
                    LazyVGrid(columns: columns, spacing: 12) {
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
                                                        getBorderColorForMood(mood),
                                                        lineWidth: selectedMood == mood ? 2 : 1
                                                    )
                                            )
                                            .shadow(
                                                color: Color.black.opacity(selectedMood == mood ? 0.05 : 0.02),
                                                radius: selectedMood == mood ? 8 : 2,
                                                x: 0,
                                                y: selectedMood == mood ? 4 : 1
                                            )
                                    )
                            }
                            .buttonStyle(MoodButtonStyle())
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedMood)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 180)
                }
            }
            
            // Continue button - floating at bottom
            VStack(spacing: 16) {
                Spacer()
                
                // Hint text
                Text("Not sure? Pick what's closest.")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(hex: "#9B9B9B"))
                
                NavigationLink(destination: Group {
                    if journalType == .guided {
                        Prompt1View(mood: selectedMood ?? "")
                    } else {
                        FreeJournalPromptView(mood: selectedMood ?? "")
                    }
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
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedMood)
                .simultaneousGesture(TapGesture().onEnded {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                })
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
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

// Custom button style with press animation
struct MoodButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
