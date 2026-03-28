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
  /// Opens the native Share/Print dialog exposing the dynamically generated Monthly Report
  static Future<void> generateAndPrintMonthlyReport(
    List<DailyReport> reports,
    InternProfile profile,
    int year,
    int month,
  ) async {
    final pdf = pw.Document();
    final monthName = DateFormat('MMMM yyyy').format(DateTime(year, month));

    // Filter only reports that have formal text
    final formalReports = reports.where((r) => r.formalReport != null && r.formalReport!.isNotEmpty).toList();

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) {
          return [
            pw.Center(
              child: pw.Text('Monthly Accomplishment Report',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 4),
            pw.Center(child: pw.Text(monthName, style: const pw.TextStyle(fontSize: 14))),
            pw.SizedBox(height: 16),
            pw.Text('Intern: ${profile.name.isEmpty ? "(Name)" : profile.name}',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.Text('Agency: ${profile.agencyOffice.isEmpty ? "(Agency)" : profile.agencyOffice}',
                style: const pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: 20),
            if (formalReports.isEmpty)
              pw.Text('No formal reports generated for this month.', style: const pw.TextStyle(fontSize: 11))
            else
              ...formalReports.map((r) {
                final dateLabel = DateFormat('MMMM d, yyyy').format(DateTime.parse(r.date));
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 16),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(dateLabel, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 4),
                      pw.Text(r.formalReport!, style: const pw.TextStyle(fontSize: 10, lineSpacing: 4)),
                      pw.Divider(),
                    ],
                  ),
                );
              }),
            pw.SizedBox(height: 24),
            pw.Text(
              'I certify on my honor that the above is a true and correct report of the activities performed.',
              style: const pw.TextStyle(fontSize: 9),
              textAlign: pw.TextAlign.justify,
            ),
            pw.SizedBox(height: 32),
            pw.Container(
              width: 150,
              decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide())),
            ),
            pw.SizedBox(height: 4),
            pw.Text(profile.name.isEmpty ? '(Intern Signature)' : profile.name.toUpperCase(),
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Monthly_Report_${profile.name.replaceAll(" ", "_")}_${month}_$year',
    );
  }

  /// Opens the native Share/Print dialog exposing the dynamically generated Form 48
  static Future<void> generateAndPrintForm48(
    List<TimeLog> logs, 
    InternProfile profile, 
    InternSettings settings, 
    int year, 
    int month
  ) async {
    final pdfData = await _buildPdf(logs, profile, settings, year, month);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfData,
      name: 'Form48_${profile.name.replaceAll(" ", "_")}_${month}_$year',
    );
  }

  /// Low-level renderer for the pixel-perfect Civil Service Commission Form 48 Grid
  static Future<Uint8List> _buildPdf(
    List<TimeLog> logs, 
    InternProfile profile, 
    InternSettings settings, 
    int year, 
    int month
  ) async {
    final pdf = pw.Document();

    // Map logs heavily to day indices for perfect grid spacing
    Map<int, TimeLog> logMap = {};
    for (var log in logs) {
      final d = DateTime.parse(log.date);
      if (d.year == year && d.month == month) {
        logMap[d.day] = log;
      }
    }

    final monthName = DateFormat('MMMM yyyy').format(DateTime(year, month));

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text('CIVIL SERVICE FORM NO. 48', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
              pw.SizedBox(height: 8),
              pw.Text('DAILY TIME RECORD', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
              pw.SizedBox(height: 12),
              
              // Name formatting
              pw.Text('-----   ${profile.name.isEmpty ? "(Intern Name)" : profile.name.toUpperCase()}   -----', 
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)
              ),
              pw.Text('(Name)', style: const pw.TextStyle(fontSize: 9)),
              pw.SizedBox(height: 8),
              
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('For the month of: $monthName', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text('Official hours: ___________', style: const pw.TextStyle(fontSize: 10)),
                ]
              ),
              pw.SizedBox(height: 12),

              // The Ledger Grid Table Hook
              _buildForm48Grid(logMap, settings, year, month),
              
              pw.SizedBox(height: 16),
              pw.Text(
                'I CERTIFY on my honor that the above is a true and correct report of the hours of work performed, record of which was made daily at the time of arrival and departure from office.', 
                textAlign: pw.TextAlign.justify,
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.SizedBox(height: 24),
              // Empty signature line for Intern
              pw.Container(
                 width: 150,
                 decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide())),
              ),
              pw.SizedBox(height: 24),
              pw.Text('Verified as to prescribed office hours.', style: const pw.TextStyle(fontSize: 9)),
              pw.SizedBox(height: 24),
              pw.Center(
                child: pw.Text('${profile.supervisorName.isEmpty ? "(Supervisor Name)" : profile.supervisorName.toUpperCase()}', 
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))
              ),
              pw.Center(child: pw.Text('In Charge', style: const pw.TextStyle(fontSize: 9))),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildForm48Grid(Map<int, TimeLog> logMap, InternSettings settings, int year, int month) {
    final headers = ['Day', 'Arrival', 'Departure', 'Late/Undertime', 'Total Hrs'];

    double totalRendered = 0.0;
    int totalLateMins = 0;

    final rows = <pw.TableRow>[];
    
    // Table Header
    rows.add(
      pw.TableRow(
        decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide())),
        children: headers.map((t) => pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: pw.Center(child: pw.Text(t, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)))
        )).toList()
      )
    );

    // Dynamic length computation
    final daysInMonth = DateTime(year, month + 1, 0).day;

    for (int day = 1; day <= daysInMonth; day++) {
      final log = logMap[day];

      String arr = "";
      String dep = "";
      String pen = "";
      String hrs = "";
      
      bool isWeekend = DateTime(year, month, day).weekday > 5;

      if (log != null) {
        arr = DateFormat('hh:mm a').format(DateTime.parse(log.timeIn));
        if (log.timeOut != null) {
          dep = DateFormat('hh:mm a').format(DateTime.parse(log.timeOut!));
          // Calculate valid totals based on core engine
          final hoursVal = HourglassEngine.calculateActualHours(log, settings);
          final lateVal = HourglassEngine.calculateLateDeductions(log, settings.expectedTimeIn);
          
          totalRendered += hoursVal;
          totalLateMins += lateVal;

          hrs = hoursVal.toStringAsFixed(1);
          if (lateVal > 0) pen = "$lateVal min";
        } else {
          dep = "Active";
        }
      } else if (isWeekend) {
        arr = "SAT/SUN";
        dep = "";
      }

      rows.add(
        pw.TableRow(
          children: [
            pw.Center(child: pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Text('$day', style: const pw.TextStyle(fontSize: 9)))),
            pw.Center(child: pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Text(arr, style: const pw.TextStyle(fontSize: 9)))),
            pw.Center(child: pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Text(dep, style: const pw.TextStyle(fontSize: 9)))),
            pw.Center(child: pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Text(pen, style: const pw.TextStyle(fontSize: 9)))),
            pw.Center(child: pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Text(hrs, style: const pw.TextStyle(fontSize: 9)))),
          ]
        )
      );
    }

    // Grand Totals Footers
    rows.add(
      pw.TableRow(
        decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide())),
        children: [
          pw.Center(child: pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 4), child: pw.Text('TOTAL', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)))),
          pw.SizedBox(),
          pw.SizedBox(),
          pw.Center(child: pw.Text('$totalLateMins mins', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9))),
          pw.Center(child: pw.Text(totalRendered.toStringAsFixed(1), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9))),
        ]
      )
    );

    return pw.Table(
      border: pw.TableBorder.all(width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(2),
        4: const pw.FlexColumnWidth(1.5),
      },
      children: rows,
    );
  }
}
