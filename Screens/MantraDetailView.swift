import SwiftUI
import Firebase

struct MantraDetailView: View {
    var entry: [String: Any]
    @Environment(\.colorScheme) var colorScheme
    private var colors: AppColors { AppColors(colorScheme) }

    // Helper to get journal type
    private var journalType: JournalType {
        if let typeString = entry["journalType"] as? String,
           let type = JournalType(rawValue: typeString) {
            return type
        }
        return .guided // Default for legacy entries
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let date = entry["date"] as? Timestamp {
                    Text(date.dateValue(), style: .date)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                if let mood = entry["mood"] as? String {
                    Text("Mood: \(mood)")
                        .font(.headline)
                }

                if let text = entry["text"] as? String {
                    Text("Mantra:")
                        .font(.title2)
                        .bold()
                    Text(text)
                        .font(.title3)
                        .padding(.bottom)
                }

                if let prompts = entry["prompts"] as? [String] {
                    // Display based on journal type
                    if journalType == .free {
                        // Free journal - only show first prompt
                        if !prompts.isEmpty && !prompts[0].isEmpty {
                            Text("Your Journal:")
                                .font(.headline)
                                .padding(.top, 8)
                            Text(prompts[0])
                                .font(.body)
                        }
                    } else {
                        // Guided journal - show all 3 prompts
                        ForEach(prompts.indices, id: \.self) { index in
                            if !prompts[index].isEmpty {
                                Text("Response \(index + 1):")
                                    .font(.headline)
                                    .padding(.top, 8)
                                Text(prompts[index])
                                    .font(.body)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .tint(colors.navTint)
        .navigationTitle("Entry")
        .navigationBarTitleDisplayMode(.inline)
    }
}
