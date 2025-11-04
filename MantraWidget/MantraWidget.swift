import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            mantra: "Your daily whisper will appear here",
            mood: "calm",
            backgroundImage: "whisper_bg_crinkledbeige",
            textColor: "#5B3520"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(
            date: Date(),
            mantra: "Breathe deeply and trust your journey",
            mood: "calm",
            backgroundImage: "whisper_bg_crinkledbeige",
            textColor: "#5B3520"
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let sharedDefaults = UserDefaults(suiteName: "group.com.studioeight.mantra")
        let mantra = sharedDefaults?.string(forKey: "latestMantra") ?? "How are you feeling today?"
        let mood = sharedDefaults?.string(forKey: "latestMood") ?? "calm"
        let backgroundImage = sharedDefaults?.string(forKey: "widgetBackground") ?? "whisper_bg_crinkledbeige"
        let textColor = sharedDefaults?.string(forKey: "widgetTextColor") ?? "#5B3520"
        let lastUpdated = sharedDefaults?.object(forKey: "lastUpdated") as? Date
        
        print("🔄 Widget Timeline Request:")
        print("   App Group: group.com.studioeight.mantra")
        print("   Mantra: \(mantra)")
        print("   Mood: \(mood)")
        print("   Background: \(backgroundImage)")
        print("   Text Color: \(textColor)")
        print("   Last Updated: \(lastUpdated?.formatted() ?? "never")")
        
        let currentDate = Date()
        let entry = SimpleEntry(
            date: currentDate,
            mantra: mantra,
            mood: mood,
            backgroundImage: backgroundImage,
            textColor: textColor
        )
        
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let mantra: String
    let mood: String
    let backgroundImage: String
    let textColor: String
}

struct MantraWidgetEntryView: View {
    var entry: SimpleEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryRectangular:
            // Lock screen - text logo (safe), centered layout
            VStack(alignment: .center, spacing: 2) {
                // Whisper text logo - centered, styled
                Text("whisper")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.secondary)
                    .tracking(0.5)
                
                // Main text - 3 lines, center-aligned
                Text(entry.mantra)
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
            VStack(spacing: 1) {
                Text("W")
                    .font(.system(size: 20, weight: .semibold))
                Text("whisper")
                    .font(.system(size: 6, weight: .medium))
            }
            .containerBackground(for: .widget) {
                Color.clear
            }
            
        case .accessoryInline:
            HStack(spacing: 4) {
                Text("whisper:")
                    .font(.system(size: 12, weight: .medium))
                Text(entry.mantra.prefix(30) + (entry.mantra.count > 30 ? "..." : ""))
                    .font(.system(size: 12, weight: .regular))
                    .lineLimit(1)
            }
            
        default:
            // Home screen widgets - Co—Star inspired dark design
            HomeScreenWidget(entry: entry, family: family)
        }
    }
}

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

struct WhisperSmallWidget: View {
    let entry: SimpleEntry
    
    var body: some View {
        VStack(spacing: 0) {
            // Top section with logo
            HStack {
                Spacer()
                Image("whisper-logo")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 14)
                    .foregroundColor(Color(hex: entry.textColor))
                    .accessibilityLabel("Whisper")
                Spacer()
            }
            .padding(.top, 12)
            .padding(.bottom, 8)
            
            // Main content area
            VStack(spacing: 0) {
                Spacer()
                
                Text(entry.mantra)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color(hex: entry.textColor))
                    .multilineTextAlignment(.center)
                    .lineLimit(6)
                    .minimumScaleFactor(0.8)
                    .padding(.horizontal, 4)
                
                Spacer()
                
                // Bottom metadata
                HStack {
                    Text(entry.date.formatted(date: .omitted, time: .shortened))
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(Color(hex: entry.textColor))
                        .opacity(0.6)
                    
                    Spacer()
                    
                    Text(entry.mood.uppercased())
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(Color(hex: entry.textColor))
                        .opacity(0.6)
                }
                .padding(.bottom, 12)
                .padding(.horizontal, 12)
            }
        }
        .containerBackground(for: .widget) {
            Image(entry.backgroundImage)
                .resizable()
                .scaledToFill()
        }
        .widgetURL(URL(string: "whisper://daily"))
    }
}

