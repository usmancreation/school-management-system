import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/student_provider.dart';

class StudentAdmissionDialog extends StatefulWidget {
  const StudentAdmissionDialog({super.key});

  @override
  State<StudentAdmissionDialog> createState() => _StudentAdmissionDialogState();
}

class _StudentAdmissionDialogState extends State<StudentAdmissionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _fnController = TextEditingController();
  final _lnController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addrController = TextEditingController();

  String _gender = 'MALE';
  String _bloodGroup = 'O+';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _fnController.dispose();
    _lnController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addrController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final success = await context.read<StudentProvider>().admitStudent(
      firstName: _fnController.text.trim(),
      lastName: _lnController.text.trim(),
      gender: _gender,
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addrController.text.trim(),
      bloodGroup: _bloodGroup,
    );

    setState(() => _isSubmitting = false);
    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Student admitted successfully! Admission number and invoice generated.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.person_add_alt_1, color: AppTheme.primary),
          SizedBox(width: 8),
          Text('New Student Admission'),
        ],
      ),
      content: SizedBox(
        width: 540,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _fnController,
                        decoration: const InputDecoration(labelText: 'First Name *'),
                        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _lnController,
                        decoration: const InputDecoration(labelText: 'Last Name *'),
                        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _gender,
                        decoration: const InputDecoration(labelText: 'Gender'),
                        items: const [
                          DropdownMenuItem(value: 'MALE', child: Text('Male')),
                          DropdownMenuItem(value: 'FEMALE', child: Text('Female')),
                          DropdownMenuItem(value: 'OTHER', child: Text('Other')),
                        ],
                        onChanged: (v) => setState(() => _gender = v ?? 'MALE'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _bloodGroup,
                        decoration: const InputDecoration(labelText: 'Blood Group'),
                        items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']
                            .map((bg) => DropdownMenuItem(value: bg, child: Text(bg)))
                            .toList(),
                        onChanged: (v) => setState(() => _bloodGroup = v ?? 'O+'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email Address'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(labelText: 'Contact Phone Number'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addrController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Residential Street Address'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
          ),
          child: _isSubmitting
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Complete Admission'),
        ),
      ],
    );
  }
}
