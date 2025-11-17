import UIKit
import SwiftUI

final class ShareManager {
    static func present(image: UIImage, caption: String? = nil, from controller: UIViewController) {
        // Convert image to temp file for better social media compatibility
        let tempURL = saveToTempFile(image: image)
        
        // Build activity items - file URL for best compatibility
        var activityItems: [Any] = [tempURL]
        
        if let caption = caption {
            activityItems.append(caption)
        }
        
        let activityController = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        
        // iPad support
        if let popover = activityController.popoverPresentationController {
            popover.sourceView = controller.view
            popover.sourceRect = CGRect(
                x: controller.view.bounds.midX,
                y: controller.view.bounds.midY,
                width: 0,
                height: 0
            )
            popover.permittedArrowDirections = []
        }
        
        // Clean up temp file after sharing completes
        activityController.completionWithItemsHandler = { _, _, _, _ in
            try? FileManager.default.removeItem(at: tempURL)
        }
        
        controller.present(activityController, animated: true)
    }
    
    // Convenience method to find topmost view controller
    static func presentFromTopController(image: UIImage, caption: String? = nil) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            return
        }
        
        var topController = rootViewController
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        
        present(image: image, caption: caption, from: topController)
    }
    
    // Save image to temporary file for reliable sharing
    private static func saveToTempFile(image: UIImage) -> URL {
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("whisper-\(UUID().uuidString).jpg")
        
        // Use JPEG with high quality for best compatibility
        if let imageData = image.jpegData(compressionQuality: 0.9) {
            try? imageData.write(to: tempURL)
        }
        
        return tempURL
    }
}
