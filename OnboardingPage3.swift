import SwiftUI

struct OnboardingPage3: View {
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Top spacer - reduced to move graphic up 10-20%
                Spacer()
                    .frame(height: geometry.size.height * 0.18)
                
                // Calendar graphic - professional DALL-E asset
                Image("calendar-graphic")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geometry.size.width * 0.3)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                    .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                
                // Gap to maintain clear hierarchy - slightly reduced to move text up
                Spacer()
                    .frame(height: geometry.size.height * 0.11)
                
                // Text content - positioned in bottom third
                VStack(spacing: 20) {
                    // Title - slightly larger font, fits on one line, bold hierarchy
                    Text("Show up for yourself daily")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "#2A2A2A"))
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                    
                    // Body - clear hierarchy separation
                    Text("Keep your streak going with daily check-ins that help you explore your thoughts and moods through smart prompts from Mantra.")
                        .font(.callout)
                        .fontWeight(.regular)
                        .foregroundColor(Color(hex: "#7A7A7A"))
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .lineSpacing(4)
                        .padding(.horizontal, 24)
                }
                
                // Bottom spacer - ensure text stays in bottom third
                Spacer()
                    .frame(height: geometry.size.height * 0.15)
            }
        }
        .background(Color(hex: "#FFFCF5"))
    }
}
