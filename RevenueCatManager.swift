import Foundation
import RevenueCat

class RevenueCatManager: ObservableObject {
    static let shared = RevenueCatManager()
    
    @Published var hasActiveSubscription = false
    @Published var availablePackages: [Package] = []
    @Published var hasPaywallTemplate = false
    @Published var offeringsLoaded = false
    
    private init() {
        // NOTE: Don't auto-check subscription here.
        // Let RootView control the flow AFTER setUser() is called.
        // This prevents the race condition where checkSubscriptionStatus()
        // runs for an anonymous user before logIn() completes.
    }
    
    func setUser(userId: String) async throws {
        let customerInfo = try await Purchases.shared.logIn(userId)
        print("✅ RevenueCat user set: \(userId)")

        // Check subscription status for the now-logged-in user
        let isActive = customerInfo.0.entitlements["premium"]?.isActive == true

        await MainActor.run {
            hasActiveSubscription = isActive
        }

        if isActive {
            print("✅ Active premium entitlement found after login")
        } else {
            print("⚠️ No active entitlement — user needs to subscribe or tap Restore")
        }
    }
    
    func checkSubscriptionStatus() async {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            let isActive = customerInfo.entitlements["premium"]?.isActive == true

            if isActive {
                await MainActor.run {
                    hasActiveSubscription = true
                }
                print("✅ Active premium entitlement")
            } else {
                await MainActor.run {
                    hasActiveSubscription = false
                }
                print("⚠️ No active entitlement — user needs to subscribe or tap Restore")
            }
        } catch {
            print("❌ Failed to check subscription status: \(error.localizedDescription)")
            await MainActor.run {
                hasActiveSubscription = false
            }
        }
    }
    
    func logout() async throws {
        _ = try await Purchases.shared.logOut()
        print("✅ RevenueCat logged out")
        await MainActor.run {
            hasActiveSubscription = false
        }
    }
    
    func fetchOfferings() async throws {
        let offerings = try await Purchases.shared.offerings()

        guard let currentOffering = offerings.current else {
            print("❌ No current offering found")
            await MainActor.run {
                availablePackages = []
                hasPaywallTemplate = false
                offeringsLoaded = true
            }
            return
        }

        let templateAvailable = currentOffering.paywall != nil

        await MainActor.run {
            availablePackages = currentOffering.availablePackages
            hasPaywallTemplate = templateAvailable
            offeringsLoaded = true
            print("✅ Loaded \(availablePackages.count) packages from offering: \(currentOffering.identifier)")
            print("Paywall template: \(templateAvailable ? "found" : "none")")
        }
    }
    
    func purchase(packageIdentifier: String) async throws {
        guard let package = await MainActor.run(body: { availablePackages.first(where: { $0.identifier == packageIdentifier }) }) else {
            throw NSError(domain: "RevenueCat", code: -1, userInfo: [NSLocalizedDescriptionKey: "Package not found"])
        }
        
        let result = try await Purchases.shared.purchase(package: package)
        
        await MainActor.run {
            hasActiveSubscription = result.customerInfo.entitlements["premium"]?.isActive == true
            
            if hasActiveSubscription {
                print("✅ Purchase successful: \(packageIdentifier)")
            } else {
                print("⚠️ Purchase completed but no premium entitlement")
            }
        }
    }
    
    func restorePurchases() async throws {
        let customerInfo = try await Purchases.shared.restorePurchases()
        await MainActor.run {
            hasActiveSubscription = customerInfo.entitlements["premium"]?.isActive == true
            
            if hasActiveSubscription {
                print("✅ Purchases restored successfully")
            } else {
                print("⚠️ No active premium subscription found")
            }
        }
    }
}
