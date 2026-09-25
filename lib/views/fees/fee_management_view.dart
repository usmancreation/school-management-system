import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/invoice_model.dart';
import '../../providers/fee_provider.dart';

import '../../core/auth/role_permissions.dart';
import '../../providers/auth_provider.dart';
import '../common/document_preview_dialog.dart';


class FeeManagementView extends StatefulWidget {
  const FeeManagementView({super.key});

  @override
  State<FeeManagementView> createState() => _FeeManagementViewState();
}

class _FeeManagementViewState extends State<FeeManagementView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeeProvider>().fetchInvoices();
    });
  }

  void _showCollectFeeDialog(InvoiceModel inv) {
    final amountController = TextEditingController(text: inv.balanceAmount.toStringAsFixed(2));
    String mode = 'CASH';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: Text('Fee Collection - ${inv.invoiceNumber}'),
          content: SizedBox(
            width: 450,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Student: ${inv.studentName} (${inv.admissionNumber})', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Fee Title: ${inv.title}', style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Outstanding Balance:'),
                      Text(Formatters.formatCurrency(inv.balanceAmount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.redAccent)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount to Pay (\$)'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: mode,
                  decoration: const InputDecoration(labelText: 'Payment Method'),
                  items: const [
                    DropdownMenuItem(value: 'CASH', child: Text('Cash at Bursar Counter')),
                    DropdownMenuItem(value: 'CARD', child: Text('Credit / Debit Card (POS)')),
                    DropdownMenuItem(value: 'BANK_TRANSFER', child: Text('Bank Wire Transfer')),
                    DropdownMenuItem(value: 'ONLINE', child: Text('Online Portal')),
                  ],
                  onChanged: (v) => setSt(() => mode = v ?? 'CASH'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final amt = double.tryParse(amountController.text) ?? 0.0;
                if (amt <= 0) return;
                Navigator.pop(ctx);
                final success = await context.read<FeeProvider>().collectFee(
                  invoiceId: inv.id,
                  amount: amt,
                  paymentMode: mode,
                );
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Payment processed successfully! Receipt logged.'), backgroundColor: Colors.green),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
              child: const Text('Confirm Payment & Issue Receipt'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final role = auth.currentUser?.role;
    final canCollect = RolePermissions.canCollectFees(role);
    final isStudentOrParent = role == RolePermissions.student || role == RolePermissions.parent;
    final provider = context.watch<FeeProvider>();
    final rawInvoices = provider.invoices;
    final invoices = isStudentOrParent
        ? rawInvoices.where((i) => i.admissionNumber == 'ADM-2024-001' || i.studentName.contains('Alexander')).toList()
        : rawInvoices;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isStudentOrParent ? 'My Fee Vouchers & Payment Receipts' : 'Fee Ledger & Cashiering',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isStudentOrParent
                          ? 'Download monthly fee challans and review verified payment receipts'
                          : 'Bursary invoices, payment receipts, and balance tracking',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () => context.read<FeeProvider>().fetchInvoices(),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Refresh Invoices'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Card(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : invoices.isEmpty
                        ? const Center(child: Text('No fee records found.'))
                        : ListView.separated(
                            itemCount: invoices.length,
                            separatorBuilder: (_, _) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final inv = invoices[index];
                              final isPaid = inv.status == 'PAID';

                              return ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: (isPaid ? Colors.green : Colors.orange).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    isPaid ? Icons.check_circle_outline : Icons.pending_outlined,
                                    color: isPaid ? Colors.green : Colors.orange,
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Text(inv.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: (isPaid ? Colors.green : Colors.red).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(inv.status, style: TextStyle(fontSize: 10.5, color: isPaid ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                                subtitle: Text(
                                  'Student: ${inv.studentName} (${inv.admissionNumber}) | Due: ${inv.dueDate} | Fee: ${inv.categoryName}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text('Total: ${Formatters.formatCurrency(inv.amountDue)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                        Text(
                                          'Balance: ${Formatters.formatCurrency(inv.balanceAmount)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: isPaid ? Colors.green : Colors.redAccent,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 16),
                                     if (!isPaid)
                                       if (canCollect)
                                         ElevatedButton(
                                           onPressed: () => _showCollectFeeDialog(inv),
                                           style: ElevatedButton.styleFrom(
                                             backgroundColor: AppTheme.secondary,
                                             foregroundColor: Colors.white,
                                             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                           ),
                                           child: const Text('Collect Fee', style: TextStyle(fontSize: 12)),
                                         )
                                       else
                                         ElevatedButton.icon(
                                           onPressed: () => DocumentPreviewDialog.showFeeChallan(context, inv),
                                           icon: const Icon(Icons.visibility, size: 14),
                                           label: const Text('Preview & Download Challan', style: TextStyle(fontSize: 11)),
                                           style: ElevatedButton.styleFrom(
                                             backgroundColor: AppTheme.primary,
                                             foregroundColor: Colors.white,
                                             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                           ),
                                         )
                                     else
                                       Row(
                                         mainAxisSize: MainAxisSize.min,
                                         children: [
                                           const Chip(label: Text('Cleared', style: TextStyle(fontSize: 11, color: Colors.green))),
                                           const SizedBox(width: 8),
                                           ElevatedButton.icon(
                                             icon: const Icon(Icons.receipt_long, size: 14),
                                             label: const Text('View Receipt', style: TextStyle(fontSize: 11)),
                                             style: ElevatedButton.styleFrom(
                                               backgroundColor: Colors.green,
                                               foregroundColor: Colors.white,
                                               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                             ),
                                             onPressed: () => DocumentPreviewDialog.showFeeReceipt(context, inv),
                                           ),
                                         ],
                                       ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
