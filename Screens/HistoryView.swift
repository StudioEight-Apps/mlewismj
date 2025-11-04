import SwiftUI

// MARK: - History View
struct HistoryView: View {
    @ObservedObject var journalManager = JournalManager.shared
    @State private var showingCalendar = false
    @State private var selectedDate: Date?
    @State private var scrollToDate: Date?
    @State private var filterByDate: Date?
    @State private var selectedTab: HistoryTab = .all

    enum HistoryTab { case all, favorites }

    // Keep this tiny so Swift's type checker is happy
    var body: some View {
        ZStack {
            Color(hex: "#FFFCF5").ignoresSafeArea()

            VStack(spacing: 0) {
                segmentedControl

                if filteredEntries.isEmpty {
                    EmptyStateView(
                        isFavoritesTab: selectedTab == .favorites,
                        hasDateFilter: filterByDate != nil,
                        clearFilter: { withAnimation { filterByDate = nil } }
                    )
                    .padding()
                } else {
                    if let d = filterByDate {
                        FilterHeaderView(
                            date: d,
                            clearFilter: { withAnimation { filterByDate = nil } }
                        )
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    }

                    EntryListView(
                        entries: filteredEntries.sorted(by: { $0.date > $1.date }),
                        scrollToDate: $scrollToDate
                    )
                }
            }

            if showingCalendar {
                CalendarPickerView(
                    journalEntries: journalManager.entries,
                    isPresented: $showingCalendar,
                    selectedDate: $selectedDate,
                    onDateSelected: { date in
                        withAnimation {
                            filterByDate = date
                            scrollToDate = date
                        }
                        showingCalendar = false
                    }
                )
            }
        }
        .preferredColorScheme(.light)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Image("whisper-logo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 32)
                    .accessibilityLabel("Whisper")
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showingCalendar = true } label: {
                    Image(systemName: "calendar")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Color(hex: "#2A2A2A"))
                        .frame(width: 24, height: 24)
                }
            }
        }
    }

    // MARK: - Segmented control
    private var segmentedControl: some View {
        Picker("", selection: $selectedTab) {
            Text("All").tag(HistoryTab.all)
            Text("Favorites").tag(HistoryTab.favorites)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    // MARK: - Filtering
    private var filteredEntries: [JournalEntry] {
        let base: [JournalEntry] = (selectedTab == .favorites)
        ? journalManager.favoritedEntries
        : journalManager.entries

        if let d = filterByDate {
            let cal = Calendar.current
            return base.filter { cal.isDate($0.date, inSameDayAs: d) }
        }
        return base
    }
}

// MARK: - Small subviews to keep type-checking fast
private struct EmptyStateView: View {
    let isFavoritesTab: Bool
    let hasDateFilter: Bool
    let clearFilter: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: isFavoritesTab ? "heart" : "book.closed")
                .font(.system(size: 60))
                .foregroundColor(Color(hex: "#5B5564"))

            Text(isFavoritesTab ? "No favorites yet" : "No thoughts yet")
                .font(.title2).fontWeight(.medium)
                .foregroundColor(Color(hex: "#2B2834"))

            Text(isFavoritesTab
                 ? "Tap the heart on entries you love"
                 : (hasDateFilter ? "Try selecting a different date" : "Create your first thought to see it here"))
            .font(.body)
            .foregroundColor(Color(hex: "#5B5564"))
            .multilineTextAlignment(.center)

            if hasDateFilter {
                Button("Show All Entries") { clearFilter() }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color(hex: "#A6B4FF"))
                    .cornerRadius(20)
                    .buttonStyle(.plain)
            }

            Spacer()
        }
    }
}

private struct FilterHeaderView: View {
    let date: Date
    let clearFilter: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Showing entries for:")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "#5B5564"))

                Text(DateFormatter.mediumDate.string(from: date))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "#2A2A2A"))
            }

            Spacer()

            Button("Show All") { clearFilter() }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(hex: "#A6B4FF"))
                .cornerRadius(16)
                .buttonStyle(.plain)
        }
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.7))
        .cornerRadius(12)
    }
}

