/// Offline keyword-matching knowledge engine for the PRISM Mentor.
/// Strictly scoped to: PRISM app navigation, LGU Lagonoy procedures,
/// and DOLE/CSC internship rules.
class PrismMentorService {
  // ──────────────────────────────────────────────────────────────────────────
  // Public API
  // ──────────────────────────────────────────────────────────────────────────

  static String getResponse(String input) {
    final lower = input.toLowerCase().trim();

    // 1. Run topic match first — if it hits, return immediately.
    final topicResponse = _matchTopic(lower);
    if (topicResponse != null) return topicResponse;

    // 2. Guard: if no topic matched, check if it looks in-scope before
    //    falling back to the generic helper prompt.
    if (_isOffTopic(lower)) {
      return "I am strictly programmed to assist with PRISM app navigation, "
          "LGU Lagonoy procedures, and DOLE/CSC internship rules. "
          "I cannot help with outside topics.";
    }

    // 3. Soft fallback — related but unrecognised phrasing.
    return "I'm your offline PRISM Mentor! I can help with SPES, GIP, OJT, "
        "DTR rules, dress codes, transmittal formats, or other LGU procedures. "
        "Try being more specific — for example, type 'spes salary' or 'dtr undertime'.";
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Topic routing
  // ──────────────────────────────────────────────────────────────────────────

  static String? _matchTopic(String q) {
    // ── SPES ────────────────────────────────────────────────────────────────
    if (_any(q, ['spes', 'special program for employment', 'dole pay',
                 'dole salary', 'student employment'])) {
      return "For SPES (Special Program for the Employment of Students), "
          "employment lasts 20 to 78 days. DOLE shoulders 40% of your salary, "
          "while LGU Lagonoy pays the remaining 60%. "
          "You must maintain passing grades to qualify for the program.";
    }

    // ── GIP ─────────────────────────────────────────────────────────────────
    if (_any(q, ['gip', 'government internship', 'stipend', '6 months',
                 'six months', 'youth 18', 'aged 18'])) {
      return "The GIP (Government Internship Program) lasts 3 to 6 months and "
          "is open to youth aged 18–30. You receive a stipend equivalent to "
          "75% of the prevailing minimum wage. Civil Service eligibility is "
          "not required to participate.";
    }

    // ── OJT / Work Immersion ─────────────────────────────────────────────────
    if (_any(q, ['ojt', 'immersion', 'work immersion', 'school hours',
                 'unpaid', 'curriculum hours', '300 hours', '480 hours',
                 'practicum'])) {
      return "OJT and Work Immersion are academic requirements. Total hours "
          "depend on your school's curriculum — usually 300 to 480 hours. "
          "While unpaid, the experience directly credits towards your "
          "graduation requirements.";
    }

    // ── DTR / CSC Form 48 Rules ──────────────────────────────────────────────
    if (_any(q, ['dtr rules', 'excess minutes', 'overtime', 'undertime',
                 'csc rule', 'csc form 48', 'late deduction', 'early departure',
                 '5:15', 'clock out early', 'clock in late'])) {
      return "Under CSC rules, standard shifts are 8 hours. Excess minutes "
          "(e.g., clocking out at 5:15 PM) are NOT credited as overtime unless "
          "officially authorized in writing. However, late arrivals or early "
          "departures are strictly deducted as undertime in your DTR.";
    }

    // ── Dress Code / Uniform ─────────────────────────────────────────────────
    if (_any(q, ['dress code', 'uniform', 'attire', 'wear', 'clothing',
                 'outfit', 'white polo', 'monday', 'flag ceremony'])) {
      return "For LGU Lagonoy, the standard dress code for Monday flag "
          "ceremonies is your official program uniform or a white polo. "
          "Smart casual attire is accepted for the rest of the week.";
    }

    // ── Transmittal Letters ──────────────────────────────────────────────────
    if (_any(q, ['transmittal', 'letter', 'format', 'hrmo letter',
                 'received by', 'addressee', 'nimfa', 'peñas',
                 'how to write', 'letter format'])) {
      return "Transmittal letters to the HRMO should include: the Date, "
          "Addressee (Ma'am Nimfa M. Peñas, HRMO), Subject line, and a "
          "bulleted list of attached documents. Always leave a 'Received By' "
          "signature block at the bottom.";
    }

    // ── Absence / Leave ──────────────────────────────────────────────────────
    if (_any(q, ['absent', 'leave', 'sick', 'excuse', 'excuse letter',
                 'how to file', 'log absence', 'on leave'])) {
      return "If you are absent, use the 'Log Absence/Leave' button on your "
          "PRISM dashboard and add clear remarks. For prolonged absences, "
          "submit an excuse letter to the HRMO upon your return.";
    }

    // ── PRISM App Navigation ─────────────────────────────────────────────────
    if (_any(q, ['how do i', 'how to use', 'where is', 'prism app',
                 'generate report', 'clock in', 'clock out', 'dtr pdf',
                 'accomplishment report', 'slide to', 'settings',
                 'progress ring'])) {
      return "In PRISM: Slide right on the main clock widget to clock in/out. "
          "Tap the progress ring for milestone analytics. Go to the Journal "
          "tab and tap 'Generate Accomplishment Report' to build your PDF. "
          "DTR generation is found in the Reports section.";
    }

    // ── General Hours / Timesheet ─────────────────────────────────────────────
    if (_any(q, ['timesheet', 'dtr', 'hours', 'total hours', 'rendered hours',
                 'target hours', 'how many hours'])) {
      return "Your PRISM dashboard tracks rendered hours in real time. Excess "
          "minutes are automatically stripped by the PRISM engine to comply "
          "with government DTR rules. Undertimes cannot be offset by overtime "
          "from different days.";
    }

    return null; // no match
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Off-topic detector
  // Checks for signals that suggest the query is entirely outside scope.
  // A query that has NO in-scope seed words AND hits an off-topic signal
  // is refused.
  // ──────────────────────────────────────────────────────────────────────────

  static bool _isOffTopic(String q) {
    // Allow-list: any word here means the question is arguably in-scope
    const inScopeSeeds = [
      'lgu', 'prism', 'hrmo', 'intern', 'dole', 'csc', 'spes', 'gip',
      'ojt', 'dtr', 'timesheet', 'leave', 'absent', 'uniform', 'dress',
      'transmittal', 'report', 'certificate', 'clock', 'shift', 'work',
      'immersion', 'practicum', 'stipend', 'salary', 'undertime', 'overtime',
      'holiday', 'schedule', 'lagonoy', 'camarines', 'government', 'civil',
      'service', 'form 48', 'attendance', 'render', 'hours',
    ];

    // If any seed is found, treat as in-scope (may just be unanswered phrasing)
    if (inScopeSeeds.any((seed) => q.contains(seed))) return false;

    // Explicit off-topic signals
    const offTopicSignals = [
      'poem', 'joke', 'story', 'write me', 'tell me a', 'sing',
      'recipe', 'what is 2', 'calculate', 'math', 'capital of',
      'weather', 'news', 'movie', 'music', 'game', 'sports',
      'basketball', 'football', 'netflix', 'youtube', 'tiktok',
      'instagram', 'facebook', 'twitter', 'dating', 'love',
      'translate', 'code for me', 'write code',
    ];

    return offTopicSignals.any((signal) => q.contains(signal));
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Utility
  // ──────────────────────────────────────────────────────────────────────────

  static bool _any(String query, List<String> keywords) =>
      keywords.any((kw) => query.contains(kw));
}
