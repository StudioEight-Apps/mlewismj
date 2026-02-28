import SwiftUI

// WidgetSetupLockScreen is now merged into WidgetSetupHomeScreen as step 2.
// This file kept for compile compatibility with any remaining references.
struct WidgetSetupLockScreen: View {
    @Environment(\.dismiss) var dismiss
    var isFromSettings: Bool = false
    var rootDismiss: (() -> Void)? = nil

    var body: some View {
        WidgetSetupHomeScreen(isFromSettings: isFromSettings)
    }
}