private struct EntryListView: View {
    let entries: [JournalEntry]
    @State private var localScrollToDate: Date?
    @Binding var scrollToDate: Date?
    @State private var entryToDelete: JournalEntry?
    @State private var showDeleteAlert = false

    var body: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(entries, id: \.id) { entry in
                    HistoryCardView(entry: entry)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                entryToDelete = entry
                                showDeleteAlert = true
                            } label: {
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 20, weight: .medium))
                            }
                            .tint(Color(hex: "#F5A5A5"))
                        }
                        .id(entry.id)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .onChange(of: scrollToDate) { _, newValue in
                guard let d = newValue else { return }
                if let target = entries.first(where: { Calendar.current.isDate($0.date, inSameDayAs: d) }) {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        proxy.scrollTo(target.id, anchor: .top)
                    }
                }
            }
            .alert("Delete this entry?", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) {
                    entryToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let entry = entryToDelete {
                        withAnimation {
                            JournalManager.shared.deleteEntry(entry)
                        }
                        entryToDelete = nil
                    }
                }
            } message: {
                Text("This entry will be permanently deleted.")
            }
        }
    }
}

// MARK: - Calendar Picker (unchanged logic; just tidy)
struct CalendarPickerView: View {
    let journalEntries: [JournalEntry]
    @Binding var isPresented: Bool
    @Binding var selectedDate: Date?
    let onDateSelected: (Date) -> Void

    @State private var tempSelectedDate: Date?

    private var dateRange: (earliest: Date, latest: Date) {
        let cal = Calendar.current
        let now = Date()
        
        // May 2025 is the absolute earliest date users can scroll to
        let may2025 = cal.date(from: DateComponents(year: 2025, month: 5, day: 1)) ?? now
        // Go forward 6 months from now as the default latest date
        let defaultLatest = cal.date(byAdding: .month, value: 6, to: now) ?? now

        if !journalEntries.isEmpty {
            let dates = journalEntries.map { $0.date }
            // Use May 2025 or earliest entry, whichever is earlier
            let earliest = min(dates.min() ?? may2025, may2025)
            let latestContent = dates.max() ?? now
            let latest = max(latestContent, defaultLatest)
            return (earliest, latest)
        } else {
            // No entries: still show May 2025 to 6 months from now
            return (may2025, defaultLatest)
        }
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .background(.ultraThinMaterial)
                .onTapGesture { isPresented = false }

            VStack(spacing: 0) {
                HStack {
                    Spacer().frame(width: 44)
                    Spacer()
                    Text("Select Date")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(hex: "#2A2A2A"))
                    Spacer()
                    Button { isPresented = false } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(hex: "#2A2A2A"))
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)

                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 30) {
                            ForEach(generateMonths(), id: \.self) { month in
                                MonthCalendarView(
                                    month: month,
                                    journalEntries: journalEntries,
                                    selectedDate: $tempSelectedDate,
                                    onDateTapped: { tempSelectedDate = $0 }
                                )
                                .id(month)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .frame(height: 300)
                    .onAppear {
                        let cal = Calendar.current
                        // Scroll to current month instead of hardcoded date
                        let now = Date()
                        if let currentMonthStart = cal.dateInterval(of: .month, for: now)?.start {
                            proxy.scrollTo(currentMonthStart, anchor: .center)
                        }
                    }
                }

                Button {
                    if let d = tempSelectedDate { onDateSelected(d) }
                    isPresented = false
                } label: {
                    Text("Continue")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(tempSelectedDate != nil ? .white : Color(hex: "#999999"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(tempSelectedDate != nil ? Color(hex: "#A6B4FF") : Color(hex: "#f0f0f0"))
                        .cornerRadius(12)
                }
                .buttonStyle(.plain)
                .disabled(tempSelectedDate == nil)
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
            .frame(width: UIScreen.main.bounds.width * 0.9)
            .background(Color.white)
            .cornerRadius(20)
        }
    }

    private func generateMonths() -> [Date] {
        let cal = Calendar.current
        let range = dateRange
        var months: [Date] = []

        var current = cal.dateInterval(of: .month, for: range.earliest)?.start ?? range.earliest
        let end     = cal.dateInterval(of: .month, for: range.latest)?.start   ?? range.latest

        while current <= end {
            months.append(current)
            guard let next = cal.date(byAdding: .month, value: 1, to: current) else { break }
            current = next
        }
        return months
    }
}

