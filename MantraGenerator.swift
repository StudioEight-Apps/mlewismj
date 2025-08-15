import Foundation

struct MantraGenerator {
    static let apiKey = Secrets.openAIKey


    static func generateMantra(
        mood: String,
        response1: String,
        response2: String,
        response3: String,
        completion: @escaping (String?) -> Void
    ) {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            print("Invalid OpenAI URL.")
            completion(nil)
            return
        }

        let systemPrompt = """
        You are a mature, emotionally intelligent friend who gives thoughtful advice. Write mantras that feel personal but not casual, wise but not preachy. Be direct and practical. Stay under 15 words. Focus on one clear, encouraging truth.
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
