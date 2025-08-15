import Foundation

struct PromptQuestionBank {
    static let questions: [String: [String]] = [
        // STRESSED
        "stressed_phase1": [
            "Describe exactly how your body feels right now. Where is the tension sitting, and what is it trying to tell you?",
            "If you had to explain your current stress level to someone else, what would you say is causing it, and how long has it been building?",
            "What were the signs that you were starting to feel stressed today—were there specific thoughts, reactions, or physical shifts?",
            "What does 'being stressed' usually look like for you? Is this moment typical or something different?",
            "Can you walk through the moment when the stress really started to spike? What happened, and how did your body react?",
            "If this stress had a color or texture, what would it be? Try to describe it in a way that externalizes the feeling."
        ],
        "stressed_phase2": [
            "What responsibilities or pressures are feeling the heaviest right now? Which ones are self-imposed vs. external?",
            "What thoughts are making the stress feel bigger or more urgent than it might actually be?",
            "When you zoom out, is there a recurring pattern to this stress? Does it remind you of past situations or fears?",
            "What expectation are you holding yourself to right now—and is it reasonable or compassionate?",
            "Is there something you're avoiding because it feels too overwhelming to face? How is that affecting your stress?",
            "Have you taken on anything recently that tipped your balance? What boundary might have been missed?"
        ],
        "stressed_phase3": [
            "What would change if you allowed yourself to step back or slow down—even just for today?",
            "What's one thing you can gently remove or say no to in order to protect your peace?",
            "If you could delegate or delay one thing, what would it be—and how would that help you breathe easier?",
            "What reminder or truth helps you re-center when things feel out of control?",
            "What would self-kindness look like in the middle of this stress—not after it ends, but right now?",
            "What's one calming action or ritual you could do today that would help regulate your nervous system?"
        ],
        
        // FRUSTRATED
        "frustrated_phase1": [
            "Describe what frustration feels like in your body right now. Are you tense, restless, or holding something in?",
            "Walk through the moment you started feeling frustrated today. What happened, and how did you respond?",
            "If your frustration had a voice, what would it be saying out loud right now?",
            "Is this frustration directed at someone, something, or yourself? Explain the story behind it.",
            "What's been building up or repeating that's finally pushed you into this feeling?",
            "How does this frustration show up in your behavior—snapping, shutting down, withdrawing? Describe what's playing out."
        ],
        "frustrated_phase2": [
            "What expectation isn't being met right now—by yourself, someone else, or a situation?",
            "Is this a moment where you feel powerless or unheard? What do you wish others understood?",
            "How long has this issue been bothering you—and has it shown up before in similar ways?",
            "What boundary feels like it's been crossed or ignored? Be specific.",
            "Are you reacting only to this moment, or is it connected to something older or deeper?",
            "What are you craving underneath the frustration—control, respect, ease, validation?"
        ],
        "frustrated_phase3": [
            "What would it feel like to soften your grip on this just a little?",
            "What's one action you could take to release this frustration in a healthy way—physically, creatively, emotionally?",
            "If you gave yourself permission to step away from this issue for a moment, what would open up for you?",
            "What can you accept in this situation, even if it's not ideal?",
            "What would it look like to respond from a place of calm instead of reactivity?",
            "What part of this frustration can you let go of so it doesn't carry into the rest of your day?"
        ],
        
        // OVERWHELMED
        "overwhelmed_phase1": [
            "Describe what being overwhelmed feels like in your body right now. Are you buzzing, heavy, frozen, or scattered?",
            "What's running through your mind on a loop today? Try to unload the mental clutter onto the page.",
            "When did the feeling of overwhelm start building? Can you trace it back to a specific trigger or moment?",
            "Is this an emotional, mental, or physical overwhelm—or a mix? Walk through how it's affecting you.",
            "What signs have you noticed that you're nearing your limit? Be honest about the cues your body and mind are sending.",
            "If your overwhelm had a metaphor—like a wave, a traffic jam, a spinning wheel—what would it be? Describe it fully."
        ],
        "overwhelmed_phase2": [
            "List out everything you feel like you're carrying right now. Which parts feel heaviest—and which ones could be set down?",
            "What expectations or pressures are stacking on top of each other to create this overwhelmed state?",
            "Is there something you're afraid will fall apart if you don't handle it perfectly?",
            "Have you been here before—this exact feeling? What patterns do you notice about how you deal with overwhelm?",
            "What voices in your mind are making things feel more urgent or intense than they need to be?",
            "Are you over-functioning to prove something—to yourself or someone else? What's underneath that pressure?"
        ],
        "overwhelmed_phase3": [
            "What would it look like to pause, breathe, and just focus on the next *one* thing?",
            "If you gave yourself permission to lower the bar today, what could shift?",
            "What's something small—but meaningful—you could release from your to-do list right now?",
            "How can you ground yourself today in the present, even if just for a few minutes?",
            "What kind of support would make this moment feel more manageable—and are you willing to ask for it?",
            "What would change if you stopped trying to do it all perfectly and just let it be enough?"
        ],
        
        // ANXIOUS
        "anxious_phase1": [
            "Describe exactly what anxiety feels like in your body right now—tight chest, jittery hands, racing heart, or something else?",
            "What thoughts are circling in your mind today, and how fast are they moving? Try to slow them down and write them out.",
            "If your anxiety had a voice, what would it be saying over and over again?",
            "When did this anxious feeling start—was there a trigger or has it been building quietly?",
            "What urges are showing up with this anxiety—do you want to escape, fix something, hide, or seek reassurance?",
            "How does this kind of anxiety usually show up for you? Is today's version familiar or different?"
        ],
        "anxious_phase2": [
            "What are you afraid might happen if things don't go the way you want them to?",
            "Are you trying to control something that isn't really yours to control? What would happen if you let go, even a little?",
            "What story are you telling yourself right now—about yourself, others, or the future—and how true is it?",
            "Does this anxiety feel connected to something from your past? When else have you felt this way before?",
            "What are you avoiding by staying in this anxious state—any hard decision, truth, or feeling?",
            "What part of you is trying to protect you with this anxiety, and can you name what it's afraid of?"
        ],
        "anxious_phase3": [
            "What would it feel like to move through today without needing all the answers right now?",
            "What is one grounding action you could take today to reconnect to your body or breath?",
            "If you let this anxiety be here without resisting it, what would shift in your body or mind?",
            "What's still true, good, or stable in your life even in this moment of unease?",
            "What would you say to a close friend who felt exactly like this? Can you offer that same kindness to yourself?",
            "What's one small thing you can do to feel just 5% safer or calmer right now?"
        ],
        
        // ANGRY
        "angry_phase1": [
            "Describe how anger is showing up in your body right now—tight jaw, clenched fists, heat, tension, or something else?",
            "What moment triggered the anger today, and how did it build? Walk through it in detail.",
            "If your anger had a shape, sound, or movement—what would it look or feel like?",
            "What did your body instinctively want to do when this anger hit—lash out, shut down, speak up, or walk away?",
            "How long have you been carrying this anger—did it start today or has it been building under the surface?",
            "Does this anger feel familiar? Is it part of a pattern or something that surprises you?"
        ],
        "angry_phase2": [
            "What boundary feels like it was crossed—by someone else or even by yourself?",
            "What are you really wanting underneath this anger—respect, space, validation, fairness, or something else?",
            "Are you holding onto any assumptions or unspoken expectations that added fuel to the fire?",
            "Is there any grief, disappointment, or fear hiding underneath the anger? What might it be protecting?",
            "Was your anger allowed to be expressed in healthy ways growing up—or did you have to hide or suppress it?",
            "What story are you replaying about this situation that's keeping the anger alive?"
        ],
        "angry_phase3": [
            "What would it look like to move this energy through your body—without harm or suppression?",
            "What part of this situation can you control—and what part can you release for your own peace?",
            "What would forgiveness (for them or for yourself) look like in this moment, even if it's just a first step?",
            "If you could express what you really need—without blame—what would you say?",
            "What's one way you can take care of yourself in the aftermath of this emotion?",
            "What can this anger teach you about your values, needs, or sense of self-worth?"
        ],
        
        // SAD
        "sad_phase1": [
            "Describe where you feel the sadness in your body—is it heavy, numb, aching, or tight anywhere?",
            "When did this sadness begin today—and was there a moment or memory that sparked it?",
            "If your sadness had a weather pattern, what would it be? Try to describe it as a full experience.",
            "How would you explain this feeling to someone who cares about you deeply?",
            "Is the sadness sharp and sudden, or slow and quiet? Describe the texture and pace of it.",
            "What thoughts or memories keep surfacing with this sadness? Write them out without judgment."
        ],
        "sad_phase2": [
            "What have you lost, missed, or longed for that might be connected to this feeling?",
            "Is this sadness connected to something unspoken—words you didn't say, emotions you didn't show?",
            "Does this moment of sadness remind you of anything from your past? What old story might be resurfacing?",
            "Have you been carrying this sadness alone? Who would understand if you shared it?",
            "What are you telling yourself about why you're feeling this way—and is it a kind story?",
            "Is there something you're grieving—not just a person, but maybe a version of yourself or a moment that passed?"
        ],
        "sad_phase3": [
            "What's one gentle thing you can offer yourself right now—comfort, softness, permission to rest?",
            "If sadness is part of being human, what does it mean about your capacity to feel, to care, to love?",
            "What would it look like to let the sadness be here without trying to solve it immediately?",
            "What beauty, softness, or truth still exists in your life, even alongside the sadness?",
            "How might this feeling shift if you allowed yourself to express it fully—through writing, tears, or movement?",
            "What's one memory or moment of connection that reminds you that joy is still possible?"
        ],
        
        // LONELY
        "lonely_phase1": [
            "Describe how loneliness feels in your body today—is it heavy, hollow, tense, restless?",
            "When did the feeling of loneliness start today? Was there a specific moment, thought, or silence?",
            "What are you most craving right now—touch, presence, conversation, or simply to be understood?"
        ],
        "lonely_phase2": [
            "What connection feels missing right now? Is it with someone specific, or just a sense of belonging?",
            "When was the last time you felt truly seen or accepted? What made that moment different?",
            "Have you been holding back from reaching out or letting others in? If so, what's stopping you?"
        ],
        "lonely_phase3": [
            "What would it look like to show up for yourself the way you wish someone else would?",
            "Is there one small act of connection you can offer or receive today—even a message, smile, or moment of presence?",
            "What kind of connection do you most want to build in your life—and what's one small step toward it?"
        ],
        
        // TIRED
        "tired_phase1": [
            "Describe the kind of tired you're feeling—is it physical, emotional, mental, or all of the above?",
            "Where in your body does the exhaustion live today—eyes, chest, shoulders, stomach?",
            "What has your body been trying to tell you today that your mind may have ignored?"
        ],
        "tired_phase2": [
            "What (or who) has been draining your energy lately without giving much back?",
            "What kind of rest do you really need—sleep, solitude, stillness, emotional release?",
            "Have you been trying to prove something by staying busy? If so, to whom?"
        ],
        "tired_phase3": [
            "What's one thing you could set down, even temporarily, to protect your energy?",
            "If your rest was sacred instead of selfish, how would you honor it today?",
            "What's one small act of nourishment you could give yourself before the day ends?"
        ],
        
        // INSECURE
        "insecure_phase1": [
            "Describe what insecurity feels like in your body right now—tight chest, shrinking posture, racing thoughts?",
            "What triggered this feeling today? Was it something someone said, something you saw, or something you told yourself?",
            "What have you been questioning about yourself today, even if it's hard to admit?"
        ],
        "insecure_phase2": [
            "What part of you is longing for approval or validation right now?",
            "Are you comparing yourself to someone else today? What's the story you're telling in that comparison?",
            "What do you believe you need to prove in order to feel enough—and is that belief helping or hurting you?"
        ],
        "insecure_phase3": [
            "What's one true thing about you that doesn't change based on someone else's opinion?",
            "What would it look like to meet this insecure part of you with kindness, instead of critique?",
            "If a close friend felt exactly this way, what would you remind them of—and can you tell yourself the same?"
        ],
        
        // FINE
        "fine_phase1": [
            "When you say you're feeling 'fine,' what does that really mean today—calm, numb, neutral, distracted?",
            "Does this version of 'fine' feel stable and true—or like something you're saying to avoid digging deeper?",
            "If someone asked how you're really doing and you had to go one layer deeper, what would you say?"
        ],
        "fine_phase2": [
            "What have you been moving through lately that might be quietly affecting you?",
            "Are you going through the motions in any area of your life—work, relationships, routines?",
            "When was the last time you felt fully lit up or deeply moved by something?"
        ],
        "fine_phase3": [
            "What's one small thing that could turn today from 'fine' to fulfilling?",
            "What would happen if you gave yourself permission to feel more deeply today—even if it's messy?",
            "If 'fine' is a protective shell, what's trying to grow underneath it?"
        ],
        
        // CALM
        "calm_phase1": [
            "Describe what calm feels like in your body right now—is there softness, stillness, looseness, or quiet?",
            "When did this feeling of calm begin today, and what helped create it?",
            "Does this calm feel earned, fleeting, or deeply rooted? Explain what makes it feel that way."
        ],
        "calm_phase2": [
            "What choices, habits, or boundaries have supported this sense of calm lately?",
            "What used to disrupt your peace that no longer holds power over you?",
            "What does calm give you access to—clarity, creativity, patience, joy?"
        ],
        "calm_phase3": [
            "How can you preserve or expand this feeling of calm into the rest of your day?",
            "What would it look like to build your life around this calm instead of chasing it?",
            "How can you help someone else experience a moment of calm today, just by how you show up?"
        ],
        
        // CONTENT
        "content_phase1": [
            "Describe what contentment feels like in your body right now—where do you feel at ease, light, or grounded?",
            "What's contributing to this sense of contentment today—big or small?",
            "What are you not needing or chasing today that you often find yourself wanting?"
        ],
        "content_phase2": [
            "What habits, people, or choices have helped create this sense of balance in your life?",
            "How is this version of contentment different from settling or playing small?",
            "What's currently 'enough' in your life—and how does it feel to acknowledge that?"
        ],
        "content_phase3": [
            "What's one small thing you can do to sustain this contentment through the week ahead?",
            "What's worth protecting in your current lifestyle, pace, or mindset?",
            "How can you return to this state more intentionally when life pulls you out of it?"
        ],
        
        // REFLECTIVE
        "reflective_phase1": [
            "What's been sitting in the back of your mind lately—an idea, memory, question, or tension?",
            "What's something you've been turning over quietly, trying to understand more clearly?",
            "Is your reflection focused more on the past, the present, or something unfolding in the future?"
        ],
        "reflective_phase2": [
            "What patterns or themes are you starting to notice in your thoughts, actions, or emotions lately?",
            "What part of your story are you beginning to see with new eyes?",
            "What are you learning about your needs, boundaries, or desires in this current season of life?"
        ],
        "reflective_phase3": [
            "What insight from today's reflection feels worth holding onto or writing down for future-you?",
            "What's one small shift you could make based on what you've noticed or learned today?",
            "How can you move forward with more clarity or intention after reflecting like this?"
        ],
        
        // HAPPY
        "happy_phase1": [
            "Describe what happiness feels like in your body right now—is there lightness, energy, warmth, or ease?",
            "What sparked this happy feeling today? Walk through the moment or memory in detail.",
            "How long has it been since you felt this way—and what makes today different?"
        ],
        "happy_phase2": [
            "What choices, habits, or people have contributed to your happiness lately?",
            "How does this feeling align with your values or what truly matters to you?",
            "What does this happiness say about who you are becoming?"
        ],
        "happy_phase3": [
            "What's one way you can celebrate or savor this feeling before the day ends?",
            "How might you create more space for this kind of happiness in your daily life?",
            "What kind of life are you building if you follow the feeling you're experiencing right now?"
        ],
        
        // GRATEFUL
        "grateful_phase1": [
            "What's one thing—big or small—you feel genuinely thankful for today, and why does it matter to you?",
            "Where do you feel gratitude in your body right now? Is it warm, expansive, still, or energizing?",
            "What's one simple pleasure or overlooked detail that you're appreciating more than usual today?"
        ],
        "grateful_phase2": [
            "What has someone done for you—recently or in the past—that you still carry with you today?",
            "What challenges or hardships have made you more appreciative of what you have now?",
            "How does feeling grateful shift the way you see your current situation?"
        ],
        "grateful_phase3": [
            "What's one small act you can do today to express your gratitude—out loud, in writing, or in action?",
            "How can you build more intentional moments of gratitude into your day or week?",
            "How does this gratitude remind you of who you want to be and how you want to show up in the world?"
        ],
        
        // EXCITED
        "excited_phase1": [
            "Describe how excitement feels in your body right now—buzzy, light, open, energized?",
            "What exactly are you feeling excited about today—and what sparked it?",
            "What are you imagining or looking forward to that's making this moment feel alive?"
        ],
        "excited_phase2": [
            "What does this excitement say about what matters most to you right now?",
            "How does this moment connect to a goal, dream, or personal value?",
            "What opportunity or shift are you standing at the edge of right now?"
        ],
        "excited_phase3": [
            "What would it look like to fully embrace this moment without shrinking or downplaying it?",
            "What's one action you can take today that honors this excitement and keeps it moving forward?",
            "How can this excitement remind you of your capacity to grow, stretch, and create something meaningful?"
        ],
        
        // HOPEFUL
        "hopeful_phase1": [
            "What's giving you a sense of hope right now, even if it's small or quiet?",
            "Where in your body or mind do you feel the hope—lightness, openness, ease, or expansion?",
            "Is your hope connected to a future moment, a dream, a relationship, or a shift inside yourself?"
        ],
        "hopeful_phase2": [
            "What challenge are you currently navigating that hope is helping you face?",
            "What evidence—past or present—supports your belief that things can get better?",
            "Are you hopeful for something external to change—or for something inside of you to grow?"
        ],
        "hopeful_phase3": [
            "What's one small action you can take that aligns with the hope you're holding today?",
            "If you fully trusted this hope, how would you show up differently this week?",
            "How can you nurture this hope daily, even if progress feels slow or invisible?"
        ],
        
        // MOTIVATED
        "motivated_phase1": [
            "Describe what motivation feels like in your body right now—energized, focused, driven, or purposeful?",
            "What's sparking this motivated feeling today? What do you feel called to do or create?",
            "Is this motivation coming from excitement, necessity, or something deeper?"
        ],
        "motivated_phase2": [
            "What goal or vision is pulling you forward right now, and why does it matter to you?",
            "What obstacles have you overcome recently that prove you can handle what's ahead?",
            "How does this motivation connect to who you want to become?"
        ],
        "motivated_phase3": [
            "What's one concrete action you can take today that moves you toward what you want?",
            "How can you sustain this motivated energy even when it gets challenging?",
            "What would success look like if you followed this motivation all the way through?"
        ],

        // LOST
        "lost_phase1": [
            "When did you first begin to feel lost, and what was happening around you at the time?",
            "What specific thoughts or situations are contributing to this sense of being lost?",
            "How does this feeling show up in your body—tension, fatigue, restlessness?",
            "What emotions are layered beneath the surface of feeling lost?",
            "Are there specific decisions or crossroads in your life that feel unclear right now?",
            "If you had to describe this feeling as a metaphor or image, what would it be?"
        ],
        "lost_phase2": [
            "Have you felt this way before? What patterns or past experiences might be repeating?",
            "What deeper need might be hidden beneath your feeling of being lost—clarity, belonging, direction?",
            "Is there a part of you that is resisting change, uncertainty, or letting go?",
            "What expectations (your own or others') might be adding pressure or confusion right now?",
            "What do you fear could happen if you make the 'wrong' move or choice?",
            "If this feeling could speak, what would it be trying to tell you about what matters most?"
        ],
        "lost_phase3": [
            "What would it look like to take one small step toward direction or clarity today?",
            "What can you do to offer yourself patience and grace as you navigate uncertainty?",
            "Who or what can you lean on for support, grounding, or wisdom right now?",
            "What past experiences show your ability to find your way—even slowly?",
            "If being lost is part of the process, what might it be preparing you for?",
            "What intention can you set today, even if you're still unsure of the full path?"
        ],

        // EMPTY
        "empty_phase1": [
            "When did you first notice this sense of emptiness, and what was happening around you?",
            "Where in your body do you feel this emptiness most strongly, and how would you describe it physically?",
            "What thoughts tend to arise when you feel emotionally empty or disconnected?",
            "How has your energy, motivation, or engagement with life been affected by this feeling?",
            "Are there particular people, situations, or events that seem to intensify this emptiness?",
            "If you could give this emptiness a shape, color, or sound, what would it be?"
        ],
        "empty_phase2": [
            "What needs, desires, or parts of yourself might be going unmet or unexpressed right now?",
            "In what ways might you be emotionally disconnected—from yourself, others, or purpose?",
            "Has there been a recent loss, transition, or period of burnout that might be contributing to this feeling?",
            "What beliefs do you hold about needing to feel 'full' or 'fulfilled' all the time?",
            "Are there any old patterns of avoidance, suppression, or self-neglect that might be surfacing?",
            "If your emptiness were trying to get your attention, what might it want you to notice or tend to?"
        ],
        "empty_phase3": [
            "What small acts of care, connection, or creativity help you feel more grounded or alive?",
            "How can you begin to gently refill yourself—emotionally, spiritually, or physically?",
            "What does your inner voice or intuition say you might be needing most right now?",
            "Who or what brings a sense of warmth, meaning, or presence into your life?",
            "How can you reframe this emptiness not as a void, but as space for something new to emerge?",
            "What would it look like to honor this season without rushing to escape it?"
        ],

        // PEACEFUL
        "peaceful_phase1": [
            "Where in your body do you feel this sense of peace most strongly?",
            "What triggered this peaceful state, and what were you doing or thinking before it arrived?",
            "How does your breathing, posture, or presence shift when you feel peaceful?",
            "What specific thoughts or sensations are contributing to your calm right now?",
            "Is there anything you're consciously letting go of that has created space for peace?",
            "How would you describe this peace—is it stillness, warmth, clarity, or something else?"
        ],
        "peaceful_phase2": [
            "What has allowed you to arrive at this peaceful state—internally or externally?",
            "In contrast to moments of stress or noise, what feels different about your perspective right now?",
            "Are there any practices, boundaries, or habits that have supported this peace?",
            "What does this peaceful moment reveal about what truly matters to you?",
            "Is there anything that usually disrupts this peace, and how can you better protect it?",
            "What can this peacefulness teach you about your needs, values, or emotional balance?"
        ],
        "peaceful_phase3": [
            "How can you anchor this feeling so it's easier to return to in moments of chaos?",
            "What rituals or routines could help you cultivate more peace in your daily life?",
            "How might you extend this peace to someone else today—through presence, kindness, or listening?",
            "What would it look like to live more consistently from this place of inner calm?",
            "How can you remind yourself that peace is always accessible, even in small doses?",
            "What intention can you carry forward from this moment to protect your inner stillness?"
        ],

        // INSPIRED
        "inspired_phase1": [
            "What specifically sparked this feeling of inspiration today?",
            "Where in your body do you feel this sense of creative or motivational energy?",
            "What thoughts or ideas are most alive in you right now?",
            "How does this inspiration affect your posture, energy level, or focus?",
            "Is this inspiration directed toward something specific or more open-ended?",
            "What environment or conditions contributed to this inspired state?"
        ],
        "inspired_phase2": [
            "What about this moment or idea resonates so deeply with you?",
            "Have you felt a similar wave of inspiration before—when and why?",
            "What values or dreams are being awakened by this inspiration?",
            "What patterns or desires does this moment connect to in your personal journey?",
            "Is there any fear, doubt, or resistance surfacing alongside the inspiration?",
            "What is this inspired feeling trying to tell you about your potential or purpose?"
        ],
        "inspired_phase3": [
            "What's one small step you can take today to act on this inspiration?",
            "How can you sustain this energy without forcing or burning it out?",
            "What would it look like to fully honor this idea or moment of clarity?",
            "How can you protect time and space for inspiration to arise more often?",
            "Who might benefit from you sharing this spark—even in a small way?",
            "What commitment can you make to yourself right now to move this forward?"
        ],

        // ENERGIZED
        "energized_phase1": [
            "What has contributed most to your feeling of energy today?",
            "Where in your body do you notice this surge of vitality or alertness?",
            "How would you describe the type of energy you're experiencing—physical, mental, emotional?",
            "When did you first notice this shift in energy?",
            "What activities or thoughts have amplified this feeling?",
            "What is your immediate impulse or desire with this energy right now?"
        ],
        "energized_phase2": [
            "What does this energy say about your current alignment with your goals or environment?",
            "Have there been times recently when you lacked this energy—what changed?",
            "Is this feeling connected to something you're passionate about or excited for?",
            "What patterns or habits tend to lead you into states like this?",
            "Are there any boundaries or limits you might need to maintain while feeling so driven?",
            "What internal message or need might this energy be highlighting?"
        ],
        "energized_phase3": [
            "How can you intentionally channel this energy into something meaningful today?",
            "What would it look like to sustain this level of energy in a healthy way?",
            "What routines or practices support you in accessing this kind of momentum regularly?",
            "Is there anyone you could uplift or support with your current energy?",
            "How can you reflect gratitude for this state while it's present?",
            "What might today look like if you used this energy with clarity and purpose?"
        ],

        // NERVOUS
        "nervous_phase1": [
            "What specific situation or thought is making you feel nervous right now?",
            "Where in your body do you feel the nervousness most clearly?",
            "When did this feeling start, and what seemed to trigger it?",
            "How would you describe this nervousness—is it sharp, buzzing, tense, or something else?",
            "What thoughts keep looping in your mind as you sit with this feeling?",
            "What do you fear might happen, and how likely does that outcome actually feel?"
        ],
        "nervous_phase2": [
            "Have you felt this type of nervousness before—if so, when and why?",
            "What deeper concern or insecurity might be hiding beneath the surface of this emotion?",
            "What part of this situation feels most uncertain or outside of your control?",
            "Is there a belief about yourself or your abilities that this nervousness is challenging?",
            "What would it mean if the worst-case scenario happened—how would you respond?",
            "What is this nervous energy trying to protect or prepare you for?"
        ],
        "nervous_phase3": [
            "What's one small action you could take to feel more grounded or prepared?",
            "What truth or reminder helps you stay centered during uncertain moments like this?",
            "How can you reframe this nervousness as anticipation, readiness, or care?",
            "What self-compassionate message would you offer to a friend feeling the same way?",
            "What has helped calm your nerves in the past—can you lean into that now?",
            "What does courage look like for you in this exact situation, even with the nerves?"
        ],

        // DRAINED
        "drained_phase1": [
            "What situations, tasks, or interactions today have contributed most to this drained feeling?",
            "Where do you physically feel the exhaustion in your body right now?",
            "When did you first notice this low-energy state—has it been building for a while?",
            "Are you mentally, emotionally, or physically drained—or a combination of these?",
            "What signs does your body or mind give you when you're reaching your limit?",
            "What thoughts keep surfacing alongside this feeling of being depleted?"
        ],
        "drained_phase2": [
            "Are there patterns in your life that repeatedly lead to this kind of burnout?",
            "What responsibilities or expectations might be draining more energy than they give back?",
            "Is there something you're holding onto emotionally that's weighing you down?",
            "How often do you give yourself permission to rest without guilt?",
            "What are you currently overextending yourself for—and why?",
            "What unmet needs might be contributing to your feeling of depletion?"
        ],
        "drained_phase3": [
            "What boundaries could you set or reinforce to protect your energy?",
            "What would it look like to truly prioritize your restoration today?",
            "What gentle reminders or truths help you let go of overworking or overgiving?",
            "How can you invite softness and stillness into the next few hours or days?",
            "What's one thing you can release right now to lighten your load?",
            "What's one small act of self-care that feels manageable and nourishing?"
        ]
    ]
    
    static func getQuestion(for mood: String, phase: Int) -> String {
        let key = "\(mood.lowercased())_phase\(phase)"
        let options = questions[key] ?? ["What are you feeling right now?"]
        return options.randomElement() ?? options[0]
    }
}
