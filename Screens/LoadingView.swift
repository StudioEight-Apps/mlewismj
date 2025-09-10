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
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#FFE683"), Color(hex: "#D8BCF6")]),
                startPoint: .top,
                endPoint: .bottom
            )
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
                VStack(spacing: 24) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "#A6B8FA")))
                        .scaleEffect(1.5)

                    Text("Finding the right words...")
                        .font(.headline)
                        .foregroundColor(Color(hex: "#2B2834"))
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
            // Force hide navigation bar completely
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let navController = findNavigationController(in: window.rootViewController) {
                navController.setNavigationBarHidden(true, animated: false)
            }
        }
        .ignoresSafeArea(.all)
    }
    
    // Helper function to find navigation controller
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
