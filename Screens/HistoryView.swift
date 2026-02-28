import SwiftUI

// MARK: - History View
struct HistoryView: View {
    var scrollToEntryId: String? = nil

    @ObservedObject var journalManager = JournalManager.shared
    @Environment(\.colorScheme) var colorScheme
    private var colors: AppColors { AppColors(colorScheme) }
    @State private var showingCalendar = false
    @State private var selectedDate: Date?
    @State private var scrollToDate: Date?
    @State private var filterByDate: Date?
    @State private var selectedTab: HistoryTab = .all

    enum HistoryTab { case all, favorites }

    var body: some View {
        ZStack {
            colors.secondaryBackground.ignoresSafeArea()

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
                        scrollToDate: $scrollToDate,
                        scrollToEntryId: scrollToEntryId
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
        .tint(colors.navTint)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("My Journal")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(colors.primaryText)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showingCalendar = true } label: {
                    Image(systemName: "calendar")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(colors.primaryText)
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
    @Environment(\.colorScheme) var colorScheme
    private var colors: AppColors { AppColors(colorScheme) }

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: isFavoritesTab ? "heart.fill" : "book.closed")
                .font(.system(size: 60))
                .foregroundColor(colors.emptyStateIcon)

            Text(isFavoritesTab ? "No favorites yet" : "No thoughts yet")
                .font(.title2).fontWeight(.medium)
                .foregroundColor(colors.primaryText)

            Text(isFavoritesTab
                 ? "Tap the heart on entries you love"
                 : (hasDateFilter ? "Try selecting a different date" : "Create your first thought to see it here"))
            .font(.body)
            .foregroundColor(colors.secondaryText)
            .multilineTextAlignment(.center)

            if hasDateFilter {
                Button("Show All Entries") { clearFilter() }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(AppColors.gold)
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
    @Environment(\.colorScheme) var colorScheme
    private var colors: AppColors { AppColors(colorScheme) }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Showing entries for:")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(colors.secondaryText)

                Text(DateFormatter.mediumDate.string(from: date))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(colors.primaryText)
            }

            Spacer()

            Button("Show All") { clearFilter() }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(AppColors.gold)
                .cornerRadius(16)
                .buttonStyle(.plain)
        }
        .padding(.vertical, 12)
        .background(colors.card.opacity(0.7))
        .cornerRadius(12)
    }
}

private struct EntryListView: View {
    let entries: [JournalEntry]
    @State private var localScrollToDate: Date?
    @Binding var scrollToDate: Date?
    var scrollToEntryId: String? = nil
    @State private var entryToDelete: JournalEntry?
    @State private var showDeleteAlert = false

    var body: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(entries, id: \.id) { entry in
                    ZStack {
                        NavigationLink(destination: JournalEntryDetailView(entryId: entry.id)) {
                            EmptyView()
                        }
                        .opacity(0)

                        HistoryCardView(entry: entry)
                    }
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
            .onAppear {
                if let entryId = scrollToEntryId {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            proxy.scrollTo(entryId, anchor: .top)
                        }
                    }
                }
            }
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
    @Environment(\.colorScheme) var colorScheme
    private var colors: AppColors { AppColors(colorScheme) }

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
            (colorScheme == .dark ? Color.black.opacity(0.7) : Color.black.opacity(0.3))
                .ignoresSafeArea()
                .onTapGesture { isPresented = false }

            VStack(spacing: 0) {
                HStack {
                    Spacer().frame(width: 44)
                    Spacer()
                    Text("Select Date")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(colors.primaryText)
                    Spacer()
                    Button { isPresented = false } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(colors.primaryText)
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
                        .foregroundColor(tempSelectedDate != nil ? .white : colors.placeholder)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(tempSelectedDate != nil ? AppColors.gold : colors.card)
                        .cornerRadius(12)
                }
                .buttonStyle(.plain)
                .disabled(tempSelectedDate == nil)
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
            .frame(width: UIScreen.main.bounds.width * 0.9)
            .background(colors.calendarPopup)
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
    @Environment(\.colorScheme) var colorScheme
    private var colors: AppColors { AppColors(colorScheme) }

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
                    .foregroundColor(colors.primaryText)
                Spacer()
            }

            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                        Text(day)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(colors.secondaryText)
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
    @Environment(\.colorScheme) var colorScheme
    private var colors: AppColors { AppColors(colorScheme) }

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
                         (isToday ? AppColors.gold : colors.calendarDayText))
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
                isSelected ? AppColors.gold :
                (entriesForDay.isEmpty ? Color.clear : AppColors.gold.opacity(0.1))
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

// MARK: - History Card — Clean summary, tap to open detail
struct HistoryCardView: View {
    @ObservedObject var journalManager = JournalManager.shared
    @Environment(\.colorScheme) var colorScheme
    private var colors: AppColors { AppColors(colorScheme) }
    let entry: JournalEntry

    private var liveEntry: JournalEntry {
        journalManager.entries.first(where: { $0.id == entry.id }) ?? entry
    }

    private var moodColor: Color { Color(hex: colorForMood(entry.mood)) }

    private var formattedDate: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: entry.date)
    }

    private var displayText: String {
        entry.text.isEmpty ? "A moment of reflection" : entry.text
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                Text(formattedDate)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(colors.secondaryText)

                Spacer()

                Text(entry.mood.capitalized)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "#2A2A2A"))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(moodColor)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 14)

            HStack(alignment: .top, spacing: 12) {
                Text(displayText)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(colors.primaryText)
                    .lineSpacing(4)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(colors.tertiaryText)
                    .padding(.top, 4)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)

            HStack(spacing: 6) {
                if liveEntry.isPinned {
                    Image(systemName: "pin.fill")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(colorScheme == .dark ? AppColors.gold : colors.primaryText)
                        .frame(width: 14, height: 14)
                }
                if liveEntry.isFavorited {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppColors.gold)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .background(
            ZStack {
                if colorScheme == .dark {
                    RoundedRectangle(cornerRadius: 18).fill(colors.card)
                        .shadow(color: Color.black.opacity(0.5), radius: 8, x: 0, y: 4)
                } else {
                    RoundedRectangle(cornerRadius: 18).fill(Color.white)
                        .shadow(color: Color.black.opacity(0.06), radius: 2, x: 0, y: 1)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                        .shadow(color: Color.black.opacity(0.06), radius: 24, x: 0, y: 12)
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(colorScheme == .dark ? colors.cardBorder : Color.black.opacity(0.06), lineWidth: 0.5)
        )
    }
}
