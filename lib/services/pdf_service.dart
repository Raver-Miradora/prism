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
  static pw.Widget _bulletCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            margin: const pw.EdgeInsets.only(top: 4, right: 6),
            width: 3,
            height: 3,
            decoration: const pw.BoxDecoration(
              color: PdfColors.black,
              shape: pw.BoxShape.circle,
            ),
          ),
          pw.Expanded(
            child: pw.Text(text, style: const pw.TextStyle(fontSize: 9, lineSpacing: 2)),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // ACCOMPLISHMENT REPORT PDF
  // ─────────────────────────────────────────────────────────────────
  static Future<void> generateAndPrintAccomplishmentReport(
    List<DailyReport> reports,
    InternProfile profile,
    InternSettings settings,
    DateTime start,
    DateTime end,
    {String? customSummaryBullets}
  ) async {
    final pdfBytes = await buildAccomplishmentReportBytes(
      reports,
      profile,
      settings,
      start,
      end,
      customSummaryBullets: customSummaryBullets,
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'Accomplishment_Report_${profile.name.replaceAll(" ", "_")}',
    );
  }

  /// Builds the bytes for the Accomplishment Report PDF (Twin Generation logic)
  static Future<Uint8List> buildAccomplishmentReportBytes(
    List<DailyReport> reports,
    InternProfile profile,
    InternSettings settings,
    DateTime start,
    DateTime end,
    {String? customSummaryBullets}
  ) async {
    final pdf = pw.Document();
    
    // Filter reports that have notes
    final activeReports = reports
        .where((r) => r.rawNotes.isNotEmpty)
        .toList(growable: true);

    // Collect all bullets from all notes
    final List<String> allBullets = [];
    for (final r in activeReports) {
      final lines = r.rawNotes
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList(growable: true);
      allBullets.addAll(lines);
    }

    final List<String> summaryBullets = [];
    if (customSummaryBullets != null && customSummaryBullets.isNotEmpty) {
      summaryBullets.addAll(
        customSummaryBullets.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(growable: true)
      );
    } else if (allBullets.isNotEmpty) {
      if (allBullets.length <= 5) {
        summaryBullets.addAll(allBullets);
      } else {
        final double step = (allBullets.length - 1) / 4.0;
        for (int i = 0; i < 5; i++) {
          final int index = (i * step).round().clamp(0, allBullets.length - 1);
          final bullet = allBullets[index];
          if (!summaryBullets.contains(bullet)) {
             summaryBullets.add(bullet);
          }
        }
      }
    }

    // Determine date range label
    final df = DateFormat('MMMM d, yyyy');
    final rangeLabel = '${df.format(start)} - ${df.format(end)}';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(60),
        build: (pw.Context context) {
          return [
            // ── HEADER REDESIGN ──────────────────────────────────────────
            pw.Center(
               child: pw.Column(
                 children: [
                   pw.Text(settings.programType == 'OJT' ? 'ON-THE-JOB TRAINING' : settings.programType.toUpperCase(),
                      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                   pw.Container(
                     margin: const pw.EdgeInsets.symmetric(vertical: 2),
                     width: 250,
                     decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(width: 1.5))),
                   ),
                   pw.Text('ACCOMPLISHMENT REPORT',
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                   pw.SizedBox(height: 12),
                 ]
               )
            ),
            
            pw.Text('The following listed below are my accomplishments under ${profile.agencyOffice.isEmpty ? "[Office Assigned]" : profile.agencyOffice}.',
                style: const pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: 12),

            pw.Text('Name: ${profile.name.isEmpty ? "________________________" : profile.name}',
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),

            // Period | Nature of Works table
            pw.Table(
              border: pw.TableBorder.all(width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(2.5),
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
                      child: pw.Center(child: pw.Text(rangeLabel, style: const pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.center)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: summaryBullets.isEmpty
                          ? pw.Text('No reports generated for this period.', style: const pw.TextStyle(fontSize: 9))
                          : pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: summaryBullets.map((b) {
                                final cleanText = b.replaceFirst('\u2022', '').trim();
                                return _bulletCell(cleanText);
                              }).toList(growable: true),
                            ),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 40),

            // ── SIGNATURE BLOCK ──────────────────────────────────────────
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Noted by - Left
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Noted by:', style: const pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 24),
                    pw.Column(
                      children: [
                        pw.Container(
                          width: 180,
                          decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide())),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          profile.supervisorName.isEmpty ? '' : profile.supervisorName.toUpperCase(),
                          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text('OFFICE HEAD', style: const pw.TextStyle(fontSize: 8)),
                      ],
                    ),
                  ],
                ),
                // Prepared by - Right
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text('Prepared & Submitted by:', style: const pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 20),
                    pw.Text(
                      profile.name.isEmpty ? '' : profile.name.toUpperCase(),
                      style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Container(
                      width: 180,
                      decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide())),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      settings.programType.toUpperCase(),
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 40),

            // ── SCHOOL & COURSE DATA ─────────────────────────────────────
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Text('NAME OF SCHOOL: ', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    pw.Text(settings.schoolName.toUpperCase(), style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  children: [
                    pw.Text('COURSE: ', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    pw.Text(settings.courseProgram.toUpperCase(), style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // ─────────────────────────────────────────────────────────────────
  // CSC FORM 48 — DAILY TIME RECORD PDF (Two-copy layout)
  // ─────────────────────────────────────────────────────────────────
  static Future<void> generateAndPrintForm48(
    List<TimeLog> logs, 
    InternProfile profile, 
    InternSettings settings, 
    int year, 
    int month,
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
    int month,
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

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildSingleForm48Copy(logMap, profile, settings, monthName, daysInMonth, year, month),
              pw.SizedBox(width: 20),
              _buildSingleForm48Copy(logMap, profile, settings, monthName, daysInMonth, year, month),
            ],
          );
        },
      ),
    );

    // Filter fieldwork logs for the Annex
    final fieldworkLogs = logs.where((l) => l.isFieldwork).toList(growable: true);
    if (fieldworkLogs.isNotEmpty) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) => _buildFieldworkAnnex(fieldworkLogs, profile, monthName),
        ),
      );
    }

    return pdf.save();
  }

  static pw.Widget _buildSingleForm48Copy(
    Map<int, TimeLog> logMap,
    InternProfile profile,
    InternSettings settings,
    String monthName,
    int daysInMonth,
    int year,
    int month,
  ) {
    const normal = pw.TextStyle(fontSize: 7);
    final bold = pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 7);
    final titleBold = pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11);

    return pw.Container(
      width: 250,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text('Civil Service Form No. 48', style: pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic)),
          pw.SizedBox(height: 4),
          pw.Text('DAILY TIME RECORD', style: titleBold),
          pw.SizedBox(height: 4),
          pw.Text('-----o0o-----', style: normal),
          pw.SizedBox(height: 6),
          
          pw.Text(
            profile.name.isEmpty ? '____________________________' : profile.name.toUpperCase(), 
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)
          ),
          pw.Text('(Name)', style: const pw.TextStyle(fontSize: 7)),
          pw.SizedBox(height: 10),
          
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.RichText(text: pw.TextSpan(children: [
                pw.TextSpan(text: 'For the month of  ', style: normal),
                pw.TextSpan(text: monthName, style: bold),
              ])),
            ],
          ),
          pw.SizedBox(height: 2),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            children: [
              pw.Text('Official hours for arrival and departure', style: normal),
            ],
          ),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            children: [
              pw.Text('Regular days: ${settings.expectedTimeIn}-${settings.expectedTimeOut}', style: normal),
              pw.Text('  Saturdays: ________', style: normal),
            ],
          ),
          pw.SizedBox(height: 8),

          _buildCSCForm48Grid(logMap, settings, year, month, daysInMonth),
          
          pw.SizedBox(height: 12),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 4),
            child: pw.Text(
              'I CERTIFY on my honor that the above is a true and correct report of the hours of work performed, '
              'record of which was made daily at the time of arrival and departure from office.',
              textAlign: pw.TextAlign.justify,
              style: const pw.TextStyle(fontSize: 7),
            ),
          ),
          pw.SizedBox(height: 16),
          
          pw.Text(
            profile.name.isEmpty ? '' : profile.name.toUpperCase(),
            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 2),
          pw.Container(
            width: 160,
            decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide())),
          ),
          pw.SizedBox(height: 12),
          
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            children: [
              pw.Text('VERIFIED as to the prescribed office hours:', style: const pw.TextStyle(fontSize: 7)),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            profile.supervisorName.isEmpty ? '' : profile.supervisorName.toUpperCase(), 
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)
          ),
          pw.SizedBox(height: 2),
          pw.Container(
            width: 160,
            decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide())),
          ),
          pw.SizedBox(height: 2),
          pw.Text('In Charge', style: const pw.TextStyle(fontSize: 7)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // Smart Filler: maps 2 DB punches into the 4 CSC Form 48 columns
  // ─────────────────────────────────────────────────────────────────
  static ({String amIn, String amOut, String pmIn, String pmOut}) _resolveForm48Slots(TimeLog log) {
    final punch1 = log.amArrivalTime != null ? DateTime.parse(log.amArrivalTime!) : null;
    final punch2 = log.pmDepartureTime != null ? DateTime.parse(log.pmDepartureTime!) : null;

    // Prefix for fieldwork
    final p1prefix = log.isFieldwork ? '*' : '';

    if (punch1 == null && punch2 == null) {
      return (amIn: '', amOut: '', pmIn: '', pmOut: '');
    }

    final noon = punch1 != null
        ? DateTime(punch1.year, punch1.month, punch1.day, 12, 0)
        : DateTime(punch2!.year, punch2.month, punch2.day, 12, 0);
    final pm1 = punch1 != null
        ? DateTime(punch1.year, punch1.month, punch1.day, 13, 0)
        : DateTime(punch2!.year, punch2.month, punch2.day, 13, 0);

    // Full shift: Punch 1 before noon AND Punch 2 after 1 PM
    if (punch1 != null && punch2 != null &&
        punch1.isBefore(noon) && punch2.isAfter(pm1)) {
      return (
        amIn: '$p1prefix${DateFormat('hh:mm').format(punch1)}',
        amOut: '12:00',
        pmIn: '01:00',
        pmOut: DateFormat('hh:mm').format(punch2),
      );
    }

    // Morning half-day: both punches at or before 1 PM
    if (punch1 != null && punch2 != null &&
        !punch1.isAfter(pm1) && !punch2.isAfter(pm1)) {
      return (
        amIn: '$p1prefix${DateFormat('hh:mm').format(punch1)}',
        amOut: DateFormat('hh:mm').format(punch2),
        pmIn: '',
        pmOut: '',
      );
    }

    // Afternoon half-day: both punches at or after noon
    if (punch1 != null && punch2 != null &&
        !punch1.isBefore(noon) && !punch2.isBefore(noon)) {
      return (
        amIn: '',
        amOut: '',
        pmIn: '$p1prefix${DateFormat('hh:mm').format(punch1)}',
        pmOut: DateFormat('hh:mm').format(punch2),
      );
    }

    // Fallback: only one punch recorded so far
    if (punch1 != null && punch2 == null) {
      final isAfternoon = !punch1.isBefore(noon);
      return (
        amIn: isAfternoon ? '' : '$p1prefix${DateFormat('hh:mm').format(punch1)}',
        amOut: '',
        pmIn: isAfternoon ? '$p1prefix${DateFormat('hh:mm').format(punch1)}' : '',
        pmOut: '',
      );
    }

    return (amIn: '', amOut: '', pmIn: '', pmOut: '');
  }

  static pw.Widget _buildCSCForm48Grid(
    Map<int, TimeLog> logMap, 
    InternSettings settings, 
    int year, 
    int month,
    int daysInMonth,
  ) {
    int totalUndertimeHours = 0;
    int totalUndertimeMins = 0;

    final hBold = pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 6);
    const cellStyle = pw.TextStyle(fontSize: 6);
    final statusStyle = pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 6, color: PdfColors.grey700);
    final weekendStyle = pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 6, color: PdfColors.grey500);

    pw.Widget cell(String text, {pw.TextStyle? style}) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 1.5, horizontal: 1),
        child: pw.Center(child: pw.Text(text, style: style ?? cellStyle, textAlign: pw.TextAlign.center)),
      );
    }

    /// Helper to draw a row with given flexes and manual borders.
    pw.Widget drawRow(List<pw.Widget> children, List<int> flexes, {
      PdfColor? bgColor, bool isTopBorder = false,
    }) {
      final cells = <pw.Widget>[];
      for (int i = 0; i < children.length; i++) {
        cells.add(
          pw.Expanded(
            flex: flexes[i],
            child: pw.Container(
              decoration: pw.BoxDecoration(
                color: bgColor,
                border: pw.Border.all(width: 0.5),
              ),
              child: children[i],
            ),
          )
        );
      }
      return pw.Row(
        children: cells,
      );
    }

    final rows = <pw.Widget>[];

    // ── Header row 1: group labels (CSC Form 48 exact) ─────────────────────
    rows.add(drawRow(
      [
        cell('Day', style: hBold),
        cell('A.M.', style: hBold),
        cell('P.M.', style: hBold),
        cell('Undertime', style: hBold),
      ],
      [12, 40, 40, 24],
      bgColor: PdfColors.grey200,
      isTopBorder: true,
    ));

    // ── Header row 2: sub-labels (Arrival / Departure) ───────────────────
    rows.add(drawRow(
      [
        cell('', style: hBold),
        cell('Arrival', style: hBold),
        cell('Departure', style: hBold),
        cell('Arrival', style: hBold),
        cell('Departure', style: hBold),
        cell('Hours', style: hBold),
        cell('Minutes', style: hBold),
      ],
      [12, 20, 20, 20, 20, 12, 12],
      bgColor: PdfColors.grey100,
    ));

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
      final log = logMap[day];

      // ── Weekend rows: print day name centered across all time cols ──────────
      if (isWeekend) {
        final label = date.weekday == DateTime.saturday ? 'SATURDAY' : 'SUNDAY';
        rows.add(drawRow([
          cell('$day'),
          cell(label, style: weekendStyle), // spanned 80 flex block
          cell(''),
          cell(''),
        ], [12, 80, 12, 12]));
        continue;
      }

      if (log == null) {
        // Empty weekday row — blank boxes
        rows.add(drawRow([
          cell('$day'),
          cell(''), cell(''), cell(''), cell(''), cell(''), cell(''),
        ], [12, 20, 20, 20, 20, 12, 12]));
        continue;
      }

      final isWork = log.status == 'WORK';

      // ── Status rows: ABSENT / LEAVE / HOLIDAY span all 4 time cols ───────
      if (!isWork) {
        String label = log.status;
        if (label == 'HOLIDAY_FULL') label = 'HOLIDAY';
        if (label == 'HOLIDAY_AM')   label = 'HOLIDAY (AM)';
        if (label == 'HOLIDAY_PM')   label = 'HOLIDAY (PM)';
        if (label == 'EXCUSED')      label = 'LEAVE';

        rows.add(drawRow([
          cell('$day'),
          cell(label, style: statusStyle), // spanned 80 flex block
          cell(''),
          cell(''),
        ], [12, 80, 12, 12]));
        continue;
      }

      // ── Work day: Smart Filler + Undertime always shown per CSC Form 48 ───
      final slots = _resolveForm48Slots(log);

      int dayLate = HourglassEngine.calculateLateDeductions(log, settings.expectedTimeIn);
      int dayEarly = 0;
      if (log.pmDepartureTime != null) {
        try {
          final timeOut = DateTime.parse(log.pmDepartureTime!);
          final expectedOut = DateFormat('HH:mm').parse(settings.expectedTimeOut);
          final expectedOutDT = DateTime(timeOut.year, timeOut.month, timeOut.day, expectedOut.hour, expectedOut.minute);
          final diffOut = expectedOutDT.difference(timeOut);
          if (diffOut.inMinutes > 0) dayEarly = diffOut.inMinutes;
        } catch (_) {}
      }
      final dayTotalUndertime = dayLate + dayEarly;
      String utHrs = '';
      String utMins = '';
      if (dayTotalUndertime > 0) {
        final h = dayTotalUndertime ~/ 60;
        final m = dayTotalUndertime % 60;
        totalUndertimeHours += h;
        totalUndertimeMins += m;
        if (h > 0) utHrs = '$h';
        if (m > 0) utMins = '$m';
      }

      rows.add(drawRow([
        cell('$day'),
        cell(slots.amIn),
        cell(slots.amOut),
        cell(slots.pmIn),
        cell(slots.pmOut),
        cell(utHrs),
        cell(utMins),
      ], [12, 20, 20, 20, 20, 12, 12]));
    }

    // ── TOTAL row ────────────────────────────────────────────────────
    totalUndertimeHours += totalUndertimeMins ~/ 60;
    totalUndertimeMins = totalUndertimeMins % 60;

    String finalTotalHrs = totalUndertimeHours > 0 ? '$totalUndertimeHours' : '';
    String finalTotalMins = totalUndertimeMins > 0 ? '$totalUndertimeMins' : '';

    rows.add(drawRow([
      cell('TOTAL', style: hBold),
      cell(finalTotalHrs, style: hBold),
      cell(finalTotalMins, style: hBold),
    ], [92, 12, 12]));

    return pw.Column(children: rows);
  }

  static pw.Widget _buildFieldworkAnnex(List<TimeLog> fieldworkLogs, InternProfile profile, String monthName) {
    final titleStyle = pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold);
    final headerStyle = pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold);
    const bodyStyle = pw.TextStyle(fontSize: 9);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Center(child: pw.Text('FIELD DEPLOYMENT ANNEX', style: titleStyle)),
        pw.Center(child: pw.Text('Audit Trail for Off-Site Fieldwork', style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic))),
        pw.SizedBox(height: 24),
        
        pw.Text('Name: ${profile.name.toUpperCase()}', style: headerStyle),
        pw.Text('Period: $monthName', style: bodyStyle),
        pw.SizedBox(height: 16),
        
        pw.Table(
          border: pw.TableBorder.all(width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(2), // Date
            1: const pw.FlexColumnWidth(4), // Location
            2: const pw.FlexColumnWidth(6), // Purpose
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Center(child: pw.Text('DATE', style: headerStyle))),
                pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Center(child: pw.Text('LOCATION / SITE', style: headerStyle))),
                pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Center(child: pw.Text('OFFICIAL PURPOSE', style: headerStyle))),
              ],
            ),
            ...fieldworkLogs.map((log) {
              final dateStr = DateFormat('MMM dd, yyyy').format(DateTime.parse(log.date));
              return pw.TableRow(
                children: [
                  pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(dateStr, style: bodyStyle)),
                  pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(log.fieldworkLocation ?? 'Not Specified', style: bodyStyle)),
                  pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(log.fieldworkPurpose ?? 'Not Specified', style: bodyStyle)),
                ],
              );
            }).toList(),
          ],
        ),
        
        pw.SizedBox(height: 32),
        pw.Text(
          'NOTE: Entries marked with an asterisk (*) in the Form 48 are authorized off-site fieldwork logs. '
          'The intern was at the locations specified above during those registry events.',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
        ),
        
        pw.Spacer(),
        
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
             pw.Column(
               crossAxisAlignment: pw.CrossAxisAlignment.start,
               children: [
                 pw.Text('Certified Correct:', style: bodyStyle),
                 pw.SizedBox(height: 24),
                 pw.Container(width: 180, decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide()))),
                 pw.SizedBox(height: 2),
                 pw.Text(profile.name.toUpperCase(), style: headerStyle),
                 pw.Text('INTERN', style: const pw.TextStyle(fontSize: 8)),
               ],
             ),
             pw.Column(
               crossAxisAlignment: pw.CrossAxisAlignment.start,
               children: [
                 pw.Text('Verified by:', style: bodyStyle),
                 pw.SizedBox(height: 24),
                 pw.Container(width: 180, decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide()))),
                 pw.SizedBox(height: 2),
                 pw.Text(profile.supervisorName.toUpperCase(), style: headerStyle),
                 pw.Text('SUPERVISOR SIGNATURE OVER PRINTED NAME', style: const pw.TextStyle(fontSize: 7)),
               ],
             ),
          ],
        ),
        pw.SizedBox(height: 16),
      ],
    );
  }
}
