import SwiftUI
import UIKit

struct ShareRenderer {
    @MainActor
    static func image<V: View>(for view: V, size: CGSize, colorScheme: ColorScheme = .light) -> UIImage {
        let renderer = ImageRenderer(content: view)
        renderer.scale = UIScreen.main.scale
        
        // Force light mode for consistent exports
        renderer.proposedSize = ProposedViewSize(size)
        
        // Create the image
        guard let uiImage = renderer.uiImage else {
            // Fallback: return empty image if rendering fails
            UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
            let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
            UIGraphicsEndImageContext()
            return image
        }
        
        return uiImage
    }
}

enum SharePreset {
    case feed    // 1080×1350 (4:5)
    case square  // 1080×1080
    case story   // 1080×1920
    
    var size: CGSize {
        switch self {
        case .feed:
            return CGSize(width: 1080, height: 1350)
        case .square:
            return CGSize(width: 1080, height: 1080)
        case .story:
            return CGSize(width: 1080, height: 1920)
        }
    }
}
