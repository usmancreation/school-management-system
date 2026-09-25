import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/pdf_generator.dart';
import '../../models/invoice_model.dart';

class DocumentPreviewDialog extends StatelessWidget {
  final String title;
  final String documentType;
  final Widget content;
  final Future<String> Function() onGeneratePdf;

  const DocumentPreviewDialog({
    super.key,
    required this.title,
    required this.documentType,
    required this.content,
    required this.onGeneratePdf,
  });

  // Factory 1: Fee Challan Preview
  static void showFeeChallan(BuildContext context, InvoiceModel inv) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => DocumentPreviewDialog(
        title: 'Fee Challan Preview - ${inv.invoiceNumber}',
        documentType: 'STUDENT FEE CHALLAN',
        onGeneratePdf: () => PdfGenerator.generateFeeChallanPdf(inv),
        content: _buildChallanContent(inv),
      ),
    );
  }

  // Factory 2: Fee Receipt Preview
  static void showFeeReceipt(BuildContext context, InvoiceModel inv) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => DocumentPreviewDialog(
        title: 'Payment Receipt Preview - ${inv.invoiceNumber}',
        documentType: 'OFFICIAL PAYMENT RECEIPT',
        onGeneratePdf: () => PdfGenerator.generateFeeReceiptPdf(inv),
        content: _buildReceiptContent(inv),
      ),
    );
  }

  // Factory 3: Report Card Preview
  static void showReportCard(
    BuildContext context, {
    required String studentName,
    required String admissionNo,
    required String rollNo,
    required String className,
    required String session,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => DocumentPreviewDialog(
        title: 'Academic Report Card - $studentName',
        documentType: 'OFFICIAL ACADEMIC TRANSCRIPT',
        onGeneratePdf: () => PdfGenerator.generateReportCardPdf(
          studentName: studentName,
          admissionNo: admissionNo,
          rollNo: rollNo,
          className: className,
          session: session,
        ),
        content: _buildReportCardContent(
          studentName: studentName,
          admissionNo: admissionNo,
          rollNo: rollNo,
          className: className,
          session: session,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820, maxHeight: 880),
        child: Column(
          children: [
            // Modal Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.description, color: Colors.white, size: 22),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Document Scrollable Sheet Canvas
            Expanded(
              child: Container(
                color: const Color(0xFFF1F5F9),
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: SingleChildScrollView(
                    child: Container(
                      width: 720,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Institution Brand Header
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 54,
                                height: 54,
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'OAKRIDGE INTERNATIONAL ACADEMY',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E3A8A),
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Sector H-8/4, Institutional Boulevard, Islamabad | Tel: +92 51 8899220',
                                      style: TextStyle(fontSize: 11, color: Colors.grey),
                                    ),
                                    Text(
                                      'Affiliation Code: AFF-9982-CBSE • NTN: 4829103-9',
                                      style: TextStyle(fontSize: 11, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFF1E3A8A)),
                                ),
                                child: Text(
                                  documentType,
                                  style: const TextStyle(
                                    color: Color(0xFF1E3A8A),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 32, thickness: 1.5),

                          // Dynamic Document Body
                          content,

                          const SizedBox(height: 36),
                          const Divider(height: 1),
                          const SizedBox(height: 16),

                          // Document Footer / Signatures
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _signatureField('Authorized Cashier'),
                              _signatureField('Bursar / Accounts Officer'),
                              _signatureField('Principal Official Seal'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Action Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  const Text(
                    'Preview mode. File will be saved directly into your Downloads folder.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Close'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        final path = await onGeneratePdf();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Saved to Downloads: ${path.split('\\').last}'),
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 6),
                              action: SnackBarAction(
                                label: 'Open PDF',
                                textColor: Colors.white,
                                onPressed: () => PdfGenerator.openFile(path),
                              ),
                            ),
                          );
                          PdfGenerator.openFile(path);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to generate PDF: $e'), backgroundColor: Colors.red),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.download, size: 16),
                    label: const Text('Download PDF Document'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Content Builders
  static Widget _buildChallanContent(InvoiceModel inv) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Challan Details Grid
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _docRow('Challan Ref #:', inv.invoiceNumber),
                    _docRow('Issue Date:', inv.issueDate),
                    _docRow('Due Date:', inv.dueDate),
                    _docRow('Bank Branch:', 'Allied Bank Ltd / HBL (Any Online Branch)'),
                    _docRow('Account Title:', 'Oakridge Academy Operations'),
                    _docRow('Account No / IBAN:', 'PK44ABPA0010029837190012'),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _docRow('Student Name:', inv.studentName),
                    _docRow('Admission ID:', inv.admissionNumber),
                    _docRow('Class / Section:', 'Grade 10 - Section A'),
                    _docRow('Roll Number:', '1001'),
                    _docRow('Guardian:', 'David Wright'),
                    _docRow('Contact:', '+1 (555) 0192-338'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Fee Table
        const Text('Fee Particulars & Tariff Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        Table(
          border: TableBorder.all(color: const Color(0xFFCBD5E1)),
          columnWidths: const {
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(6),
            2: FlexColumnWidth(3),
          },
          children: [
            TableRow(
              decoration: const BoxDecoration(color: Color(0xFFE2E8F0)),
              children: [
                _tableHeader('Sr.'),
                _tableHeader('Particulars / Head'),
                _tableHeader('Amount', align: TextAlign.right),
              ],
            ),
            TableRow(
              children: [
                _tableCell('1'),
                _tableCell('Monthly Tuition Fee (Term 1)'),
                _tableCell(Formatters.formatCurrency(inv.amountDue * 0.70), align: TextAlign.right),
              ],
            ),
            TableRow(
              children: [
                _tableCell('2'),
                _tableCell('Science Laboratory & IT Equipment Fund'),
                _tableCell(Formatters.formatCurrency(inv.amountDue * 0.15), align: TextAlign.right),
              ],
            ),
            TableRow(
              children: [
                _tableCell('3'),
                _tableCell('Library Resources & Exam Registration'),
                _tableCell(Formatters.formatCurrency(inv.amountDue * 0.15), align: TextAlign.right),
              ],
            ),
            TableRow(
              decoration: const BoxDecoration(color: Color(0xFFF1F5F9)),
              children: [
                _tableCell(''),
                _tableCell('Total Payable Within Due Date', isBold: true),
                _tableCell(Formatters.formatCurrency(inv.amountDue), isBold: true, align: TextAlign.right),
              ],
            ),
            TableRow(
              children: [
                _tableCell(''),
                _tableCell('Late Surcharge (After Due Date +5%)'),
                _tableCell(Formatters.formatCurrency(inv.amountDue * 0.05), align: TextAlign.right),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static Widget _buildReceiptContent(InvoiceModel inv) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Verified Badge
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PAYMENT STATUS: PAID IN FULL', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('Transaction Ref: TXN-${inv.invoiceNumber}-VERIFIED • Cleared on Counter', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              Text(
                Formatters.formatCurrency(inv.amountDue),
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Receipt Fields Table
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFCBD5E1)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            children: [
              _twoColLine('Receipt Number:', 'REC-${inv.invoiceNumber}'),
              const Divider(height: 1),
              _twoColLine('Invoice Reference:', inv.invoiceNumber),
              const Divider(height: 1),
              _twoColLine('Student Full Name:', inv.studentName),
              const Divider(height: 1),
              _twoColLine('Admission ID:', inv.admissionNumber),
              const Divider(height: 1),
              _twoColLine('Class / Section:', 'Grade 10 - Section A'),
              const Divider(height: 1),
              _twoColLine('Fee Category:', inv.categoryName.isNotEmpty ? inv.categoryName : inv.title),
              const Divider(height: 1),
              _twoColLine('Payment Mode:', 'Cash Counter / Bank Transfer (Cleared)'),
              const Divider(height: 1),
              _twoColLine('Date of Clearance:', inv.issueDate),
              const Divider(height: 1),
              _twoColLine('Balance Remaining:', '\$0.00 (Nil)'),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _buildReportCardContent({
    required String studentName,
    required String admissionNo,
    required String rollNo,
    required String className,
    required String session,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Meta
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _docRow('Student Name:', studentName),
                    _docRow('Admission ID:', admissionNo),
                    _docRow('Roll Number:', rollNo),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _docRow('Class / Section:', className),
                    _docRow('Academic Session:', session),
                    _docRow('Cumulative GPA:', '3.88 / 4.0 (Grade A+)'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Marks Table
        Table(
          border: TableBorder.all(color: const Color(0xFFCBD5E1)),
          columnWidths: const {
            0: FlexColumnWidth(4),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(2),
            3: FlexColumnWidth(2),
            4: FlexColumnWidth(2),
            5: FlexColumnWidth(2),
            6: FlexColumnWidth(3),
          },
          children: [
            TableRow(
              decoration: const BoxDecoration(color: Color(0xFFE2E8F0)),
              children: [
                _tableHeader('Subject'),
                _tableHeader('Max', align: TextAlign.center),
                _tableHeader('Theory', align: TextAlign.center),
                _tableHeader('Prac', align: TextAlign.center),
                _tableHeader('Total', align: TextAlign.center),
                _tableHeader('Grade', align: TextAlign.center),
                _tableHeader('Remarks'),
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
        const SizedBox(height: 16),

        // Summary Bar
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Marks: 544 / 600', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Text('Percentage: 90.67%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Text('Attendance: 96.5%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Text('Result: PASSED WITH DISTINCTION', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  // Helpers
  static Widget _docRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(width: 110, child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  static Widget _twoColLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12.5, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  static Widget _tableHeader(String title, {TextAlign align = TextAlign.left}) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(title, textAlign: align, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  static Widget _tableCell(String value, {bool isBold = false, TextAlign align = TextAlign.left}) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(value, textAlign: align, style: TextStyle(fontSize: 12, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
    );
  }

  static TableRow _subjectRow(String subject, int max, int theory, int practical, int total, String grade, String remarks) {
    return TableRow(
      children: [
        _tableCell(subject),
        _tableCell('$max', align: TextAlign.center),
        _tableCell('$theory', align: TextAlign.center),
        _tableCell(practical > 0 ? '$practical' : '-', align: TextAlign.center),
        _tableCell('$total', isBold: true, align: TextAlign.center),
        _tableCell(grade, isBold: true, align: TextAlign.center),
        _tableCell(remarks),
      ],
    );
  }

  static Widget _signatureField(String label) {
    return Column(
      children: [
        Container(width: 140, height: 1, color: Colors.grey.shade400),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10.5, color: Colors.grey)),
      ],
    );
  }
}
