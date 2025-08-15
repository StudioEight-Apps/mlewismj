import SwiftUI
import UIKit

struct ImageShareHelper {
    
    static func shareMantraCard(mantra: String, mood: String) {
        print("🎨 Creating mantra card image...")
        
        // Generate the image
        let cardImage = MantraCardGenerator.createMantraCard(mantra: mantra, mood: mood)
        
        // Create share content
        let shareText = "My daily mantra ✨"
        let activityItems: [Any] = [shareText, cardImage]
        
        // Present the share sheet
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootViewController = window.rootViewController {
                
                let activityViewController = UIActivityViewController(
                    activityItems: activityItems,
                    applicationActivities: nil
                )
                
                // Configure for iPad if needed
                if let popover = activityViewController.popoverPresentationController {
                    popover.sourceView = window
                    popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
                    popover.permittedArrowDirections = []
                }
                
                // Find the topmost view controller to present from
                var topController = rootViewController
                while let presentedController = topController.presentedViewController {
                    topController = presentedController
                }
                
                topController.present(activityViewController, animated: true) {
                    print("✅ Share sheet presented successfully")
                }
            }
        }
    }
}
