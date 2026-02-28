import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct WelcomeView: View {
   @EnvironmentObject var authViewModel: AuthViewModel
   @ObservedObject var journalManager = JournalManager.shared
   @ObservedObject var notificationManager = NotificationManager.shared
   @Environment(\.colorScheme) var colorScheme
   private var colors: AppColors { AppColors(colorScheme) }
   @State private var navigateToJournal = false
   @State private var userName: String = "Friend"
   @State private var greeting: String = "Good morning"
   @State private var weekDates: [Date] = []
   @State private var selectedWeekDate = Date()
   @State private var currentStreak: Int = 0
   @State private var dailyWhisper: String = "Loading your daily whisper..."
   @State private var isDailyWhisperLoading = true
   @State private var cardScale: CGFloat = 0.96
   @State private var whisperOpacity: Double = 0
   @State private var dailyWhisperEntryId: String? = nil
   @State private var isDailyWhisperFavorited: Bool = false
   @State private var isDailyWhisperPinned: Bool = false
   // Recent entries computed directly — no caching, no timing bugs

   // Name prompt banner states
   @State private var hasSeenNamePrompt = UserDefaults.standard.bool(forKey: "hasSeenNamePrompt")
   @State private var showNamePrompt = false

   var body: some View {
       NavigationStack {
           ZStack {
               colors.screenBackground.ignoresSafeArea()

               mainContent
           }
           .toolbar {
               ToolbarItem(placement: .navigationBarLeading) {
                   NavigationLink(destination: HistoryView()) {
                       Image(systemName: "book")
                           .foregroundColor(colors.toolbarIcon)
                           .font(.system(size: 17, weight: .regular))
                   }
               }
               ToolbarItem(placement: .principal) {
                   Image("whisper-logo")
                       .resizable()
                       .renderingMode(.template)
                       .foregroundColor(colors.primaryText)
                       .scaledToFit()
                       .frame(maxWidth: 90)
                       .accessibilityLabel("Whisper")
               }
               ToolbarItem(placement: .navigationBarTrailing) {
                   NavigationLink(destination: SettingsView()) {
                       Image(systemName: "gearshape")
                           .foregroundColor(colors.toolbarIcon)
                           .font(.system(size: 17, weight: .regular))
                   }
               }
           }
           .navigationBarTitle("", displayMode: .inline)
           .navigationDestination(isPresented: $navigateToJournal) {
               JournalModeSelectionView(preSelectedType: .free)
           }
       }
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
       .onReceive(notificationManager.$shouldOpenFreeJournal) { shouldOpen in
           if shouldOpen {
               // Small delay to let navigation stack settle after app launch
               DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                   navigateToJournal = true
                   notificationManager.shouldOpenFreeJournal = false
               }
           }
       }
   }

   // Shared card style — solid fills, clean definition
   private let cardRadius: CGFloat = 16
   private func cardBackground() -> some View {
       ZStack {
           if colorScheme == .dark {
               RoundedRectangle(cornerRadius: cardRadius)
                   .fill(colors.card)
           } else {
               RoundedRectangle(cornerRadius: cardRadius)
                   .fill(Color.white)
                   .shadow(color: Color.black.opacity(0.04), radius: 1, x: 0, y: 1)
                   .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                   .shadow(color: Color.black.opacity(0.06), radius: 20, x: 0, y: 10)
           }
           RoundedRectangle(cornerRadius: cardRadius)
               .stroke(colorScheme == .dark ? colors.cardBorder : Color.black.opacity(0.06), lineWidth: 0.5)
       }
   }

   var mainContent: some View {
       ScrollView(showsIndicators: false) {
           VStack(spacing: 16) {
               if showNamePrompt {
                   namePromptBanner
               }

               headerSection
               calendarStrip
               streakRow
               whisperCard

               journalButton
                   .padding(.top, 6)

               recentEntriesSection
                   .padding(.top, 16)
           }
           .padding(.horizontal, 20)
           .padding(.top, 8)
           .padding(.bottom, 40)
       }
   }

   // MARK: - Header

   var headerSection: some View {
       HStack {
           HStack(spacing: 0) {
               Text("\(greeting), ")
                   .font(.system(size: 24, weight: .semibold))
                   .foregroundColor(colors.primaryText)
               Text(userName)
                   .font(.system(size: 24, weight: .semibold))
                   .foregroundColor(colors.primaryText)
           }

           Spacer()
       }
       .padding(.horizontal, 4)
       .padding(.top, 16)
       .onAppear {
           loadUserName()
           updateGreeting()
           generateWeekDates()
           loadDailyWhisper()
       }
   }

   // MARK: - Calendar Strip

   var calendarStrip: some View {
       HStack(spacing: 0) {
           ForEach(weekDates, id: \.self) { date in
               CalendarDayBubble(
                   date: date,
                   entries: entriesForDate(date),
                   isSelected: Calendar.current.isDate(date, inSameDayAs: selectedWeekDate),
                   onTap: { selectedWeekDate = date }
               )
               .frame(maxWidth: .infinity)
           }
       }
       .padding(.vertical, 10)
       .padding(.horizontal, 6)
       .background(cardBackground())
   }

   // MARK: - Streak Row

   var streakRow: some View {
       Group {
           if !journalManager.isLoading && currentStreak > 0 {
               Text("🔥 \(currentStreak) day streak")
                   .font(.system(size: 13, weight: .medium))
                   .foregroundColor(colors.streakText)
                   .frame(maxWidth: .infinity, alignment: .center)
           }
       }
   }

   // MARK: - Whisper Card

   var whisperCard: some View {
       VStack(alignment: .leading, spacing: 0) {
           // Date
           Text(todayFormatted)
               .font(.system(size: 11, weight: .medium))
               .tracking(1.2)
               .foregroundColor(colors.tertiaryText)
               .textCase(.uppercase)
               .padding(.bottom, 22)

           // Whisper text
           whisperContent
               .padding(.bottom, 22)

           // Divider
           Rectangle()
               .fill(colors.divider)
               .frame(width: 28, height: 1)
               .padding(.bottom, 14)

           // Actions — centered
           HStack {
               Spacer()
               if !isDailyWhisperLoading {
                   whisperActions
               }
               Spacer()
           }
       }
       .padding(.top, 28)
       .padding(.bottom, 22)
       .padding(.leading, 24)
       .padding(.trailing, 20)
       .frame(maxWidth: .infinity, alignment: .leading)
       .background(cardBackground())
       .scaleEffect(cardScale)
       .onAppear {
           withAnimation(.easeOut(duration: 0.3)) {
               cardScale = 1.0
           }
           withAnimation(.easeOut(duration: 0.35).delay(0.1)) {
               whisperOpacity = 1.0
           }
           syncDailyWhisperState()
       }
   }

   private var todayFormatted: String {
       let formatter = DateFormatter()
       formatter.dateFormat = "EEEE, MMMM d"
       return formatter.string(from: Date())
   }

   var whisperContent: some View {
       Group {
           if isDailyWhisperLoading {
               VStack(spacing: 10) {
                   ProgressView()
                       .scaleEffect(0.8)
                       .tint(AppColors.gold)
                   Text("Preparing your whisper...")
                       .font(.system(size: 13, weight: .regular))
                       .foregroundColor(colors.tertiaryText)
               }
               .frame(minHeight: 70)
           } else {
               Text(dailyWhisper)
                   .font(.system(size: 20, weight: .semibold, design: .serif))
                   .foregroundColor(colors.primaryText)
                   .multilineTextAlignment(.leading)
                   .lineSpacing(6)
                   .tracking(-0.3)
                   .fixedSize(horizontal: false, vertical: true)
                   .padding(.trailing, 12)
                   .opacity(whisperOpacity)
           }
       }
   }

   // MARK: - Whisper Actions

   var whisperActions: some View {
       HStack(spacing: 16) {
           Button(action: pinDailyWhisper) {
               Image(systemName: isDailyWhisperPinned ? "pin.fill" : "pin")
                   .font(.system(size: 16, weight: .medium))
                   .foregroundColor(isDailyWhisperPinned ? (colorScheme == .dark ? AppColors.gold : colors.primaryText) : colors.whisperActionIcon)
                   .frame(width: 44, height: 44)
                   .contentShape(Rectangle())
           }
           .buttonStyle(PlainButtonStyle())

           Button(action: {
               let generator = UIImpactFeedbackGenerator(style: .light)
               generator.impactOccurred()
               shareWhisper()
           }) {
               Image("icon-paper-plane")
                   .renderingMode(.template)
                   .resizable()
                   .scaledToFit()
                   .frame(width: 18, height: 18)
                   .frame(width: 44, height: 44)
                   .contentShape(Rectangle())
                   .foregroundColor(colors.whisperActionIcon)
           }
           .buttonStyle(PlainButtonStyle())

           Button(action: favoriteDailyWhisper) {
               Image(systemName: isDailyWhisperFavorited ? "heart.fill" : "heart")
                   .font(.system(size: 16, weight: .medium))
                   .foregroundColor(isDailyWhisperFavorited ? AppColors.gold : colors.whisperActionIcon)
                   .frame(width: 44, height: 44)
                   .contentShape(Rectangle())
           }
           .buttonStyle(PlainButtonStyle())
       }
   }

   // MARK: - Journal Button

   var journalButton: some View {
       NavigationLink(destination: JournalModeSelectionView()) {
           HStack {
               VStack(alignment: .leading, spacing: 3) {
                   Text("Start Journaling")
                       .font(.system(size: 17, weight: .semibold))
                       .foregroundColor(colors.primaryText)
                   Text("Begin today's entry")
                       .font(.system(size: 13, weight: .regular))
                       .foregroundColor(colors.tertiaryText)
               }
               Spacer()
               ZStack {
                   Circle()
                       .fill(colors.buttonBackground)
                       .frame(width: 40, height: 40)
                   Image(systemName: "arrow.right")
                       .font(.system(size: 14, weight: .semibold))
                       .foregroundColor(colors.buttonText)
               }
           }
           .padding(.horizontal, 20)
           .padding(.vertical, 20)
           .background(
               ZStack {
                   if colorScheme == .dark {
                       // Dark mode: lighter elevated card
                       RoundedRectangle(cornerRadius: cardRadius)
                           .fill(
                               LinearGradient(
                                   colors: [
                                       Color(hex: "#2A2A2E"),
                                       Color(hex: "#222225")
                                   ],
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing
                               )
                           )
                           .shadow(color: Color.black.opacity(0.6), radius: 16, x: 0, y: 8)
                       // Shine border
                       RoundedRectangle(cornerRadius: cardRadius)
                           .stroke(
                               LinearGradient(
                                   colors: [
                                       Color.white.opacity(0.25),
                                       Color.white.opacity(0.08)
                                   ],
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing
                               ),
                               lineWidth: 1
                           )
                   } else {
                       // Light mode: warm frosted card with depth
                       RoundedRectangle(cornerRadius: cardRadius)
                           .fill(
                               LinearGradient(
                                   colors: [
                                       Color(hex: "#FDFCFB"),
                                       Color(hex: "#F8F4F0")
                                   ],
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing
                               )
                           )
                           .shadow(color: Color(hex: "#C4A574").opacity(0.08), radius: 2, x: 0, y: 1)
                           .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                           .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 10)
                       // Gold-tinted shine border
                       RoundedRectangle(cornerRadius: cardRadius)
                           .stroke(
                               LinearGradient(
                                   colors: [
                                       Color(hex: "#E8DED3"),
                                       Color(hex: "#EBE6E0")
                                   ],
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing
                               ),
                               lineWidth: 1
                           )
                   }
               }
           )
       }
       .buttonStyle(PlainButtonStyle())
   }

   // MARK: - Recent Entries (computed directly — no caching)

   private var recentEntries: [JournalEntry] {
       guard !journalManager.isLoading, !journalManager.entries.isEmpty else { return [] }
       let filtered = journalManager.entries.filter { entry in
           let isAutoWhisperEntry = entry.journalType == .free
               && entry.prompts.allSatisfy({ $0.isEmpty })
               && entry.text == dailyWhisper
           return !isAutoWhisperEntry
       }
       return Array(filtered.sorted(by: { $0.date > $1.date }).prefix(3))
   }

   var recentEntriesSection: some View {
       VStack(alignment: .leading, spacing: 10) {
           if !recentEntries.isEmpty {
               HStack {
                   Text("Recent")
                       .font(.system(size: 15, weight: .semibold))
                       .foregroundColor(colors.primaryText)
                   Spacer()
                   NavigationLink(destination: HistoryView()) {
                       Text("See All")
                           .font(.system(size: 13, weight: .medium))
                           .foregroundColor(AppColors.gold)
                   }
               }
               .padding(.horizontal, 4)

               VStack(spacing: 10) {
                   ForEach(recentEntries, id: \.id) { entry in
                       NavigationLink(destination: JournalEntryDetailView(entryId: entry.id)) {
                           recentEntryRow(entry: entry)
                       }
                       .buttonStyle(PlainButtonStyle())
                   }
               }
           }
       }
   }

   private func recentEntryRow(entry: JournalEntry) -> some View {
       HStack(spacing: 12) {
           // Mood color accent bar
           RoundedRectangle(cornerRadius: 2)
               .fill(moodColor(for: entry.mood))
               .frame(width: 4, height: 36)

           VStack(alignment: .leading, spacing: 3) {
               Text(entry.text.isEmpty ? "A moment of reflection" : entry.text)
                   .font(.system(size: 14, weight: .medium))
                   .foregroundColor(colors.primaryText)
                   .lineLimit(1)

               HStack(spacing: 6) {
                   Text(entry.mood.capitalized)
                       .font(.system(size: 11, weight: .medium))
                       .foregroundColor(moodColor(for: entry.mood))

                   Text("·")
                       .font(.system(size: 11))
                       .foregroundColor(colors.tertiaryText)

                   Text(entryDateFormatted(entry.date))
                       .font(.system(size: 11, weight: .regular))
                       .foregroundColor(colors.tertiaryText)
               }
           }

           Spacer()

           HStack(spacing: 4) {
               if entry.isPinned {
                   Image(systemName: "pin.fill")
                       .font(.system(size: 9, weight: .medium))
                       .foregroundColor(colorScheme == .dark ? AppColors.gold : colors.primaryText)
                       .frame(width: 10, height: 10)
               }
               if entry.isFavorited {
                   Image(systemName: "heart.fill")
                       .font(.system(size: 9, weight: .medium))
                       .foregroundColor(AppColors.gold)
               }
           }

           Image(systemName: "chevron.right")
               .font(.system(size: 10, weight: .medium))
               .foregroundColor(colors.tertiaryText)
       }
       .padding(.horizontal, 14)
       .padding(.vertical, 14)
       .clipShape(RoundedRectangle(cornerRadius: cardRadius))
       .background(
           ZStack {
               if colorScheme == .dark {
                   RoundedRectangle(cornerRadius: cardRadius)
                       .fill(colors.card)
                       .shadow(color: Color.black.opacity(0.5), radius: 8, x: 0, y: 4)
               } else {
                   RoundedRectangle(cornerRadius: cardRadius)
                       .fill(Color.white)
                       .shadow(color: Color.black.opacity(0.06), radius: 2, x: 0, y: 1)
                       .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                       .shadow(color: Color.black.opacity(0.06), radius: 24, x: 0, y: 12)
               }
           }
       )
       .overlay(
           RoundedRectangle(cornerRadius: cardRadius)
               .stroke(colorScheme == .dark ? colors.cardBorder : Color.black.opacity(0.06), lineWidth: 0.5)
       )
   }

   private func moodColor(for mood: String) -> Color {
       Color(hex: colorForMood(mood))
   }

   private func entryDateFormatted(_ date: Date) -> String {
       let calendar = Calendar.current
       if calendar.isDateInToday(date) {
           let formatter = DateFormatter()
           formatter.dateFormat = "h:mm a"
           return "Today, \(formatter.string(from: date))"
       } else if calendar.isDateInYesterday(date) {
           return "Yesterday"
       } else {
           let formatter = DateFormatter()
           formatter.dateFormat = "MMM d"
           return formatter.string(from: date)
       }
   }

   // MARK: - Name Prompt Banner

   var namePromptBanner: some View {
       HStack {
           VStack(alignment: .leading, spacing: 4) {
               Text("Personalize your greetings")
                   .font(.system(size: 14, weight: .semibold))
                   .foregroundColor(colors.primaryText)

               Text("Add your name in Settings for a personal touch")
                   .font(.system(size: 12, weight: .regular))
                   .foregroundColor(colors.secondaryText)
           }

           Spacer()

           Button(action: dismissNamePrompt) {
               Image(systemName: "xmark")
                   .font(.system(size: 12, weight: .medium))
                   .foregroundColor(colors.secondaryText)
                   .frame(width: 20, height: 20)
           }
       }
       .padding(.horizontal, 16)
       .padding(.vertical, 12)
       .background(
           RoundedRectangle(cornerRadius: cardRadius)
               .fill(colors.bannerBackground)
       )
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

               VStack(alignment: .leading, spacing: 0) {
                   Spacer()

                   VStack(alignment: .leading, spacing: 22) {
                       Text(cleanedWhisper)
                           .font(.system(size: 64, weight: .semibold, design: .serif))
                           .foregroundColor(Color(hex: randomBackground.textColor))
                           .multilineTextAlignment(.leading)
                           .lineSpacing(6)
                           .tracking(-0.4)
                           .lineLimit(4)
                           .minimumScaleFactor(0.75)
                           .fixedSize(horizontal: false, vertical: true)
                           .frame(maxWidth: 820, alignment: .leading)

                       Image("whisper-logo")
                           .resizable()
                           .renderingMode(.template)
                           .aspectRatio(contentMode: .fit)
                           .frame(width: 140)
                           .foregroundColor(Color(hex: randomBackground.textColor))
                           .opacity(0.6)
                   }
                   .padding(.leading, 60)
                   .padding(.trailing, 90)

                   Spacer()
                       .frame(height: 80)
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

   // MARK: - Daily Whisper Actions

   /// Check if current daily whisper already exists as an entry (from a previous favorite/pin)
   private func syncDailyWhisperState() {
       if let existingEntry = journalManager.entries.first(where: { $0.text == dailyWhisper && $0.journalType == .free && $0.prompts.allSatisfy({ $0.isEmpty }) }) {
           dailyWhisperEntryId = existingEntry.id
           isDailyWhisperFavorited = existingEntry.isFavorited
           isDailyWhisperPinned = existingEntry.isPinned
       }
   }

   /// Ensures the daily whisper is saved as a journal entry, returns the entry
   private func ensureDailyWhisperEntry() -> JournalEntry? {
       // If already saved, find and return it
       if let entryId = dailyWhisperEntryId,
          let existing = journalManager.entries.first(where: { $0.id == entryId }) {
           return existing
       }

       // Save as a new lightweight entry
       let bg = BackgroundConfig.random()
       journalManager.saveEntry(
           mood: "reflective",
           response1: "",
           response2: "",
           response3: "",
           mantra: dailyWhisper,
           journalType: .free,
           backgroundImage: bg.imageName,
           textColor: bg.textColor
       )

       // Find the just-saved entry
       if let newEntry = journalManager.entries.first(where: { $0.text == dailyWhisper && $0.journalType == .free && $0.prompts.allSatisfy({ $0.isEmpty }) }) {
           dailyWhisperEntryId = newEntry.id
           return newEntry
       }
       return nil
   }

   private func favoriteDailyWhisper() {
       let generator = UIImpactFeedbackGenerator(style: .light)
       generator.impactOccurred()

       guard let entry = ensureDailyWhisperEntry() else { return }
       journalManager.toggleFavorite(entry)

       withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
           isDailyWhisperFavorited.toggle()
       }
   }

   private func pinDailyWhisper() {
       let generator = UIImpactFeedbackGenerator(style: .light)
       generator.impactOccurred()

       guard let entry = ensureDailyWhisperEntry() else { return }
       journalManager.togglePin(entry)

       withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
           isDailyWhisperPinned.toggle()
       }
   }

   // MARK: - Calendar & Streak Functions

   private func generateWeekDates() {
       let calendar = Calendar.current
       let today = Date()
       weekDates = []

       guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) else {
           return
       }

       for i in 0..<7 {
           if let date = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
               weekDates.append(date)
           }
       }
   }

   private func entriesForDate(_ date: Date) -> [JournalEntry] {
       journalManager.entries.filter { entry in
           Calendar.current.isDate(entry.date, inSameDayAs: date)
       }
   }

   private func calculateStreak(with entries: [JournalEntry]) {
       guard !entries.isEmpty else {
           currentStreak = 0
           return
       }

       let calendar = Calendar.current
       let today = calendar.startOfDay(for: Date())

       let uniqueDates = Set(entries.map { calendar.startOfDay(for: $0.date) })
       let sortedDates = uniqueDates.sorted(by: >)

       guard let mostRecentDate = sortedDates.first else {
           currentStreak = 0
           return
       }

       let daysSinceMostRecent = calendar.dateComponents([.day], from: mostRecentDate, to: today).day ?? 0

       if daysSinceMostRecent > 1 {
           currentStreak = 0
           return
       }

       var streak = 0
       var checkDate = daysSinceMostRecent == 0 ? today : mostRecentDate

       while uniqueDates.contains(checkDate) {
           streak += 1
           guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else {
               break
           }
           checkDate = previousDay
       }

       currentStreak = streak
   }

   private func loadDailyWhisper() {
       isDailyWhisperLoading = true

       let calendar = Calendar.current
       let today = calendar.startOfDay(for: Date())

       if let cachedWhisper = UserDefaults.standard.string(forKey: "dailyWhisper"),
          let cachedDateInterval = UserDefaults.standard.object(forKey: "dailyWhisperDate") as? TimeInterval {
           let cachedDate = Date(timeIntervalSince1970: cachedDateInterval)
           if calendar.isDate(cachedDate, inSameDayAs: today) {
               dailyWhisper = cachedWhisper
               isDailyWhisperLoading = false
               syncDailyWhisperState()
               return
           }
       }

       DailyWhisperGenerator.generateDailyWhisper(for: today) { whisper in
           DispatchQueue.main.async {
               if let whisper = whisper {
                   dailyWhisper = whisper
                   UserDefaults.standard.set(whisper, forKey: "dailyWhisper")
                   UserDefaults.standard.set(today.timeIntervalSince1970, forKey: "dailyWhisperDate")
               } else {
                   dailyWhisper = getFallbackWhisper()
               }
               isDailyWhisperLoading = false
               syncDailyWhisperState()
           }
       }
   }

   private func getFallbackWhisper() -> String {
       let fallbackWhispers = [
           "Every breath is a fresh beginning",
           "You carry more strength than you know",
           "This moment is enough",
           "Growth happens in the quiet moments",
           "Trust the journey you're on",
           "Your presence matters more than you realize",
           "Peace is found in acceptance",
           "You are exactly where you need to be"
       ]

       let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
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
       default: greeting = "Good evening"
       }
   }
}

