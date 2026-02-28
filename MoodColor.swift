import Foundation

// Single source of truth for mood → color mapping
// Palette: Anthropic-inspired muted pastels — low saturation, high sophistication

func colorForMood(_ mood: String) -> String {
    switch mood.lowercased() {

    // Rose — tense, agitated energy
    case "stressed", "anxious", "frustrated", "overwhelmed", "nervous", "angry", "restless":
        return "#E0C4BC"

    // Lavender — low, heavy energy
    case "sad", "lonely", "tired", "drained", "empty", "insecure", "lost", "numb", "nostalgic":
        return "#CABFD4"

    // Slate — neutral, processing
    case "fine", "reflective", "calm", "content", "confused", "bored":
        return "#B8C8D8"

    // Sage — positive, uplifting
    case "happy", "grateful", "hopeful", "motivated",
         "peaceful", "inspired", "energized", "excited", "proud", "loving":
        return "#BDD0BD"

    default:
        return "#B8C8D8" // Slate neutral
    }
}

// Border color (slightly darker version of each mood color)
func borderColorForMood(_ mood: String) -> String {
    switch mood.lowercased() {
    case "stressed", "anxious", "frustrated", "overwhelmed", "nervous", "angry", "restless":
        return "#D0AFA5"
    case "sad", "lonely", "tired", "drained", "empty", "insecure", "lost", "numb", "nostalgic":
        return "#B5A8C0"
    case "fine", "reflective", "calm", "content", "confused", "bored":
        return "#A0B4C4"
    case "happy", "grateful", "hopeful", "motivated",
         "peaceful", "inspired", "energized", "excited", "proud", "loving":
        return "#A5C0A5"
    default:
        return "#A0B4C4"
    }
}
