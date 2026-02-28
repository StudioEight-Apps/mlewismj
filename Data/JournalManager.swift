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

    // MARK: - Widget Keys (App Group)
    private enum WidgetKeys {
        static let hasPinnedEntry = "hasPinnedEntry"
        static let latestMantra = "latestMantra"
        static let latestMood = "latestMood"
        static let widgetBackground = "widgetBackground"
        static let widgetTextColor = "widgetTextColor"
        static let widgetAlignment = "widgetAlignment"
        static let mantraTimestamp = "mantraTimestamp"
        static let allEntries = "allEntries"
    }

    /// Clears pinned payload keys so the widget cannot keep rendering stale pinned content after unpin.
    private func clearPinnedWidgetPayload() {
        sharedDefaults.removeObject(forKey: WidgetKeys.latestMantra)
        sharedDefaults.removeObject(forKey: WidgetKeys.latestMood)
        sharedDefaults.removeObject(forKey: WidgetKeys.widgetBackground)
        sharedDefaults.removeObject(forKey: WidgetKeys.widgetTextColor)
        sharedDefaults.removeObject(forKey: WidgetKeys.widgetAlignment)
        sharedDefaults.removeObject(forKey: WidgetKeys.mantraTimestamp)
    }

    /// Writes a widget-safe "latest" payload. Used for pinned mode and as a rotation fallback.
    private func writeLatestWidgetPayload(mantra: String, mood: String, backgroundImage: String, textColor: String, timestamp: Date = Date()) {
        let alignment = BackgroundConfig.widgetAlignmentString(for: backgroundImage)
        sharedDefaults.set(mantra, forKey: WidgetKeys.latestMantra)
        sharedDefaults.set(mood, forKey: WidgetKeys.latestMood)
        sharedDefaults.set(backgroundImage, forKey: WidgetKeys.widgetBackground)
        sharedDefaults.set(textColor, forKey: WidgetKeys.widgetTextColor)
        sharedDefaults.set(alignment, forKey: WidgetKeys.widgetAlignment)
        sharedDefaults.set(timestamp, forKey: WidgetKeys.mantraTimestamp)
    }

    /// Ensures the widget always has something renderable (prevents grey placeholder on fresh installs / empty states).
    private func ensureWidgetRenderableFallbackIfNeeded() {
        if sharedDefaults.string(forKey: WidgetKeys.latestMantra) != nil { return }
        writeLatestWidgetPayload(
            mantra: "How are you feeling today?",
            mood: "calm",
            backgroundImage: "whisper_bg_crinkledbeige",
            textColor: "#5B3520",
            timestamp: Date()
        )
        sharedDefaults.set(false, forKey: WidgetKeys.hasPinnedEntry)
    }

    private func reloadWidgets() {
        WidgetCenter.shared.reloadTimelines(ofKind: "MantraWidget")
        WidgetCenter.shared.reloadAllTimelines()
    }

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

    // MARK: - Save Entry to Firebase (Updated for V3)
    func saveEntry(
        mood: String,
        response1: String,
        response2: String,
        response3: String,
        mantra: String,
        journalType: JournalType = .guided,
        backgroundImage: String,
        textColor: String,
        promptQuestions: [String] = []
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
            promptQuestions: promptQuestions,
            isFavorited: false,
            isPinned: false,
            journalType: journalType,
            backgroundImage: backgroundImage,
            textColor: textColor
        )

        entries.append(entry)
        saveToFirebase(entry: entry, userId: userId)
        
        // Sync to widget for rotation
        syncEntriesToWidget()
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
        
        if entries[index].isPinned {
            // PINNING
            // Set flag first so the widget reload will see pinned mode
            sharedDefaults.set(true, forKey: WidgetKeys.hasPinnedEntry)
            
            saveLatestMantraForWidget(
                entries[index].text,
                mood: entries[index].mood,
                backgroundImage: entries[index].backgroundImage,
                textColor: entries[index].textColor
            )
            
            WidgetCenter.shared.reloadTimelines(ofKind: "MantraWidget")
            WidgetCenter.shared.reloadAllTimelines()
        } else {
            // UNPINNING
            // Switch to rotation mode immediately
            sharedDefaults.set(false, forKey: WidgetKeys.hasPinnedEntry)

            // Clear pinned payload so WidgetKit cannot keep showing the last pinned whisper forever.
            clearPinnedWidgetPayload()

            // Ensure rotation entries are synced, and write an immediate fallback "latest" payload for render safety.
            syncEntriesToWidget()
            if let fallback = entries.first(where: { $0.id != entry.id }) ?? entries.first {
                writeLatestWidgetPayload(
                    mantra: fallback.text,
                    mood: fallback.mood,
                    backgroundImage: fallback.backgroundImage,
                    textColor: fallback.textColor,
                    timestamp: Date()
                )
            } else {
                ensureWidgetRenderableFallbackIfNeeded()
            }

            reloadWidgets()
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
            "promptQuestions": entry.promptQuestions,
            "isFavorited": entry.isFavorited,
            "isPinned": entry.isPinned,
            "journalType": entry.journalType.rawValue,
            "backgroundImage": entry.backgroundImage,
            "textColor": entry.textColor,
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
                    
                    let promptQuestions = data["promptQuestions"] as? [String] ?? []
                    let isFavorited = data["isFavorited"] as? Bool ?? false
                    let isPinned = data["isPinned"] as? Bool ?? false
                    let journalTypeString = data["journalType"] as? String ?? "guided"
                    let journalType = JournalType(rawValue: journalTypeString) ?? .guided
                    let backgroundImage = data["backgroundImage"] as? String ?? "whisper-bg-1"
                    let textColor = data["textColor"] as? String ?? "#FFFFFF"

                    return JournalEntry(
                        id: id,
                        date: timestamp.dateValue(),
                        mood: mood,
                        text: text,
                        colorHex: colorHex,
                        prompts: prompts,
                        promptQuestions: promptQuestions,
                        isFavorited: isFavorited,
                        isPinned: isPinned,
                        journalType: journalType,
                        backgroundImage: backgroundImage,
                        textColor: textColor
                    )
                }
                
                DispatchQueue.main.async {
                    self?.entries = loadedEntries
                    print("✅ Loaded \(loadedEntries.count) entries from Firebase")
                    
                    // Sync entries to widget for rotation feature
                    self?.syncEntriesToWidget()
                }
            }
    }
    
    // MARK: - Clear Entries
    private func clearEntries() {
        listener?.remove()
        listener = nil
        entries.removeAll()
        
        // Clear widget cache on sign out so one account never shows another account's data
        clearWidgetCacheForSignOut()
        
        print("🔄 Cleared entries for signed out user")
    }
    
    private func clearWidgetCacheForSignOut() {
        sharedDefaults.removeObject(forKey: WidgetKeys.latestMantra)
        sharedDefaults.removeObject(forKey: WidgetKeys.latestMood)
        sharedDefaults.removeObject(forKey: WidgetKeys.widgetBackground)
        sharedDefaults.removeObject(forKey: WidgetKeys.widgetTextColor)
        sharedDefaults.removeObject(forKey: WidgetKeys.mantraTimestamp)
        sharedDefaults.removeObject(forKey: WidgetKeys.hasPinnedEntry)
        sharedDefaults.removeObject(forKey: WidgetKeys.allEntries)
        WidgetCenter.shared.reloadTimelines(ofKind: "MantraWidget")
        WidgetCenter.shared.reloadAllTimelines()
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
                  DispatchQueue.main.async {
                      self.syncEntriesToWidget()
                  }
              }
          }
    }
    
    // MARK: - Clear All Entries
    func clearAllEntries() {
        print("🗑️ JournalManager: Clearing all entries for account deletion")
        listener?.remove()
        listener = nil
        entries.removeAll()
        
        sharedDefaults.removeObject(forKey: WidgetKeys.latestMantra)
        sharedDefaults.removeObject(forKey: WidgetKeys.latestMood)
        sharedDefaults.removeObject(forKey: WidgetKeys.widgetBackground)
        sharedDefaults.removeObject(forKey: WidgetKeys.widgetTextColor)
        sharedDefaults.removeObject(forKey: WidgetKeys.mantraTimestamp)
        sharedDefaults.removeObject(forKey: WidgetKeys.hasPinnedEntry)
        sharedDefaults.removeObject(forKey: WidgetKeys.allEntries)
        
        WidgetCenter.shared.reloadTimelines(ofKind: "MantraWidget")
        WidgetCenter.shared.reloadAllTimelines()
        print("✅ JournalManager: All data cleared")
    }

    // MARK: - Widget Support
    func saveLatestMantraForWidget(_ mantra: String, mood: String, backgroundImage: String, textColor: String) {
        writeLatestWidgetPayload(mantra: mantra, mood: mood, backgroundImage: backgroundImage, textColor: textColor, timestamp: Date())
        reloadWidgets()
        print("✅ Mantra saved for widget: \(mantra) with background: \(backgroundImage)")
    }
    
    func clearWidget() {
        clearPinnedWidgetPayload()
        sharedDefaults.removeObject(forKey: WidgetKeys.allEntries)
        sharedDefaults.set(false, forKey: WidgetKeys.hasPinnedEntry)
        reloadWidgets()
    }
    
    // MARK: - Widget Auto-Rotation Support
    func syncEntriesToWidget() {
        guard !entries.isEmpty else {
            // Keep widget renderable even when there are no entries yet (fresh install / new account).
            sharedDefaults.removeObject(forKey: WidgetKeys.allEntries)
            ensureWidgetRenderableFallbackIfNeeded()
            reloadWidgets()
            print("📱 Widget: No entries to sync for rotation - wrote fallback payload")
            return
        }
        
        let simplifiedEntries: [[String: String]] = entries.map { entry in
            let bg = entry.backgroundImage.trimmingCharacters(in: .whitespacesAndNewlines)
            let safeBackground = bg.isEmpty ? "whisper_bg_crinkledbeige" : bg

            let tc = entry.textColor.trimmingCharacters(in: .whitespacesAndNewlines)
            let safeTextColor = tc.isEmpty ? "#5B3520" : tc
            
            let alignment = BackgroundConfig.widgetAlignmentString(for: safeBackground)

            return [
                "mantra": entry.text,
                "mood": entry.mood,
                "backgroundImage": safeBackground,
                "textColor": safeTextColor,
                "widgetAlignment": alignment
            ]
        }
        
        if let encoded = try? JSONEncoder().encode(simplifiedEntries) {
            sharedDefaults.set(encoded, forKey: WidgetKeys.allEntries)
            WidgetCenter.shared.reloadAllTimelines()
            print("✅ Widget: Synced \(simplifiedEntries.count) entries for rotation")
        } else {
            print("❌ Widget: Failed to encode entries for rotation")
        }
    }
    
    func getLatestWidgetData() -> (mantra: String, mood: String, backgroundImage: String, textColor: String, timestamp: Date)? {
        guard let mantra = sharedDefaults.string(forKey: WidgetKeys.latestMantra),
              let mood = sharedDefaults.string(forKey: WidgetKeys.latestMood),
              let backgroundImage = sharedDefaults.string(forKey: WidgetKeys.widgetBackground),
              let textColor = sharedDefaults.string(forKey: WidgetKeys.widgetTextColor),
              let timestamp = sharedDefaults.object(forKey: WidgetKeys.mantraTimestamp) as? Date else {
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
