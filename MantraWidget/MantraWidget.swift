import WidgetKit
import SwiftUI

// MARK: - Background Rotation Config
// Mirrors BackgroundConfig.swift for widget use (widget can't access main app code)
struct WidgetBackground {
    let imageName: String
    let textColor: String
    let alignment: Alignment
    
    // Full set — needed for displaying pinned entries that may use any background
    static let all: [WidgetBackground] = [
        WidgetBackground(imageName: "sunset_teal_blend", textColor: "#F3EDE0", alignment: .center),
        WidgetBackground(imageName: "forest_green", textColor: "#C5FFB3", alignment: .center),
        WidgetBackground(imageName: "whisper_bg_deepreds", textColor: "#F5EDE5", alignment: .center),
        WidgetBackground(imageName: "sunkissed_whisper", textColor: "#42210B", alignment: .center),
        WidgetBackground(imageName: "whisper_bg_cream", textColor: "#1F2E78", alignment: .center),
        WidgetBackground(imageName: "whisper_bg_goldenblend", textColor: "#3E2A1C", alignment: .center),
        WidgetBackground(imageName: "whisper_bg_orangebluefade", textColor: "#E4B7A0", alignment: .center),
        WidgetBackground(imageName: "whisper_bg_amberforest", textColor: "#EEDDB4", alignment: .center),
        WidgetBackground(imageName: "blue_static", textColor: "#F9C99D", alignment: .center),
        WidgetBackground(imageName: "whisper_bg_charcoalgrain", textColor: "#F5E8D8", alignment: .center),
        WidgetBackground(imageName: "whisper_bg_espressofade", textColor: "#EEDFCB", alignment: .center),
        WidgetBackground(imageName: "whisper_color_poeticwine", textColor: "#F4F1EC", alignment: .center),
        WidgetBackground(imageName: "whisper_texture_cloudydream", textColor: "#D97A3F", alignment: .center),
        WidgetBackground(imageName: "whisper_texture_peeledpaper", textColor: "#1A1A1A", alignment: .top),
        WidgetBackground(imageName: "whisper_texture_bluetexture", textColor: "#2F2F2F", alignment: .center),
        WidgetBackground(imageName: "whisper_texture_coastal", textColor: "#F3E9D3", alignment: .center),
        WidgetBackground(imageName: "whisper_bg_crinkledbeige", textColor: "#5B3520", alignment: .center),
    ]

    // Curated set — dark/rich backgrounds only, for daily auto-rotation
    // Light text on moody backgrounds = premium widget look
    static let rotation: [WidgetBackground] = [
        WidgetBackground(imageName: "sunset_teal_blend", textColor: "#F3EDE0", alignment: .center),
        WidgetBackground(imageName: "forest_green", textColor: "#C5FFB3", alignment: .center),
        WidgetBackground(imageName: "whisper_bg_deepreds", textColor: "#F5EDE5", alignment: .center),
        WidgetBackground(imageName: "whisper_bg_orangebluefade", textColor: "#E4B7A0", alignment: .center),
        WidgetBackground(imageName: "whisper_bg_amberforest", textColor: "#EEDDB4", alignment: .center),
        WidgetBackground(imageName: "blue_static", textColor: "#F9C99D", alignment: .center),
        WidgetBackground(imageName: "whisper_bg_charcoalgrain", textColor: "#F5E8D8", alignment: .center),
        WidgetBackground(imageName: "whisper_bg_espressofade", textColor: "#EEDFCB", alignment: .center),
        WidgetBackground(imageName: "whisper_color_poeticwine", textColor: "#F4F1EC", alignment: .center),
        WidgetBackground(imageName: "whisper_texture_coastal", textColor: "#F3E9D3", alignment: .center),
    ]

    /// Returns a curated background for daily rotation (dark/rich only)
    static func forToday(date: Date = Date()) -> WidgetBackground {
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
        let index = dayOfYear % rotation.count
        return rotation[index]
    }
}

