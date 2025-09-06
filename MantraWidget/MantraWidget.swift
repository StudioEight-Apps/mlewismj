import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), mantra: "Your daily mantra will appear here", mood: "calm")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), mantra: "Breathe deeply and trust your journey", mood: "calm")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        // Get mantra from App Group UserDefaults - Updated for Studio Eight LLC
        let sharedDefaults = UserDefaults(suiteName: "group.com.studioeight.mantra")
        let mantra = sharedDefaults?.string(forKey: "latestMantra") ?? "How are you feeling today?"
        let mood = sharedDefaults?.string(forKey: "latestMood") ?? "calm"
        let lastUpdated = sharedDefaults?.object(forKey: "lastUpdated") as? Date
        
        // Debug logging
        print("📱 Widget Timeline Request:")
        print("   App Group: group.com.studioeight.mantra")
        print("   Mantra: \(mantra)")
        print("   Mood: \(mood)")
        print("   Last Updated: \(lastUpdated?.formatted() ?? "never")")
        
        let currentDate = Date()
        let entry = SimpleEntry(date: currentDate, mantra: mantra, mood: mood)
        
        // Update every hour
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
            // Lock screen rectangular widget - adaptive sizing
            VStack(spacing: adaptiveSpacing(for: entry.mantra)) {
                // Smaller "mantra" text to save space
                Text("mantra")
                    .font(.system(size: 10, weight: .semibold, design: .serif))
                
                // Mantra text with adaptive sizing based on length
                Text(entry.mantra)
                    .font(.system(size: adaptiveFontSize(for: entry.mantra), weight: .regular))
                    .lineLimit(adaptiveLineLimit(for: entry.mantra))
                    .minimumScaleFactor(0.7)
                    .multilineTextAlignment(adaptiveAlignment(for: entry.mantra))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .containerBackground(for: .widget) {
                Color.clear
            }
            
        case .accessoryCircular:
            // Simple circular widget
            VStack(spacing: 1) {
                Text("M")
                    .font(.system(size: 20, weight: .bold, design: .serif))
                
                Text("mantra")
                    .font(.system(size: 6, weight: .medium))
            }
            .containerBackground(for: .widget) {
                Color.clear
            }
            
        case .accessoryInline:
            // Simple inline widget - text only
            HStack(spacing: 4) {
                Text("mantra:")
                    .font(.system(size: 12, weight: .medium, design: .serif))
                
                Text(entry.mantra.prefix(30) + (entry.mantra.count > 30 ? "..." : ""))
                    .font(.system(size: 12, weight: .regular))
                    .lineLimit(1)
            }
            
        default:
            // Home screen widgets with your exact brand colors
            HomeScreenWidget(entry: entry, family: family)
        }
    }
    
    private func getMoodEmoji(_ mood: String) -> String {
        switch mood.lowercased() {
        case "happy", "joyful", "excited": return "😊"
        case "calm", "peaceful", "relaxed": return "😌"
        case "anxious", "stressed", "overwhelmed": return "😰"
        case "sad", "lonely", "down": return "😢"
        case "angry", "frustrated", "irritated": return "😤"
        case "grateful", "blessed": return "🙏"
        case "motivated", "determined": return "💪"
        case "confused", "uncertain": return "🤔"
        case "hopeful": return "🌟"
        case "content": return "☺️"
        case "reflective": return "🤔"
        case "tired": return "😴"
        case "insecure": return "😟"
        case "fine": return "😐"
        default: return "✨"
        }
    }
    
    // MARK: - Adaptive Sizing Functions for Lock Screen
    private func adaptiveFontSize(for mantra: String) -> CGFloat {
        let charCount = mantra.count
        switch charCount {
        case 0...40:
            return 13  // Large font for short mantras
        case 41...80:
            return 11  // Medium font for medium mantras
        default:
            return 10  // Small font for long mantras
        }
    }
    
    private func adaptiveLineLimit(for mantra: String) -> Int {
        let charCount = mantra.count
        switch charCount {
        case 0...40:
            return 2   // Short mantras don't need many lines
        case 41...80:
            return 2   // Medium mantras get 2 lines
        default:
            return 3   // Long mantras get maximum lines
        }
    }
    
    private func adaptiveSpacing(for mantra: String) -> CGFloat {
        let charCount = mantra.count
        switch charCount {
        case 0...40:
            return 3   // More spacing for short mantras (more breathing room)
        case 41...80:
            return 2   // Medium spacing
        default:
            return 1   // Tight spacing for long mantras
        }
    }
    
    private func adaptiveAlignment(for mantra: String) -> TextAlignment {
        let charCount = mantra.count
        return charCount <= 40 ? .center : .leading
    }
}

