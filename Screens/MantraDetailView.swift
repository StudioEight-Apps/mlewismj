import SwiftUI
import Firebase

struct MantraDetailView: View {
    var entry: [String: Any]

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
                    ForEach(prompts.indices, id: \.self) { index in
                        Text("Response \(index + 1):")
                            .font(.headline)
                            .padding(.top, 8)
                        Text(prompts[index])
                            .font(.body)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Entry")
        .navigationBarTitleDisplayMode(.inline)
    }
}

