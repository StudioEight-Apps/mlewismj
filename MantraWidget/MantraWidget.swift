import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), mantra: "Your daily whisper will appear here", mood: "calm")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), mantra: "Breathe deeply and trust your journey", mood: "calm")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let sharedDefaults = UserDefaults(suiteName: "group.com.studioeight.mantra")
        let mantra = sharedDefaults?.string(forKey: "latestMantra") ?? "How are you feeling today?"
        let mood = sharedDefaults?.string(forKey: "latestMood") ?? "calm"
        let lastUpdated = sharedDefaults?.object(forKey: "lastUpdated") as? Date
        
        print("🔄 Widget Timeline Request:")
        print("   App Group: group.com.studioeight.mantra")
        print("   Mantra: \(mantra)")
        print("   Mood: \(mood)")
        print("   Last Updated: \(lastUpdated?.formatted() ?? "never")")
        
        let currentDate = Date()
        let entry = SimpleEntry(date: currentDate, mantra: mantra, mood: mood)
        
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let mantra: String
    let mood: String
}

struct MantraWidgetEntryView: View {
    var entry: SimpleEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryRectangular:
            // Lock screen - text only for reliability
            VStack(spacing: 2) {
                Text("whisper")
                    .font(.system(size: 10, weight: .medium, design: .serif))
                    .italic()
                    .foregroundColor(.primary)
                
                Text(entry.mantra)
                    .font(.system(size: 11, weight: .regular))
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .containerBackground(for: .widget) {
                Color.clear
            }
            
        case .accessoryCircular:
            VStack(spacing: 1) {
                Text("W")
                    .font(.system(size: 20, weight: .bold, design: .serif))
                    .italic()
                Text("whisper")
                    .font(.system(size: 6, weight: .medium))
            }
            .containerBackground(for: .widget) {
                Color.clear
            }
            
        case .accessoryInline:
            HStack(spacing: 4) {
                Text("whisper:")
                    .font(.system(size: 12, weight: .medium, design: .serif))
                    .italic()
                Text(entry.mantra.prefix(30) + (entry.mantra.count > 30 ? "..." : ""))
                    .font(.system(size: 12, weight: .regular))
                    .lineLimit(1)
            }
            
        default:
            // Home screen widgets - back to beige background
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
        VStack(spacing: 8) {
            // Use your actual logo assets
            Group {
                if Bundle.main.url(forResource: "Whisper App Tranny Logo", withExtension: "png") != nil {
                    Image("Whisper App Tranny Logo")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.black)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 55, height: 18)
                } else if Bundle.main.url(forResource: "WhisperLogo_Beige", withExtension: "png") != nil {
                    Image("WhisperLogo_Beige")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.black)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 55, height: 18)
                } else {
                    Text("whisper")
                        .font(.system(size: 14, weight: .medium, design: .serif))
                        .italic()
                        .foregroundColor(.black)
                        .frame(height: 18)
                }
            }
            
            Text(entry.mantra)
                .font(.system(size: 10, weight: .regular))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineLimit(5) // Conservative
                .minimumScaleFactor(0.7)
                .frame(maxHeight: 65) // Prevent overflow
            
            Spacer(minLength: 0)
            
            HStack {
                Text(entry.date.formatted(date: .omitted, time: .shortened))
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(.black)
                    .opacity(0.6)
                    .lineLimit(1)
                
                Spacer()
                
                Text(entry.mood.uppercased())
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(.black)
                    .opacity(0.6)
                    .lineLimit(1)
            }
            .frame(height: 12)
        }
        .padding(10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color(hex: "#F6EFE6")
                .ignoresSafeArea(.all) // Ensure full coverage
        )
        .containerBackground(Color(hex: "#F6EFE6"), for: .widget)
        .widgetURL(URL(string: "whisper://daily"))
    }
}

struct WhisperMediumWidget: View {
    let entry: SimpleEntry
    
    var body: some View {
        VStack(spacing: 10) {
            // Logo with conservative sizing
            Group {
                if Bundle.main.url(forResource: "WhisperLogo_Black", withExtension: "png") != nil {
                    Image("WhisperLogo_Black")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.black)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 70, height: 22) // Fixed dimensions
                } else {
                    Text("whisper")
                        .font(.system(size: 18, weight: .medium, design: .serif))
                        .italic()
                        .foregroundColor(.black)
                        .frame(height: 22)
                }
            }
            
            Text(entry.mantra)
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineLimit(5) // Conservative for medium
                .minimumScaleFactor(0.7)
                .frame(maxHeight: 75)
            
            Spacer(minLength: 0)
            
            HStack {
                Text(entry.date.formatted(date: .omitted, time: .shortened))
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.black)
                    .opacity(0.6)
                    .lineLimit(1)
                
                Spacer()
                
                Text(entry.mood.uppercased())
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.black)
                    .opacity(0.6)
                    .lineLimit(1)
            }
            .frame(height: 14)
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color(hex: "#F6EFE6")
                .ignoresSafeArea(.all)
        )
        .containerBackground(Color(hex: "#F6EFE6"), for: .widget)
        .widgetURL(URL(string: "whisper://daily"))
    }
}

struct WhisperLargeWidget: View {
    let entry: SimpleEntry
    
    var body: some View {
        VStack(spacing: 16) {
            // Logo with conservative sizing
            Group {
                if Bundle.main.url(forResource: "WhisperLogo_Black", withExtension: "png") != nil {
                    Image("WhisperLogo_Black")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.black)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 85, height: 28) // Fixed for large
                } else {
                    Text("whisper")
                        .font(.system(size: 22, weight: .medium, design: .serif))
                        .italic()
                        .foregroundColor(.black)
                        .frame(height: 28)
                }
            }
            
            Text(entry.mantra)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineLimit(10) // More room in large widget
                .minimumScaleFactor(0.7)
                .frame(maxHeight: 140)
            
            Spacer(minLength: 0)
            
            HStack {
                Text(entry.date.formatted(date: .omitted, time: .shortened))
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.black)
                    .opacity(0.6)
                    .lineLimit(1)
                
                Spacer()
                
                Text(entry.mood.uppercased())
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.black)
                    .opacity(0.6)
                    .lineLimit(1)
            }
            .frame(height: 16)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color(hex: "#F6EFE6")
                .ignoresSafeArea(.all)
        )
        .containerBackground(Color(hex: "#F6EFE6"), for: .widget)
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
    SimpleEntry(date: .now, mantra: "Create space for your feelings, then choose peace for your heart.", mood: "calm")
}

#Preview(as: .systemMedium) {
    MantraWidget()
} timeline: {
    SimpleEntry(date: .now, mantra: "Every breath is a new beginning, every moment a chance to grow.", mood: "hopeful")
}

#Preview(as: .systemLarge) {
    MantraWidget()
} timeline: {
    SimpleEntry(date: .now, mantra: "Breathe deeply and trust your journey through life's beautiful moments and challenges that shape who you become.", mood: "reflective")
}
