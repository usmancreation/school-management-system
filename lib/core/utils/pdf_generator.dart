import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../models/invoice_model.dart';
import '../../core/utils/formatters.dart';

class PdfGenerator {
  static String getDownloadsDirectory() {
    final userProfile = Platform.environment['USERPROFILE'];
    if (userProfile != null) {
      final downloads = Directory('$userProfile\\Downloads');
      if (downloads.existsSync()) return downloads.path;
      return userProfile;
    }
    return Directory.current.path;
  }

  /// Open file with default Windows viewer
  static void openFile(String filePath) {
    if (Platform.isWindows) {
      Process.run('cmd', ['/c', 'start', '', filePath]);
    }
  }

  /// Open folder highlighting file
  static void openFolder(String filePath) {
    if (Platform.isWindows) {
      Process.run('explorer.exe', ['/select,', filePath]);
    }
  }

  /// 1. Generate Fee Challan PDF
  static Future<String> generateFeeChallanPdf(InvoiceModel inv) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.only(bottom: 12),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(width: 2, color: PdfColors.blue900)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'OAKRIDGE INTERNATIONAL ACADEMY',
                          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                        ),
                        pw.Text(
                          'Sector H-8/4, Institutional Area, Islamabad | Tel: +92 51 8899220',
                          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                        ),
                        pw.Text(
                          'Affiliation Code: AFF-9982-CBSE | NTN: 4829103-9',
                          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.blue900,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(
                        'STUDENT CHALLAN',
                        style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // Challan & Student Meta
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey300),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _pdfInfoRow('Challan No:', inv.invoiceNumber),
                          _pdfInfoRow('Issue Date:', inv.issueDate),
                          _pdfInfoRow('Due Date:', inv.dueDate),
                          _pdfInfoRow('Bank:', 'Allied Bank Ltd / HBL (Branch Counter)'),
                          _pdfInfoRow('Account Title:', 'Oakridge Academy Operations'),
                          _pdfInfoRow('Account / IBAN:', 'PK44ABPA0010029837190012'),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 16),
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey300),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _pdfInfoRow('Student Name:', inv.studentName),
                          _pdfInfoRow('Admission No:', inv.admissionNumber),
                          _pdfInfoRow('Class / Grade:', 'Grade 10 - Section A'),
                          _pdfInfoRow('Roll Number:', '1001'),
                          _pdfInfoRow('Guardian:', 'David Wright'),
                          _pdfInfoRow('Contact:', '+1 (555) 0192-338'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Fee Breakdown Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _tableCell('Sr.', isHeader: true, flex: 1),
                      _tableCell('Particulars / Fee Description', isHeader: true, flex: 6),
                      _tableCell('Amount (PKR / USD)', isHeader: true, flex: 3, align: pw.TextAlign.right),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _tableCell('1', flex: 1),
                      _tableCell('Monthly Tuition Fee (Term 1)', flex: 6),
                      _tableCell(Formatters.formatCurrency(inv.amountDue * 0.70), flex: 3, align: pw.TextAlign.right),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _tableCell('2', flex: 1),
                      _tableCell('Science Laboratory & IT Equipment Fund', flex: 6),
                      _tableCell(Formatters.formatCurrency(inv.amountDue * 0.15), flex: 3, align: pw.TextAlign.right),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _tableCell('3', flex: 1),
                      _tableCell('Library Resources & Exam Registration', flex: 6),
                      _tableCell(Formatters.formatCurrency(inv.amountDue * 0.15), flex: 3, align: pw.TextAlign.right),
                    ],
                  ),
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                    children: [
                      _tableCell('', flex: 1),
                      _tableCell('Total Payable Within Due Date', isHeader: true, flex: 6),
                      _tableCell(Formatters.formatCurrency(inv.amountDue), isHeader: true, flex: 3, align: pw.TextAlign.right),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _tableCell('', flex: 1),
                      _tableCell('Late Surcharge (After Due Date +5%)', flex: 6),
                      _tableCell(Formatters.formatCurrency(inv.amountDue * 0.05), flex: 3, align: pw.TextAlign.right),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 24),

              // Instructions
              pw.Text('Important Instructions:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
              pw.Bullet(text: 'Fee must be deposited in any designated bank branch on or before the due date.', style: const pw.TextStyle(fontSize: 8)),
              pw.Bullet(text: 'After due date, late surcharge will be charged automatically.', style: const pw.TextStyle(fontSize: 8)),
              pw.Bullet(text: 'Retain Student Copy for your official records and verification.', style: const pw.TextStyle(fontSize: 8)),
              pw.SizedBox(height: 36),

              // Signatures
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    children: [
                      pw.Container(width: 140, decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide()))),
                      pw.SizedBox(height: 4),
                      pw.Text('Bank Cashier Stamp & Sign', style: const pw.TextStyle(fontSize: 8)),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Container(width: 140, decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide()))),
                      pw.SizedBox(height: 4),
                      pw.Text('School Bursar / Finance Officer', style: const pw.TextStyle(fontSize: 8)),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Container(width: 140, decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide()))),
                      pw.SizedBox(height: 4),
                      pw.Text('Parent / Depositor Signature', style: const pw.TextStyle(fontSize: 8)),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    final downloadsDir = getDownloadsDirectory();
    final fileName = 'Fee_Challan_${inv.invoiceNumber.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_')}.pdf';
    final filePath = '$downloadsDir\\$fileName';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    return filePath;
  }

  /// 2. Generate Fee Payment Receipt PDF
  static Future<String> generateFeeReceiptPdf(InvoiceModel inv) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.only(bottom: 12),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(width: 2, color: PdfColors.green800)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'OAKRIDGE INTERNATIONAL ACADEMY',
                          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                        ),
                        pw.Text(
                          'Sector H-8/4, Institutional Area, Islamabad | Accounts & Bursar Department',
                          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.green700,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(
                        'OFFICIAL PAYMENT RECEIPT',
                        style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Payment Status Banner
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.green50,
                  border: pw.Border.all(color: PdfColors.green300),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('PAYMENT STATUS: PAID & VERIFIED', style: pw.TextStyle(color: PdfColors.green800, fontWeight: pw.FontWeight.bold, fontSize: 13)),
                        pw.Text('Receipt Transaction Ref: TXN-${inv.invoiceNumber}-VERIFIED', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                      ],
                    ),
                    pw.Text(
                      Formatters.formatCurrency(inv.amountDue),
                      style: pw.TextStyle(color: PdfColors.green800, fontWeight: pw.FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Student & Payment Details
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  _twoColRow('Receipt Number:', 'REC-${inv.invoiceNumber}'),
                  _twoColRow('Invoice Reference:', inv.invoiceNumber),
                  _twoColRow('Student Full Name:', inv.studentName),
                  _twoColRow('Admission ID:', inv.admissionNumber),
                  _twoColRow('Class / Section:', 'Grade 10 - Section A'),
                  _twoColRow('Fee Category:', inv.categoryName.isNotEmpty ? inv.categoryName : inv.title),
                  _twoColRow('Payment Mode:', 'Cash Counter / Bank Transfer (Cleared)'),
                  _twoColRow('Date of Clearance:', inv.issueDate),
                  _twoColRow('Balance Remaining:', '\$0.00 (Nil)'),
                ],
              ),
              pw.SizedBox(height: 32),

              pw.Text('Computer Generated Official Receipt. Valid without physical counter-signature.', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
              pw.SizedBox(height: 40),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    children: [
                      pw.Container(width: 160, decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide()))),
                      pw.SizedBox(height: 4),
                      pw.Text('Cashier / Bursar Officer', style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.green800, width: 2),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Text('VERIFIED & AUDITED\nOAKRIDGE ERP', textAlign: pw.TextAlign.center, style: pw.TextStyle(color: PdfColors.green800, fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Column(
                    children: [
                      pw.Container(width: 160, decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide()))),
                      pw.SizedBox(height: 4),
                      pw.Text('Principal Academic Seal', style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    final downloadsDir = getDownloadsDirectory();
    final fileName = 'Receipt_${inv.invoiceNumber.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_')}.pdf';
    final filePath = '$downloadsDir\\$fileName';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    return filePath;
  }

  /// 3. Generate Academic Report Card PDF
  static Future<String> generateReportCardPdf({
    required String studentName,
    required String admissionNo,
    required String rollNo,
    required String className,
    required String session,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text('OAKRIDGE INTERNATIONAL ACADEMY', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                    pw.Text('OFFICIAL ACADEMIC TRANSCRIPT & REPORT CARD', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800)),
                    pw.Text('Session: $session | Mid-Term Examinations', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Divider(thickness: 1.5, color: PdfColors.blue900),
              pw.SizedBox(height: 12),

              // Student details
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _pdfInfoRow('Student Name:', studentName),
                      _pdfInfoRow('Admission No:', admissionNo),
                      _pdfInfoRow('Roll Number:', rollNo),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _pdfInfoRow('Class / Section:', className),
                      _pdfInfoRow('Overall Standing:', 'Rank #2 in Class'),
                      _pdfInfoRow('Cumulative GPA:', '3.88 / 4.0 (Grade A+)'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Marks Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _tableCell('Subject', isHeader: true, flex: 4),
                      _tableCell('Max', isHeader: true, flex: 2, align: pw.TextAlign.center),
                      _tableCell('Theory', isHeader: true, flex: 2, align: pw.TextAlign.center),
                      _tableCell('Prac', isHeader: true, flex: 2, align: pw.TextAlign.center),
                      _tableCell('Total', isHeader: true, flex: 2, align: pw.TextAlign.center),
                      _tableCell('Grade', isHeader: true, flex: 2, align: pw.TextAlign.center),
                      _tableCell('Remarks', isHeader: true, flex: 3),
                    ],
                  ),
                  _subjectRow('Advanced Mathematics', 100, 94, 0, 94, 'A+', 'Outstanding'),
                  _subjectRow('Physics (Theory & Lab)', 100, 68, 20, 88, 'A', 'Very Good'),
                  _subjectRow('Chemistry (Theory & Lab)', 100, 71, 20, 91, 'A+', 'Excellent'),
                  _subjectRow('English Literature', 100, 85, 0, 85, 'A', 'Proficient'),
                  _subjectRow('Computer Science & AI', 100, 72, 25, 97, 'A+', 'Exceptional'),
                  _subjectRow('Pakistan Studies / History', 100, 89, 0, 89, 'A', 'Commendable'),
                ],
              ),
              pw.SizedBox(height: 16),

              // Summary
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  border: pw.Border.all(color: PdfColors.blue200),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Total Marks: 544 / 600', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                    pw.Text('Percentage: 90.67%', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                    pw.Text('Attendance: 96.5% (44/45 Days)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                    pw.Text('Result: PASSED WITH DISTINCTION', style: pw.TextStyle(color: PdfColors.green800, fontWeight: pw.FontWeight.bold, fontSize: 11)),
                  ],
                ),
              ),
              pw.SizedBox(height: 48),

              // Signatures
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    children: [
                      pw.Container(width: 140, decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide()))),
                      pw.SizedBox(height: 4),
                      pw.Text('Class Teacher', style: const pw.TextStyle(fontSize: 8)),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Container(width: 140, decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide()))),
                      pw.SizedBox(height: 4),
                      pw.Text('Controller of Examinations', style: const pw.TextStyle(fontSize: 8)),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Container(width: 140, decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide()))),
                      pw.SizedBox(height: 4),
                      pw.Text('Principal & Head of School', style: const pw.TextStyle(fontSize: 8)),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    final downloadsDir = getDownloadsDirectory();
    final fileName = 'ReportCard_${admissionNo.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_')}.pdf';
    final filePath = '$downloadsDir\\$fileName';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    return filePath;
  }

  // Helpers
  static pw.Widget _pdfInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.SizedBox(width: 90, child: pw.Text(label, style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700))),
          pw.Expanded(child: pw.Text(value, style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold))),
        ],
      ),
    );
  }

  static pw.TableRow _twoColRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(label, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(value, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
        ),
      ],
    );
  }

  static pw.Widget _tableCell(String text, {bool isHeader = false, int flex = 1, pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static pw.TableRow _subjectRow(String subject, int max, int theory, int practical, int total, String grade, String remarks) {
    return pw.TableRow(
      children: [
        _tableCell(subject, flex: 4),
        _tableCell('$max', flex: 2, align: pw.TextAlign.center),
        _tableCell('$theory', flex: 2, align: pw.TextAlign.center),
        _tableCell(practical > 0 ? '$practical' : '-', flex: 2, align: pw.TextAlign.center),
        _tableCell('$total', isHeader: true, flex: 2, align: pw.TextAlign.center),
        _tableCell(grade, isHeader: true, flex: 2, align: pw.TextAlign.center),
        _tableCell(remarks, flex: 3),
      ],
    );
  }
}
