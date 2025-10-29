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
        // Get secure API key first
        SecureAPIManager.shared.getOpenAIAPIKey { apiKey in
            guard let apiKey = apiKey else {
                print("Failed to get OpenAI API key")
                completion(nil)
                return
            }
            
            guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
                print("Invalid OpenAI URL.")
                completion(nil)
                return
            }

            // Build the user prompt based on journal type
            let userPrompt: String
            if journalType == .free {
                // For free journal, create a custom prompt that emphasizes short, punchy mantras
                userPrompt = """
                Based on this person's mood (\(mood)) and their free-form journal entry below, create a SHORT, PUNCHY mantra in the exact style of these examples:
                
                Examples of the style:
                - "Confidence starts when comparison stops"
                - "Move like it's already happening"
                - "Let them wonder"
                - "Your pace is perfect"
                - "Trust the timing"
                
                Their journal entry:
                \(response1)
                
                Create a mantra that is:
                - Maximum 12 words
                - No colons or definitions
                - Conversational and direct
                - Empowering and personal
                - Sounds like advice from a wise friend
                
                Return ONLY the mantra, nothing else.
                """
            } else {
                // Use the original guided prompt
                userPrompt = WhisperVoice.personalizedMantraPrompt(
                    mood: mood,
                    response1: response1,
                    response2: response2,
                    response3: response3
                )
            }

            let requestBody: [String: Any] = [
                "model": "gpt-4o",
                "messages": [
                    ["role": "system", "content": WhisperVoice.systemPrompt],
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
                print("JSON encoding error: \(error.localizedDescription)")
                completion(nil)
                return
            }

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("API request error: \(error.localizedDescription)")
                    completion(nil)
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    print("No HTTP response received.")
                    completion(nil)
                    return
                }

                print("HTTP Status Code: \(httpResponse.statusCode)")

                guard let data = data else {
                    print("No data returned from OpenAI.")
                    completion(nil)
                    return
                }

                if let raw = String(data: data, encoding: .utf8) {
                    print("OpenAI Raw Response: \(raw)")
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let choices = json["choices"] as? [[String: Any]],
                       let message = choices.first?["message"] as? [String: Any],
                       let content = message["content"] as? String {
                        completion(content.trimmingCharacters(in: .whitespacesAndNewlines))
                    } else {
                        print("Unexpected OpenAI response format.")
                        completion(nil)
                    }
                } catch {
                    print("Failed to decode response: \(error.localizedDescription)")
                    completion(nil)
                }
            }.resume()
        }
    }
}
