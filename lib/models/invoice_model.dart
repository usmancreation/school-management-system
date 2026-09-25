class InvoiceModel {
  final String id;
  final String invoiceNumber;
  final String title;
  final double amountDue;
  final double amountPaid;
  final double balanceAmount;
  final String dueDate;
  final String issueDate;
  final String status;
  final String studentId;
  final String admissionNumber;
  final String firstName;
  final String lastName;
  final String categoryName;

  InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.title,
    required this.amountDue,
    required this.amountPaid,
    required this.balanceAmount,
    required this.dueDate,
    this.issueDate = '2025-09-01',
    required this.status,
    required this.studentId,
    required this.admissionNumber,
    required this.firstName,
    required this.lastName,
    required this.categoryName,
  });

  String get studentName => '$firstName $lastName'.trim();

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'] ?? '',
      invoiceNumber: json['invoice_number'] ?? '',
      title: json['title'] ?? '',
      amountDue: (json['amount_due'] as num?)?.toDouble() ?? 0.0,
      amountPaid: (json['amount_paid'] as num?)?.toDouble() ?? 0.0,
      balanceAmount: (json['balance_amount'] as num?)?.toDouble() ?? 0.0,
      dueDate: json['due_date'] ?? '',
      issueDate: json['issue_date'] ?? json['created_at']?.toString().split('T').first ?? '2025-09-01',
      status: json['status'] ?? 'UNPAID',
      studentId: json['student_id'] ?? '',
      admissionNumber: json['admission_number'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      categoryName: json['category_name'] ?? 'Tuition Fee',
    );
  }
}

