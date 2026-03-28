import 'dart:async';

class AiReportService {
  /// Simulates a call to an LLM endpoint (like Gemini or OpenAI)
  /// Converts informal "yap" notes into a rigid Civil Service Commission paragraph.
  Future<String> synthesizeReport(String rawNotes) async {
    // 1. Simulate the 2-second processing time of a real API over a 4G connection
    await Future.delayed(const Duration(seconds: 2));

    // 2. Reject empty calls
    if (rawNotes.trim().isEmpty) {
      return "ERROR: The daily journal requires at least one sentence of informal notes before generating a formal report attachment.";
    }

    // 3. Mock the "Formalized" output text
    // In the future, you will swap this literal string for a `http.post` call to the Gemini API.
    final String formalOutput = """
This log serves as the formal Daily Time Record (DTR) narrative attachment for the active shift. 

The intern reported for duty at the designated time and conducted the following activities, which were summarized informally as:

"$rawNotes"

These tasks align strictly with the standard operating procedures of the assigned governmental division. Technical assistance was provided where required by supervisors, and all deliverables for the documented shift were completed satisfactorily prior to the intern's departure.
""";

    return formalOutput.trim();
  }
}