// MARK: - Calendar Day Bubble

struct CalendarDayBubble: View {
   let date: Date
   let entries: [JournalEntry]
   let isSelected: Bool
   let onTap: () -> Void
   @Environment(\.colorScheme) var colorScheme
   private var colors: AppColors { AppColors(colorScheme) }

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
                   .font(.system(size: 11, weight: .regular))
                   .foregroundColor(colors.secondaryText)

               ZStack {
                   Circle()
                       .fill(isSelected ? colors.calendarSelected : Color.clear)
                       .frame(width: 30, height: 30)

                   Text(dayNumber)
                       .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                       .foregroundColor(isSelected ? colors.calendarSelectedText : colors.calendarDayText)
               }

               HStack(spacing: 2) {
                   ForEach(0..<min(entries.count, 3), id: \.self) { _ in
                       Circle()
                           .fill(AppColors.gold)
                           .frame(width: 3, height: 3)
                   }
               }
               .frame(height: 5)
           }
       }
       .buttonStyle(PlainButtonStyle())
       .frame(width: 40)
   }
}

struct DailyWhisperGenerator {
    static func generateDailyWhisper(for date: Date, completion: @escaping (String?) -> Void) {
        // Get user's voice preference (defaults to 1 if not set)
        let voiceId = UserDefaults.standard.integer(forKey: "voice_id")
        let selectedVoiceId = voiceId > 0 ? voiceId : 1

        let systemPrompt = WhisperVoice.systemPrompt(for: selectedVoiceId)
        let userPrompt = WhisperVoice.dailyWhisperPrompt(for: selectedVoiceId)

        print("🌅 Generating daily whisper with voice ID: \(selectedVoiceId)")

        // Try Anthropic first, fall back to OpenAI
        generateWithAnthropic(systemPrompt: systemPrompt, userPrompt: userPrompt) { result in
            if let result = result {
                completion(result)
            } else {
                print("⚠️ Daily whisper: Anthropic unavailable, falling back to OpenAI")
                generateWithOpenAI(systemPrompt: systemPrompt, userPrompt: userPrompt, completion: completion)
            }
        }
    }

