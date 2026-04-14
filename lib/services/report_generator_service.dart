import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../data/models/intern_profile.dart';
import '../data/models/intern_settings.dart';
import '../data/models/daily_report.dart';
import 'pdf_service.dart';

class ReportGeneratorService {
  /// Generates the native high-fidelity PDF accomplishment report.
  static Future<String> generateReport({
    required List<DailyReport> reports,
    required InternProfile profile,
    required InternSettings settings,
    required DateTime start,
    required DateTime end,
    String? customSummaryBullets,
  }) async {
    try {
      final pdfPath = await _generatePdf(
        reports: reports,
        profile: profile,
        settings: settings,
        start: start,
        end: end,
        customSummaryBullets: customSummaryBullets,
      );
      return pdfPath;
    } catch (e) {
      rethrow;
    }
  }

  static Future<String> _generatePdf({
    required List<DailyReport> reports,
    required InternProfile profile,
    required InternSettings settings,
    required DateTime start,
    required DateTime end,
    String? customSummaryBullets,
  }) async {
    final bytes = await PdfService.buildAccomplishmentReportBytes(
      reports,
      profile,
      settings,
      start,
      end,
      customSummaryBullets: customSummaryBullets,
    );

    final directory = await getApplicationDocumentsDirectory();
    final fileName =
        'Accomplishment_Report_${profile.name.replaceAll(' ', '_')}_${DateFormat('yyyyMMdd').format(start)}.pdf';
    final file = File('${directory.path}/$fileName');

    await file.writeAsBytes(bytes);
    return file.path;
  }

}
