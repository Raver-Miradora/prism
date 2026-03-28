import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

import '../data/models/time_log.dart';
import '../data/models/intern_profile.dart';
import '../data/models/intern_settings.dart';
import '../data/models/daily_report.dart';
import '../core/utils/hourglass_engine.dart';

class PdfService {
  // ─────────────────────────────────────────────────────────────────
  // MONTHLY ACCOMPLISHMENT REPORT PDF
  // ─────────────────────────────────────────────────────────────────
  static Future<void> generateAndPrintMonthlyReport(
    List<DailyReport> reports,
    InternProfile profile,
    int year,
    int month,
  ) async {
    final pdf = pw.Document();
    final monthName = DateFormat('MMMM yyyy').format(DateTime(year, month));

    // Filter reports that have formal text
    final formalReports = reports
        .where((r) => r.formalReport != null && r.formalReport!.isNotEmpty)
        .toList();

    // Collect all bullets from all formal reports
    final List<String> allBullets = [];
    for (final r in formalReports) {
      final lines = r.formalReport!
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();
      allBullets.addAll(lines);
    }

    // Determine date range
    final firstDay = 1;
    final lastDay = DateTime(year, month + 1, 0).day;
    final periodLabel = '${DateFormat('MMMM').format(DateTime(year, month))} $firstDay-$lastDay, $year';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            pw.Center(
              child: pw.Text('Monthly Accomplishment Report',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 4),
            pw.Center(child: pw.Text(monthName, style: const pw.TextStyle(fontSize: 12))),
            pw.SizedBox(height: 16),

            pw.Text('Name: ${profile.name.isEmpty ? "________________________" : profile.name}',
                style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
            pw.Text('Agency/Office: ${profile.agencyOffice.isEmpty ? "________________________" : profile.agencyOffice}',
                style: const pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: 20),

            // Period | Nature of Works table
            pw.Table(
              border: pw.TableBorder.all(width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(5),
              },
              children: [
                // Header
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Center(child: pw.Text('Period', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Center(child: pw.Text('Nature of Works', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
                    ),
                  ],
                ),
                // Data row
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(periodLabel, style: const pw.TextStyle(fontSize: 9)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: allBullets.isEmpty
                          ? pw.Text('No formal reports generated for this period.', style: const pw.TextStyle(fontSize: 9))
                          : pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: allBullets.take(5).map((b) {
                                // Ensure bullet format
                                final text = b.startsWith('\u2022') ? b : '\u2022 $b';
                                return pw.Padding(
                                  padding: const pw.EdgeInsets.only(bottom: 4),
                                  child: pw.Text(text, style: const pw.TextStyle(fontSize: 9, lineSpacing: 2)),
                                );
                              }).toList(),
                            ),
                    ),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 32),

            // Certification section
            pw.Text('Prepared & submitted by;', style: const pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: 24),
            pw.Center(
              child: pw.Container(
                width: 200,
                decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide())),
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Center(
              child: pw.Text(
                profile.name.isEmpty ? '' : profile.name.toUpperCase(),
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 32),

            pw.Text('Noted by:', style: const pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: 24),
            pw.Center(
              child: pw.Container(
                width: 200,
                decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide())),
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Center(
              child: pw.Text(
                profile.supervisorName.isEmpty ? '' : profile.supervisorName.toUpperCase(),
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Center(child: pw.Text('OFFICE HEAD', style: const pw.TextStyle(fontSize: 9))),
            pw.SizedBox(height: 24),

            pw.Row(
              children: [
                pw.Text('NAME OF SCHOOL: ', style: const pw.TextStyle(fontSize: 10)),
                pw.Expanded(child: pw.Container(
                  decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide())),
                  child: pw.Text(' ', style: const pw.TextStyle(fontSize: 10)),
                )),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Row(
              children: [
                pw.Text('COURSE: ', style: const pw.TextStyle(fontSize: 10)),
                pw.Expanded(child: pw.Container(
                  decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide())),
                  child: pw.Text(' ', style: const pw.TextStyle(fontSize: 10)),
                )),
              ],
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Monthly_Report_${profile.name.replaceAll(" ", "_")}_${month}_$year',
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // CSC FORM 48 — DAILY TIME RECORD PDF (pixel-perfect replica)
  // ─────────────────────────────────────────────────────────────────
  static Future<void> generateAndPrintForm48(
    List<TimeLog> logs, 
    InternProfile profile, 
    InternSettings settings, 
    int year, 
    int month
  ) async {
    final pdfData = await _buildForm48Pdf(logs, profile, settings, year, month);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfData,
      name: 'Form48_${profile.name.replaceAll(" ", "_")}_${month}_$year',
    );
  }

  static Future<Uint8List> _buildForm48Pdf(
    List<TimeLog> logs, 
    InternProfile profile, 
    InternSettings settings, 
    int year, 
    int month
  ) async {
    final pdf = pw.Document();

    // Map logs to day indices
    Map<int, TimeLog> logMap = {};
    for (var log in logs) {
      final d = DateTime.parse(log.date);
      if (d.year == year && d.month == month) {
        logMap[d.day] = log;
      }
    }

    final monthName = DateFormat('MMMM yyyy').format(DateTime(year, month));
    final daysInMonth = DateTime(year, month + 1, 0).day;

    final bold = pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8);
    final normal = const pw.TextStyle(fontSize: 8);
    final smallBold = pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 7);
    final small = const pw.TextStyle(fontSize: 7);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text('Civil Service Form No. 48', style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic)),
              pw.SizedBox(height: 6),
              pw.Text('DAILY TIME RECORD', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
              pw.SizedBox(height: 8),
              
              // Name
              pw.Text('-----o0o-----', style: const pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 4),
              pw.Text(
                profile.name.isEmpty ? '____________________________' : profile.name.toUpperCase(), 
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)
              ),
              pw.Text('(Name)', style: const pw.TextStyle(fontSize: 8)),
              pw.SizedBox(height: 8),
              
              // Month and official hours
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.RichText(text: pw.TextSpan(children: [
                    pw.TextSpan(text: 'For the month of  ', style: normal),
                    pw.TextSpan(text: monthName, style: bold),
                  ])),
                  pw.Text('Official hours for arrival and departure', style: normal),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text('Regular days: ${settings.expectedTimeIn} - ${settings.expectedTimeOut}    ', style: small),
                  pw.Text('Saturdays: ________', style: small),
                ],
              ),
              pw.SizedBox(height: 8),

              // The full CSC Form 48 grid
              _buildCSCForm48Grid(logMap, settings, year, month, daysInMonth),
              
              pw.SizedBox(height: 12),
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 16),
                child: pw.Text(
                  'I CERTIFY on my honor that the above is a true and correct report of the hours of work performed, '
                  'record of which was made daily at the time of arrival and departure from office.',
                  textAlign: pw.TextAlign.justify,
                  style: const pw.TextStyle(fontSize: 8),
                ),
              ),
              pw.SizedBox(height: 20),
              
              // Intern signature
              pw.Container(
                width: 180,
                decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide())),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                profile.name.isEmpty ? '' : profile.name.toUpperCase(),
                style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 16),
              
              pw.Text('VERIFIED as to the prescribed office hours:', style: const pw.TextStyle(fontSize: 8)),
              pw.SizedBox(height: 20),
              pw.Container(
                width: 180,
                decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide())),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                profile.supervisorName.isEmpty ? '' : profile.supervisorName.toUpperCase(), 
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)
              ),
              pw.Text('In Charge', style: const pw.TextStyle(fontSize: 8)),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildCSCForm48Grid(
    Map<int, TimeLog> logMap, 
    InternSettings settings, 
    int year, 
    int month,
    int daysInMonth,
  ) {
    double totalRendered = 0.0;
    int totalUndertimeHours = 0;
    int totalUndertimeMins = 0;

    final hBold = pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 7);
    final cellStyle = const pw.TextStyle(fontSize: 7);

    pw.Widget cell(String text, {pw.TextStyle? style}) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 1),
        child: pw.Center(child: pw.Text(text, style: style ?? cellStyle, textAlign: pw.TextAlign.center)),
      );
    }

    final rows = <pw.TableRow>[];

    // Multi-row header matching CSC Form 48 exactly
    // Row 1: Day | A.M. (colspan 2) | P.M. (colspan 2) | Undertime (colspan 2)
    rows.add(pw.TableRow(
      children: [
        cell('Day', style: hBold),
        pw.Container(child: pw.Center(child: pw.Text('A.M.', style: hBold, textAlign: pw.TextAlign.center))),
        pw.SizedBox(), // AM second col merged visually
        pw.Container(child: pw.Center(child: pw.Text('P.M.', style: hBold, textAlign: pw.TextAlign.center))),
        pw.SizedBox(), // PM second col merged visually
        pw.Container(child: pw.Center(child: pw.Text('Undertime', style: hBold, textAlign: pw.TextAlign.center))),
        pw.SizedBox(), // Undertime second col
      ],
    ));

    // Row 2: Sub-headers
    rows.add(pw.TableRow(
      children: [
        cell(''),
        cell('Arrival', style: hBold),
        cell('Depar-\nture', style: hBold),
        cell('Arrival', style: hBold),
        cell('Depar-\nture', style: hBold),
        cell('Hours', style: hBold),
        cell('Min-\nutes', style: hBold),
      ],
    ));

    // Day rows
    for (int day = 1; day <= daysInMonth; day++) {
      final log = logMap[day];
      bool isWeekend = DateTime(year, month, day).weekday > 5;

      String amArr = '';
      String amDep = '';
      String pmArr = '';
      String pmDep = '';
      String utHrs = '';
      String utMins = '';

      if (log != null) {
        final timeIn = DateTime.parse(log.timeIn);
        
        // AM arrival
        amArr = DateFormat('hh:mm').format(timeIn);

        if (log.timeOut != null) {
          final timeOut = DateTime.parse(log.timeOut!);
          
          // Simple split: if clocked in before noon -> AM arrival, PM departure
          // Assume AM departure = 12:00 PM (lunch), PM arrival = 1:00 PM (after lunch)
          amDep = '12:00';
          pmArr = '1:00';
          pmDep = DateFormat('hh:mm').format(timeOut);

          final hoursVal = HourglassEngine.calculateActualHours(log, settings);
          final lateVal = HourglassEngine.calculateLateDeductions(log, settings.expectedTimeIn);
          
          totalRendered += hoursVal;

          if (lateVal > 0) {
            final h = lateVal ~/ 60;
            final m = lateVal % 60;
            totalUndertimeHours += h;
            totalUndertimeMins += m;
            if (h > 0) utHrs = '$h';
            if (m > 0) utMins = '$m';
          }
        } else {
          // Still clocked in
          amDep = '';
          pmArr = '';
          pmDep = '';
        }
      } else if (isWeekend) {
        // Leave weekend rows blank (CSC standard)
      }

      rows.add(pw.TableRow(
        children: [
          cell('$day'),
          cell(amArr),
          cell(amDep),
          cell(pmArr),
          cell(pmDep),
          cell(utHrs),
          cell(utMins),
        ],
      ));
    }

    // Normalize minutes overflow
    totalUndertimeHours += totalUndertimeMins ~/ 60;
    totalUndertimeMins = totalUndertimeMins % 60;

    // Total row
    rows.add(pw.TableRow(
      decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(width: 1))),
      children: [
        cell('Total', style: hBold),
        cell(''),
        cell(''),
        cell(''),
        cell(''),
        cell('$totalUndertimeHours', style: hBold),
        cell('$totalUndertimeMins', style: hBold),
      ],
    ));

    return pw.Table(
      border: pw.TableBorder.all(width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),    // Day
        1: const pw.FlexColumnWidth(1.5),  // AM Arrival
        2: const pw.FlexColumnWidth(1.5),  // AM Departure
        3: const pw.FlexColumnWidth(1.5),  // PM Arrival
        4: const pw.FlexColumnWidth(1.5),  // PM Departure
        5: const pw.FlexColumnWidth(1),    // Hours
        6: const pw.FlexColumnWidth(1),    // Minutes
      },
      children: rows,
    );
  }
}
