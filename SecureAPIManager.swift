import Foundation
import FirebaseRemoteConfig

class SecureAPIManager {
    static let shared = SecureAPIManager()
    
    private var cachedAPIKey: String?
    private var lastFetchTime: Date?
    private let cacheExpirationInterval: TimeInterval = 3600 // 1 hour
    
    private init() {}
    
    func getOpenAIAPIKey(completion: @escaping (String?) -> Void) {
        // Check cache first
        if let cachedKey = cachedAPIKey,
           let lastFetch = lastFetchTime,
           Date().timeIntervalSince(lastFetch) < cacheExpirationInterval {
            completion(cachedKey)
            return
        }
        
        // Fetch from Firebase Remote Config
        let remoteConfig = RemoteConfig.remoteConfig()
        
        // Set cache expiration to 1 hour
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0 // Allow immediate fetching for debugging
        remoteConfig.configSettings = settings
        
        remoteConfig.fetch { [weak self] status, error in
            if let error = error {
                print("Failed to fetch Remote Config: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            remoteConfig.activate { _, error in
                if let error = error {
                    print("Failed to activate Remote Config: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                let apiKey = remoteConfig.configValue(forKey: "openai_api_key").stringValue ?? ""
                
                if apiKey.isEmpty {
                    print("OpenAI API key not found in Remote Config")
                    completion(nil)
                    return
                }
                
                // Cache the key
                self?.cachedAPIKey = apiKey
                self?.lastFetchTime = Date()
                
                completion(apiKey)
            }
        }
    }
}
