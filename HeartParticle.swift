import Foundation
import SwiftUI

struct HeartParticle: Identifiable {
    let id: UUID
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var opacity: Double
    var scale: CGFloat
    var angle: Double
    var distance: Double
}
