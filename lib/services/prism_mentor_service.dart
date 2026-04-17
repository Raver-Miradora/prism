import 'dart:math';
import 'mentor_knowledge_base.dart';

/// Offline keyword-matching knowledge engine for the PRISM Mentor.
/// Strictly scoped to: PRISM app navigation, LGU Lagonoy procedures,
/// and DOLE/CSC internship rules.
class PrismMentorService {
  // ──────────────────────────────────────────────────────────────────────────
  // Public API
  // ──────────────────────────────────────────────────────────────────────────

  static String getResponse(String input, [String? programType]) {
    // Aggressive cleaning: lowercase, trim, and strip punctuation
    final lower = input.toLowerCase().trim().replaceAll(RegExp(r'[^\w\s]'), '');

    // ── Conversational & Emoji Handling ──────────────────────────────────────
    if (_isEmojiOrVeryShort(lower)) {
      return _getGreetingResponse();
    }

    // ── Context-Aware Ambiguity Routing ──────────────────────────────────────
    final ambiguityResponse = _handleAmbiguity(lower, programType);
    if (ambiguityResponse != null) return ambiguityResponse;

    // ── Standard Matching ────────────────────────────────────────────────────
    
    // 1. Run topic match first — if it hits, return immediately.
    final topicResponse = _matchTopic(lower);
    if (topicResponse != null) return topicResponse;

    // 2. Aggressive Default Refusal (Catch-All)
    if (_isOffTopic(lower)) {
      return "I am strictly programmed to assist with **PRISM app navigation** "
          "and **LGU Lagonoy procedures**. I cannot fulfill outside requests.";
    }

    // 3. Dynamic Fallback Roulette
    return _getRandomFallback();
  }

  /// Returns a list of suggested follow-up questions based on the last topic.
  static List<String> getSuggestions(String input, [String? programType]) {
    final q = input.toLowerCase().trim().replaceAll(RegExp(r'[^\w\s]'), '');
    
    // Check ambiguity routing first for suggestions
    if (_isRequirementQuery(q)) {
      final contextProgram = _getMappedProgram(q, programType);
      if (contextProgram == 'OJT') return ['OJT Hours', 'Journal Entry', 'Target Hours'];
      if (contextProgram == 'SPES') return ['SPES Salary', 'SPES Guidelines', 'DTR Rules'];
    }

    // Look for a specific knowledge match
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

  static String? _handleAmbiguity(String q, String? programType) {
    if (!_isRequirementQuery(q)) return null;

    final contextProgram = _getMappedProgram(q, programType);

    if (contextProgram == 'OJT') {
      return MentorKnowledgeBase.knowledgeGraph.entries
          .firstWhere((e) => e.key.contains('ojt requirements'))
          .value['response'];
    }
    
    if (contextProgram == 'SPES') {
      return MentorKnowledgeBase.knowledgeGraph.entries
          .firstWhere((e) => e.key.contains('spes requirements'))
          .value['response'];
    }

    return "Are you asking for the **OJT** or **SPES** requirements? Both programs have different folder and folder-clearance checklists.";
  }

  /// Prioritizes explicit keywords in the query over the user profile context.
  /// Also maps aliases (e.g., Immersion -> OJT).
  static String? _getMappedProgram(String q, String? profileProgram) {
    // 1. Explicit Intent Priority
    if (q.contains('spes')) return 'SPES';
    if (q.contains('ojt') || q.contains('immersion')) return 'OJT';

    // 2. Profile Context Fallback (with Alias Mapping)
    if (profileProgram == null) return null;
    final p = profileProgram.toUpperCase();

    if (p.contains('OJT') || p.contains('IMMERSION') || p.contains('PRACTICUM')) return 'OJT';
    if (p.contains('SPES')) return 'SPES';
    
    return null;
  }

  static bool _isRequirementQuery(String q) {
    const keywords = ['requirement', 'checklist', 'folder', 'docs', 'list', 'check list'];
    return keywords.any((kw) => q.contains(kw));
  }

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
