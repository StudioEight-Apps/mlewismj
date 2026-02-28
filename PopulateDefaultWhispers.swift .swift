import Foundation
import FirebaseFirestore
import FirebaseAuth

extension JournalManager {

    // MARK: - Background Rotation (12 backgrounds)
    private static let backgroundRotation: [(background: String, textColor: String)] = [
        ("forest_green", "#C5FFB3"),
        ("whisper_bg_deepreds", "#F5EDE5"),
        ("sunkissed_whisper", "#42210B"),
        ("whisper_bg_cream", "#1F2E78"),
        ("whisper_bg_goldenblend", "#3E2A1C"),
        ("blue_static", "#F9C99D"),
        ("whisper_bg_espressofade", "#EEDFCB"),
        ("whisper_color_poeticwine", "#F4F1EC"),
        ("whisper_texture_peeledpaper", "#1A1A1A"),
        ("whisper_texture_bluetexture", "#2F2F2F"),
        ("whisper_bg_crinkledbeige", "#5B3520"),
        ("whisper_bg_charcoalgrain", "#F5E8D8"),
    ]

    // MARK: - Voice 1: Naval Energy
    private static let navalWhispers: [(text: String, mood: String)] = [
        ("The world doesn't ignore clarity.", "motivated"),
        ("What worries you, masters you.", "anxious"),
        ("Create more than you consume.", "motivated"),
        ("Attention is your life. Spend it carefully.", "reflective"),
        ("Most suffering is arguing with reality.", "stressed"),
        ("Be an observer of your thoughts, not a prisoner.", "calm"),
        ("What you believe about yourself becomes your reality.", "hopeful"),
        ("Focusing on the past steals both your present and your future.", "reflective"),
        ("You are not your thoughts, you are the witness.", "calm"),
        ("Escape competition through authenticity.", "motivated"),
        ("A kick in the teeth may be the best thing in the world for you.", "stressed"),
        ("You can escape reality, but not the consequences of escaping reality.", "reflective"),
        ("The most important decision you make is to be in a good mood.", "calm"),
        ("Do not disturb yourself by imagining your whole life at once.", "anxious"),
        ("The next level of your life requires a calmer you.", "stressed"),
    ]

    // MARK: - Voice 2: WeTheUrban × WNRS
    private static let urbanWhispers: [(text: String, mood: String)] = [
        ("You have yet to meet everyone who is going to love you.", "hopeful"),
        ("Fall in love with your own potential.", "motivated"),
        ("Go do some main character stuff today.", "excited"),
        ("You're not behind. You're being prepared.", "anxious"),
        ("The version of you that's coming will thank you for not giving up.", "tired"),
        ("You were not meant to play small.", "motivated"),
        ("Be open to the idea that your best days are still ahead.", "hopeful"),
        ("You deserve connections that don't make you question your worth.", "sad"),
        ("Tell people what they mean to you while they're still here.", "reflective"),
        ("Be so focused on growth that comparison fades.", "insecure"),
        ("Stop comparing yourself to people who don't even know you exist.", "insecure"),
        ("You will always be your oldest friend. Take care of you.", "lonely"),
        ("Be the reason why people believe in beautiful souls.", "calm"),
        ("Believe that things can suddenly change in your favor.", "hopeful"),
        ("It is your life, be the main character of it.", "motivated"),
    ]

    // MARK: - Voice 3: Stoic Operator
    private static let stoicWhispers: [(text: String, mood: String)] = [
        ("Discipline is the purest form of self-respect.", "motivated"),
        ("Ready is not a feeling. It's a decision.", "anxious"),
        ("Every day you prove you can start again.", "tired"),
        ("Life is short. You must act before you are ready.", "stressed"),
        ("Stop waiting for the right moment. Create it.", "motivated"),
        ("Consistency looks like nothing is happening, until everything changes.", "frustrated"),
        ("Feelings are something you have, not something you are.", "overwhelmed"),
        ("You can miss someone and still know you made the right choice.", "sad"),
        ("Growth doesn't always feel good, but it's always worth it.", "stressed"),
        ("You are under no obligation to be the person you were yesterday.", "reflective"),
        ("What you create is an honest reflection of who you are.", "calm"),
        ("Do it. No one is watching. Just go for it.", "anxious"),
        ("The privilege of a lifetime is becoming who you truly are.", "hopeful"),
        ("To be a star, you must burn.", "motivated"),
        ("Change is uncomfortable, but necessary.", "stressed"),
    ]

