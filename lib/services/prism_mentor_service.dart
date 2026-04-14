class PrismMentorService {
  /// Analyzes the intern's input query using an offline keyword-matching engine
  /// and returns the most relevant hardcoded LGU context response.
  static String getResponse(String input) {
    final lower = input.toLowerCase();

    // Dress Code Rules
    if (lower.contains('dress code') || lower.contains('uniform') || lower.contains('attire') || lower.contains('wear')) {
      return "For LGU Lagonoy, the standard dress code for Monday flag ceremony is your official program uniform or a white polo. Smart casual for the rest of the week.";
    }

    // Transmittal formats
    if (lower.contains('transmittal') || lower.contains('letter') || lower.contains('format') || lower.contains('submit')) {
      return "Transmittal letters to the HRMO should include the Date, Addressee (Ma'am Nimfa M. Peñas), Subject, and a bulleted list of attached documents. Always leave room for a 'Received By' signature block.";
    }

    // DTR & Timesheet Rules
    if (lower.contains('timesheet') || lower.contains('dtr') || lower.contains('hours') || lower.contains('overtime')) {
      return "Excess minutes are automatically stripped by the PRISM engine internally to comply with exact government DTR rules. Undertimes cannot be offset by overtimes within different days.";
    }
    
    // Leave / Absent
    if (lower.contains('absent') || lower.contains('leave') || lower.contains('sick')) {
      return "If you are absent, be sure to use the 'Log Absence/Leave' button on your dashboard. Provide clear remarks. Prolonged absences may require an excuse letter upon your return.";
    }

    // Default Fallback
    return "I'm your offline PRISM Mentor! I can help with basic LGU procedures like dress codes, transmittal formats, or DTR timesheet rules. What do you need help with?";
  }
}