// MARK: - Timeline Provider
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        let bg = WidgetBackground.forToday()
        return SimpleEntry(
            date: Date(),
            mantra: "Your daily whisper will appear here",
            mood: "calm",
            backgroundImage: bg.imageName,
            textColor: bg.textColor,
            widgetAlignment: bg.alignment,
            isPlaceholder: true
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let bg = WidgetBackground.forToday()
        let entry = SimpleEntry(
            date: Date(),
            mantra: "Breathe deeply and trust your journey",
            mood: "calm",
            backgroundImage: bg.imageName,
            textColor: bg.textColor,
            widgetAlignment: bg.alignment
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let sharedDefaults = UserDefaults(suiteName: "group.com.studioeight.mantra")
        let currentDate = Date()
        let calendar = Calendar.current
        
        // Check if there's a pinned entry
        let hasPinnedEntry = sharedDefaults?.bool(forKey: "hasPinnedEntry") ?? false
        
        if hasPinnedEntry {
            // PINNED MODE: Use the pinned entry's specific background
            let mantra = sharedDefaults?.string(forKey: "latestMantra") ?? "How are you feeling today?"
            let mood = sharedDefaults?.string(forKey: "latestMood") ?? "calm"
            let backgroundImage = sharedDefaults?.string(forKey: "widgetBackground") ?? "whisper_bg_crinkledbeige"
            let textColor = sharedDefaults?.string(forKey: "widgetTextColor") ?? "#5B3520"
            let alignmentString = sharedDefaults?.string(forKey: "widgetAlignment") ?? "center"
            
            let entry = SimpleEntry(
                date: currentDate,
                mantra: mantra,
                mood: mood,
                backgroundImage: backgroundImage,
                textColor: textColor,
                widgetAlignment: alignmentFromString(alignmentString)
            )
            
            print("📌 Widget: Pinned mode - showing pinned mantra with its background")
            
            let nextUpdate = calendar.date(byAdding: .hour, value: 1, to: currentDate)!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
            
        } else if let entriesData = sharedDefaults?.data(forKey: "allEntries"),
                  let decodedEntries = try? JSONDecoder().decode([[String: String]].self, from: entriesData),
                  !decodedEntries.isEmpty {
            
            // ROTATION MODE: Single daily background for all entries
            let dailyBackground = WidgetBackground.forToday(date: currentDate)
            
            var timelineEntries: [SimpleEntry] = []
            
            let startOfCurrentHour = calendar.dateComponents([.year, .month, .day, .hour], from: currentDate)
            guard let currentHourDate = calendar.date(from: startOfCurrentHour) else {
                let entry = createPlaceholderEntry(date: currentDate)
                let timeline = Timeline(entries: [entry], policy: .atEnd)
                completion(timeline)
                return
            }
            
            // Generate 24 entries (one for each hour)
            for hourOffset in 0..<24 {
                guard let entryDate = calendar.date(byAdding: .hour, value: hourOffset, to: currentHourDate) else {
                    continue
                }
                
                // Deterministic mantra selection based on hour + day
                let hour = calendar.component(.hour, from: entryDate)
                let dayOfYear = calendar.ordinality(of: .day, in: .year, for: entryDate) ?? 1
                let seed = (hour + dayOfYear)
                let index = seed % decodedEntries.count
                let selectedEntry = decodedEntries[index]
                
                // Mantra and mood from entry, background from daily selection
                let mantra = selectedEntry["mantra"] ?? "How are you feeling today?"
                let mood = selectedEntry["mood"] ?? "calm"
                
                let entry = SimpleEntry(
                    date: entryDate,
                    mantra: mantra,
                    mood: mood,
                    backgroundImage: dailyBackground.imageName,
                    textColor: dailyBackground.textColor,
                    widgetAlignment: dailyBackground.alignment
                )
                
                timelineEntries.append(entry)
            }
            
            print("🔄 Widget: Rotation mode - \(decodedEntries.count) mantras with daily background: \(dailyBackground.imageName)")
            
            let timeline = Timeline(entries: timelineEntries, policy: .atEnd)
            completion(timeline)
            
        } else {
            // NO ENTRIES: Show placeholder with daily background
            print("📱 Widget: No entries available - showing placeholder")
            
            let entry = createPlaceholderEntry(date: currentDate)
            let nextUpdate = calendar.date(byAdding: .hour, value: 1, to: currentDate)!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }
    
    private func createPlaceholderEntry(date: Date) -> SimpleEntry {
        let bg = WidgetBackground.forToday(date: date)
        return SimpleEntry(
            date: date,
            mantra: "How are you feeling today?",
            mood: "calm",
            backgroundImage: bg.imageName,
            textColor: bg.textColor,
            widgetAlignment: bg.alignment,
            isPlaceholder: true
        )
    }
}

// MARK: - Timeline Entry
struct SimpleEntry: TimelineEntry {
    let date: Date
    let mantra: String
    let mood: String
    let backgroundImage: String
    let textColor: String
    let widgetAlignment: Alignment
    var isPlaceholder: Bool = false
}

// MARK: - Helper Functions

/// Clean mantra text — strip quotes and trailing punctuation for clean widget display
func cleanMantraText(_ text: String) -> String {
    var cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
    if cleaned.hasPrefix("\"") && cleaned.hasSuffix("\"") {
        cleaned = String(cleaned.dropFirst().dropLast())
    }
    if cleaned.hasPrefix("'") && cleaned.hasSuffix("'") {
        cleaned = String(cleaned.dropFirst().dropLast())
    }
    let terminal = CharacterSet(charactersIn: ".,;:!?…")
    while let last = cleaned.last, terminal.contains(String(last).unicodeScalars.first!) {
        cleaned = String(cleaned.dropLast())
    }
    return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
}

func alignmentFromString(_ alignmentString: String) -> Alignment {
    switch alignmentString.lowercased() {
    case "top":
        return .top
    case "bottom":
        return .bottom
    default:
        return .center
    }
}

// MARK: - Widget Entry View
struct MantraWidgetEntryView: View {
    var entry: SimpleEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryRectangular:
            // Lock screen - text only, no background image
            VStack(alignment: .center, spacing: 2) {
                Text("Whisper")
                    .font(.system(size: 11, weight: .semibold, design: .serif))
                    .italic()
                    .foregroundColor(.secondary)
                
                Text(cleanMantraText(entry.mantra))
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.primary)
                    .lineLimit(3)
                    .minimumScaleFactor(0.85)
                    .multilineTextAlignment(.center)
                    .lineSpacing(0.5)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .containerBackground(for: .widget) {
                Color.clear
            }
            
        case .accessoryCircular:
            // Journal reminder — tap to open app
            ZStack {
                AccessoryWidgetBackground()
                VStack(spacing: 2) {
                    Image(systemName: "pencil.line")
                        .font(.system(size: 16, weight: .medium))
                    Text("journal")
                        .font(.system(size: 8, weight: .medium, design: .serif))
                }
            }
            .containerBackground(for: .widget) {
                Color.clear
            }
            
        case .accessoryInline:
            HStack(spacing: 4) {
                Text("Whisper:")
                    .font(.system(size: 12, weight: .medium))
                Text(entry.mantra.prefix(30) + (entry.mantra.count > 30 ? "..." : ""))
                    .font(.system(size: 12, weight: .regular))
                    .lineLimit(1)
            }
            
        default:
            // Home screen widgets
            HomeScreenWidget(entry: entry, family: family)
        }
    }
}

