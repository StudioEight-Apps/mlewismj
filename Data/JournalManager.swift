import Foundation
import Combine
import FirebaseFirestore
import FirebaseAuth
import WidgetKit

class JournalManager: ObservableObject {
    static let shared = JournalManager()

    @Published var entries: [JournalEntry] = []
    @Published var isLoading = false
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    private var authStateListener: AuthStateDidChangeListenerHandle?
    private let sharedDefaults = UserDefaults(suiteName: "group.com.studioeight.mantra") ?? UserDefaults.standard

    private init() {
        setupAuthListener()
    }
    
    // MARK: - Auth Listener
    private func setupAuthListener() {
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            if let user = user {
                self?.loadUserEntries(userId: user.uid)
            } else {
                self?.clearEntries()
            }
        }
    }

    // MARK: - Save Entry to Firebase (Updated for V2)
    func saveEntry(
        mood: String,
        response1: String,
        response2: String,
        response3: String,
        mantra: String,
        journalType: JournalType = .guided
    ) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ No authenticated user - cannot save entry")
            return
        }
        
        let entry = JournalEntry(
            date: Date(),
            mood: mood,
            text: mantra,
            colorHex: colorForMood(mood),
            prompts: [response1, response2, response3],
            isFavorited: false,
            isPinned: false,
            journalType: journalType
        )

        entries.append(entry)
        saveToFirebase(entry: entry, userId: userId)
    }
    
    // MARK: - Toggle Favorite
    func toggleFavorite(_ entry: JournalEntry) {
        guard let userId = Auth.auth().currentUser?.uid,
              let index = entries.firstIndex(where: { $0.id == entry.id }) else {
            return
        }
        
        entries[index].isFavorited.toggle()
        
        db.collection("users")
          .document(userId)
          .collection("journalEntries")
          .document(entry.id)
          .updateData(["isFavorited": entries[index].isFavorited]) { error in
              if let error = error {
                  print("❌ Failed to update favorite status: \(error.localizedDescription)")
              }
          }
    }
    
    // MARK: - Toggle Pin (Only one can be pinned at a time)
    func togglePin(_ entry: JournalEntry) {
        guard let userId = Auth.auth().currentUser?.uid,
              let index = entries.firstIndex(where: { $0.id == entry.id }) else {
            return
        }
        
        let wasPinned = entries[index].isPinned
        
        // If pinning this entry, unpin all others
        if !wasPinned {
            for i in 0..<entries.count {
                if entries[i].isPinned {
                    entries[i].isPinned = false
                    updatePinStatusInFirebase(userId: userId, entryId: entries[i].id, isPinned: false)
                }
            }
        }
        
        // Toggle current entry
        entries[index].isPinned.toggle()
        updatePinStatusInFirebase(userId: userId, entryId: entry.id, isPinned: entries[index].isPinned)
        
        // Update widget with background
        if entries[index].isPinned {
            let background = BackgroundConfig.random()
            saveLatestMantraForWidget(
                entries[index].text,
                mood: entries[index].mood,
                backgroundImage: background.imageName,
                textColor: background.textColor
            )
        } else {
            clearWidget()
        }
    }
    
    private func updatePinStatusInFirebase(userId: String, entryId: String, isPinned: Bool) {
        db.collection("users")
          .document(userId)
          .collection("journalEntries")
          .document(entryId)
          .updateData(["isPinned": isPinned]) { error in
              if let error = error {
                  print("❌ Failed to update pin status: \(error.localizedDescription)")
              }
          }
    }
    
    // MARK: - Get Pinned Entry
    var pinnedEntry: JournalEntry? {
        entries.first(where: { $0.isPinned })
    }
    
    // MARK: - Get Favorited Entries
    var favoritedEntries: [JournalEntry] {
        entries.filter { $0.isFavorited }.sorted { $0.date > $1.date }
    }
    
    private func saveToFirebase(entry: JournalEntry, userId: String) {
        let entryData: [String: Any] = [
            "id": entry.id,
            "date": Timestamp(date: entry.date),
            "mood": entry.mood,
            "text": entry.text,
            "colorHex": entry.colorHex,
            "prompts": entry.prompts,
            "isFavorited": entry.isFavorited,
            "isPinned": entry.isPinned,
            "journalType": entry.journalType.rawValue,
            "createdAt": Timestamp(date: Date())
        ]
        
        db.collection("users")
          .document(userId)
          .collection("journalEntries")
          .document(entry.id)
          .setData(entryData) { error in
              if let error = error {
                  print("❌ Failed to save entry to Firebase: \(error.localizedDescription)")
                  DispatchQueue.main.async {
                      self.entries.removeAll { $0.id == entry.id }
                  }
              } else {
                  print("✅ Entry saved to Firebase successfully")
              }
          }
    }

    // MARK: - Load User Entries from Firebase
    private func loadUserEntries(userId: String) {
        isLoading = true
        
        listener = db.collection("users")
            .document(userId)
            .collection("journalEntries")
            .order(by: "date", descending: false)
            .addSnapshotListener { [weak self] querySnapshot, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                }
                
                if let error = error {
                    print("❌ Error loading entries: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("No journal entries found")
                    return
                }
                
                let loadedEntries = documents.compactMap { doc -> JournalEntry? in
                    let data = doc.data()
                    
                    guard let id = data["id"] as? String,
                          let timestamp = data["date"] as? Timestamp,
                          let mood = data["mood"] as? String,
                          let text = data["text"] as? String,
                          let colorHex = data["colorHex"] as? String,
                          let prompts = data["prompts"] as? [String] else {
                        print("❌ Invalid entry data for document: \(doc.documentID)")
                        return nil
                    }
                    
                    let isFavorited = data["isFavorited"] as? Bool ?? false
                    let isPinned = data["isPinned"] as? Bool ?? false
                    let journalTypeString = data["journalType"] as? String ?? "guided"
                    let journalType = JournalType(rawValue: journalTypeString) ?? .guided
                    
                    return JournalEntry(
                        id: id,
                        date: timestamp.dateValue(),
                        mood: mood,
                        text: text,
                        colorHex: colorHex,
                        prompts: prompts,
                        isFavorited: isFavorited,
                        isPinned: isPinned,
                        journalType: journalType
                    )
                }
                
                DispatchQueue.main.async {
                    self?.entries = loadedEntries
                    print("✅ Loaded \(loadedEntries.count) entries from Firebase")
                }
            }
    }
    
    // MARK: - Clear Entries
    private func clearEntries() {
        listener?.remove()
        listener = nil
        entries.removeAll()
        print("🔄 Cleared entries for signed out user")
    }
    
    // MARK: - Delete Entry
    func deleteEntry(_ entry: JournalEntry) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ No authenticated user - cannot delete entry")
            return
        }
        
        entries.removeAll { $0.id == entry.id }
        
        db.collection("users")
          .document(userId)
          .collection("journalEntries")
          .document(entry.id)
          .delete() { error in
              if let error = error {
                  print("❌ Failed to delete entry from Firebase: \(error.localizedDescription)")
                  DispatchQueue.main.async {
                      self.entries.append(entry)
                  }
              } else {
                  print("✅ Entry deleted from Firebase successfully")
              }
          }
    }
    
    // MARK: - Clear All Entries
    func clearAllEntries() {
        print("🗑️ JournalManager: Clearing all entries for account deletion")
        listener?.remove()
        listener = nil
        entries.removeAll()
        sharedDefaults.removeObject(forKey: "latestMantra")
        sharedDefaults.removeObject(forKey: "latestMood")
        sharedDefaults.removeObject(forKey: "widgetBackground")
        sharedDefaults.removeObject(forKey: "widgetTextColor")
        sharedDefaults.removeObject(forKey: "mantraTimestamp")
        WidgetCenter.shared.reloadAllTimelines()
        print("✅ JournalManager: All data cleared")
    }

    // MARK: - Widget Support
    func saveLatestMantraForWidget(_ mantra: String, mood: String, backgroundImage: String, textColor: String) {
        sharedDefaults.set(mantra, forKey: "latestMantra")
        sharedDefaults.set(mood, forKey: "latestMood")
        sharedDefaults.set(backgroundImage, forKey: "widgetBackground")
        sharedDefaults.set(textColor, forKey: "widgetTextColor")
        sharedDefaults.set(Date(), forKey: "mantraTimestamp")
        WidgetCenter.shared.reloadAllTimelines()
        print("✅ Mantra saved for widget: \(mantra) with background: \(backgroundImage)")
    }
    
    func clearWidget() {
        sharedDefaults.removeObject(forKey: "latestMantra")
        sharedDefaults.removeObject(forKey: "latestMood")
        sharedDefaults.removeObject(forKey: "widgetBackground")
        sharedDefaults.removeObject(forKey: "widgetTextColor")
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func getLatestWidgetData() -> (mantra: String, mood: String, backgroundImage: String, textColor: String, timestamp: Date)? {
        guard let mantra = sharedDefaults.string(forKey: "latestMantra"),
              let mood = sharedDefaults.string(forKey: "latestMood"),
              let backgroundImage = sharedDefaults.string(forKey: "widgetBackground"),
              let textColor = sharedDefaults.string(forKey: "widgetTextColor"),
              let timestamp = sharedDefaults.object(forKey: "mantraTimestamp") as? Date else {
            return nil
        }
        return (mantra: mantra, mood: mood, backgroundImage: backgroundImage, textColor: textColor, timestamp: timestamp)
    }
    
    func getLatestMantraForWidget() -> (mantra: String, mood: String)? {
        if let data = getLatestWidgetData() {
            return (data.mantra, data.mood)
        }
        return nil
    }
    
    // MARK: - Legacy Methods
    func save() {
        print("ℹ️ Legacy save() called - entries are auto-saved to Firebase")
    }

    func load() {
        print("ℹ️ Legacy load() called - entries are auto-loaded from Firebase")
    }
    
    // MARK: - Cleanup
    deinit {
        if let authStateListener = authStateListener {
            Auth.auth().removeStateDidChangeListener(authStateListener)
        }
        listener?.remove()
    }
}
