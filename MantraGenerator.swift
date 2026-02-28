import Foundation

struct MantraGenerator {
    static func generateMantra(
        mood: String,
        response1: String,
        response2: String,
        response3: String,
        journalType: JournalType = .guided,
        completion: @escaping (String?) -> Void
    ) {
        // Get user's voice preference (defaults to 1 if not set)
        let voiceId = UserDefaults.standard.integer(forKey: "voice_id")
        let selectedVoiceId = voiceId > 0 ? voiceId : 1

        let systemPrompt = WhisperVoice.systemPrompt(for: selectedVoiceId)
        let userPrompt = WhisperVoice.personalizedPrompt(
            for: selectedVoiceId,
            mood: mood,
            response1: response1,
            response2: response2,
            response3: response3
        )

        print("🎯 Generating mantra with voice ID: \(selectedVoiceId)")

        // Try Anthropic first, fall back to OpenAI
        generateWithAnthropic(systemPrompt: systemPrompt, userPrompt: userPrompt, voiceId: selectedVoiceId) { result in
            if let result = result {
                completion(result)
            } else {
                print("⚠️ Anthropic unavailable, falling back to OpenAI")
                generateWithOpenAI(systemPrompt: systemPrompt, userPrompt: userPrompt, voiceId: selectedVoiceId, completion: completion)
            }
        }
    }

    // MARK: - Anthropic (Claude)

    private static func generateWithAnthropic(systemPrompt: String, userPrompt: String, voiceId: Int, completion: @escaping (String?) -> Void) {
        SecureAPIManager.shared.getAnthropicAPIKey { apiKey in
            guard let apiKey = apiKey else {
                completion(nil)
                return
            }

            guard let url = URL(string: "https://api.anthropic.com/v1/messages") else {
                completion(nil)
                return
            }

            let requestBody: [String: Any] = [
                "model": "claude-sonnet-4-5-20250929",
                "max_tokens": 80,
                "temperature": 0.85,
                "system": systemPrompt,
                "messages": [
                    ["role": "user", "content": userPrompt]
                ]
            ]

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
            request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            } catch {
                print("❌ Anthropic JSON encoding error: \(error.localizedDescription)")
                completion(nil)
                return
            }

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("❌ Anthropic request error: \(error.localizedDescription)")
                    completion(nil)
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(nil)
                    return
                }

                print("🤖 Anthropic HTTP Status: \(httpResponse.statusCode) | Voice: \(voiceId)")

                guard httpResponse.statusCode == 200, let data = data else {
                    if let data = data, let raw = String(data: data, encoding: .utf8) {
                        print("❌ Anthropic error response: \(raw)")
                    }
                    completion(nil)
                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let content = json["content"] as? [[String: Any]],
                       let textBlock = content.first(where: { $0["type"] as? String == "text" }),
                       let text = textBlock["text"] as? String {
                        let cleaned = WhisperVoice.cleanWhisperText(text)
                        print("✅ Anthropic whisper: \(cleaned)")
                        completion(cleaned)
                    } else {
                        print("❌ Unexpected Anthropic response format")
                        completion(nil)
                    }
                } catch {
                    print("❌ Anthropic decode error: \(error.localizedDescription)")
                    completion(nil)
                }
            }.resume()
        }
    }

    // MARK: - OpenAI (Fallback)

    private static func generateWithOpenAI(systemPrompt: String, userPrompt: String, voiceId: Int, completion: @escaping (String?) -> Void) {
        SecureAPIManager.shared.getOpenAIAPIKey { apiKey in
            guard let apiKey = apiKey else {
                print("❌ Failed to get OpenAI API key")
                completion(nil)
                return
            }

            guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
                completion(nil)
                return
            }

            let requestBody: [String: Any] = [
                "model": "gpt-4o",
                "messages": [
                    ["role": "system", "content": systemPrompt],
                    ["role": "user", "content": userPrompt]
                ],
                "temperature": 0.8,
                "max_tokens": 80
            ]

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            } catch {
                print("❌ OpenAI JSON encoding error: \(error.localizedDescription)")
                completion(nil)
                return
            }

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("❌ OpenAI request error: \(error.localizedDescription)")
                    completion(nil)
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(nil)
                    return
                }

                print("🟢 OpenAI HTTP Status: \(httpResponse.statusCode) | Voice: \(voiceId)")

                guard let data = data else {
                    completion(nil)
                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let choices = json["choices"] as? [[String: Any]],
                       let message = choices.first?["message"] as? [String: Any],
                       let content = message["content"] as? String {
                        let cleaned = WhisperVoice.cleanWhisperText(content)
                        print("✅ OpenAI whisper: \(cleaned)")
                        completion(cleaned)
                    } else {
                        print("❌ Unexpected OpenAI response format")
                        completion(nil)
                    }
                } catch {
                    print("❌ OpenAI decode error: \(error.localizedDescription)")
                    completion(nil)
                }
            }.resume()
        }
    }
}
