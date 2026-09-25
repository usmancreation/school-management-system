import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../providers/teacher_provider.dart';

class TeacherListView extends StatefulWidget {
  const TeacherListView({super.key});

  @override
  State<TeacherListView> createState() => _TeacherListViewState();
}

class _TeacherListViewState extends State<TeacherListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeacherProvider>().fetchTeachers();
    });
  }

  void _showAddTeacherDialog() {
    final fn = TextEditingController();
    final ln = TextEditingController();
    final des = TextEditingController(text: 'Senior Subject Teacher');
    final em = TextEditingController();
    final ph = TextEditingController();
    final sal = TextEditingController(text: '4800');
    String gen = 'FEMALE';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: const Text('Add Faculty Member'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(child: TextField(controller: fn, decoration: const InputDecoration(labelText: 'First Name *'))),
                      const SizedBox(width: 12),
                      Expanded(child: TextField(controller: ln, decoration: const InputDecoration(labelText: 'Last Name *'))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: des, decoration: const InputDecoration(labelText: 'Designation'))),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: gen,
                          decoration: const InputDecoration(labelText: 'Gender'),
                          items: const [
                            DropdownMenuItem(value: 'FEMALE', child: Text('Female')),
                            DropdownMenuItem(value: 'MALE', child: Text('Male')),
                          ],
                          onChanged: (v) => setSt(() => gen = v ?? 'FEMALE'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: em, decoration: const InputDecoration(labelText: 'Email Address'))),
                      const SizedBox(width: 12),
                      Expanded(child: TextField(controller: ph, decoration: const InputDecoration(labelText: 'Phone Number'))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: sal, decoration: const InputDecoration(labelText: 'Basic Monthly Salary (\$)')),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (fn.text.isEmpty || ln.text.isEmpty) return;
                Navigator.pop(ctx);
                final success = await context.read<TeacherProvider>().addTeacher(
                  firstName: fn.text.trim(),
                  lastName: ln.text.trim(),
                  designation: des.text.trim(),
                  gender: gen,
                  email: em.text.trim(),
                  phone: ph.text.trim(),
                  basicSalary: double.tryParse(sal.text) ?? 4500.0,
                );
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Faculty record added successfully!'), backgroundColor: Colors.green),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
              child: const Text('Save Faculty'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TeacherProvider>();
    final teachers = provider.teachers;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Faculty & Staff Directory', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Manage academic staff, designations, and payroll structures', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _showAddTeacherDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Faculty Member'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Card(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : teachers.isEmpty
                        ? const Center(child: Text('No staff members registered.'))
                        : ListView.separated(
                            itemCount: teachers.length,
                            separatorBuilder: (_, _) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final t = teachers[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppTheme.secondary.withValues(alpha: 0.15),
                                  child: Text(
                                    t.firstName[0].toUpperCase(),
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.secondary),
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Text(t.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.purple.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(t.employeeCode, style: const TextStyle(fontSize: 11, color: Colors.purple, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                                subtitle: Text(
                                  '${t.designation} | Email: ${t.email ?? "-"} | Phone: ${t.phone ?? "-"}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                trailing: Text(
                                  'Salary: ${Formatters.formatCurrency(t.basicSalary)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green),
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