    // MARK: - Voice 4: Soft Spiritual Guide
    private static let guideWhispers: [(text: String, mood: String)] = [
        ("Not every season is about growing.", "tired"),
        ("You don't need to rush your way through this life.", "stressed"),
        ("When something is for you, there is peace in it.", "calm"),
        ("Don't rush what's still aligning for you.", "anxious"),
        ("The peace you want begins where resistance ends.", "stressed"),
        ("Sometimes the healthiest move is to just let it be.", "overwhelmed"),
        ("It's okay if it takes a little longer than you thought.", "frustrated"),
        ("Trust, what's yours will arrive in peace, not chaos.", "anxious"),
        ("You haven't met all of you yet.", "hopeful"),
        ("Forgive yourself for not knowing what only time could teach.", "sad"),
        ("Remember when you wanted what you currently have.", "reflective"),
        ("Sit alone. You will find all your answers.", "calm"),
        ("Beautiful days do not come to you. You must walk toward them.", "motivated"),
        ("The light for the path gets brighter the further down it you go.", "hopeful"),
        ("Don't settle, and don't struggle. Life is what flows in between.", "calm"),
    ]

    // MARK: - Populate Default Whispers for New Users
    func populateDefaultWhispersForNewUser() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ No authenticated user - cannot populate default whispers")
            return
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)

        userRef.getDocument { [weak self] document, error in
            guard let self = self else { return }

            if let error = error {
                print("❌ Error checking default whispers flag: \(error.localizedDescription)")
                return
            }

            if let hasDefaultWhispers = document?.data()?["hasDefaultWhispers"] as? Bool, hasDefaultWhispers {
                print("ℹ️ User already has default whispers - skipping population")
                return
            }

            if !self.entries.isEmpty {
                print("ℹ️ User already has entries - skipping default whispers")
                return
            }

            // Get user's selected voice (defaults to 1 if not set)
            let voiceId = UserDefaults.standard.integer(forKey: "voice_id")
            let selectedVoiceId = voiceId > 0 ? voiceId : 1

            print("🎉 New user detected - populating 15 default whispers for voice \(selectedVoiceId)")

            // Select whispers based on voice ID
            let selectedWhispers: [(text: String, mood: String)]
            switch selectedVoiceId {
            case 1:
                selectedWhispers = JournalManager.navalWhispers
                print("📝 Using Naval Energy whispers")
            case 2:
                selectedWhispers = JournalManager.urbanWhispers
                print("📝 Using WeTheUrban × WNRS whispers")
            case 3:
                selectedWhispers = JournalManager.stoicWhispers
                print("📝 Using Stoic Operator whispers")
            case 4:
                selectedWhispers = JournalManager.guideWhispers
                print("📝 Using Soft Spiritual Guide whispers")
            default:
                selectedWhispers = JournalManager.navalWhispers
                print("📝 Defaulting to Naval Energy whispers")
            }

            let calendar = Calendar.current
            let today = Date()
            guard let sampleDate = calendar.date(byAdding: .day, value: -60, to: today) else {
                print("❌ Failed to calculate sample whisper date")
                return
            }

            // Build default entries with rotating backgrounds
            let defaultEntries: [JournalEntry] = selectedWhispers.enumerated().map { index, whisper in
                let bgIndex = index % JournalManager.backgroundRotation.count
                let bg = JournalManager.backgroundRotation[bgIndex]

                return JournalEntry(
                    date: sampleDate,
                    mood: whisper.mood,
                    text: whisper.text,
                    colorHex: colorForMood(whisper.mood),
                    prompts: ["", "", ""],
                    isFavorited: false,
                    isPinned: false,
                    journalType: .guided,
                    backgroundImage: bg.background,
                    textColor: bg.textColor
                )
            }

            // IMPORTANT: seed local state and widget immediately
            DispatchQueue.main.async {
                self.entries = defaultEntries
                self.syncEntriesToWidget()
            }

            // Save each entry to Firebase in the background
            for entry in defaultEntries {
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
                            print("❌ Failed to save default whisper: \(error.localizedDescription)")
                        }
                    }
            }

            userRef.setData(["hasDefaultWhispers": true], merge: true) { error in
                if let error = error {
                    print("❌ Failed to set default whispers flag: \(error.localizedDescription)")
                } else {
                    print("✅ Successfully populated 15 default whispers for voice \(selectedVoiceId)")
                }
            }
        }
    }
}
