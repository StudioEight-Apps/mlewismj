import Foundation

struct JournalEntry: Identifiable, Codable {
    var id: String = UUID().uuidString
    var date: Date
    var mood: String
    var text: String        // this is the mantra
    var colorHex: String    // theme color
    var prompts: [String]                // response1, response2, response3
    var promptQuestions: [String] = []    // the actual questions asked (saved for display)

    // V2 Features - Favorites & Pinning
    var isFavorited: Bool = false
    var isPinned: Bool = false
    var journalType: JournalType = .guided
    
    // V3 Features - Permanent Background
    var backgroundImage: String = "whisper-bg-1"
    var textColor: String = "#FFFFFF"
}

// Journal Type Enum - Guided vs Free Journal
enum JournalType: String, Codable {
    case guided = "guided"
    case free = "free"
}
