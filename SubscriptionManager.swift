import Foundation
import StoreKit
import FirebaseFirestore
import FirebaseAuth

@MainActor
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasActiveSubscription = true  // TEMP: Free until EIN received
    @Published var currentSubscription: SubscriptionPlan?
    
    private let productIDs: Set<String> = [
        "com.mantraapp.MantraApp.weekly",
        "com.mantraapp.MantraApp.monthly",
        "com.mantraapp.MantraApp.annual"
    ]
    
    private var products: [Product] = []
    private var updateListenerTask: Task<Void, Error>?
    private let db = Firestore.firestore()
    private var isInitialized = false
    
    private init() {
        // Don't initialize StoreKit immediately
    }
    
    func initialize() async {
        guard !isInitialized else { return }
        isInitialized = true
        
        print("Initializing SubscriptionManager...")
        // TEMP: Skip StoreKit initialization for free version
        // updateListenerTask = listenForTransactions()
        // await loadProducts()
        // await checkSubscriptionStatus()
        print("SubscriptionManager initialization complete - FREE VERSION")
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    func loadProducts() async {
        // TEMP: Skip product loading for free version
        return
        
        print("Starting to load products...")
        print("Product IDs to load: \(productIDs)")
        
        do {
            products = try await Product.products(for: productIDs)
            print("Loaded \(products.count) products")
            
            for product in products {
                print("Product: \(product.id)")
                print("  - Name: \(product.displayName)")
                print("  - Price: \(product.displayPrice)")
                print("  - Type: \(product.type)")
            }
            
            if products.isEmpty {
                print("WARNING: No products loaded!")
                print("This means either:")
                print("1. Products don't exist in App Store Connect")
                print("2. Product IDs don't match exactly")
                print("3. Products aren't in 'Ready to Submit' status")
                print("4. Network/StoreKit connection issue")
                errorMessage = "No subscription options available"
            }
        } catch {
            print("Failed to load products: \(error)")
            print("Error type: \(type(of: error))")
            print("Error details: \(error.localizedDescription)")
            errorMessage = "Failed to load subscription options: \(error.localizedDescription)"
        }
    }
    
    func getProduct(for plan: SubscriptionPlan) -> Product? {
        print("Looking for product with ID: \(plan.rawValue)")
        let product = products.first { $0.id == plan.rawValue }
        
        if let product = product {
            print("Found product: \(product.displayName) - \(product.displayPrice)")
            return product
        } else {
            print("Product not found for \(plan.rawValue)")
            print("Available product IDs: \(products.map { $0.id })")
            print("Total products loaded: \(products.count)")
            return nil
        }
    }
    
    func purchase(plan: SubscriptionPlan) async {
        // TEMP: Skip purchases for free version
        return
        
        guard let product = getProduct(for: plan) else {
            errorMessage = "Product not found"
            print("Purchase failed: Product not found for \(plan.rawValue)")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            print("Starting purchase for \(plan.rawValue)")
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                print("Purchase successful, verifying transaction...")
                let transaction = try checkVerified(verification)
                await saveSubscriptionToFirebase(transaction: transaction, plan: plan)
                hasActiveSubscription = true
                currentSubscription = plan
                await transaction.finish()
                print("Purchase completed successfully")
                
            case .userCancelled:
                print("Purchase cancelled by user")
                errorMessage = nil
                
            case .pending:
                print("Purchase pending approval")
                errorMessage = "Purchase is pending approval"
                
            @unknown default:
                print("Unknown purchase result")
                errorMessage = "Unknown purchase result"
            }
        } catch {
            print("Purchase failed: \(error)")
            errorMessage = "Purchase failed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func restorePurchases() async {
        // TEMP: Skip restore for free version
        return
        
        print("Starting purchase restoration...")
        isLoading = true
        errorMessage = nil
        
        do {
            try await AppStore.sync()
            await checkSubscriptionStatus()
            print("Purchase restoration completed")
        } catch {
            print("Failed to restore purchases: \(error)")
            errorMessage = "Failed to restore purchases"
        }
        
        isLoading = false
    }
    
    func checkSubscriptionStatus() async {
        // TEMP: Force free version until EIN received
        self.hasActiveSubscription = true
        print("Subscription status check - FREE VERSION ACTIVE")
        return
        
        print("Checking subscription status...")
        var hasActiveSubscription = false
        var currentPlan: SubscriptionPlan?
        
        for await result in StoreKit.Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                if let expirationDate = transaction.expirationDate,
                   expirationDate > Date() {
                    hasActiveSubscription = true
                    print("Found active subscription: \(transaction.productID), expires: \(expirationDate)")
                    
                    if let plan = SubscriptionPlan(rawValue: transaction.productID) {
                        currentPlan = plan
                    }
                } else {
                    print("Found expired subscription: \(transaction.productID)")
                }
                
                await transaction.finish()
            } catch {
                print("Failed to verify transaction: \(error)")
            }
        }
        
        self.hasActiveSubscription = hasActiveSubscription
        self.currentSubscription = currentPlan
        
        print("Subscription status check complete:")
        print("  - Has active subscription: \(hasActiveSubscription)")
        print("  - Current plan: \(currentPlan?.rawValue ?? "none")")
        
        await updateFirebaseSubscriptionStatus(hasActive: hasActiveSubscription, plan: currentPlan)
    }
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            print("Starting transaction listener...")
            for await result in StoreKit.Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)
                    print("Transaction update received: \(transaction.productID)")
                    await self.checkSubscriptionStatus()
                    await transaction.finish()
                } catch {
                    print("Transaction verification failed: \(error)")
                }
            }
        }
    }
    
    private func saveSubscriptionToFirebase(transaction: StoreKit.Transaction, plan: SubscriptionPlan) async {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No authenticated user")
            return
        }
        
        let subscriptionData: [String: Any] = [
            "plan": plan.rawValue,
            "transactionId": transaction.id,
            "originalTransactionId": transaction.originalID,
            "purchaseDate": Timestamp(date: transaction.purchaseDate),
            "expirationDate": transaction.expirationDate.map { Timestamp(date: $0) } as Any,
            "isActive": true,
            "lastUpdated": Timestamp(date: Date())
        ]
        
        do {
            try await db.collection("users").document(userId).collection("subscriptions").document(transaction.originalID.description).setData(subscriptionData)
            print("Subscription saved to Firebase")
        } catch {
            print("Failed to save subscription to Firebase: \(error)")
        }
    }
    
    private func updateFirebaseSubscriptionStatus(hasActive: Bool, plan: SubscriptionPlan?) async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let statusData: [String: Any] = [
            "hasActive": hasActive,
            "currentPlan": plan?.rawValue ?? "",
            "lastChecked": Timestamp(date: Date())
        ]
        
        do {
            try await db.collection("users").document(userId).updateData(statusData)
            print("Firebase subscription status updated")
        } catch {
            print("Failed to update subscription status: \(error)")
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

enum SubscriptionPlan: String, CaseIterable {
    case weekly = "com.mantraapp.MantraApp.weekly"
    case monthly = "com.mantraapp.MantraApp.monthly"
    case annual = "com.mantraapp.MantraApp.annual"
    
    var displayName: String {
        switch self {
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .annual: return "Annual"
        }
    }
    
    var price: String {
        switch self {
        case .weekly: return "$2.99"
        case .monthly: return "$9.99"
        case .annual: return "$59.99"
        }
    }
    
    var badge: String? {
        switch self {
        case .weekly: return "MOST POPULAR"
        case .monthly: return nil
        case .annual: return nil
        }
    }
}

enum StoreError: Error {
    case failedVerification
}
