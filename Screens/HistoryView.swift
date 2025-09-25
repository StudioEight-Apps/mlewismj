import SwiftUI

struct HistoryView: View {
    @ObservedObject var journalManager = JournalManager.shared
    @State private var showingCalendar = false
    @State private var selectedDate: Date?
    @State private var scrollToDate: Date?
    @State private var filterByDate: Date? // New: for filtering entries

    var filteredEntries: [JournalEntry] {
        if let filterDate = filterByDate {
            let calendar = Calendar.current
            return journalManager.entries.filter { calendar.isDate($0.date, inSameDayAs: filterDate) }
        } else {
            // Show ALL entries from ALL time, not just current month
            return journalManager.entries
        }
    }

    var body: some View {
        ZStack {
            Color(hex: "#FFFCF5") // ✅ Consistent background
                .ignoresSafeArea()

            if filteredEntries.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "book.closed")
                        .font(.system(size: 60))
                        .foregroundColor(Color(hex: "#5B5564"))

                    Text(filterByDate != nil ? "No thoughts for this date" : "No thoughts yet")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(Color(hex: "#2B2834"))

                    Text(filterByDate != nil ? "Try selecting a different date" : "Create your first thought to see it here")
                        .font(.body)
                        .foregroundColor(Color(hex: "#5B5564"))
                        .multilineTextAlignment(.center)
                    
                    // Show reset button if filtering by date - FIXED
                    if filterByDate != nil {
                        Button("Show All Entries") {
                            withAnimation {
                                filterByDate = nil
                            }
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color(hex: "#A6B4FF")) // ✅ Fixed color
                        .cornerRadius(20)
                        .buttonStyle(PlainButtonStyle())
                        .shadow(radius: 0)
                    }
                }
                .padding()
            } else {
                VStack(spacing: 0) {
                    // Filter indicator and reset button
                    if let filterDate = filterByDate {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Showing entries for:")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Color(hex: "#5B5564"))
                                
                                Text(DateFormatter.mediumDate.string(from: filterDate))
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color(hex: "#2A2A2A"))
                            }
                            
                            Spacer()
                            
                            Button("Show All") {
                                withAnimation {
                                    filterByDate = nil
                                }
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color(hex: "#A6B4FF")) // ✅ Fixed color
                            .cornerRadius(16)
                            .buttonStyle(PlainButtonStyle())
                            .shadow(radius: 0)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(12)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    }
                    
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredEntries.sorted(by: { $0.date > $1.date }), id: \.id) { entry in
                                    HistoryCardView(entry: entry)
                                        .id(entry.id) // Use entry.id instead of date for unique identification
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 20)
                            .padding(.bottom, 100)
                        }
                        .onChange(of: scrollToDate) { oldValue, newValue in
                            if let date = newValue {
                                // Find the first entry for this date to scroll to
                                if let targetEntry = filteredEntries.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
                                    withAnimation(.easeInOut(duration: 0.8)) {
                                        proxy.scrollTo(targetEntry.id, anchor: .top)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // Calendar Overlay
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
                Button(action: {
                    showingCalendar = true
                }) {
                    Image(systemName: "calendar")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Color(hex: "#2A2A2A"))
                        .frame(width: 24, height: 24)
                }
            }
        }
    }
}

// MARK: - Calendar Picker View
struct CalendarPickerView: View {
    let journalEntries: [JournalEntry]
    @Binding var isPresented: Bool
    @Binding var selectedDate: Date?
    let onDateSelected: (Date) -> Void
    
    @State private var tempSelectedDate: Date? // Temporary selection until OK is pressed
    
