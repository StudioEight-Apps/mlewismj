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
   
   // Name prompt banner states
   @State private var hasSeenNamePrompt = UserDefaults.standard.bool(forKey: "hasSeenNamePrompt")
   @State private var showNamePrompt = false

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
           if !entries.isEmpty {
               calculateStreak(with: entries)
           }
       }
       .onReceive(journalManager.$isLoading) { isLoading in
           if !isLoading && !journalManager.entries.isEmpty {
               calculateStreak(with: journalManager.entries)
           }
       }
   }
   
   var mainContent: some View {
       ScrollView {
           VStack(spacing: 0) {
               // Name prompt banner - appears at top when needed
               if showNamePrompt {
                   namePromptBanner
               }
               
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
   
   var namePromptBanner: some View {
       HStack {
           VStack(alignment: .leading, spacing: 4) {
               Text("Personalize your greetings")
                   .font(.system(size: 14, weight: .semibold))
                   .foregroundColor(Color(hex: "#2A2A2A"))
               
               Text("Add your name in Settings for a personal touch")
                   .font(.system(size: 12, weight: .regular))
                   .foregroundColor(Color(hex: "#5B5564"))
           }
           
           Spacer()
           
           Button(action: dismissNamePrompt) {
               Image(systemName: "xmark")
                   .font(.system(size: 12, weight: .medium))
                   .foregroundColor(Color(hex: "#5B5564"))
                   .frame(width: 20, height: 20)
           }
       }
       .padding(.horizontal, 16)
       .padding(.vertical, 12)
       .background(Color(hex: "#A6B4FF").opacity(0.1))
       .overlay(
           RoundedRectangle(cornerRadius: 8)
               .stroke(Color(hex: "#A6B4FF").opacity(0.3), lineWidth: 1)
       )
       .cornerRadius(8)
       .padding(.horizontal, 20)
       .padding(.bottom, 10)
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
               
               // Check if we should show name prompt
               if userName == "Friend" && !hasSeenNamePrompt {
                   showNamePrompt = true
               }
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
   
   // MARK: - Name Prompt Functions
   
   private func dismissNamePrompt() {
       UserDefaults.standard.set(true, forKey: "hasSeenNamePrompt")
       hasSeenNamePrompt = true
       showNamePrompt = false
   }
   
   // MARK: - Existing Functions
   
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
   
   private func calculateStreak(with entries: [JournalEntry]) {
       let calendar = Calendar.current
       let today = Date()
       var streak = 0
       
       if entries.isEmpty {
           return
       }
       
       let todayEntriesCheck = entries.filter { calendar.isDate($0.date, inSameDayAs: today) }
       let hasJournaledToday = !todayEntriesCheck.isEmpty
       let startDay = hasJournaledToday ? 0 : 1
       
       for i in startDay...365 {
           guard let checkDate = calendar.date(byAdding: .day, value: -i, to: today) else { break }
           let entriesForDay = entries.filter { calendar.isDate($0.date, inSameDayAs: checkDate) }
           
           if entriesForDay.isEmpty {
               break
           } else {
               streak += 1
           }
       }
       
       if streak != currentStreak {
           currentStreak = streak
           UserDefaults.standard.set(streak, forKey: "currentStreak")
       }
   }
   
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
       guard let userId = Auth.auth().currentUser?.uid else { return }
       
       let db = Firestore.firestore()
       db.collection("users").document(userId).getDocument { document, error in
           if let document = document, document.exists,
              let data = document.data(),
              let name = data["name"] as? String {
               DispatchQueue.main.async {
                   let firstName = name.split(separator: " ").first.map(String.init) ?? name
                   self.userName = firstName
                   
                   // Re-check name prompt after loading user name
                   if self.userName == "Friend" && !self.hasSeenNamePrompt {
                       self.showNamePrompt = true
                   }
               }
           }
       }
   }
   
   private func updateGreeting() {
       let hour = Calendar.current.component(.hour, from: Date())
       
       switch hour {
       case 5..<12: greeting = "Good morning"
       case 12..<17: greeting = "Good afternoon"
       case 17..<22: greeting = "Good evening"
       default: greeting = "Good night"
       }
   }
}

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

struct DailyMantraGenerator {
   static func generateDailyMantra(for date: Date, completion: @escaping (String?) -> Void) {
       SecureAPIManager.shared.getOpenAIAPIKey { apiKey in
           guard let apiKey = apiKey else {
               completion(nil)
               return
           }
           
           guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
               completion(nil)
               return
           }
           
           let systemPrompt = """
           You are Steady Friend. Write one short morning mantra that feels like wisdom from an understanding friend.
           
           Orientation: life-maxxing, potential-maxxing, present awareness; gratitude for this era and its tools. 
           Tone: grounded, slightly stoic, optimistic; best-friend energy, not macho. 
           Form: exactly one complete sentence, 12 words or fewer. 
           Punctuation allowed: periods, commas, semicolons only. Never: dashes, ellipses, quotes, exclamation points, question marks. 
           Standards: never suggest quitting or lowering standards; emphasize agency, discipline, craft, curiosity. 
           Language: concrete and actionable; avoid clichés, abstraction, and therapy jargon. 
           Time rule: never mention weekdays or calendar dates; "today" is allowed. 
           Banned words: gentle, tonight, soothe, comfort, grace, required, really, very, just, simply, must, kinda, manifest, universe, vibes, embrace, journey. 
           Mood rules: if sadness/grief/heartbreak/purposelessness, validate worth and presence; no productivity framing. 
           Continuity: if journal context is provided, reflect it implicitly while keeping the morning orientation. 
           Anchors: You now know what is not working; adjust course. Do what you can today; progress follows. 
           
           Output: return exactly one line that obeys every rule above.
           """
           
           let userPrompt = "Write one morning mantra. Return one line only."
           
           let requestBody: [String: Any] = [
               "model": "gpt-4o",
               "messages": [
                   ["role": "system", "content": systemPrompt],
                   ["role": "user", "content": userPrompt]
               ],
               "temperature": 0.6,
               "max_tokens": 25
           ]

           var request = URLRequest(url: url)
           request.httpMethod = "POST"
           request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
           request.setValue("application/json", forHTTPHeaderField: "Content-Type")

           do {
               request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
           } catch {
               completion(nil)
               return
           }

           URLSession.shared.dataTask(with: request) { data, response, error in
               if let error = error {
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
}