// MARK: - Month Calendar View
struct MonthCalendarView: View {
    let month: Date
    let journalEntries: [JournalEntry]
    @Binding var selectedDate: Date?
    let onDateTapped: (Date) -> Void

    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f
    }()

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Spacer()
                Text(dateFormatter.string(from: month))
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(Color(hex: "#2A2A2A"))
                Spacer()
            }

            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                        Text(day)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(hex: "#999999"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 32)
                    }
                }

                let days = generateDaysInMonth()
                let weeks = days.chunked(into: 7)

                VStack(spacing: 0) {
                    ForEach(0..<weeks.count, id: \.self) { w in
                        HStack(spacing: 0) {
                            ForEach(0..<7, id: \.self) { i in
                                if i < weeks[w].count {
                                    CalendarDayView(
                                        dayData: weeks[w][i],
                                        journalEntries: journalEntries,
                                        selectedDate: selectedDate,
                                        onDateTapped: onDateTapped
                                    )
                                } else {
                                    Rectangle().fill(Color.clear)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 40)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private func generateDaysInMonth() -> [CalendarDayData] {
        guard let range = calendar.range(of: .day, in: .month, for: month),
              let first = calendar.date(from: calendar.dateComponents([.year, .month], from: month)) else {
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: first)
        var days: [CalendarDayData] = []

        for _ in 1..<firstWeekday {
            days.append(CalendarDayData(date: nil, dayNumber: nil))
        }

        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: first) {
                days.append(CalendarDayData(date: date, dayNumber: day))
            }
        }
        return days
    }
}

// MARK: - Calendar Day View
struct CalendarDayView: View {
    let dayData: CalendarDayData
    let journalEntries: [JournalEntry]
    let selectedDate: Date?
    let onDateTapped: (Date) -> Void

    private var entriesForDay: [JournalEntry] {
        guard let date = dayData.date else { return [] }
        return journalEntries.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }

    private var isToday: Bool {
        guard let date = dayData.date else { return false }
        return Calendar.current.isDateInToday(date)
    }

    private var isSelected: Bool {
        guard let date = dayData.date, let selected = selectedDate else { return false }
        return Calendar.current.isDate(date, inSameDayAs: selected)
    }

    var body: some View {
        Button {
            if let date = dayData.date { onDateTapped(date) }
        } label: {
            VStack(spacing: 4) {
                Text(dayData.dayNumber?.description ?? "")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(
                        dayData.date == nil ? Color.clear :
                        (isSelected ? .white :
                         (isToday ? Color(hex: "#A6B4FF") : Color(hex: "#2A2A2A")))
                    )

                HStack(spacing: 2) {
                    ForEach(Array(entriesForDay.prefix(4).enumerated()), id: \.offset) { _, entry in
                        Circle()
                            .fill(Color(hex: entry.colorHex))
                            .frame(width: 4, height: 4)
                    }
                }
                .frame(height: 6)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .background(
                isSelected ? Color(hex: "#A6B4FF") :
                (entriesForDay.isEmpty ? Color.clear : Color(hex: "#A6B4FF").opacity(0.1))
            )
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
        .disabled(dayData.date == nil)
    }
}

// MARK: - Supporting Types / Utils
struct CalendarDayData {
    let date: Date?
    let dayNumber: Int?
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

extension DateFormatter {
    static let mediumDate: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }()
}

// MARK: - History Card (with animations) - POLISHED VERSION
struct HistoryCardView: View {
    @ObservedObject var journalManager = JournalManager.shared
    let entry: JournalEntry
    @State private var isExpanded = false
    
    // Animation states
    @State private var heartScale: CGFloat = 1.0
    @State private var heartRotation: Double = 0
    @State private var pinScale: CGFloat = 1.0
    @State private var pinOffsetY: CGFloat = 0
    @State private var shareScale: CGFloat = 1.0
    @State private var shareRotation: Double = 0
    @State private var particles: [HeartParticle] = []

    private var moodColor: Color { Color(hex: entry.colorHex) }

    private var formattedDate: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: entry.date)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // MARK: - Header (Date & Mood Badge) - BETTER SPACING
            HStack(alignment: .center, spacing: 0) {
                Text(formattedDate)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "#7C7C7C"))
                
                Spacer()
                
                Text(entry.mood.capitalized)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(moodColor)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 14)

            // MARK: - Mantra Text - COMPACT
            HStack(alignment: .top) {
                Text(entry.text.isEmpty ? "Your personalized thought will appear here once complete." : entry.text)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: "#2B2834"))
                    .lineSpacing(4)
                    .multilineTextAlignment(.leading)
                    .lineLimit(isExpanded ? nil : 3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 14)
            .frame(minHeight: 55, alignment: .top)

            // MARK: - Action Buttons - SOFT & MINIMAL
            HStack(spacing: 4) {
                // Pin Button
                Button {
                    animatePin()
                    journalManager.togglePin(entry)
                } label: {
                    Image(systemName: entry.isPinned ? "pin.fill" : "pin")
                        .font(.system(size: 18, weight: .light))
                        .foregroundColor(entry.isPinned ? Color(hex: "#A6B4FF") : Color(hex: "#9E9E9E"))
                        .frame(width: 36, height: 36)
                        .scaleEffect(pinScale)
                        .offset(y: pinOffsetY)
                }
                .buttonStyle(.plain)

                // Share Button
                Button {
                    animateShare()
                    shareWhisper()
                } label: {
                    Image(systemName: "paperplane")
                        .font(.system(size: 17, weight: .light))
                        .foregroundColor(Color(hex: "#9E9E9E"))
                        .frame(width: 36, height: 36)
                        .scaleEffect(shareScale)
                        .rotationEffect(.degrees(shareRotation))
                }
                .buttonStyle(.plain)

                Spacer()

                // Favorite Button with particles
                Button {
                    animateFavorite()
                    journalManager.toggleFavorite(entry)
                } label: {
                    ZStack {
                        Image(systemName: entry.isFavorited ? "heart.fill" : "heart")
                            .font(.system(size: 19, weight: .light))
                            .foregroundColor(entry.isFavorited ? Color(hex: "#A6B4FF") : Color(hex: "#9E9E9E"))
                            .frame(width: 36, height: 36)
                            .scaleEffect(heartScale)
                            .rotationEffect(.degrees(heartRotation))
                        
                        // Particle burst overlay
                        ForEach(particles) { particle in
                            Circle()
                                .fill(Color(hex: "#A6B4FF"))
                                .frame(width: particle.size, height: particle.size)
                                .offset(x: particle.x, y: particle.y)
                                .opacity(particle.opacity)
                                .scaleEffect(particle.scale)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 14)

            // MARK: - Expandable Reflection Section - SOFT & MINIMAL
            if isExpanded && !entry.prompts.isEmpty {
                Divider()
                    .background(Color(hex: "#E8E8E8"))
                    .padding(.horizontal, 20)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Reflection")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(hex: "#7A7A7A"))

                    ForEach(Array(entry.prompts.enumerated()), id: \.offset) { i, answer in
                        if !answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(getPromptQuestion(for: i))
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(Color(hex: "#9E9E9E"))
                                
                                Text(answer)
                                    .font(.system(size: 15))
                                    .foregroundColor(Color(hex: "#2B2834"))
                                    .lineSpacing(4)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 14)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            // Show/Hide Reflection Button
            if !entry.prompts.isEmpty {
                Divider()
                    .background(Color(hex: "#E8E8E8"))
                
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isExpanded.toggle()
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text(isExpanded ? "Show less" : "Show reflection")
                            .font(.system(size: 14, weight: .medium))
                        
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundColor(Color(hex: "#7A7A7A"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                }
                .buttonStyle(.plain)
            }
        }
        // MARK: - Card Container - SOFT SHADOWS
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
    
    // MARK: - Animation Functions
    private func animatePin() {
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 15)) {
            pinScale = 1.3
            pinOffsetY = -3
        }
        
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 10).delay(0.1)) {
            pinScale = 1.0
            pinOffsetY = 0
        }
        
        Task { @MainActor in
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
        }
    }
    
    private func animateFavorite() {
        let isFavoriting = !entry.isFavorited
        
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 12)) {
            heartScale = 1.3
            heartRotation = -8
        }
        
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 10).delay(0.1)) {
            heartScale = 1.0
            heartRotation = 0
        }
        
        if isFavoriting {
            createParticleBurst()
        }
        
        Task { @MainActor in
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
    }
    
    private func animateShare() {
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 15)) {
            shareScale = 1.2
            shareRotation = 10
        }
        
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 10).delay(0.1)) {
            shareScale = 1.0
            shareRotation = 0
        }
        
        Task { @MainActor in
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
    }
    
    private func createParticleBurst() {
        let particleCount = Int.random(in: 6...8)
        var newParticles: [HeartParticle] = []
        
        for i in 0..<particleCount {
            let angle = (Double(i) / Double(particleCount)) * 360.0 + Double.random(in: -20...20)
            let distance = Double.random(in: 30...50)
            
            let particle = HeartParticle(
                id: UUID(),
                x: 0,
                y: 0,
                size: CGFloat.random(in: 4...7),
                opacity: 1.0,
                scale: 1.0,
                angle: angle,
                distance: distance
            )
            newParticles.append(particle)
        }
        
        particles = newParticles
        
        withAnimation(.easeOut(duration: 0.6)) {
            for i in 0..<particles.count {
                let angle = particles[i].angle * .pi / 180
                particles[i].x = cos(angle) * particles[i].distance
                particles[i].y = sin(angle) * particles[i].distance
                particles[i].opacity = 0
                particles[i].scale = 0.3
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            particles.removeAll()
        }
    }

    private func shareWhisper() {
        Task { @MainActor in
            // Use entry's saved background
            let background = BackgroundConfig(
                imageName: entry.backgroundImage,
                textColor: entry.textColor
            )

            var text = entry.text.trimmingCharacters(in: .whitespacesAndNewlines)
            let terminals = CharacterSet(charactersIn: ".,;:!?…")
            while let last = text.last, terminals.contains(String(last).unicodeScalars.first!) {
                text = String(text.dropLast())
            }

            let card = ZStack {
                Image(background.imageName).resizable().aspectRatio(contentMode: .fill)
                    .frame(width: 1080, height: 1080).clipped()
                VStack(spacing: 24) {
                    Text(text)
                        .font(.system(size: 80, weight: .bold, design: .serif))
                        .foregroundColor(Color(hex: background.textColor))
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .lineSpacing(10)
                        .tracking(-0.4)
                        .minimumScaleFactor(0.75)
                        .allowsTightening(true)
                        .frame(maxWidth: 820)
                    Image("whisper-logo")
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 140)
                        .foregroundColor(Color(hex: background.textColor))
                        .opacity(0.82)
                }
            }
            .frame(width: 1080, height: 1080)

            let image = ShareRenderer.image(
                for: card,
                size: CGSize(width: 1080, height: 1080),
                colorScheme: .light
            )
            ShareManager.presentFromTopController(image: image, caption: nil)
        }
    }

    private func getPromptQuestion(for index: Int) -> String {
        switch index {
        case 0: return "How are you feeling right now?"
        case 1: return "Why do you think you're feeling this way?"
        case 2: return "What's something you're grateful for right now?"
        default: return "Reflection \(index + 1):"
        }
    }
}
