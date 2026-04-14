import 'dart:io';
import 'package:flutter/services.dart';
import 'package:docx_template/docx_template.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

import '../data/models/intern_profile.dart';
import '../data/models/intern_settings.dart';
import '../data/models/daily_report.dart';
import 'pdf_service.dart';

class ReportGeneratorService {
  /// Generates both DOCX and PDF accomplishment reports.
  /// Returns a Map with 'docx' and 'pdf' paths.
  static Future<Map<String, String>> generateDualReport({
    required List<DailyReport> reports,
    required InternProfile profile,
    required InternSettings settings,
    required DateTime start,
    required DateTime end,
    String? customSummaryBullets,
  }) async {
    final Map<String, String> paths = {};

    try {
      // 1. Generate DOCX
      final docxPath = await _generateDocx(
        reports: reports,
        profile: profile,
        settings: settings,
        start: start,
        end: end,
        customSummaryBullets: customSummaryBullets,
      );
      paths['docx'] = docxPath;

      // 2. Generate PDF (Twin Generation)
      final pdfPath = await _generatePdf(
        reports: reports,
        profile: profile,
        settings: settings,
        start: start,
        end: end,
        customSummaryBullets: customSummaryBullets,
      );
      paths['pdf'] = pdfPath;
    } catch (e) {
      rethrow;
    }

    return paths;
  }

  static Future<String> _generateDocx({
    required List<DailyReport> reports,
    required InternProfile profile,
    required InternSettings settings,
    required DateTime start,
    required DateTime end,
    String? customSummaryBullets,
  }) async {
    final templateName = settings.programType == 'SPES'
        ? 'template_spes.docx'
        : 'template_ojt.docx';
    final data = await rootBundle.load('assets/templates/$templateName');
    final bytes = data.buffer.asUint8List();

    final docx = await DocxTemplate.fromBytes(bytes);

    // Ensure we work with a mutable copy to prevent 'Cannot modify unmodifiable list'
    final mutableReports = List<DailyReport>.from(reports, growable: true);

    // Prepare content mapping
    final Content content = Content();

    // Scalar Tags
    content.add(TextContent('INTERN_NAME', profile.name.toUpperCase()));
    content
        .add(TextContent('OFFICE_HEAD', profile.supervisorName.toUpperCase()));
    content.add(TextContent('SCHOOL', settings.schoolName.toUpperCase()));
    content.add(TextContent('COURSE', settings.courseProgram.toUpperCase()));

    final df = DateFormat('MMM d, yyyy');
    final periodStr = '${df.format(start)} - ${df.format(end)}';
    content.add(TextContent('PERIOD', periodStr));

    // Table Content (WORKS)
    final List<String> summaryBullets =
        _getSummaryBullets(mutableReports, customSummaryBullets);

    final List<Content> tableContent = List<Content>.from(
      summaryBullets.map((bullet) {
        final c = Content();
        // Tag-based table mapping: map bullet to 'WORKS' and same period to 'PERIOD' if multi-row
        c.add(TextContent('PERIOD', periodStr));
        c.add(TextContent('WORKS', bullet.replaceFirst('•', '').trim()));
        return c;
      }).toList(growable: true),
      growable: true,
    );

    content.add(ListContent('WORKS',
        tableContent)); // Uses 'WORKS' as the list tag to match template row definition

    final d = await docx.generate(content);

    if (d == null) throw Exception("Failed to generate DOCX data");

    final directory = await getApplicationDocumentsDirectory();
    final fileName =
        'Accomplishment_Report_${profile.name.replaceAll(' ', '_')}_${DateFormat('yyyyMMdd').format(start)}.docx';
    final file = File('${directory.path}/$fileName');

    await file.writeAsBytes(d);
    return file.path;
  }

  static Future<String> _generatePdf({
    required List<DailyReport> reports,
    required InternProfile profile,
    required InternSettings settings,
    required DateTime start,
    required DateTime end,
    String? customSummaryBullets,
  }) async {
    // We leverage the refined PDF service for the high-fidelity Twin PDF
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

  static List<String> _getSummaryBullets(
      List<DailyReport> reports, String? customSummaryBullets) {
    if (customSummaryBullets != null && customSummaryBullets.isNotEmpty) {
      return customSummaryBullets
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(growable: true);
    }

    final List<String> allBullets = <String>[];
    final activeReports = reports.where((r) => r.rawNotes.isNotEmpty).toList(growable: true);
    for (final r in activeReports) {
      final lines = r.rawNotes
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList(growable: true);
      allBullets.addAll(lines);
    }

    return allBullets;
  }
}
