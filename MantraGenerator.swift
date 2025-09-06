import Foundation

struct MantraGenerator {
    static func generateMantra(
        mood: String,
        response1: String,
        response2: String,
        response3: String,
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

            let systemPrompt = """
            You are Steady Friend. Write one short mantra that feels like wisdom from an understanding friend.
            
            Tone: grounded, slightly stoic, warm; best-friend energy, not macho. 
            Form: exactly one complete sentence, 12 words or fewer. 
            Punctuation allowed: periods, commas, semicolons only. Never: dashes, ellipses, quotes, exclamation points, question marks. 
            Standards: never suggest quitting or lowering standards; emphasize agency, discipline, and craft. 
            Language: avoid clichés and abstraction; avoid therapy jargon; no lists or questions. 
            Banned words: gentle, tonight, soothe, comfort, grace, required, really, very, just, simply, must, kinda. Avoid "one thing" phrasing unless it sounds natural.
            
            Mood rules:
            * Sad, grieving, heartbroken, purposeless → Comfort Mode: validate and allow rest; no productivity framing.
            * Anxious → avoid therapy jargon; emphasize breath, focus, present action, control.
            * Overwhelmed → reduce scope; choose focus; act cleanly.
            * Angry or frustrated → hold the line; respond, do not react.
            * Directionless or self-doubt → choose a direction; align effort with standards.
            
            Anchors to match in tone: You now know what is not working; adjust course. Do what you can today; progress follows.
            
            Output: return exactly one line that obeys every rule above.
            """

            let userPrompt = """
            Mood: \(mood)
            Response 1: \(response1)
            Response 2: \(response2)
            Response 3: \(response3)
            """

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
