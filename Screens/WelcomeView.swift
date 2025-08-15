import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct WelcomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject var journalManager = JournalManager.shared
    @State private var userName: String = "Friend"
    @State private var greeting: String = "Good morning"
    @State private var weekDates: [Date] = []
    @State private var selectedWeekDate = Date()
    @State private var currentStreak: Int = 0
    @State private var dailyMantra: String = "Loading your daily inspiration..."
    @State private var isDailyMantraLoading = true

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#FFFCF5").ignoresSafeArea()
                mainContent
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(Color(hex: "#2A2A2A"))
                            .font(.system(size: 20))
                    }
                }
            }
            .navigationBarTitle("", displayMode: .inline)
        }
        .preferredColorScheme(.light)
        .onReceive(journalManager.$entries) { entries in
            // Only calculate streak if we actually have entries loaded
            // This prevents overwriting UserDefaults with 0 during initial load
            print("📦 Entries updated: \(entries.count) total entries")
            print("🔍 ONRECEIVE DEBUG: About to pass \(entries.count) entries to calculateStreak")
            print("🔍 ONRECEIVE DEBUG: First entry mood: \(entries.first?.mood ?? "none")")
            if !entries.isEmpty {
                print("🔄 Calculating streak with loaded entries")
                print("🚨 ENTRIES PARAM: \(entries.map { $0.mood })")
                calculateStreak(with: entries)
            } else {
                print("⏳ Skipping streak calculation - no entries loaded yet")
            }
        }
        .onReceive(journalManager.$isLoading) { isLoading in
            // Calculate streak when loading finishes
            if !isLoading && !journalManager.entries.isEmpty {
                print("🔄 Loading finished, calculating streak")
                calculateStreak(with: journalManager.entries)
            }
        }
    }
    
    var mainContent: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer().frame(height: 20)
                logoSection
                greetingSection
                calendarScrollView
                streakDisplay
                Spacer().frame(height: 30)
                mantraCard
                buttonStack
            }
        }
    }
    
    var logoSection: some View {
        Text("mantra")
            .font(.system(size: 64, weight: .medium, design: .serif))
            .foregroundColor(Color(hex: "#2A2A2A"))
            .padding(.bottom, 30)
    }
    
    var greetingSection: some View {
        Text("\(greeting), \(userName)")
            .font(.system(size: 21, weight: .medium, design: .default))
            .foregroundColor(Color(hex: "#222222"))
            .padding(.bottom, 45)
            .onAppear {
                loadUserName()
                updateGreeting()
                generateWeekDates()
                loadDailyMantra()
                currentStreak = UserDefaults.standard.integer(forKey: "currentStreak")
                print("🏆 Loaded cached streak: \(currentStreak)")
            }
    }
    
    var calendarScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(weekDates, id: \.self) { date in
                    CalendarDayBubble(
                        date: date,
                        entries: entriesForDate(date),
                        isSelected: Calendar.current.isDate(date, inSameDayAs: selectedWeekDate),
                        onTap: { selectedWeekDate = date }
                    )
                }
            }
            .padding(.horizontal, 24)
        }
        .frame(height: 65)
        .padding(.bottom, 27)
    }
    
    var streakDisplay: some View {
        HStack(spacing: 4) {
            Text("🔥").font(.system(size: 13))
            
            if journalManager.isLoading {
                Text("Loading streak...")
                    .font(.system(size: 13, weight: .regular, design: .default))
                    .foregroundColor(Color(hex: "#7A6EFF"))
            } else {
                Text("\(currentStreak)-day streak")
                    .font(.system(size: 13, weight: .regular, design: .default))
                    .foregroundColor(Color(hex: "#7A6EFF"))
            }
        }
        .padding(.bottom, 25)
    }
    
    var mantraCard: some View {
        VStack(spacing: 16) {
            Text("Mantra of the Day")
                .font(.system(size: 18, weight: .semibold, design: .serif))
                .foregroundColor(Color(hex: "#333333"))
            
            mantraContent
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 24)
        .frame(width: UIScreen.main.bounds.width * 0.9)
        .frame(minHeight: 220)
        .background(Color(hex: "#F5F0E8"))
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 4)
        .padding(.bottom, 40)
    }
    
    var mantraContent: some View {
        Group {
            if isDailyMantraLoading {
                HStack(spacing: 8) {
                    ProgressView().scaleEffect(0.8)
                    Text("Loading inspiration...")
                        .font(.system(size: 15, weight: .regular, design: .default))
                        .foregroundColor(Color(hex: "#333333"))
                }
                .frame(minHeight: 80)
            } else {
                Text(dailyMantra)
                    .font(.system(size: 16, weight: .regular, design: .default))
                    .foregroundColor(Color(hex: "#333333"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                    .frame(minHeight: 80)
            }
        }
    }
    
    var buttonStack: some View {
        VStack(spacing: 12) {
            NavigationLink(destination: NewMantraView()) {
                Text("Start New Mantra")
                    .font(.system(size: 16, weight: .semibold, design: .default))
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width * 0.9)
                    .frame(height: 52)
                    .background(Color(hex: "#A6B4FF"))
                    .cornerRadius(18)
            }
            .buttonStyle(PlainButtonStyle())

            NavigationLink(destination: HistoryView()) {
                Text("View History")
                    .font(.system(size: 16, weight: .semibold, design: .default))
                    .foregroundColor(Color(hex: "#222222"))
                    .frame(width: UIScreen.main.bounds.width * 0.9)
                    .frame(height: 52)
                    .background(Color.white)
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(hex: "#A6B4FF"), lineWidth: 1))
                    .cornerRadius(18)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.bottom, 40)
    }
    
    // MARK: - Calendar Functions
    private func generateWeekDates() {
        let calendar = Calendar.current
        let today = Date()
        weekDates = []
        
        for i in -3...3 {
            if let date = calendar.date(byAdding: .day, value: i, to: today) {
                weekDates.append(date)
            }
        }
    }
    
    private func entriesForDate(_ date: Date) -> [JournalEntry] {
        let calendar = Calendar.current
        return journalManager.entries.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    // MARK: - Streak Calculation
    private func calculateStreak(with entries: [JournalEntry]) {
        print("🔍 PARAMETER DEBUG: Received \(entries.count) entries in function parameter")
        print("🔍 PARAMETER DEBUG: First entry: \(entries.first?.mood ?? "none")")
        print("🔍 MANAGER DEBUG: journalManager.entries.count = \(journalManager.entries.count)")
        
        let calendar = Calendar.current
        let today = Date()
        var streak = 0
        
        print("🔥 STREAK DEBUG: Starting streak calculation")
        print("🔍 PARAMETER DEBUG: Received \(entries.count) entries in function parameter")
        print("🔍 PARAMETER DEBUG: First entry: \(entries.first?.mood ?? "none")")
        print("🔍 MANAGER DEBUG: journalManager.entries.count = \(journalManager.entries.count)")
        print("📅 Total entries: \(entries.count)")
        print("📅 Current date: \(today)")
        
        // NEW DEBUG CODE - Check timezone and date handling
        let todayStart = calendar.startOfDay(for: today)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: todayStart)!
        
        print("🗓️ Today (start of day): \(todayStart)")
        print("🗓️ Yesterday (start of day): \(yesterday)")
        print("🕐 Current timezone: \(TimeZone.current.identifier)")
        
        // Check entries for each day specifically
        let todayEntries = entries.filter { calendar.isDate($0.date, inSameDayAs: todayStart) }
        let yesterdayEntries = entries.filter { calendar.isDate($0.date, inSameDayAs: yesterday) }
        
        print("📅 Today's entries: \(todayEntries.count)")
        print("📅 Yesterday's entries: \(yesterdayEntries.count)")
        
        // Show the actual dates of recent entries for comparison
        let sortedEntries = entries.sorted { $0.date > $1.date }
        print("📅 Recent entries with dates:")
        for (index, entry) in sortedEntries.prefix(5).enumerated() {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            formatter.timeZone = TimeZone.current
            print("  Entry \(index + 1): \(formatter.string(from: entry.date)) - \(entry.mood)")
        }
        // END NEW DEBUG CODE
        
        if entries.isEmpty {
            print("❌ No entries found - not overwriting UserDefaults")
            // Don't overwrite UserDefaults during initial load when no entries are present
            return
        }
        
        let todayEntriesCheck = entries.filter { calendar.isDate($0.date, inSameDayAs: today) }
        let hasJournaledToday = !todayEntriesCheck.isEmpty
        
        print("📅 Has journaled today: \(hasJournaledToday)")
        print("📅 Today's entries count: \(todayEntriesCheck.count)")
        
        let startDay = hasJournaledToday ? 0 : 1
        print("📅 Starting from day: -\(startDay)")
        
        for i in startDay...365 {
            guard let checkDate = calendar.date(byAdding: .day, value: -i, to: today) else { break }
            
            let entriesForDay = entries.filter { calendar.isDate($0.date, inSameDayAs: checkDate) }
            
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            print("📆 Day -\(i) (\(formatter.string(from: checkDate))): \(entriesForDay.count) entries")
            
            if entriesForDay.isEmpty {
                print("❌ Found gap on day -\(i), stopping streak count")
                break
            } else {
                streak += 1
                print("✅ Day -\(i) has entries, streak now: \(streak)")
            }
        }
        
        print("🏆 Final calculated streak: \(streak) days")
        print("🏆 Current displayed streak: \(currentStreak)")
        
        if streak != currentStreak {
            print("🏆 Updating streak from \(currentStreak) to \(streak)")
            currentStreak = streak
            UserDefaults.standard.set(streak, forKey: "currentStreak")
            print("💾 Saved streak \(streak) to UserDefaults")
        } else {
            print("🏆 Streak unchanged at \(streak)")
        }
        
        // Force UI update
        DispatchQueue.main.async {
            print("🔄 Force updating UI streak to: \(self.currentStreak)")
        }
    }
    
    // MARK: - Other Functions
    private func loadDailyMantra() {
        let dateKey = getDailyMantraKey()
        
        if let cachedMantra = UserDefaults.standard.string(forKey: "dailyMantra_\(dateKey)") {
            dailyMantra = cachedMantra
            isDailyMantraLoading = false
            return
        }
        
        DailyMantraGenerator.generateDailyMantra(for: Date()) { mantra in
            DispatchQueue.main.async {
                if let mantra = mantra {
                    self.dailyMantra = mantra
                    UserDefaults.standard.set(mantra, forKey: "dailyMantra_\(dateKey)")
                } else {
                    self.dailyMantra = self.getFallbackMantra()
                }
                self.isDailyMantraLoading = false
            }
        }
    }
    
    private func getDailyMantraKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    private func getFallbackMantra() -> String {
        let fallbackMantras = [
            "Today is a new opportunity to grow.",
            "You have everything you need within you.",
            "Small steps forward are still progress.",
            "Trust yourself and take it one moment at a time.",
            "You are capable of more than you realize."
        ]
        
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return fallbackMantras[dayOfYear % fallbackMantras.count]
    }
    
    private func loadUserName() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ No authenticated user")
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { document, error in
            if let error = error {
                print("❌ Error fetching user: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                let data = document.data()
                if let name = data?["name"] as? String {
                    DispatchQueue.main.async {
                        let firstName = name.split(separator: " ").first.map(String.init) ?? name
                        self.userName = firstName
                        print("✅ Loaded user name: \(firstName)")
                    }
                }
            } else {
                print("❌ User document does not exist")
            }
        }
    }
    
    private func updateGreeting() {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 5..<12:
            greeting = "Good morning"
        case 12..<17:
            greeting = "Good afternoon"
        case 17..<22:
            greeting = "Good evening"
        default:
            greeting = "Good night"
        }
    }
}

