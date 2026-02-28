import Foundation

// MARK: - Voice Archetype Model

struct VoiceArchetype {
    let voiceId: Int
    let variations: [Variation]

    /// A single reveal combination — name, tagline, and writer pair
    struct Variation {
        let name: String
        let tagline: String
        let writers: [WriterReference]
    }

    struct WriterReference {
        let name: String
        let quote: String
    }

    /// Pick a random variation so the reveal feels unique
    func randomVariation() -> Variation {
        variations.randomElement() ?? variations[0]
    }
}


// MARK: - Archetype Definitions (3 variations each)

extension VoiceArchetype {

    static func archetype(for voiceId: Int) -> VoiceArchetype {
        switch voiceId {
        case 1: return observer
        case 2: return empath
        case 3: return commander
        case 4: return sage
        default: return observer
        }
    }

    // ─────────────────────────────────────────────
    // Voice 1 — Naval Energy
    // Detached intelligence, observational truth
    // ─────────────────────────────────────────────

    static let observer = VoiceArchetype(
        voiceId: 1,
        variations: [
            Variation(
                name: "The Observer",
                tagline: "Detached clarity. Truth that cuts through noise.",
                writers: [
                    WriterReference(
                        name: "Naval Ravikant",
                        quote: "A calm mind, a fit body, a house full of love."
                    ),
                    WriterReference(
                        name: "Seneca",
                        quote: "We suffer more in imagination than in reality."
                    ),
                    WriterReference(
                        name: "Marcus Aurelius",
                        quote: "You have power over your mind, not outside events. Realize this, and you will find strength."
                    )
                ]
            ),
            Variation(
                name: "The Thinker",
                tagline: "Sharp perception. Quiet logic over loud emotion.",
                writers: [
                    WriterReference(
                        name: "Albert Camus",
                        quote: "In the depth of winter, I learned that within me lay an invincible summer."
                    ),
                    WriterReference(
                        name: "Epictetus",
                        quote: "It's not what happens to you, but how you react that matters."
                    ),
                    WriterReference(
                        name: "Naval Ravikant",
                        quote: "The most important skill is the ability to control your own mind."
                    )
                ]
            ),
            Variation(
                name: "The Realist",
                tagline: "Self-trust. Seeing the world without flinching.",
                writers: [
                    WriterReference(
                        name: "Ralph Waldo Emerson",
                        quote: "Do not go where the path may lead. Go where there is no path."
                    ),
                    WriterReference(
                        name: "Seneca",
                        quote: "Luck is what happens when preparation meets opportunity."
                    ),
                    WriterReference(
                        name: "Albert Camus",
                        quote: "Life is the sum of all your choices."
                    )
                ]
            )
        ]
    )

    // ─────────────────────────────────────────────
    // Voice 2 — Urban / WNRS
    // Soft confidence, screenshot-worthy affirmation
    // ─────────────────────────────────────────────

    static let empath = VoiceArchetype(
        voiceId: 2,
        variations: [
            Variation(
                name: "The Empath",
                tagline: "Soft confidence. Words that make you feel seen.",
                writers: [
                    WriterReference(
                        name: "Maya Angelou",
                        quote: "There is no greater agony than bearing an untold story inside you."
                    ),
                    WriterReference(
                        name: "Kahlil Gibran",
                        quote: "Out of suffering have emerged the strongest souls."
                    ),
                    WriterReference(
                        name: "Nikki Giovanni",
                        quote: "We love because it's the only true adventure."
                    )
                ]
            ),
            Variation(
                name: "The Dreamer",
                tagline: "Bold vulnerability. Beauty in the becoming.",
                writers: [
                    WriterReference(
                        name: "Toni Morrison",
                        quote: "You are your best thing."
                    ),
                    WriterReference(
                        name: "Zora Neale Hurston",
                        quote: "There are years that ask questions and years that answer."
                    ),
                    WriterReference(
                        name: "Langston Hughes",
                        quote: "Hold fast to dreams, for if dreams die, life is a broken-winged bird that cannot fly."
                    )
                ]
            ),
            Variation(
                name: "The Believer",
                tagline: "Unwavering self-worth. Light that refuses to dim.",
                writers: [
                    WriterReference(
                        name: "James Baldwin",
                        quote: "Not everything that is faced can be changed, but nothing can be changed until it is faced."
                    ),
                    WriterReference(
                        name: "Maya Angelou",
                        quote: "We delight in the beauty of the butterfly, but rarely admit the changes it has gone through."
                    ),
                    WriterReference(
                        name: "Kahlil Gibran",
                        quote: "Your living is determined not so much by what life brings to you as by what you bring to life."
                    )
                ]
            )
        ]
    )