// MARK: - Home Screen Widgets (Your Exact Brand Colors)
struct HomeScreenWidget: View {
    let entry: SimpleEntry
    let family: WidgetFamily
    
    var body: some View {
        switch family {
        case .systemSmall:
            MantraSmallWidget(entry: entry)
        case .systemMedium:
            MantraMediumWidget(entry: entry)
        case .systemLarge:
            MantraLargeWidget(entry: entry)
        default:
            MantraSmallWidget(entry: entry)
        }
    }
}

struct MantraSmallWidget: View {
    let entry: SimpleEntry
    
    var body: some View {
        VStack(spacing: 12) {
            // Centered "mantra" text logo at top - matching your app exactly
            Text("mantra")
                .font(.system(size: 18, weight: .semibold, design: .serif))
                .foregroundColor(Color(hex: "#2A2A2A"))
            
            // Mantra text - let it expand naturally
            Text(entry.mantra)
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(Color(hex: "#2A2A2A"))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(nil)
            
            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "#FFFCF5"))
        .containerBackground(Color(hex: "#FFFCF5"), for: .widget)
        .widgetURL(URL(string: "mantra://daily"))
    }
}

struct MantraMediumWidget: View {
    let entry: SimpleEntry
    
    var body: some View {
        VStack(spacing: 16) {
            // Centered "mantra" text logo at top - matching your app exactly
            Text("mantra")
                .font(.system(size: 22, weight: .semibold, design: .serif))
                .foregroundColor(Color(hex: "#2A2A2A"))
            
            // Mantra text - let it expand naturally in available space
            Text(entry.mantra)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(Color(hex: "#2A2A2A"))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(nil)
            
            Spacer(minLength: 0)
            
            // Time indicator in bottom right
            HStack {
                Spacer()
                Text(entry.date.formatted(date: .omitted, time: .shortened))
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(Color(hex: "#2A2A2A"))
                    .opacity(0.4)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "#FFFCF5"))
        .containerBackground(Color(hex: "#FFFCF5"), for: .widget)
        .widgetURL(URL(string: "mantra://daily"))
    }
}

struct MantraLargeWidget: View {
    let entry: SimpleEntry
    
    var body: some View {
        VStack(spacing: 20) {
            // Centered "mantra" text logo at top - matching your app exactly
            Text("mantra")
                .font(.system(size: 28, weight: .semibold, design: .serif))
                .foregroundColor(Color(hex: "#2A2A2A"))
            
            // Main mantra text underneath, centered - plenty of lines
            VStack(spacing: 16) {
                Text(entry.mantra)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color(hex: "#2A2A2A"))
                    .multilineTextAlignment(.center)
                    .lineLimit(15)
                    .minimumScaleFactor(0.8)
                
                // Subtle decorative line in your soft purple
                Rectangle()
                    .fill(Color(hex: "#A6B4FF"))
                    .frame(width: 50, height: 2)
                    .cornerRadius(1)
            }
            
            Spacer()
            
            // Bottom section with date - minimal
            HStack {
                Spacer()
                Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(Color(hex: "#2A2A2A"))
                    .opacity(0.4)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "#FFFCF5"))
        .containerBackground(Color(hex: "#FFFCF5"), for: .widget)
        .widgetURL(URL(string: "mantra://daily"))
    }
}

struct MantraWidget: Widget {
    let kind: String = "MantraWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MantraWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Daily Mantra")
        .description("Your personalized daily mantra from your journal reflections.")
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

// Color extension for hex colors - matching your existing Color+Hex.swift
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
    SimpleEntry(date: .now, mantra: "In stillness, find your strength and let wisdom guide your way.", mood: "calm")
    SimpleEntry(date: .now, mantra: "Every breath is a new beginning, every moment a chance to grow.", mood: "hopeful")
}

#Preview(as: .accessoryRectangular) {
    MantraWidget()
} timeline: {
    SimpleEntry(date: .now, mantra: "Breathe deeply and trust your journey through life's beautiful moments", mood: "calm")
}
