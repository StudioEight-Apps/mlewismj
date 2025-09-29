import SwiftUI

struct LoadingView: View {
    var mood: String
    var response1: String
    var response2: String
    var response3: String

    @State private var isLoadingComplete = false
    @State private var generatedMantra: String = ""

    var body: some View {
        ZStack {
            // Clean background matching app
            Color(hex: "#FFFCF5")
                .ignoresSafeArea()

            if isLoadingComplete {
                MantraSummaryView(
                    mood: mood,
                    prompt1: response1,
                    prompt2: response2,
                    prompt3: response3,
                    mantra: generatedMantra
                )
            } else {
                VStack(spacing: 0) {
                    // Whisper logo at absolute top
                    Image("whisper-logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 24)
                        .foregroundColor(Color(hex: "#2A2A2A"))
                        .padding(.top, 60)
                        .padding(.bottom, 40)
                    
                    Spacer()
                    
                    // Centered loading content
                    VStack(spacing: 24) {
                        // Custom three-dot animation
                        ThreeDotsLoader()

                        Text("Finding the right words...")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(Color(hex: "#2A2A2A"))
                            .opacity(0.7)
                    }
                    
                    Spacer()
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        MantraGenerator.generateMantra(
                            mood: mood,
                            response1: response1,
                            response2: response2,
                            response3: response3
                        ) { result in
                            generatedMantra = result ?? "Breathe. You are here now."
                            isLoadingComplete = true
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let navController = findNavigationController(in: window.rootViewController) {
                navController.setNavigationBarHidden(true, animated: false)
            }
        }
        .ignoresSafeArea(.all)
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

// Custom three-dot loading animation
struct ThreeDotsLoader: View {
    @State private var animationIndex = 0
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color(hex: "#A6B4FF"))
                    .frame(width: 10, height: 10)
                    .scaleEffect(animationIndex == index ? 1.2 : 0.8)
                    .opacity(animationIndex == index ? 1.0 : 0.4)
                    .animation(.easeInOut(duration: 0.6), value: animationIndex)
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
            withAnimation {
                animationIndex = (animationIndex + 1) % 3
            }
        }
    }
}