    // ─────────────────────────────────────────────
    // Voice 3 — Stoic Operator
    // Discipline, calm command, no-nonsense
    // ─────────────────────────────────────────────

    static let commander = VoiceArchetype(
        voiceId: 3,
        variations: [
            Variation(
                name: "The Commander",
                tagline: "Calm discipline. Says what needs to be said.",
                writers: [
                    WriterReference(
                        name: "Marcus Aurelius",
                        quote: "Waste no more time arguing about what a good man should be. Be one."
                    ),
                    WriterReference(
                        name: "Ernest Hemingway",
                        quote: "There is nothing to writing. All you do is sit down and bleed."
                    ),
                    WriterReference(
                        name: "David Goggins",
                        quote: "You are in danger of living a life so comfortable and soft that you will die without ever realizing your potential."
                    )
                ]
            ),
            Variation(
                name: "The Warrior",
                tagline: "Controlled intensity. Action over hesitation.",
                writers: [
                    WriterReference(
                        name: "Miyamoto Musashi",
                        quote: "Think lightly of yourself and deeply of the world."
                    ),
                    WriterReference(
                        name: "Sun Tzu",
                        quote: "In the midst of chaos, there is also opportunity."
                    ),
                    WriterReference(
                        name: "Bruce Lee",
                        quote: "Do not pray for an easy life. Pray for the strength to endure a difficult one."
                    )
                ]
            ),
            Variation(
                name: "The Builder",
                tagline: "Relentless standards. Respect earned through action.",
                writers: [
                    WriterReference(
                        name: "Theodore Roosevelt",
                        quote: "Do what you can, with what you have, where you are."
                    ),
                    WriterReference(
                        name: "Marcus Aurelius",
                        quote: "The impediment to action advances action. What stands in the way becomes the way."
                    ),
                    WriterReference(
                        name: "Jocko Willink",
                        quote: "Discipline equals freedom."
                    )
                ]
            )
        ]
    )

    // ─────────────────────────────────────────────
    // Voice 4 — Soft Spiritual Guide
    // Gentle, present-moment, grounding
    // ─────────────────────────────────────────────

    static let sage = VoiceArchetype(
        voiceId: 4,
        variations: [
            Variation(
                name: "The Sage",
                tagline: "Gentle wisdom. Present, patient, and grounding.",
                writers: [
                    WriterReference(
                        name: "Rumi",
                        quote: "The wound is the place where the light enters you."
                    ),
                    WriterReference(
                        name: "Lao Tzu",
                        quote: "Nature does not hurry, yet everything is accomplished."
                    ),
                    WriterReference(
                        name: "Eckhart Tolle",
                        quote: "Realize deeply that the present moment is all you ever have."
                    )
                ]
            ),
            Variation(
                name: "The Seeker",
                tagline: "Mindful stillness. Peace as a practice.",
                writers: [
                    WriterReference(
                        name: "Thich Nhat Hanh",
                        quote: "Walk as if you are kissing the Earth with your feet."
                    ),
                    WriterReference(
                        name: "Alan Watts",
                        quote: "Muddy water is best cleared by leaving it alone."
                    ),
                    WriterReference(
                        name: "Rumi",
                        quote: "Silence is the language of God. All else is poor translation."
                    )
                ]
            ),
            Variation(
                name: "The Poet",
                tagline: "Tender awareness. Finding meaning in the quiet.",
                writers: [
                    WriterReference(
                        name: "Rumi",
                        quote: "What you seek is seeking you."
                    ),
                    WriterReference(
                        name: "Rabindranath Tagore",
                        quote: "You can't cross the sea merely by standing and staring at the water."
                    ),
                    WriterReference(
                        name: "Khalil Gibran",
                        quote: "The deeper that sorrow carves into your being, the more joy you can contain."
                    )
                ]
            )
        ]
    )
}


// MARK: - Voice Question Data

struct VoiceQuestionData {
    let key: String
    let headline: String
    let subheadline: String
    let options: [VoiceOption]
    var useQuoteStyle: Bool = false

    struct VoiceOption {
        let text: String
        let voiceId: Int
    }
}

extension VoiceQuestionData {

    static let allQuestions: [VoiceQuestionData] = [
        q1_innerVoice,
        q2_selfTalk,
        q3_stressResponse,
        q4_hardestPart,
        q5_trustAdvice,
        q6_endOfDay,
        q7_quoteResonance,
        q8_overthinking
    ]

