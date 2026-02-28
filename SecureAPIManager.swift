import Foundation
import FirebaseRemoteConfig

class SecureAPIManager {
    static let shared = SecureAPIManager()

    private var cachedOpenAIKey: String?
    private var cachedAnthropicKey: String?
    private var lastFetchTime: Date?
    #if DEBUG
    private let cacheExpirationInterval: TimeInterval = 60 // 1 minute in debug
    #else
    private let cacheExpirationInterval: TimeInterval = 3600 // 1 hour in production
    #endif

    private init() {}

    // MARK: - Anthropic API Key

    func getAnthropicAPIKey(completion: @escaping (String?) -> Void) {
        // Check cache first
        if let cachedKey = cachedAnthropicKey,
           let lastFetch = lastFetchTime,
           Date().timeIntervalSince(lastFetch) < cacheExpirationInterval {
            completion(cachedKey)
            return
        }

        fetchRemoteConfig { [weak self] in
            let configValue = RemoteConfig.remoteConfig().configValue(forKey: "anthropic_api_key")
            let apiKey: String? = configValue.stringValue

            print("🔑 Anthropic Remote Config source: \(configValue.source.rawValue) (0=static, 1=default, 2=remote)")
            print("🔑 Anthropic key length: \(apiKey?.count ?? 0)")

            guard let apiKey = apiKey, !apiKey.isEmpty else {
                print("ℹ️ Anthropic API key not found in Remote Config - will fall back to OpenAI")
                completion(nil)
                return
            }

            self?.cachedAnthropicKey = apiKey
            self?.lastFetchTime = Date()
            print("✅ Anthropic API key loaded successfully")
            completion(apiKey)
        }
    }

    // MARK: - OpenAI API Key

    func getOpenAIAPIKey(completion: @escaping (String?) -> Void) {
        // Check cache first
        if let cachedKey = cachedOpenAIKey,
           let lastFetch = lastFetchTime,
           Date().timeIntervalSince(lastFetch) < cacheExpirationInterval {
            completion(cachedKey)
            return
        }

        fetchRemoteConfig { [weak self] in
            let apiKey: String? = RemoteConfig.remoteConfig().configValue(forKey: "openai_api_key").stringValue

            guard let apiKey = apiKey, !apiKey.isEmpty else {
                print("❌ OpenAI API key not found in Remote Config")
                completion(nil)
                return
            }

            self?.cachedOpenAIKey = apiKey
            self?.lastFetchTime = Date()
            completion(apiKey)
        }
    }

    // MARK: - Shared Remote Config Fetch

    private func fetchRemoteConfig(completion: @escaping () -> Void) {
        let remoteConfig = RemoteConfig.remoteConfig()

        let settings = RemoteConfigSettings()
        #if DEBUG
        settings.minimumFetchInterval = 0 // No cache during development
        #else
        settings.minimumFetchInterval = 3600 // 1 hour cache for production
        #endif
        remoteConfig.configSettings = settings

        remoteConfig.fetch { status, error in
            if let error = error {
                print("❌ Failed to fetch Remote Config: \(error.localizedDescription)")
                completion()
                return
            }

            print("📡 Remote Config fetch status: \(status.rawValue) (0=noFetchYet, 1=success, 2=throttled, 3=failure)")

            remoteConfig.activate { changed, error in
                if let error = error {
                    print("❌ Failed to activate Remote Config: \(error.localizedDescription)")
                }
                print("📡 Remote Config activated. Changed: \(changed)")
                completion()
            }
        }
    }
}
