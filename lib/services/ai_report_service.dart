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
    final suffixes = [
      'in accordance with assigned departmental objectives',
      'to enhance operational workflow and efficiency',
      'ensuring compliance with standard municipal procedures',
      'supporting ongoing departmental projects and goals',
      'maintaining high standards of governmental professionalism',
      'contributing to the streamlined delivery of public services',
    ];

    final random = DateTime.now().millisecond;

    for (int i = 0; i < rawLines.length; i++) {
      String clean = rawLines[i];
      // Strip trailing period
      if (clean.endsWith('.')) {
        clean = clean.substring(0, clean.length - 1);
      }
      // Capitalize first letter
      if (clean.isNotEmpty) {
        clean = clean[0].toUpperCase() + clean.substring(1);
      }
      
      final suffix = suffixes[(random + i) % suffixes.length];
      
      // One-sentence professional bullet point
      buffer.writeln('• $clean $suffix.');
    }

    return buffer.toString().trim();
  }

  /// Summarizes a month's worth of informal notes into 1-5 professional bullet points.
  Future<String> synthesizeMonthlySummary(List<String> allDailyNotes) async {
    await Future.delayed(const Duration(seconds: 3)); 

    if (allDailyNotes.isEmpty) {
      return "No notes found for this period to summarize.";
    }
    
    final allWords = allDailyNotes.join(' ').split(' ');
    if (allWords.length < 5) return "Insufficient daily data for a professional summary.";

    final allSummaries = [
      "• Facilitated daily administrative support and documentation management.",
      "• Executed assigned technical tasks and departmental project milestones.",
      "• Collaborated with team members on standard operating procedure refinements.",
      "• Maintained accurately verified records of daily operational activities.",
      "• Engaged in specialized training and professional development sessions.",
    ];

    // Determine how many bullets based on volume (1-5)
    final bulletCount = (allWords.length / 10).clamp(1, 5).toInt();
    return allSummaries.take(bulletCount).join('\n');
  }
}
