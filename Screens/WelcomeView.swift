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
   @State private var dailyWhisper: String = "Loading your daily whisper..."
   @State private var isDailyWhisperLoading = true
   @State private var cardScale: CGFloat = 0.98
   @State private var whisperOpacity: Double = 0
   
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
               if showNamePrompt {
                   namePromptBanner
               }
               
               Spacer().frame(height: 5)
               logoSection
               greetingSection
               calendarScrollView
               streakDisplay
               Spacer().frame(height: 30)
               whisperCard
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
       Image("whisper-logo")
           .resizable()
           .scaledToFit()
           .frame(maxWidth: 135)
           .accessibilityLabel("Whisper")
           .background(Color.clear)
           .padding(.top, 0)
           .padding(.bottom, 20)
   }
   
   var greetingSection: some View {
       Text("\(greeting), \(userName)")
           .font(.system(size: 21, weight: .medium))
           .foregroundColor(Color(hex: "#222222"))
           .padding(.bottom, 30)
           .onAppear {
               loadUserName()
               updateGreeting()
               generateWeekDates()
               loadDailyWhisper()
               currentStreak = UserDefaults.standard.integer(forKey: "currentStreak")
               
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
       HStack(spacing: 6) {
           Text("🔥").font(.system(size: 13))
           
           if journalManager.isLoading {
               Text("Loading streak...")
                   .font(.system(size: 13, weight: .medium))
                   .foregroundColor(Color(hex: "#7A6EFF"))
           } else {
               Text("\(currentStreak)-day streak")
                   .font(.system(size: 13, weight: .medium))
                   .foregroundColor(Color(hex: "#7A6EFF"))
           }
       }
       .padding(.horizontal, 12)
       .padding(.vertical, 6)
       .background(Color(hex: "#A6B4FF").opacity(0.12))
       .cornerRadius(20)
       .padding(.bottom, 25)
   }
   
   var whisperCard: some View {
       ZStack(alignment: .bottomTrailing) {
           VStack(spacing: 0) {
               Text(Date().formatted(.dateTime.month(.twoDigits).day(.twoDigits).year()))
                   .font(.system(size: 12, weight: .medium))
                   .tracking(0.5)
                   .foregroundColor(Color(hex: "#6A6A6A"))
                   .multilineTextAlignment(.center)
                   .padding(.bottom, 16)
               
               whisperContent
           }
           .padding(.top, 24)
           .padding(.horizontal, 24)
           .padding(.bottom, 28)
           .frame(width: UIScreen.main.bounds.width * 0.9)
           .frame(minHeight: 200)
           .background(Color(hex: "#F5F0E8"))
           .overlay(
               RoundedRectangle(cornerRadius: 18)
                   .stroke(Color(hex: "#E9E2D6"), lineWidth: 1)
           )
           .cornerRadius(18)
           .shadow(color: Color.black.opacity(0.10), radius: 12, x: 0, y: 6)
           .scaleEffect(cardScale)
           
           WhisperShareButton(
               isEnabled: !isDailyWhisperLoading && !dailyWhisper.isEmpty,
               action: shareWhisper
           )
           .offset(x: -16, y: -16)
       }
       .padding(.bottom, 48)
       .onAppear {
           withAnimation(.easeOut(duration: 0.2)) {
               cardScale = 1.0
           }
           withAnimation(.easeOut(duration: 0.18).delay(0.1)) {
               whisperOpacity = 1.0
           }
       }
   }
   
   var whisperContent: some View {
       Group {
           if isDailyWhisperLoading {
               HStack(spacing: 8) {
                   ProgressView().scaleEffect(0.8)
                   Text("Loading whisper...")
                       .font(.system(size: 15, weight: .regular))
                       .foregroundColor(Color(hex: "#6A6A6A"))
               }
               .frame(minHeight: 80)
           } else {
               Text(dailyWhisper)
                   .font(.system(size: 21, weight: .semibold, design: .serif))
                   .foregroundColor(Color(hex: "#2B2B2B"))
                   .multilineTextAlignment(.center)
                   .lineSpacing(6)
                   .tracking(-0.2)
                   .lineLimit(3)
                   .padding(.horizontal, 20)
                   .padding(.bottom, 20)
                   .frame(minHeight: 80)
                   .opacity(whisperOpacity)
           }
       }
   }
   
   var buttonStack: some View {
       VStack(spacing: 12) {
           NavigationLink(destination: NewMantraView()) {
               Text("Start Journaling")
                   .font(.system(size: 17, weight: .semibold))
                   .foregroundColor(.white)
                   .frame(width: UIScreen.main.bounds.width * 0.9)
                   .frame(height: 52)
                   .background(Color(hex: "#A6B4FF"))
                   .cornerRadius(18)
                   .shadow(color: Color.black.opacity(0.10), radius: 10, x: 0, y: 4)
           }
           .buttonStyle(PlainButtonStyle())

           NavigationLink(destination: HistoryView()) {
               Text("View History")
                   .font(.system(size: 17, weight: .semibold))
                   .foregroundColor(Color(hex: "#222222"))
                   .frame(width: UIScreen.main.bounds.width * 0.9)
                   .frame(height: 52)
                   .background(Color.white)
                   .overlay(
                       RoundedRectangle(cornerRadius: 18)
                           .stroke(Color(hex: "#A6B4FF"), lineWidth: 1)
                   )
                   .cornerRadius(18)
           }
           .buttonStyle(PlainButtonStyle())
       }
       .padding(.bottom, 20)
   }
   
   // MARK: - Share Function
   
   private func shareWhisper() {
       Task { @MainActor in
           let randomBackground = BackgroundConfig.random()
           
           var cleanedWhisper = dailyWhisper.trimmingCharacters(in: .whitespacesAndNewlines)
           if cleanedWhisper.last == "." {
               cleanedWhisper = String(cleanedWhisper.dropLast())
           }
           
           let shareCard = ZStack {
               Image(randomBackground.imageName)
                   .resizable()
                   .aspectRatio(contentMode: .fill)
                   .frame(width: 1080, height: 1350)
                   .clipped()
               
               VStack(spacing: 0) {
                   Spacer()
                   
                   VStack(spacing: 22) {
                       Text(cleanedWhisper)
                           .font(.system(size: 68, weight: .bold, design: .serif))
                           .foregroundColor(Color(hex: randomBackground.textColor))
                           .multilineTextAlignment(.center)
                           .lineSpacing(6)
                           .tracking(-0.3)
                           .lineLimit(4)
                           .minimumScaleFactor(0.75)
                           .fixedSize(horizontal: false, vertical: true)
                           .frame(maxWidth: 820)
                       
                       Image("whisper-logo")
                           .resizable()
                           .renderingMode(.template)
                           .aspectRatio(contentMode: .fit)
                           .frame(width: 160)
                           .foregroundColor(Color(hex: randomBackground.textColor))
                           .opacity(0.82)
                   }
                   .offset(y: 30)
                   
                   Spacer()
               }
           }
           .frame(width: 1080, height: 1350)
           
           let image = ShareRenderer.image(
               for: shareCard,
               size: CGSize(width: 1080, height: 1350),
               colorScheme: .light
           )
           
           ShareManager.presentFromTopController(
               image: image,
               caption: nil
           )
       }
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
   
   private func loadDailyWhisper() {
       let dateKey = getDailyWhisperKey()
       
       if let cachedWhisper = UserDefaults.standard.string(forKey: "dailyWhisper_\(dateKey)") {
           dailyWhisper = cachedWhisper
           isDailyWhisperLoading = false
           return
       }
       
       DailyWhisperGenerator.generateDailyWhisper(for: Date()) { whisper in
           DispatchQueue.main.async {
               if let whisper = whisper {
                   self.dailyWhisper = whisper
                   UserDefaults.standard.set(whisper, forKey: "dailyWhisper_\(dateKey)")
               } else {
                   self.dailyWhisper = self.getFallbackWhisper()
               }
               self.isDailyWhisperLoading = false
           }
       }
   }
   
   private func getDailyWhisperKey() -> String {
       let formatter = DateFormatter()
       formatter.dateFormat = "yyyy-MM-dd"
       return formatter.string(from: Date())
   }
   
   private func getFallbackWhisper() -> String {
       let fallbackWhispers = [
           "You still have time.",
           "Believe their actions.",
           "Stop rehearsing their approval.",
           "Silence can be louder than proof.",
           "Don't lose your voice, the world is crowded."
       ]
       
       let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
       return fallbackWhispers[dayOfYear % fallbackWhispers.count]
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

// MARK: - Whisper Share Button Component
struct WhisperShareButton: View {
    let isEnabled: Bool
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        }) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Circle()
                            .stroke(Color(hex: "#E9E2D6"), lineWidth: 1)
                    )
                    .shadow(
                        color: isPressed ? Color.black.opacity(0.12) : (isEnabled ? Color.black.opacity(0.06) : Color.clear),
                        radius: isPressed ? 10 : 8,
                        x: 0,
                        y: 4
                    )
                
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(hex: "#7A6EFF"))
            }
            .contentShape(Rectangle())
            .frame(width: 44, height: 44)
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .opacity(isEnabled ? 1.0 : 0.5)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isEnabled)
        .accessibilityLabel("Share today's whisper")
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if isEnabled {
                        withAnimation(.easeOut(duration: 0.1)) {
                            isPressed = true
                        }
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeOut(duration: 0.1)) {
                        isPressed = false
                    }
                }
        )
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
                   .font(.system(size: 12, weight: .regular))
                   .foregroundColor(Color(hex: "#444444"))
               
               ZStack {
                   Circle()
                       .fill(isSelected ? Color(hex: "#b7b4ff") : Color.clear)
                       .frame(width: 30, height: 30)
                   
                   Text(dayNumber)
                       .font(.system(size: 13, weight: .medium))
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

struct DailyWhisperGenerator {
    static func generateDailyWhisper(for date: Date, completion: @escaping (String?) -> Void) {
        SecureAPIManager.shared.getOpenAIAPIKey { apiKey in
            guard let apiKey = apiKey else {
                completion(nil)
                return
            }
            
            guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
                completion(nil)
                return
            }
            
            let requestBody: [String: Any] = [
                "model": "gpt-4o",
                "messages": [
                    ["role": "system", "content": WhisperVoice.systemPrompt],
                    ["role": "user", "content": WhisperVoice.dailyWhisperPrompt()]
                ],
                "temperature": 0.7,
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
