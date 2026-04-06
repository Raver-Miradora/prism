import 'dart:async';

class AiReportService {
  /// Simulates a call to an LLM endpoint (like Gemini or OpenAI)
  /// Converts informal "yap" notes into a formal bullet-point accomplishment report.
  Future<String> synthesizeReport(String rawNotes) async {
    // 1. Simulate the 2-second processing time of a real API over a 4G connection
    await Future.delayed(const Duration(seconds: 1));

    // 2. Reject empty calls
    if (rawNotes.trim().isEmpty) {
      return "ERROR: The daily journal requires at least one sentence of informal notes before generating a formal report attachment.";
    }

    // 3. Clean and isolate the raw text, effectively stripping previous polish bullets
    String cleanNotes = rawNotes.replaceAll('•', '').trim();
    if (cleanNotes.isEmpty) return "";

    final lower = cleanNotes.toLowerCase();
    final random = DateTime.now().millisecond;

    // 4. Simulate Context-Aware Transformations
    if (lower.contains('assisted spes') || lower.contains('spes applicants')) {
      final options = [
        "Facilitated the SPES application process, including document verification and eligibility screening.",
        "Provided administrative support to Special Program for Employment of Students (SPES) applicants, ensuring compliance with DOLE requirements.",
        "Coordinated the registration and screening process for prospective SPES beneficiaries."
      ];
      return '• ${options[random % options.length]}';
    }

    if (lower.contains('encoded') || lower.contains('encode data') || lower.contains('encoding')) {
      final options = [
        "Executed systematic data entry and encoding tasks to maintain accurate digital records.",
        "Processed and encoded organizational documents into the secure database system.",
        "Transcribed and digitized physical records, ensuring data integrity and accessibility."
      ];
      return '• ${options[random % options.length]}';
    }

    // 5. Generic Rewrite Engine (Simulated LLM)
    List<String> activeVerbs = ["Spearheaded", "Facilitated", "Executed", "Completed", "Managed", "Processed", "Coordinated"];
    String verb = activeVerbs[random % activeVerbs.length];
    
    // Remove informal conversational prefixes
    if (lower.startsWith('i ')) cleanNotes = cleanNotes.substring(2).trim();
    if (lower.startsWith('just ')) cleanNotes = cleanNotes.substring(5).trim();
    if (lower.startsWith('i just ')) cleanNotes = cleanNotes.substring(7).trim();
    
    if (cleanNotes.isNotEmpty) {
      cleanNotes = cleanNotes[0].toLowerCase() + cleanNotes.substring(1);
    }
    
    if (cleanNotes.endsWith('.')) {
      cleanNotes = cleanNotes.substring(0, cleanNotes.length - 1);
    }

    final genericContexts = [
      "in alignment with standard operational protocols",
      "to support the administrative objectives of the department",
      "ensuring accuracy and procedural compliance",
    ];
    final context = genericContexts[random % genericContexts.length];

    return '• $verb $cleanNotes $context.';
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