    // MARK: - Anthropic (Claude)

    private static func generateWithAnthropic(systemPrompt: String, userPrompt: String, completion: @escaping (String?) -> Void) {
        SecureAPIManager.shared.getAnthropicAPIKey { apiKey in
            guard let apiKey = apiKey else {
                completion(nil)
                return
            }

            guard let url = URL(string: "https://api.anthropic.com/v1/messages") else {
                completion(nil)
                return
            }

            let requestBody: [String: Any] = [
                "model": "claude-sonnet-4-5-20250929",
                "max_tokens": 50,
                "system": systemPrompt,
                "messages": [
                    ["role": "user", "content": userPrompt]
                ]
            ]

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
            request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            } catch {
                completion(nil)
                return
            }

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("❌ Daily whisper Anthropic error: \(error.localizedDescription)")
                    completion(nil)
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200,
                      let data = data else {
                    completion(nil)
                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let content = json["content"] as? [[String: Any]],
                       let textBlock = content.first(where: { $0["type"] as? String == "text" }),
                       let text = textBlock["text"] as? String {
                        let cleaned = WhisperVoice.cleanWhisperText(text)
                        print("✅ Daily whisper (Anthropic): \(cleaned)")
                        completion(cleaned)
                    } else {
                        completion(nil)
                    }
                } catch {
                    completion(nil)
                }
            }.resume()
        }
    }

    // MARK: - OpenAI (Fallback)

    private static func generateWithOpenAI(systemPrompt: String, userPrompt: String, completion: @escaping (String?) -> Void) {
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
                    ["role": "system", "content": systemPrompt],
                    ["role": "user", "content": userPrompt]
                ],
                "temperature": 0.9,
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
                        let cleaned = WhisperVoice.cleanWhisperText(content)
                        print("✅ Daily whisper (OpenAI): \(cleaned)")
                        completion(cleaned)
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
