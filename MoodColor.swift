import Foundation

func colorForMood(_ mood: String) -> String {
    switch mood.lowercased() {
    // Red/Pink group - Darker versions
    case "stressed":
        return "#F5A5A5" // Darker pink-red
    case "frustrated":
        return "#F5A5A5"
    case "overwhelmed":
        return "#F5A5A5"
    case "anxious":
        return "#F5A5A5"
        
    // Purple group - Darker versions
    case "angry":
        return "#C8B5E8" // Darker purple
    case "sad":
        return "#C8B5E8"
    case "lonely":
        return "#C8B5E8"
    case "tired":
        return "#C8B5E8"
    case "insecure":
        return "#C8B5E8"
    case "fine":
        return "#C8B5E8"
        
    // Green group - Darker versions
    case "calm":
        return "#B5D6BA" // Darker green
    case "content":
        return "#B5D6BA"
    case "reflective":
        return "#B5D6BA"
    case "happy":
        return "#B5D6BA"
    case "grateful":
        return "#B5D6BA"
    case "excited":
        return "#B5D6BA"
    case "hopeful":
        return "#B5D6BA"
    case "motivated":
        return "#B5D6BA"
        
    default:
        return "#C8B5E8" // Default purple
    }
}
