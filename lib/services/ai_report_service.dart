import 'dart:async';

class AiReportService {
  /// Simulates a call to an LLM endpoint (like Gemini or OpenAI)
  /// Converts informal "yap" notes into a formal bullet-point accomplishment report.
  Future<String> synthesizeReport(String rawNotes) async {
    // 1. Simulate the 2-second processing time of a real API over a 4G connection
    await Future.delayed(const Duration(seconds: 2));

    // 2. Reject empty calls
    if (rawNotes.trim().isEmpty) {
      return "ERROR: The daily journal requires at least one sentence of informal notes before generating a formal report attachment.";
    }

    // 3. Parse individual task lines from the raw notes
    // Split by newline or period to detect multiple tasks
    final rawLines = rawNotes
        .split(RegExp(r'[\n\r]+|(?<=\.)\s+'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final buffer = StringBuffer();

    for (final line in rawLines) {
      String clean = line;
      // Strip trailing period
      if (clean.endsWith('.')) {
        clean = clean.substring(0, clean.length - 1);
      }
      // Capitalize first letter
      if (clean.isNotEmpty) {
        clean = clean[0].toUpperCase() + clean.substring(1);
      }
      // One-sentence professional bullet point with no colon
      buffer.writeln('• $clean in accordance with assigned departmental objectives.');
    }

    return buffer.toString().trim();
  }
}
