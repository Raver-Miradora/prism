import 'dart:math';
import 'mentor_knowledge_base.dart';

/// Offline keyword-matching knowledge engine for the PRISM Mentor.
/// Strictly scoped to: PRISM app navigation, LGU Lagonoy procedures,
/// and DOLE/CSC internship rules.
class PrismMentorService {
  // ──────────────────────────────────────────────────────────────────────────
  // Public API
  // ──────────────────────────────────────────────────────────────────────────

  static String getResponse(String input) {
    // Aggressive cleaning: lowercase, trim, and strip punctuation
    final lower = input.toLowerCase().trim().replaceAll(RegExp(r'[^\w\s]'), '');

    // ── Conversational & Emoji Handling ──────────────────────────────────────
    if (_isEmojiOrVeryShort(lower)) {
      return _getGreetingResponse();
    }

    // ── Standard Matching ────────────────────────────────────────────────────
    
    // 1. Run topic match first — if it hits, return immediately.
    final topicResponse = _matchTopic(lower);
    if (topicResponse != null) return topicResponse;

    // 2. Aggressive Default Refusal (Catch-All)
    // Check if it's off-topic based on signals OR substantial length without hits.
    if (_isOffTopic(lower)) {
      return "I am strictly programmed to assist with **PRISM app navigation** "
          "and **LGU Lagonoy procedures**. I cannot fulfill outside requests.";
    }

    // 3. Dynamic Fallback Roulette
    // Soft fallback — related but unrecognised phrasing.
    return _getRandomFallback();
  }

  /// Returns a list of suggested follow-up questions based on the last topic.
  static List<String> getSuggestions(String input) {
    final q = input.toLowerCase().trim().replaceAll(RegExp(r'[^\w\s]'), '');
    
    // Look for a specific knowledge match first
    for (var entry in MentorKnowledgeBase.knowledgeGraph.entries) {
      if (_any(q, entry.key)) {
        return List<String>.from(entry.value['suggestions'] ?? []);
      }
    }

    // Default discovery suggestions
    return ['DTR Rules', 'Dress Code', 'OJT Academy Info', 'Generating PDF'];
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Topic routing
  // ──────────────────────────────────────────────────────────────────────────

  static String? _matchTopic(String q) {
    // Basic Keyword Map Lookup
    for (var entry in MentorKnowledgeBase.knowledgeGraph.entries) {
      if (_any(q, entry.key)) {
        return entry.value['response'];
      }
    }

    return null; // no match
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Guardrails
  // ──────────────────────────────────────────────────────────────────────────

  static bool _isOffTopic(String q) {
    const offTopicSignals = [
      'poem', 'joke', 'story', 'write me', 'tell me a', 'sing',
      'recipe', 'math', 'weather', 'news', 'movie', 'music', 'game',
      'dating', 'love', 'translate', 'code for me', 'write code', 'hello world',
      'c++', 'java', 'python', 'javascript', 'programming',
    ];

    if (offTopicSignals.any((signal) => q.contains(signal))) return true;

    if (q.length > 10) {
      const inScopeSeeds = [
        'lgu', 'prism', 'hrmo', 'intern', 'dole', 'csc', 'spes', 'gip',
        'ojt', 'dtr', 'timesheet', 'leave', 'absent', 'uniform', 'dress',
        'transmittal', 'report', 'certificate', 'clock', 'shift', 'work',
        'immersion', 'practicum', 'stipend', 'salary', 'undertime', 'overtime',
        'holiday', 'schedule', 'lagonoy', 'government', 'civil', 'service',
        'attendance', 'render', 'hours', 'stress', 'overwhelmed', 'mental health',
        'safety', 'harassment', 'communication', 'ergonomics', 'personality',
        'writing', 'ethics', 'integrity', 'hygiene', 'grooming', 'punctual',
        'department', 'assignment', 'placement', 'id card', 'application',
      ];

      if (!inScopeSeeds.any((seed) => q.contains(seed))) return true;
    }

    return false;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────────────────────────────────

  static bool _isEmojiOrVeryShort(String q) {
    if (q.length < 3) return true;
    return q.replaceAll(RegExp(r'[^\w\s]'), '').trim().isEmpty;
  }

  static String _getGreetingResponse() {
    const greetings = [
      "👋 How can I help your shift today?",
      "I'm here! What do you need help with?",
      "Need guidance on **LGU procedures**? Ask away!",
      "👋 Ready to assist with **DTR** or **internship rules**.",
    ];
    return greetings[Random().nextInt(greetings.length)];
  }

  static String _getRandomFallback() {
    const fallbacks = [
      "I didn't quite catch that. Could you rephrase your **LGU question**?",
      "Ask me about **DTR rules**, **SPES**, or **transmittal formats**.",
      "I don't have that in my LGU rulebook. Try asking about **hours** or **dress codes**.",
      "I'm limited to **PRISM** and **LGU Lagonoy** procedures. Could you be more specific?",
    ];
    return fallbacks[Random().nextInt(fallbacks.length)];
  }

  static bool _any(String query, List<String> keywords) {
    // Basic typo tolerance: match if any keyword is a substring of the query
    // or if the query contains a pluralized version of the keyword.
    for (var kw in keywords) {
      if (query.contains(kw)) return true;
      // Handle simple plurals (e.g., "spess", "reports")
      if (query.contains(kw.substring(0, kw.length - 1)) && kw.length > 4) {
         // This is a bit too loose, let's just stick to contains for now
         // but we can add more explicit keywords to individual topics.
      }
    }
    return false;
  }
}
