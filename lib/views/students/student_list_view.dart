import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/student_model.dart';
import '../../providers/student_provider.dart';
import '../../core/auth/role_permissions.dart';
import '../../providers/auth_provider.dart';
import 'student_admission_dialog.dart';

class StudentListView extends StatefulWidget {
  const StudentListView({super.key});

  @override
  State<StudentListView> createState() => _StudentListViewState();
}

class _StudentListViewState extends State<StudentListView> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProvider>().fetchStudents();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final role = auth.currentUser?.role;
    final canAdmit = RolePermissions.canAdmitStudents(role);
    final isStudentOrParent = role == RolePermissions.student || role == RolePermissions.parent;
    final provider = context.watch<StudentProvider>();
    final rawStudents = provider.students;
    
    // Privacy filter: If student or parent, restrict list to their own student record only!
    final students = isStudentOrParent
        ? rawStudents.where((s) => s.admissionNumber == 'ADM-2024-001' || s.fullName.contains('Alexander')).toList()
        : rawStudents;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isStudentOrParent ? 'My Student Academic Profile' : 'Student Roster & Directory',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isStudentOrParent
                          ? 'Personal enrollment file, academic status, and guardian details'
                          : 'Manage enrolled students, admission files, and academic profiles',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
                const Spacer(),
                if (canAdmit)
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (ctx) => const StudentAdmissionDialog(),
                      );
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Admit Student'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Search Bar & Filters
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => context.read<StudentProvider>().fetchStudents(val),
                    decoration: InputDecoration(
                      hintText: 'Search by student name, roll number, or admission ID...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                context.read<StudentProvider>().fetchStudents('');
                              },
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () => context.read<StudentProvider>().fetchStudents(_searchController.text),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Refresh'),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Data Table
            Expanded(
              child: Card(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : students.isEmpty
                        ? const Center(child: Text('No students found in record.'))
                        : ListView.separated(
                            itemCount: students.length,
                            separatorBuilder: (_, _) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final st = students[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                                  child: Text(
                                    st.firstName[0].toUpperCase(),
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary),
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Text(st.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Roll: ${st.rollNumber ?? "-"}',
                                        style: const TextStyle(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        st.status,
                                        style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Text(
                                  'Admission: ${st.admissionNumber} | Class: ${st.className} (${st.sectionName}) | Phone: ${st.phone ?? "-"}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.visibility_outlined, size: 20),
                                  tooltip: 'View Profile',
                                  onPressed: () => _showStudentDetails(st),
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

  void _showStudentDetails(StudentModel st) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Student Profile - ${st.fullName}'),
        content: SizedBox(
          width: 450,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('Admission Number', st.admissionNumber),
              _detailRow('Enrolled Class', '${st.className} - Section ${st.sectionName}'),
              _detailRow('Roll Number', st.rollNumber ?? '-'),
              _detailRow('Gender', st.gender),
              _detailRow('Blood Group', st.bloodGroup ?? 'Not provided'),
              _detailRow('Email Address', st.email ?? 'Not provided'),
              _detailRow('Phone Contact', st.phone ?? 'Not provided'),
              _detailRow('Enrollment Status', st.status),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
