import Foundation

struct JournalEntry: Identifiable, Codable {
    var id: String = UUID().uuidString
    var date: Date
    var mood: String
    var text: String        // this is the mantra
    var colorHex: String    // theme color
    var prompts: [String]   // response1, response2, response3
}

