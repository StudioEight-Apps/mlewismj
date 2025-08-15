import SwiftUI
import Firebase
import UIKit

@main
struct MantraApp: App {
    // Inject Firebase AppDelegate properly
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    // Shared auth view model
    @StateObject var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authViewModel)
                .preferredColorScheme(.light)  // Forces light mode app-wide
        }
    }
}

// Proper UIApplicationDelegate with Firebase setup
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
