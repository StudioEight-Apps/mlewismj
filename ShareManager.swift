import UIKit
import SwiftUI

final class ShareManager {
    static func present(image: UIImage, caption: String? = nil, from controller: UIViewController) {
        // Build activity items - image first, caption optional
        var activityItems: [Any] = [image]
        
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
}
