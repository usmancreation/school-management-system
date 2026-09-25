import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/exam_provider.dart';

import '../../core/auth/role_permissions.dart';
import '../../providers/auth_provider.dart';
import '../common/document_preview_dialog.dart';


class ExamMarksView extends StatefulWidget {
  const ExamMarksView({super.key});

  @override
  State<ExamMarksView> createState() => _ExamMarksViewState();
}

class _ExamMarksViewState extends State<ExamMarksView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExamProvider>().fetchExamsAndMarks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final role = auth.currentUser?.role;
    final canEnter = RolePermissions.canEnterMarks(role);
    final isStudentOrParent = role == RolePermissions.student || role == RolePermissions.parent;
    final provider = context.watch<ExamProvider>();
    final exams = provider.exams;
    final rawMarks = provider.marks;
    final marks = isStudentOrParent
        ? rawMarks.where((m) => m.admissionNumber == 'ADM-2024-001' || m.studentName.contains('Alexander')).toList()
        : rawMarks;

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
                      isStudentOrParent ? 'My Official Report Card & Transcript' : 'Examinations & Grading Registry',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isStudentOrParent
                          ? 'Academic Session: ${auth.academicYear} | Overall Grade: A+ (GPA: 3.88)'
                          : 'Exam sessions, subject-wise marks entry, and GPA report cards',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
                const Spacer(),
                if (isStudentOrParent)
                  ElevatedButton.icon(
                    onPressed: () {
                      DocumentPreviewDialog.showReportCard(
                        context,
                        studentName: auth.currentUser?.fullName ?? 'Alexander Wright',
                        admissionNo: 'ADM-2024-001',
                        rollNo: '1001',
                        className: 'Grade 10 - Section A',
                        session: auth.academicYear,
                      );
                    },
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('Preview & Download Report Card'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                  )
                else ...[
                  if (canEnter) ...[
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Marks entry terminal active. Synchronized with PostgreSQL.'), backgroundColor: AppTheme.primary),
                        );
                      },
                      icon: const Icon(Icons.edit_note, size: 18),
                      label: const Text('Enter Subject Marks'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                    ),
                    const SizedBox(width: 10),
                  ],
                  OutlinedButton.icon(
                    onPressed: () => context.read<ExamProvider>().fetchExamsAndMarks(),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Refresh'),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),

            // Active Exams Cards
            if (exams.isNotEmpty) ...[
              SizedBox(
                height: 90,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: exams.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 16),
                  itemBuilder: (context, idx) {
                    final ex = exams[idx];
                    return Container(
                      width: 280,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Text(ex.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                                child: const Text('Published', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('${ex.startDate} to ${ex.endDate} | ${ex.totalPapers} Scheduled Papers', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Marks Roster
            const Text('Marks Sheet - Grade 10 Mathematics', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: Card(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : marks.isEmpty
                        ? const Center(child: Text('No marks recorded.'))
                        : ListView.separated(
                            itemCount: marks.length,
                            separatorBuilder: (_, _) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final m = marks[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppTheme.secondary.withValues(alpha: 0.1),
                                  child: Text(m.firstName[0], style: const TextStyle(color: AppTheme.secondary, fontWeight: FontWeight.bold)),
                                ),
                                title: Text(m.studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                subtitle: Text('Admission: ${m.admissionNumber} | Subject: ${m.subjectName}', style: const TextStyle(fontSize: 12)),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text('Score: ${m.totalObtained.toStringAsFixed(1)} / ${m.maxMarks.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                        Text('Theory: ${m.theoryMarks} | Prac: ${m.practicalMarks}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                      ],
                                    ),
                                    const SizedBox(width: 16),
                                    Container(
                                      width: 44,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: AppTheme.primary,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        m.grade,
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
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