    // Start from May 2025 and work backwards/forwards
    private var dateRange: (earliest: Date, latest: Date) {
        let calendar = Calendar.current
        let may2025 = calendar.date(from: DateComponents(year: 2025, month: 5, day: 1)) ?? Date()
        let currentDate = Date()
        
        // Extend range based on entries if they exist outside May 2025
        if !journalEntries.isEmpty {
            let entryDates = journalEntries.map { $0.date }
            let earliestEntry = entryDates.min() ?? may2025
            let latestEntry = entryDates.max() ?? currentDate
            
            let earliest = min(earliestEntry, may2025)
            let latest = max(latestEntry, calendar.date(byAdding: .month, value: 6, to: currentDate) ?? currentDate)
            
            return (earliest, latest)
        } else {
            // Default range: May 2025 to 6 months from now
            let latest = calendar.date(byAdding: .month, value: 6, to: currentDate) ?? currentDate
            return (may2025, latest)
        }
    }
    
    var body: some View {
        ZStack {
            // Blur background
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .background(.ultraThinMaterial)
                .onTapGesture {
                    isPresented = false
                }
            
            // Calendar Card
            VStack(spacing: 0) {
                // Header - better centered alignment
                HStack {
                    // Left spacer to balance the X button
                    Spacer()
                        .frame(width: 44) // Same width as X button
                    
                    Spacer()
                    Text("Select Date")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(hex: "#2A2A2A"))
                    Spacer()
                    
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(hex: "#2A2A2A"))
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                // Scrollable Calendar
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 30) {
                            ForEach(generateMonths(), id: \.self) { month in
                                MonthCalendarView(
                                    month: month,
                                    journalEntries: journalEntries,
                                    selectedDate: $tempSelectedDate,
                                    onDateTapped: { date in
                                        tempSelectedDate = date
                                    }
                                )
                                .id(month)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .frame(height: 300)
                    .onAppear {
                        // Scroll to May 2025 on first load
                        let calendar = Calendar.current
                        if let may2025 = calendar.date(from: DateComponents(year: 2025, month: 5, day: 1)) {
                            proxy.scrollTo(may2025, anchor: .center)
                        }
                    }
                }
                
                // Continue Button - FIXED
                Button(action: {
                    if let selectedDate = tempSelectedDate {
                        onDateSelected(selectedDate)
                    }
                    isPresented = false
                }) {
                    Text("Continue")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(tempSelectedDate != nil ? .white : Color(hex: "#999999"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(tempSelectedDate != nil ? Color(hex: "#A6B4FF") : Color(hex: "#f0f0f0")) // ✅ Fixed color
                        .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
                .shadow(radius: 0)
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
        let calendar = Calendar.current
        let range = dateRange
        var months: [Date] = []
        
        var currentMonth = calendar.dateInterval(of: .month, for: range.earliest)?.start ?? range.earliest
        let endMonth = calendar.dateInterval(of: .month, for: range.latest)?.start ?? range.latest
        
        while currentMonth <= endMonth {
            months.append(currentMonth)
            guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) else { break }
            currentMonth = nextMonth
        }
        
        return months // Chronological order - earliest first (so scroll up = past, scroll down = future)
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
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 16) {
            // Month Header - centered and properly aligned
            HStack {
                Spacer()
                Text(dateFormatter.string(from: month))
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(Color(hex: "#2A2A2A"))
                Spacer()
            }
            
            VStack(spacing: 0) {
                // Weekday Headers - like Airbnb
                HStack(spacing: 0) {
                    ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                        Text(day)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(hex: "#999999"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 32)
                    }
                }
                
                // Calendar Grid - exactly like Airbnb
                let days = generateDaysInMonth()
                let weeks = days.chunked(into: 7)
                
                VStack(spacing: 0) {
                    ForEach(0..<weeks.count, id: \.self) { weekIndex in
                        HStack(spacing: 0) {
                            ForEach(0..<7, id: \.self) { dayIndex in
                                if dayIndex < weeks[weekIndex].count {
                                    CalendarDayView(
                                        dayData: weeks[weekIndex][dayIndex],
                                        journalEntries: journalEntries,
                                        selectedDate: selectedDate,
                                        onDateTapped: onDateTapped
                                    )
                                } else {
                                    // Empty cell
                                    Rectangle()
                                        .fill(Color.clear)
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
        guard let monthRange = calendar.range(of: .day, in: .month, for: month),
              let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month)) else {
            return []
        }
        
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        var days: [CalendarDayData] = []
        
        // Add empty days for the beginning of the month
        for _ in 1..<firstWeekday {
            days.append(CalendarDayData(date: nil, dayNumber: nil))
        }
        
        // Add actual days of the month
        for day in monthRange {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
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
        let calendar = Calendar.current
        let entries = journalEntries.filter { calendar.isDate($0.date, inSameDayAs: date) }
        
        // Debug logging
        if !entries.isEmpty {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            print("📅 Date: \(formatter.string(from: date)) has \(entries.count) entries:")
            for entry in entries {
                print("  - \(entry.mood): \(entry.text.prefix(30))...")
            }
        }
        
        return entries
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
        Button(action: {
            if let date = dayData.date {
                onDateTapped(date)
            }
        }) {
            VStack(spacing: 4) {
                // Day number - Airbnb style - FIXED
                Text(dayData.dayNumber?.description ?? "")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(
                        dayData.date == nil ? Color.clear :
                        isSelected ? .white :
                        isToday ? Color(hex: "#A6B4FF") : // ✅ Fixed color
                        Color(hex: "#2A2A2A")
                    )
                
                // Mood dots - horizontal row like Airbnb
                HStack(spacing: 2) {
                    ForEach(Array(entriesForDay.prefix(4).enumerated()), id: \.offset) { index, entry in
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
                // Selected state - FIXED
                isSelected ? Color(hex: "#A6B4FF") : // ✅ Fixed color
                (entriesForDay.isEmpty ? Color.clear : Color(hex: "#A6B4FF").opacity(0.1)) // ✅ Fixed color
            )
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(dayData.date == nil)
    }
}

// MARK: - Supporting Data Structures and Extensions
struct CalendarDayData {
    let date: Date?
    let dayNumber: Int?
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

extension DateFormatter {
    static let mediumDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}

// MARK: - Original History Card View (unchanged)
struct HistoryCardView: View {
    let entry: JournalEntry
    @State private var isExpanded = false

    private var moodColor: Color {
        Color(hex: entry.colorHex)
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: entry.date)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                Text(formattedDate)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#5B5564"))

                HStack {
                    Text(entry.mood)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(moodColor)
                        .clipShape(Capsule())

                    Spacer()
                }

                Text(entry.text.isEmpty ? "Your personalized thought will appear here once complete." : entry.text)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: "#2B2834"))
                    .multilineTextAlignment(.leading)
                    .lineLimit(isExpanded ? nil : 3)
                    .padding(.bottom, 10)
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)

            if isExpanded && !entry.prompts.isEmpty {
                Divider()
                    .background(Color(hex: "#E4E4E4"))
                    .padding(.horizontal, 20)

                VStack(alignment: .leading, spacing: 20) {
                    Text("Reflection")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "#2B2834"))

                    ForEach(Array(entry.prompts.enumerated()), id: \.offset) { index, answer in
                        if !answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(getPromptQuestion(for: index))
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(hex: "#5B5564"))

                                Text(answer)
                                    .font(.system(size: 15))
                                    .foregroundColor(Color(hex: "#2B2834"))
                                    .padding(.leading, 6)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }

            if !entry.prompts.isEmpty {
                Divider()
                    .background(Color(hex: "#E4E4E4"))
                
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isExpanded.toggle()
                        }
                    }) {
                        HStack(spacing: 4) {
                            Text(isExpanded ? "Show less" : "Show reflection")
                                .font(.system(size: 14, weight: .medium))
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(Color(hex: "#2B2834"))
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .background(Color.clear)
                    .shadow(radius: 0)
                    Spacer()
                }
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
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