// MARK: - Calendar Day Bubble Component
struct CalendarDayBubble: View {
    let date: Date
    let entries: [JournalEntry]
    let isSelected: Bool
    let onTap: () -> Void
    
    private var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text(dayName)
                    .font(.system(size: 12, weight: .regular, design: .default))
                    .foregroundColor(Color(hex: "#444444"))
                
                ZStack {
                    Circle()
                        .fill(isSelected ? Color(hex: "#b7b4ff") : Color.clear)
                        .frame(width: 30, height: 30)
                    
                    Text(dayNumber)
                        .font(.system(size: 13, weight: .medium, design: .default))
                        .foregroundColor(isSelected ? .white : Color(hex: "#222222"))
                }
                
                HStack(spacing: 1) {
                    if entries.count > 3 {
                        ForEach(0..<3, id: \.self) { _ in
                            Circle()
                                .fill(Color(hex: "#c7b8ff"))
                                .frame(width: 3, height: 3)
                        }
                        Text("...")
                            .font(.system(size: 8))
                            .foregroundColor(Color(hex: "#c7b8ff"))
                    } else {
                        ForEach(Array(entries.enumerated()), id: \.offset) { _, _ in
                            Circle()
                                .fill(Color(hex: "#c7b8ff"))
                                .frame(width: 3, height: 3)
                        }
                        ForEach(0..<(3 - entries.count), id: \.self) { _ in
                            Circle()
                                .fill(Color.clear)
                                .frame(width: 3, height: 3)
                        }
                    }
                }
                .frame(height: 6)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .frame(width: 40)
    }
}

// MARK: - Daily Mantra Generator
struct DailyMantraGenerator {
    static func generateDailyMantra(for date: Date, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            completion(nil)
            return
        }
        
        let systemPrompt = """
        You are a wise teacher who creates grounding daily mantras. Write mantras that feel real, honest, and centered - not fluffy motivation. Focus on inner alignment, patience, presence, and authentic growth. Keep it under 8 words. Avoid numbers, achievements, or external goals. Think Buddhist wisdom meets practical life guidance.
        """
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        let dayName = formatter.string(from: date)
        
        let userPrompt = """
        Create a grounding mantra for \(dayName) that helps someone feel centered and aligned. Focus on inner peace, patience, or presence - not achievement or motivation.
        """
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userPrompt]
            ],
            "temperature": 0.6,
            "max_tokens": 25
        ]
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(Secrets.openAIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Daily mantra API error: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data else {
                completion(nil)
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    completion(content.trimmingCharacters(in: .whitespacesAndNewlines))
                } else {
                    completion(nil)
                }
            } catch {
                completion(nil)
            }
        }.resume()
    }
}
