import UIKit
import SwiftUI

final class SocialShareManager {
    
    // MARK: - Main Share Method
    /// Shares an image with NO text by default (caption is optional)
    /// The mantra text is already baked into the image design
    static func shareImage(_ image: UIImage, caption: String? = nil, completion: ((Bool) -> Void)? = nil) {
        // First, try to save to Photos (always works)
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        // Then present the standard share sheet
        presentShareSheet(image: image, caption: caption, completion: completion)
    }
    
    // MARK: - Standard Share Sheet (works for Messages, Mail, Save to Files, etc.)
    private static func presentShareSheet(image: UIImage, caption: String? = nil, completion: ((Bool) -> Void)? = nil) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            completion?(false)
            return
        }
        
        var topController = rootViewController
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        
        // Convert image to PNG data for better compatibility
        guard let imageData = image.pngData() else {
            completion?(false)
            return
        }
        
        // Create a temporary file for the image (required for some apps)
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("whisper-share-\(UUID().uuidString).png")
        
        do {
            try imageData.write(to: tempURL)
            
            // ONLY share the image file - no text unless explicitly provided
            var activityItems: [Any] = [tempURL]
            if let caption = caption, !caption.isEmpty {
                activityItems.insert(caption, at: 0)
            }
            
            let activityViewController = UIActivityViewController(
                activityItems: activityItems,
                applicationActivities: nil
            )
            
            // Exclude activities that don't work well with our content
            activityViewController.excludedActivityTypes = [
                .addToReadingList,
                .assignToContact,
                .openInIBooks
            ]
            
            // iPad support
            if let popover = activityViewController.popoverPresentationController {
                popover.sourceView = topController.view
                popover.sourceRect = CGRect(
                    x: topController.view.bounds.midX,
                    y: topController.view.bounds.midY,
                    width: 0,
                    height: 0
                )
                popover.permittedArrowDirections = []
            }
            
            // Handle completion
            activityViewController.completionWithItemsHandler = { activityType, completed, returnedItems, error in
                // Clean up temp file
                try? FileManager.default.removeItem(at: tempURL)
                
                if let error = error {
                    print("❌ Share error: \(error.localizedDescription)")
                    completion?(false)
                    return
                }
                
                if completed {
                    print("✅ Share completed via: \(activityType?.rawValue ?? "unknown")")
                    completion?(true)
                } else {
                    print("ℹ️ Share cancelled")
                    completion?(false)
                }
            }
            
            topController.present(activityViewController, animated: true)
            
        } catch {
            print("❌ Failed to write temp file: \(error.localizedDescription)")
            completion?(false)
        }
    }
    
    // MARK: - Instagram Stories Share (Custom URL Scheme)
    static func shareToInstagramStories(image: UIImage, completion: ((Bool) -> Void)? = nil) {
        guard let instagramURL = URL(string: "instagram-stories://share"),
              UIApplication.shared.canOpenURL(instagramURL) else {
            print("❌ Instagram not installed or not configured in Info.plist")
            completion?(false)
            return
        }
        
        // Prepare the image data
        guard let imageData = image.pngData() else {
            completion?(false)
            return
        }
        
        // Use UIPasteboard for Instagram sharing
        let pasteboardItems: [[String: Any]] = [
            [
                "com.instagram.sharedSticker.backgroundImage": imageData,
                "com.instagram.sharedSticker.backgroundTopColor": "#FFFCF5",
                "com.instagram.sharedSticker.backgroundBottomColor": "#E8E2D6"
            ]
        ]
        
        let pasteboardOptions: [UIPasteboard.OptionsKey: Any] = [
            .expirationDate: Date().addingTimeInterval(60 * 5) // 5 minutes
        ]
        
        UIPasteboard.general.setItems(pasteboardItems, options: pasteboardOptions)
        
        // Open Instagram
        UIApplication.shared.open(instagramURL) { success in
            if success {
                print("✅ Opened Instagram Stories")
                completion?(true)
            } else {
                print("❌ Failed to open Instagram Stories")
                completion?(false)
            }
        }
    }
    
    // MARK: - Facebook Share (Custom URL Scheme)
    static func shareToFacebook(image: UIImage, completion: ((Bool) -> Void)? = nil) {
        // Save to Photos first (Facebook pulls from Photos)
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        guard let facebookURL = URL(string: "fb://"),
              UIApplication.shared.canOpenURL(facebookURL) else {
            print("❌ Facebook not installed or not configured in Info.plist")
            completion?(false)
            return
        }
        
        // For Facebook, we use the share sheet approach since FB removed direct sharing APIs
        // The image was saved to Photos, so user can pick it from there
        presentShareSheet(image: image, caption: nil, completion: completion)
    }
    
    // MARK: - Twitter/X Share (URL Scheme)
    static func shareToTwitter(text: String, image: UIImage? = nil, completion: ((Bool) -> Void)? = nil) {
        // Twitter/X sharing via share sheet works best
        // The app will appear in the share sheet if installed
        if let image = image {
            presentShareSheet(image: image, caption: text, completion: completion)
        } else {
            // Text-only tweet
            guard let twitterURL = URL(string: "twitter://post?message=\(text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"),
                  UIApplication.shared.canOpenURL(twitterURL) else {
                presentShareSheet(image: UIImage(), caption: text, completion: completion)
                return
            }
            
            UIApplication.shared.open(twitterURL) { success in
                completion?(success)
            }
        }
    }
    
    // MARK: - Check if Social Apps are Installed
    static func canShareToInstagram() -> Bool {
        guard let url = URL(string: "instagram-stories://share") else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
    
    static func canShareToFacebook() -> Bool {
        guard let url = URL(string: "fb://") else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
    
    static func canShareToTwitter() -> Bool {
        guard let url = URL(string: "twitter://") else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
}
