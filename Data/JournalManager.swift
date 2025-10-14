import Foundation
import Combine
import FirebaseFirestore
import FirebaseAuth
import WidgetKit

class JournalManager: ObservableObject {
    static let shared = JournalManager()

    // Use @Published to trigger view updates
    @Published var entries: [JournalEntry] = []
    @Published var isLoading = false
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    private var authStateListener: AuthStateDidChangeListenerHandle?
    
    // Widget support
    private let sharedDefaults = UserDefaults.standard

    private init() {
        // Load entries when user signs in
        setupAuthListener()
    }
    
    // MARK: - Auth Listener - FIXED: Updated to new Firebase syntax
    private func setupAuthListener() {
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            if let user = user {
                self?.loadUserEntries(userId: user.uid)
            } else {
                self?.clearEntries()
            }
        }
    }

    // MARK: - Save Entry to Firebase
    func saveEntry(
        mood: String,
        response1: String,
        response2: String,
        response3: String,
        mantra: String
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
            prompts: [response1, response2, response3]
        )

        // Add to local array immediately for UI responsiveness
        entries.append(entry)
        
        // Save to Firebase
        saveToFirebase(entry: entry, userId: userId)
        
        // Save latest mantra for widget
        saveLatestMantraForWidget(mantra, mood: mood)
    }
    
    private func saveToFirebase(entry: JournalEntry, userId: String) {
        let entryData: [String: Any] = [
            "id": entry.id,
            "date": Timestamp(date: entry.date),
            "mood": entry.mood,
            "text": entry.text,
            "colorHex": entry.colorHex,
            "prompts": entry.prompts,
            "createdAt": Timestamp(date: Date())
        ]
        
        db.collection("users")
          .document(userId)
          .collection("journalEntries")
          .document(entry.id)
          .setData(entryData) { error in
              if let error = error {
                  print("❌ Failed to save entry to Firebase: \(error.localizedDescription)")
                  // Remove from local array if Firebase save failed
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
        
        // Set up real-time listener
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
                    
                    return JournalEntry(
                        id: id,
                        date: timestamp.dateValue(),
                        mood: mood,
                        text: text,
                        colorHex: colorHex,
                        prompts: prompts
                    )
                }
                
                DispatchQueue.main.async {
                    self?.entries = loadedEntries
                    print("✅ Loaded \(loadedEntries.count) entries from Firebase")
                }
            }
    }
    
    // MARK: - Clear Entries (on sign out)
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
        
        // Remove from local array immediately
        entries.removeAll { $0.id == entry.id }
        
        // Delete from Firebase
        db.collection("users")
          .document(userId)
          .collection("journalEntries")
          .document(entry.id)
          .delete() { error in
              if let error = error {
                  print("❌ Failed to delete entry from Firebase: \(error.localizedDescription)")
                  // Re-add to local array if Firebase delete failed
                  DispatchQueue.main.async {
                      self.entries.append(entry)
                  }
              } else {
                  print("✅ Entry deleted from Firebase successfully")
              }
          }
    }
    
    // MARK: - Clear All Entries (for account deletion)
    /// Called when user deletes their account
    /// Removes all local data, stops listeners, and clears widget data
    func clearAllEntries() {
        print("🗑️ JournalManager: Clearing all entries for account deletion")
        
        // Stop listening to Firestore
        listener?.remove()
        listener = nil
        
        // Clear all journal entries from memory
        entries.removeAll()
        
        // Clear widget data
        sharedDefaults.removeObject(forKey: "latestMantra")
        sharedDefaults.removeObject(forKey: "latestMood")
        sharedDefaults.removeObject(forKey: "mantraTimestamp")
        
        // Refresh widgets to show empty state
        WidgetCenter.shared.reloadAllTimelines()
        
        print("✅ JournalManager: All data cleared")
    }

    // MARK: - Widget Support
    func saveLatestMantraForWidget(_ mantra: String, mood: String) {
        sharedDefaults.set(mantra, forKey: "latestMantra")
        sharedDefaults.set(mood, forKey: "latestMood")
        sharedDefaults.set(Date(), forKey: "mantraTimestamp")
        
        // Trigger widget refresh
        WidgetCenter.shared.reloadAllTimelines()
        
        print("✅ Mantra saved for widget: \(mantra)")
    }
    
    func getLatestWidgetData() -> (mantra: String, mood: String, timestamp: Date)? {
        guard let mantra = sharedDefaults.string(forKey: "latestMantra"),
              let mood = sharedDefaults.string(forKey: "latestMood"),
              let timestamp = sharedDefaults.object(forKey: "mantraTimestamp") as? Date else {
            return nil
        }
        return (mantra: mantra, mood: mood, timestamp: timestamp)
    }
    
    // Legacy method for backward compatibility
    func getLatestMantraForWidget() -> (mantra: String, mood: String)? {
        if let data = getLatestWidgetData() {
            return (data.mantra, data.mood)
        }
        return nil
    }
    
    // MARK: - Legacy Methods (kept for compatibility)
    func save() {
        // This method is now handled automatically by saveEntry()
        print("ℹ️ Legacy save() called - entries are auto-saved to Firebase")
    }

    func load() {
        // This method is now handled automatically by auth listener
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
