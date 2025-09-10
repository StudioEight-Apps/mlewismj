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
    
    // 4-column grid
    let columns = [
        GridItem(.adaptive(minimum: 80), spacing: 12),
        GridItem(.adaptive(minimum: 80), spacing: 12),
        GridItem(.adaptive(minimum: 80), spacing: 12),
        GridItem(.adaptive(minimum: 80), spacing: 12)
    ]
    
    // Get color for selected mood based on groupings
    func getColorForMood(_ mood: String) -> Color {
        guard mood == selectedMood else { return Color(hex: "#FFF8F3") }
        
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
        // Purple Group - FIXED: Consistent with main theme
        case "Angry", "Insecure", "Drained", "Tired", "Fine", "Reflective":
            return Color(hex: "#A6B4FF") // ✅ Now matches primary color
        default:
            return Color(hex: "#FFF8F3")
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Title - FIXED: Consistent typography
                Text("How are you feeling?")
                    .font(.system(size: 28, weight: .bold)) // ✅ System sans-serif for headers
                    .foregroundColor(Color(hex: "#2A2A2A")) // ✅ Consistent text color
                    .padding(.top, 40)
                    .padding(.bottom, 30)
                
                // Mood grid
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(moods, id: \.self) { mood in
                        Button(action: {
                            selectedMood = mood
                        }) {
                            Text(mood)
                                .font(.system(size: 15, weight: .medium)) // ✅ System sans-serif
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    Capsule()
                                        .fill(getColorForMood(mood))
                                        .overlay(
                                            Capsule()
                                                .stroke(Color(hex: "#1C1C1C"), lineWidth: 1.5)
                                        )
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Continue button - FIXED: Consistent styling
                Button(action: {
                    navigateToPrompt = true
                }) {
                    Text("Continue")
                        .font(.system(size: 17, weight: .semibold)) // ✅ System sans-serif for buttons
                        .foregroundColor(selectedMood != nil ? .white : Color.gray)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52) // ✅ Consistent button height
                        .background(
                            RoundedRectangle(cornerRadius: 12) // ✅ Consistent button radius
                                .fill(selectedMood != nil ? Color(hex: "#A6B4FF") : Color(hex: "#f7f2ec")) // ✅ Consistent primary color
                        )
                }
                .disabled(selectedMood == nil)
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 20)
                .padding(.bottom, 34)
            }
            .background(Color(hex: "#FFFCF5").ignoresSafeArea()) // ✅ Consistent background
            .navigationBarBackButtonHidden(false)
            .navigationDestination(isPresented: $navigateToPrompt) {
                Prompt1View(mood: selectedMood ?? "")
            }
        }
    }
}