struct WhisperMediumWidget: View {
    let entry: SimpleEntry
    
    var body: some View {
        VStack(spacing: 0) {
            // Top section with logo
            HStack {
                Spacer()
                Image("whisper-logo")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 16)
                    .foregroundColor(Color(hex: entry.textColor))
                    .accessibilityLabel("Whisper")
                Spacer()
            }
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            // Main content area
            VStack(spacing: 0) {
                Spacer()
                
                Text(entry.mantra)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Color(hex: entry.textColor))
                    .multilineTextAlignment(.center)
                    .lineLimit(5)
                    .minimumScaleFactor(0.8)
                    .padding(.horizontal, 8)
                
                Spacer()
                
                // Bottom metadata
                HStack {
                    Text(entry.date.formatted(date: .omitted, time: .shortened))
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color(hex: entry.textColor))
                        .opacity(0.6)
                    
                    Spacer()
                    
                    Text(entry.mood.uppercased())
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color(hex: entry.textColor))
                        .opacity(0.6)
                }
                .padding(.bottom, 16)
                .padding(.horizontal, 16)
            }
        }
        .containerBackground(for: .widget) {
            Image(entry.backgroundImage)
                .resizable()
                .scaledToFill()
        }
        .widgetURL(URL(string: "whisper://daily"))
    }
}

struct WhisperLargeWidget: View {
    let entry: SimpleEntry
    
    var body: some View {
        VStack(spacing: 0) {
            // Top section with logo
            HStack {
                Spacer()
                Image("whisper-logo")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 18)
                    .foregroundColor(Color(hex: entry.textColor))
                    .accessibilityLabel("Whisper")
                Spacer()
            }
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            // Main content area
            VStack(spacing: 0) {
                Spacer()
                
                Text(entry.mantra)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(Color(hex: entry.textColor))
                    .multilineTextAlignment(.center)
                    .lineLimit(8)
                    .minimumScaleFactor(0.8)
                    .padding(.horizontal, 12)
                
                Spacer()
                
                // Bottom metadata
                HStack {
                    Text(entry.date.formatted(date: .omitted, time: .shortened))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(hex: entry.textColor))
                        .opacity(0.6)
                    
                    Spacer()
                    
                    Text(entry.mood.uppercased())
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(hex: entry.textColor))
                        .opacity(0.6)
                }
                .padding(.bottom, 20)
                .padding(.horizontal, 20)
            }
        }
        .containerBackground(for: .widget) {
            Image(entry.backgroundImage)
                .resizable()
                .scaledToFill()
        }
        .widgetURL(URL(string: "whisper://daily"))
    }
}

struct MantraWidget: Widget {
    let kind: String = "MantraWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MantraWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Whisper")
        .description("Your personalized whisper from your journal reflections.")
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

#Preview(as: .systemSmall) {
    MantraWidget()
} timeline: {
    SimpleEntry(
        date: .now,
        mantra: "Create space for your feelings, then choose peace for your heart.",
        mood: "calm",
        backgroundImage: "whisper_bg_crinkledbeige",
        textColor: "#5B3520"
    )
}

#Preview(as: .systemMedium) {
    MantraWidget()
} timeline: {
    SimpleEntry(
        date: .now,
        mantra: "Every breath is a new beginning, every moment a chance to grow.",
        mood: "hopeful",
        backgroundImage: "blue_static",
        textColor: "#F9C99D"
    )
}

#Preview(as: .systemLarge) {
    MantraWidget()
} timeline: {
    SimpleEntry(
        date: .now,
        mantra: "Breathe deeply and trust your journey through life's beautiful moments and challenges that shape who you become.",
        mood: "reflective",
        backgroundImage: "forest_green",
        textColor: "#C5FFB3"
    )
}
