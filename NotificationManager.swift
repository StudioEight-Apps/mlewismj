import Foundation
import UserNotifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "notificationsEnabled")
            if isEnabled {
                scheduleDaily()
            } else {
                cancelAll()
            }
        }
    }

    @Published var reminderHour: Int {
        didSet {
            UserDefaults.standard.set(reminderHour, forKey: "reminderHour")
            if isEnabled { scheduleDaily() }
        }
    }

    @Published var reminderMinute: Int {
        didSet {
            UserDefaults.standard.set(reminderMinute, forKey: "reminderMinute")
            if isEnabled { scheduleDaily() }
        }
    }

    /// Whether the user has granted system notification permission
    @Published var permissionGranted: Bool = false

    /// Deep link flag — when true, app opens to journal with free journal highlighted
    @Published var shouldOpenFreeJournal: Bool = false

    private init() {
        self.isEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        self.reminderHour = UserDefaults.standard.object(forKey: "reminderHour") as? Int ?? 20  // Default 8 PM
        self.reminderMinute = UserDefaults.standard.object(forKey: "reminderMinute") as? Int ?? 0
        checkPermission()
    }

    // MARK: - Permission

    func requestPermission(completion: @escaping (Bool) -> Void = { _ in }) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                self.permissionGranted = granted
                if granted && self.isEnabled {
                    self.scheduleDaily()
                }
                completion(granted)
            }
        }
    }

    func checkPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.permissionGranted = settings.authorizationStatus == .authorized
            }
        }
    }

    // MARK: - Scheduling

    func scheduleDaily() {
        // Remove old notification before scheduling new one
        cancelAll()

        let content = UNMutableNotificationContent()
        content.title = "Whisper"
        content.body = randomReminderMessage()
        content.sound = .default
        content.userInfo = ["action": "openFreeJournal"]

        var dateComponents = DateComponents()
        dateComponents.hour = reminderHour
        dateComponents.minute = reminderMinute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "whisper-daily-reminder", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Notification scheduling error: \(error.localizedDescription)")
            } else {
                print("✅ Daily reminder scheduled for \(self.reminderHour):\(String(format: "%02d", self.reminderMinute))")
            }
        }
    }

    func cancelAll() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["whisper-daily-reminder"])
    }

    // MARK: - Notification Tap Handler

    func handleNotificationTap(userInfo: [AnyHashable: Any]) {
        if let action = userInfo["action"] as? String, action == "openFreeJournal" {
            DispatchQueue.main.async {
                self.shouldOpenFreeJournal = true
            }
        }
    }

    // MARK: - Formatted Time

    var formattedTime: String {
        let hour12 = reminderHour % 12 == 0 ? 12 : reminderHour % 12
        let period = reminderHour < 12 ? "AM" : "PM"
        return "\(hour12):\(String(format: "%02d", reminderMinute)) \(period)"
    }

    /// Date representation for DatePicker binding
    var reminderDate: Date {
        get {
            var components = DateComponents()
            components.hour = reminderHour
            components.minute = reminderMinute
            return Calendar.current.date(from: components) ?? Date()
        }
        set {
            let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
            reminderHour = components.hour ?? 20
            reminderMinute = components.minute ?? 0
        }
    }

    // MARK: - Time-Aware Reminder Messages

    private func randomReminderMessage() -> String {
        let morningMessages = [
            "Hey, how are you feeling?",
            "What would a successful day look like?",
            "Good morning, what's on your mind?",
            "What are you working toward today?"
        ]

        let afternoonMessages = [
            "Hey, how are you feeling?",
            "Any thoughts you want to dump?",
            "What was the best part of today?",
            "What did today teach you?"
        ]

        let lateNightMessages = [
            "Go to sleep with a clear mind. Dump some thoughts.",
            "Any thoughts you want to dump?",
            "How was today, actually?"
        ]

        let messages: [String]
        if reminderHour < 12 {
            messages = morningMessages
        } else if reminderHour < 20 {
            messages = afternoonMessages
        } else {
            messages = lateNightMessages
        }

        return messages.randomElement() ?? messages[0]
    }
}