// MARK: - Home Screen Widget Router
struct HomeScreenWidget: View {
    let entry: SimpleEntry
    let family: WidgetFamily
    
    var body: some View {
        switch family {
        case .systemSmall:
            WhisperSmallWidget(entry: entry)
        case .systemMedium:
            WhisperMediumWidget(entry: entry)
        case .systemLarge:
            WhisperLargeWidget(entry: entry)
        default:
            WhisperSmallWidget(entry: entry)
        }
    }
}

// MARK: - Small Widget
struct WhisperSmallWidget: View {
    let entry: SimpleEntry

    var body: some View {
        ZStack(alignment: .top) {
            // Logo — top center
            Image("whisper-logo")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(height: 12)
                .foregroundColor(Color(hex: entry.textColor).opacity(0.7))
                .frame(maxWidth: .infinity)
                .padding(.top, 14)

            if entry.isPlaceholder {
                // Placeholder — centered, lighter prompt
                VStack(spacing: 6) {
                    Spacer()
                    Text(entry.mantra)
                        .font(.system(size: 15, weight: .regular, design: .serif))
                        .italic()
                        .foregroundColor(Color(hex: entry.textColor).opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 30)
            } else {
                // Real mantra — bottom left, editorial
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()

                    Text(cleanMantraText(entry.mantra))
                        .font(.system(size: 19, weight: .semibold, design: .serif))
                        .foregroundColor(Color(hex: entry.textColor))
                        .multilineTextAlignment(.leading)
                        .lineLimit(5)
                        .lineSpacing(3)
                        .tracking(-0.3)
                        .minimumScaleFactor(0.55)
                }
                .padding(.leading, 14)
                .padding(.trailing, 12)
                .padding(.bottom, 14)
                .padding(.top, 32)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        .containerBackground(for: .widget) {
            GeometryReader { geometry in
                Image(entry.backgroundImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: entry.widgetAlignment)
                    .clipped()
            }
        }
        .widgetURL(URL(string: "whisper://daily"))
    }
}

// MARK: - Medium Widget
struct WhisperMediumWidget: View {
    let entry: SimpleEntry

    var body: some View {
        ZStack(alignment: .top) {
            // Logo — top center
            Image("whisper-logo")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(height: 14)
                .foregroundColor(Color(hex: entry.textColor).opacity(0.7))
                .frame(maxWidth: .infinity)
                .padding(.top, 14)

            if entry.isPlaceholder {
                // Placeholder — centered, lighter prompt
                VStack(spacing: 6) {
                    Spacer()
                    Text(entry.mantra)
                        .font(.system(size: 18, weight: .regular, design: .serif))
                        .italic()
                        .foregroundColor(Color(hex: entry.textColor).opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                    Spacer()
                }
                .padding(.horizontal, 32)
                .padding(.top, 30)
            } else {
                // Real mantra — bottom left, editorial
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()

                    Text(cleanMantraText(entry.mantra))
                        .font(.system(size: 24, weight: .semibold, design: .serif))
                        .foregroundColor(Color(hex: entry.textColor))
                        .multilineTextAlignment(.leading)
                        .lineLimit(4)
                        .lineSpacing(4)
                        .tracking(-0.3)
                        .minimumScaleFactor(0.55)
                        .padding(.trailing, 20)
                }
                .padding(.leading, 18)
                .padding(.trailing, 14)
                .padding(.bottom, 16)
                .padding(.top, 34)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        .containerBackground(for: .widget) {
            GeometryReader { geometry in
                Image(entry.backgroundImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: entry.widgetAlignment)
                    .clipped()
            }
        }
        .widgetURL(URL(string: "whisper://daily"))
    }
}

// MARK: - Large Widget
struct WhisperLargeWidget: View {
    let entry: SimpleEntry

    var body: some View {
        ZStack(alignment: .top) {
            // Logo — top center
            Image("whisper-logo")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(height: 16)
                .foregroundColor(Color(hex: entry.textColor).opacity(0.7))
                .frame(maxWidth: .infinity)
                .padding(.top, 20)

            if entry.isPlaceholder {
                // Placeholder — centered, lighter prompt
                VStack(spacing: 8) {
                    Spacer()
                    Text(entry.mantra)
                        .font(.system(size: 22, weight: .regular, design: .serif))
                        .italic()
                        .foregroundColor(Color(hex: entry.textColor).opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                    Spacer()
                }
                .padding(.horizontal, 40)
                .padding(.top, 36)
            } else {
                // Real mantra — bottom left, editorial
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()

                    Text(cleanMantraText(entry.mantra))
                        .font(.system(size: 32, weight: .semibold, design: .serif))
                        .foregroundColor(Color(hex: entry.textColor))
                        .multilineTextAlignment(.leading)
                        .lineLimit(8)
                        .lineSpacing(6)
                        .tracking(-0.3)
                        .minimumScaleFactor(0.55)
                        .padding(.trailing, 24)
                }
                .padding(.leading, 22)
                .padding(.trailing, 18)
                .padding(.bottom, 24)
                .padding(.top, 42)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) {
            GeometryReader { geometry in
                Image(entry.backgroundImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: entry.widgetAlignment)
                    .clipped()
            }
        }
        .widgetURL(URL(string: "whisper://daily"))
    }
}

// MARK: - Widget Configuration
struct MantraWidget: Widget {
    let kind: String = "MantraWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MantraWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Whisper")
        .description("Let your journal whisper back to you throughout the day.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .accessoryRectangular,
            .accessoryCircular,
            .accessoryInline
        ])
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255.0
        let g = Double((int >> 8) & 0xFF) / 255.0
        let b = Double(int & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Previews
#Preview(as: .systemSmall) {
    MantraWidget()
} timeline: {
    SimpleEntry(
        date: .now,
        mantra: "You are in the process of discovering your own strength.",
        mood: "hopeful",
        backgroundImage: "whisper_bg_crinkledbeige",
        textColor: "#5B3520",
        widgetAlignment: .center
    )
}

#Preview(as: .systemMedium) {
    MantraWidget()
} timeline: {
    SimpleEntry(
        date: .now,
        mantra: "Every breath is a new beginning, every moment a chance to grow.",
        mood: "calm",
        backgroundImage: "blue_static",
        textColor: "#F9C99D",
        widgetAlignment: .center
    )
}

#Preview(as: .systemLarge) {
    MantraWidget()
} timeline: {
    SimpleEntry(
        date: .now,
        mantra: "Breathe deeply and trust your journey through life's beautiful moments.",
        mood: "reflective",
        backgroundImage: "forest_green",
        textColor: "#C5FFB3",
        widgetAlignment: .center
    )
}
