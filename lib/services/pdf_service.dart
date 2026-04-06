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
  // MONTHLY ACCOMPLISHMENT REPORT PDF
  // ─────────────────────────────────────────────────────────────────
  static Future<void> generateAndPrintMonthlyReport(
    List<DailyReport> reports,
    InternProfile profile,
    int year,
    int month,
    {String? customSummaryBullets}
  ) async {
    final pdf = pw.Document();
    final monthName = DateFormat('MMMM yyyy').format(DateTime(year, month));

    // Filter reports that have notes
    final activeReports = reports
        .where((r) => r.rawNotes.isNotEmpty)
        .toList();

    // Collect all bullets from all notes
    final List<String> allBullets = [];
    for (final r in activeReports) {
      final lines = r.rawNotes
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();
      allBullets.addAll(lines);
    }

    final List<String> summaryBullets = [];
    if (customSummaryBullets != null && customSummaryBullets.isNotEmpty) {
      summaryBullets.addAll(
        customSummaryBullets.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty)
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
                      child: summaryBullets.isEmpty
                          ? pw.Text('No reports generated for this period.', style: const pw.TextStyle(fontSize: 9))
                          : pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: summaryBullets.map((b) {
                                final cleanText = b.replaceFirst('\u2022', '').trim();
                                return _bulletCell(cleanText);
                              }).toList(),
                            ),
                    ),
                  ],
                ),
              ],
            ),

            // Certification section - Right Aligned
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                   pw.Text('Prepared & submitted by;', style: const pw.TextStyle(fontSize: 10)),
                   pw.SizedBox(height: 24),
                   pw.Container(
                    width: 200,
                    decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide())),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    profile.name.isEmpty ? '' : profile.name.toUpperCase(),
                    style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 32),

            // Noted by - Left Aligned
            pw.Align(
              alignment: pw.Alignment.centerLeft,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Noted by:', style: const pw.TextStyle(fontSize: 10)),
                  pw.SizedBox(height: 24),
                  pw.Column(
                    children: [
                      pw.Container(
                        width: 200,
                        decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide())),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        profile.supervisorName.isEmpty ? '' : profile.supervisorName.toUpperCase(),
                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text('OFFICE HEAD', style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 32),

            // School and Course - Right Aligned
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Row(
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Text('NAME OF SCHOOL: ', style: const pw.TextStyle(fontSize: 10)),
                      pw.Container(
                        width: 150,
                        decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide())),
                        child: pw.Text(' ', style: const pw.TextStyle(fontSize: 10)),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Text('COURSE: ', style: const pw.TextStyle(fontSize: 10, letterSpacing: 0.5)),
                      pw.Container(
                        width: 150,
                        decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide())),
                        child: pw.Text(' ', style: const pw.TextStyle(fontSize: 10)),
                      ),
                    ],
                  ),
                ],
              ),
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
  // CSC FORM 48 — DAILY TIME RECORD PDF (Two-copy layout)
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

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          // Wrap two identical DTRs in a Row with a Spacer
          return pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildSingleForm48Copy(logMap, profile, settings, monthName, daysInMonth, year, month),
              pw.SizedBox(width: 20), // Vertical Divider space
              _buildSingleForm48Copy(logMap, profile, settings, monthName, daysInMonth, year, month),
            ],
          );
        },
      ),
    );

    // Filter fieldwork logs for the Annex
    final fieldworkLogs = logs.where((l) => l.isFieldwork).toList();
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
    final normal = const pw.TextStyle(fontSize: 7);
    final bold = pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 7);
    final titleBold = pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11);

    return pw.Container(
      width: 250, // Perfect for half A4 width
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
          
          pw.Container(
            width: 160,
            decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide())),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            profile.name.isEmpty ? '' : profile.name.toUpperCase(),
            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),
          
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            children: [
              pw.Text('VERIFIED as to the prescribed office hours:', style: const pw.TextStyle(fontSize: 7)),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Container(
            width: 160,
            decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide())),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            profile.supervisorName.isEmpty ? '' : profile.supervisorName.toUpperCase(), 
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)
          ),
          pw.Text('In Charge', style: const pw.TextStyle(fontSize: 7)),
        ],
      ),
    );
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
    final cellStyle = const pw.TextStyle(fontSize: 6.5);

    pw.Widget cell(String text, {pw.TextStyle? style}) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 1.5, horizontal: 1),
        child: pw.Center(child: pw.Text(text, style: style ?? cellStyle, textAlign: pw.TextAlign.center)),
      );
    }

    final rows = <pw.TableRow>[];

    // Header 1
    rows.add(pw.TableRow(
      children: [
        cell('Day', style: hBold),
        pw.Container(height: 12, child: pw.Center(child: pw.Text('AM Arrival', style: hBold))),
        pw.Container(height: 12, child: pw.Center(child: pw.Text('PM Departure', style: hBold))),
        pw.Container(height: 12, child: pw.Center(child: pw.Text('Undertime Hrs', style: hBold))),
        pw.Container(height: 12, child: pw.Center(child: pw.Text('Undertime Mins', style: hBold))),
      ],
    ));

    final timeFormatter = DateFormat('hh:mm');

    for (int day = 1; day <= daysInMonth; day++) {
      final log = logMap[day];

      String amArr = '';
      String pmDep = '';
      String utHrs = '';
      String utMins = '';

      if (log != null) {
        final isWork = log.status == 'WORK';
        final isFullHoliday = log.status == 'HOLIDAY_FULL';
        final isAMHoliday = log.status == 'HOLIDAY_AM';
        final isPMHoliday = log.status == 'HOLIDAY_PM';

        if (isFullHoliday) {
          amArr = 'HOLIDAY';
          pmDep = log.remarks ?? '';
        } else if (isAMHoliday) {
          amArr = 'HOLIDAY';
        } else if (isPMHoliday) {
          pmDep = 'HOLIDAY';
        } else if (log.status == 'ABSENT' || log.status == 'EXCUSED') {
          amArr = log.status;
          pmDep = log.remarks ?? '';
        }
        
        if (isWork) {
           if (log.amArrivalTime != null) {
             amArr = timeFormatter.format(DateTime.parse(log.amArrivalTime!));
             if (log.isFieldwork) amArr = '*$amArr';
           }
           if (log.pmDepartureTime != null) {
             pmDep = timeFormatter.format(DateTime.parse(log.pmDepartureTime!));
           }

           // Undertime calculation
           int dayLate = HourglassEngine.calculateLateDeductions(log, settings.expectedTimeIn);
           int dayEarly = 0;
           if (log.pmDepartureTime != null) {
              try {
                final timeOut = DateTime.parse(log.pmDepartureTime!);
                final expectedOut = DateFormat("HH:mm").parse(settings.expectedTimeOut);
                final expectedOutDT = DateTime(timeOut.year, timeOut.month, timeOut.day, expectedOut.hour, expectedOut.minute);
                final diffOut = expectedOutDT.difference(timeOut);
                if (diffOut.inMinutes > 0) dayEarly = diffOut.inMinutes;
              } catch (_) {}
           }

           final dayTotalUndertime = dayLate + dayEarly;
           if (dayTotalUndertime > 0) {
             final h = dayTotalUndertime ~/ 60;
             final m = dayTotalUndertime % 60;
             totalUndertimeHours += h;
             totalUndertimeMins += m;
             if (h > 0) utHrs = '$h';
             if (m > 0) utMins = '$m';
           }
        }
      }

      rows.add(pw.TableRow(
        children: [
          cell('$day'),
          cell(amArr),
          cell(pmDep),
          cell(utHrs),
          cell(utMins),
        ],
      ));
    }

    totalUndertimeHours += totalUndertimeMins ~/ 60;
    totalUndertimeMins = totalUndertimeMins % 60;

    rows.add(pw.TableRow(
      decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(width: 1))),
      children: [
        cell('TOTAL', style: hBold),
        cell(''),
        cell(''),
        cell('$totalUndertimeHours', style: hBold),
        cell('$totalUndertimeMins', style: hBold),
      ],
    ));

    return pw.Table(
      border: pw.TableBorder.all(width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(1.2), // Day
        1: const pw.FlexColumnWidth(2.5), // AM Arrival
        2: const pw.FlexColumnWidth(2.5), // PM Departure
        3: const pw.FlexColumnWidth(1.5), // Hours
        4: const pw.FlexColumnWidth(1.5), // Minutes
      },
      children: rows,
    );
  }

  static pw.Widget _buildFieldworkAnnex(List<TimeLog> fieldworkLogs, InternProfile profile, String monthName) {
    final titleStyle = pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold);
    final headerStyle = pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold);
    final bodyStyle = const pw.TextStyle(fontSize: 9);

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
          style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
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
