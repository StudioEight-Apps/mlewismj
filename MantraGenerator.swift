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
            You write mantras for a modern journaling app.
            Tone: warm, current, and supportive — like advice from a caring friend. 
            Style: short, clear, and screenshot-worthy. Gentle but true; never fluffy, never abstract. 
            Form: one sentence only, 12 words or fewer. Occasionally two short rhythmic lines are allowed. 
            Voice: conversational and relatable; phrasing should feel modern and save-worthy. 
            Punctuation: periods, commas, semicolons only. No dashes, ellipses, quotes, exclamation points, or question marks. (Contractions are fine.)
            Mood rules:
            • Sad, grieving, heartbroken → validate, soothe, and give permission to rest. 
            • Anxious, overwhelmed → ground them in calm and remind them of what's controllable. 
            • Unmotivated, tired, stuck → gently encourage with small, doable next steps. 
            • Frustrated, angry → center peace, boundaries, and moving forward. 
            • Hopeful, energized → encourage direction and consistency without pressure. 
            • Content, reflective → reinforce gratitude, balance, and steady joy. 
            Anchors for tone and rhythm (do not copy, only match): 
            • You've returned to yourself before. You can do it again. 
            • Believe their actions. 
            • You still have time. 
            • You deserve all the good coming your way. 
            • You deserve to think highly of yourself. 
            • For your sanity, let people think what they want. 
            • Let it end. Let it change. Let it hurt. Let it heal. 
            • You gotta let go of what let go of you. 
            • Remind yourself that rest is not wasted time. 
            Output: return exactly one mantra that follows all rules above.
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