    // Q1: What does your inner voice sound like?
    static let q1_innerVoice = VoiceQuestionData(
        key: "inner_voice",
        headline: "Which of these sounds most like your inner voice?",
        subheadline: "",
        options: [
            VoiceOption(text: "I'm always analyzing, trying to make sense of it all.", voiceId: 1),
            VoiceOption(text: "I feel things deeply. Sometimes too deeply.", voiceId: 2),
            VoiceOption(text: "I know what I'm capable of. Time to prove it.", voiceId: 3),
            VoiceOption(text: "It is what it is. I'll figure it out.", voiceId: 4)
        ]
    )

    // Q2: What do you tell yourself in hard moments?
    static let q2_selfTalk = VoiceQuestionData(
        key: "self_talk",
        headline: "What do you tell yourself when things get hard?",
        subheadline: "",
        options: [
            VoiceOption(text: "Figure it out. You always do.", voiceId: 1),
            VoiceOption(text: "This is making you stronger.", voiceId: 2),
            VoiceOption(text: "Get up. No one's coming to save you.", voiceId: 3),
            VoiceOption(text: "This will pass. It always does.", voiceId: 4)
        ]
    )

    // Q3: When everything hits at once
    static let q3_stressResponse = VoiceQuestionData(
        key: "stress_response",
        headline: "When everything hits at once, your first instinct is to…",
        subheadline: "",
        options: [
            VoiceOption(text: "Map out every possible outcome.", voiceId: 1),
            VoiceOption(text: "Go quiet. I need to process alone.", voiceId: 2),
            VoiceOption(text: "Push through. I'll rest when it's done.", voiceId: 3),
            VoiceOption(text: "Let it ride. I trust it'll work out.", voiceId: 4)
        ]
    )

    // Q4: What takes the most energy
    static let q4_hardestPart = VoiceQuestionData(
        key: "hardest_part",
        headline: "What takes the most energy in your day?",
        subheadline: "",
        options: [
            VoiceOption(text: "Making sense of everything in my head", voiceId: 1),
            VoiceOption(text: "Holding space for how I feel and what others need", voiceId: 2),
            VoiceOption(text: "Staying patient when I know where I want to be", voiceId: 3),
            VoiceOption(text: "Slowing down enough to actually enjoy it", voiceId: 4)
        ]
    )

    // Q5: What kind of advisor resonates
    static let q5_trustAdvice = VoiceQuestionData(
        key: "trust_advice",
        headline: "When you need real advice, you trust someone who…",
        subheadline: "",
        options: [
            VoiceOption(text: "Tells you the truth, even when it's uncomfortable", voiceId: 1),
            VoiceOption(text: "Believes in you, even when you don't", voiceId: 2),
            VoiceOption(text: "Pushes you to be better, with respect", voiceId: 3),
            VoiceOption(text: "Listens first, then speaks gently", voiceId: 4)
        ]
    )

    // Q6: What do you need at end of day
    static let q6_endOfDay = VoiceQuestionData(
        key: "end_of_day",
        headline: "At the end of a long day, what do you reach for?",
        subheadline: "",
        options: [
            VoiceOption(text: "A new perspective. Something to reframe it.", voiceId: 1),
            VoiceOption(text: "A reminder that I'm on the right track", voiceId: 2),
            VoiceOption(text: "Something that fires me up for tomorrow", voiceId: 3),
            VoiceOption(text: "Permission to just breathe and let it go", voiceId: 4)
        ]
    )

    // Q7: Direct quote preference (quote card style, 2x weight)
    static let q7_quoteResonance = VoiceQuestionData(
        key: "quote_resonance",
        headline: "Pick the message that speaks to you most.",
        subheadline: "",
        options: [
            VoiceOption(text: "What worries you, masters you.", voiceId: 1),
            VoiceOption(text: "You have yet to meet everyone who is going to love you.", voiceId: 2),
            VoiceOption(text: "Ready is not a feeling. It's a decision.", voiceId: 3),
            VoiceOption(text: "Beautiful days do not come to you. You must walk toward them.", voiceId: 4)
        ],
        useQuoteStyle: true
    )

    // Q8: Scenario — how they want to be spoken to (2x weight)
    static let q8_overthinking = VoiceQuestionData(
        key: "overthinking",
        headline: "Your mind won't stop running.",
        subheadline: "Which response feels most like what you need?",
        options: [
            VoiceOption(text: "Step back. Observe it without reacting.", voiceId: 1),
            VoiceOption(text: "You've been through worse. You'll get through this too.", voiceId: 2),
            VoiceOption(text: "Stop thinking. Start doing.", voiceId: 3),
            VoiceOption(text: "Let it be. Not everything needs solving right now.", voiceId: 4)
        ]
    )
}
