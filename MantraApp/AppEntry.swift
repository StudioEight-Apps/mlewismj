import SwiftUI
import Firebase
import FirebaseAnalytics
import UIKit
import RevenueCat
import UserNotifications

@main
struct MantraApp: App {
    // Inject Firebase AppDelegate properly
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @ObservedObject private var themeManager = ThemeManager.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(AuthViewModel.shared)
                .preferredColorScheme(themeManager.preferredColorScheme)
        }
    }
}

// Proper UIApplicationDelegate with Firebase setup
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        AnalyticsService.shared.trackAppOpened()

        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "appl_WOHwnfwZmKLoIIBSmLZnmXfRKnL")

        // Set notification delegate so we can handle taps
        UNUserNotificationCenter.current().delegate = self

        // Refresh notification permission state on launch
        NotificationManager.shared.checkPermission()

        return true
    }

    // Handle notification tap when app is in background/killed
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        NotificationManager.shared.handleNotificationTap(userInfo: userInfo)
        completionHandler()
    }

    // Show notification even when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.banner, .sound]
    }
}
