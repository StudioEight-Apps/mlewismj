import SwiftUI
import UIKit

struct MantraCardGenerator {
    
    static func createMantraCard(mantra: String, mood: String) -> UIImage {
        // Card dimensions (optimized for social sharing: 1080x1080 square)
        let cardSize = CGSize(width: 1080, height: 1080)
        
        // Validate inputs to prevent NaN
        guard cardSize.width > 0 && cardSize.height > 0 else {
            print("❌ Invalid card size")
            return createFallbackImage()
        }
        
        // Create graphics context
        UIGraphicsBeginImageContextWithOptions(cardSize, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            print("❌ Failed to create graphics context")
            return createFallbackImage()
        }
        
        // Create beautiful gradient background
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                colors: [
                                    UIColor(hex: "#FFE683").cgColor,     // #FFE683
                                    UIColor(hex: "#F5D982").cgColor,     // #F5D982
                                    UIColor(hex: "#E8C8F0").cgColor,     // #E8C8F0
                                    UIColor(hex: "#D8CCF6").cgColor      // #D8CCF6
                                ] as CFArray,
                                locations: [0.0, 0.3, 0.7, 1.0])!
        
        // Draw gradient
        let startPoint = CGPoint(x: 0, y: 0)
        let endPoint = CGPoint(x: cardSize.width, y: cardSize.height)
        context.drawLinearGradient(gradient,
                                 start: startPoint,
                                 end: endPoint,
                                 options: [])
        
        // Main card background with subtle design
        let cardMargin: CGFloat = 80
        let cardWidth = cardSize.width - (cardMargin * 2)
        let cardHeight: CGFloat = 700
        let cardX = cardMargin
        let cardY = (cardSize.height - cardHeight) / 2
        
        let cardRect = CGRect(x: cardX, y: cardY, width: cardWidth, height: cardHeight)
        
        // Validate rect before drawing
        guard cardRect.width > 0 && cardRect.height > 0 &&
              !cardRect.origin.x.isNaN && !cardRect.origin.y.isNaN else {
            print("❌ Invalid card rect")
            UIGraphicsEndImageContext()
            return createFallbackImage()
        }
        
        // Draw card with subtle shadow effect
        let shadowPath = UIBezierPath(roundedRect: cardRect.offsetBy(dx: 0, dy: 8), cornerRadius: 32)
        UIColor.black.withAlphaComponent(0.1).setFill()
        shadowPath.fill()
        
        let cardPath = UIBezierPath(roundedRect: cardRect, cornerRadius: 32)
        UIColor.white.withAlphaComponent(0.98).setFill()
        cardPath.fill()
        
        // Decorative top accent
        let accentRect = CGRect(x: cardX + 40, y: cardY + 40, width: cardWidth - 80, height: 4)
        let accentPath = UIBezierPath(roundedRect: accentRect, cornerRadius: 2)
        getMoodColor(mood).setFill()
        accentPath.fill()
        
        // Title text with better typography
        let titleText = "Daily Mantra"
        let titleFont = UIFont.systemFont(ofSize: 32, weight: .light)
        let titleColor = UIColor(hex: "#2B2834").withAlphaComponent(0.8)
        
        let titleWidth = cardWidth - 80
        let titleRect = CGRect(x: cardX + 40,
                              y: cardY + 80,
                              width: titleWidth,
                              height: 50)
        
        let titleParagraphStyle = NSMutableParagraphStyle()
        titleParagraphStyle.alignment = .center
        
        titleText.draw(in: titleRect, withAttributes: [
            .font: titleFont,
            .foregroundColor: titleColor,
            .paragraphStyle: titleParagraphStyle
        ])
        
        // Main mantra text with beautiful typography
        let mantraFont = UIFont.systemFont(ofSize: 42, weight: .medium)
        let mantraColor = UIColor(hex: "#2B2834")
        
        let mantraWidth = cardWidth - 120
        let mantraRect = CGRect(x: cardX + 60,
                               y: cardY + 160,
                               width: mantraWidth,
                               height: 360)
        
        let mantraParagraphStyle = NSMutableParagraphStyle()
        mantraParagraphStyle.alignment = .center
        mantraParagraphStyle.lineSpacing = 12
        mantraParagraphStyle.lineHeightMultiple = 1.2
        
        // Safely truncate long mantras
        let displayMantra = mantra.count > 150 ? String(mantra.prefix(150)) + "..." : mantra
        
        displayMantra.draw(in: mantraRect, withAttributes: [
            .font: mantraFont,
            .foregroundColor: mantraColor,
            .paragraphStyle: mantraParagraphStyle
        ])
        
        // Mood pill with better design
        let moodColor = getMoodColor(mood)
        let pillWidth: CGFloat = 200
        let pillHeight: CGFloat = 50
        let pillX = cardX + (cardWidth - pillWidth) / 2
        let pillY = cardY + 540
        
        let moodRect = CGRect(x: pillX, y: pillY, width: pillWidth, height: pillHeight)
        let moodPath = UIBezierPath(roundedRect: moodRect, cornerRadius: 25)
        moodColor.setFill()
        moodPath.fill()
        
        // Mood text with better styling
        let moodFont = UIFont.systemFont(ofSize: 22, weight: .semibold)
        let moodTextRect = CGRect(x: pillX, y: pillY + 12, width: pillWidth, height: 26)
        let moodParagraphStyle = NSMutableParagraphStyle()
        moodParagraphStyle.alignment = .center
        
        mood.capitalized.draw(in: moodTextRect, withAttributes: [
            .font: moodFont,
            .foregroundColor: UIColor.white,
            .paragraphStyle: moodParagraphStyle
        ])
        
        // App branding with elegant styling
        let brandText = "✨ Mantra"
        let brandFont = UIFont.systemFont(ofSize: 28, weight: .light)
        let brandColor = UIColor(hex: "#2B2834").withAlphaComponent(0.6)
        
        let brandRect = CGRect(x: cardX, y: cardY + 620, width: cardWidth, height: 40)
        let brandParagraphStyle = NSMutableParagraphStyle()
        brandParagraphStyle.alignment = .center
        
        brandText.draw(in: brandRect, withAttributes: [
            .font: brandFont,
            .foregroundColor: brandColor,
            .paragraphStyle: brandParagraphStyle
        ])
        
        // Get the final image
        let cardImage = UIGraphicsGetImageFromCurrentImageContext() ?? createFallbackImage()
        UIGraphicsEndImageContext()
        
        print("✅ Beautiful mantra card created successfully")
        return cardImage
    }
    
    // Create a simple fallback image if anything fails
    private static func createFallbackImage() -> UIImage {
        let size = CGSize(width: 1080, height: 1080)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        // Simple gradient fallback
        if let context = UIGraphicsGetCurrentContext() {
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                    colors: [UIColor.systemPurple.cgColor, UIColor.systemBlue.cgColor] as CFArray,
                                    locations: [0, 1])!
            context.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: 0, y: size.height), options: [])
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return image
    } 
    
    private static func getMoodColor(_ mood: String) -> UIColor {
        UIColor(hex: colorForMood(mood))
    }
}
