import FirebaseFunctions

enum MantraAPI {
    private static let functions = Functions.functions(region: "us-central1")

    static func ping(completion: @escaping (Bool) -> Void) {
        functions.httpsCallable("generateMantra").call([:]) { result, error in
            if let error = error { print("Callable error:", error); completion(false); return }
            let ok = (result?.data as? [String: Any])?["ok"] as? Bool ?? false
            completion(ok)
        }
    }
}

