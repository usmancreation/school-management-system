import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/auth/role_permissions.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../common/document_preview_dialog.dart';


class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchMetrics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final dash = context.watch<DashboardProvider>();
    final metrics = dash.metrics;
    final role = auth.currentUser?.role;

    if (dash.isLoading && metrics == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Role Specific Portal Router
    switch (role) {
      case RolePermissions.student:
        return _buildStudentDashboard(context, auth);
      case RolePermissions.parent:
        return _buildParentDashboard(context, auth);
      case RolePermissions.teacher:
        return _buildTeacherDashboard(context, auth);
      case RolePermissions.accountant:
        return _buildAccountantDashboard(context, metrics, auth);
      case RolePermissions.librarian:
        return _buildLibrarianDashboard(context, auth);
      case RolePermissions.transportManager:
        return _buildTransportDashboard(context, auth);
      case RolePermissions.receptionist:
        return _buildReceptionistDashboard(context, metrics, auth);
      default:
        return _buildAdminDashboard(context, metrics, auth);
    }
  }

  // ===========================================================================
  // 1. STUDENT DASHBOARD
  // ===========================================================================
  Widget _buildStudentDashboard(BuildContext context, AuthProvider auth) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Profile Hero Banner
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E3A8A).withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white,
                    child: Text(
                      'AW',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              auth.currentUser?.fullName ?? 'Alexander Wright',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Roll # 1001',
                                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Class: Grade 10 - Section A  •  Adm: ADM-2024-001  •  Session: ${auth.academicYear}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Student Stat Cards
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    title: 'My Attendance Rate',
                    value: '96.5%',
                    icon: Icons.fact_check_outlined,
                    color: const Color(0xFF10B981),
                    subtitle: '44 Present / 1 Absent',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _statCard(
                    title: 'Term GPA Standing',
                    value: '3.88 / 4.0',
                    icon: Icons.military_tech_outlined,
                    color: const Color(0xFF3B82F6),
                    subtitle: 'Rank #2 in Class 10-A',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _statCard(
                    title: 'Fee Voucher Status',
                    value: 'Cleared',
                    icon: Icons.check_circle_outline,
                    color: const Color(0xFF059669),
                    subtitle: 'Current term balance \$0.00',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _statCard(
                    title: 'Books Borrowed',
                    value: '2 Books',
                    icon: Icons.menu_book_outlined,
                    color: const Color(0xFF8B5CF6),
                    subtitle: 'Physics Vol 1, Clean Code',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Schedule & Quick Access
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Class Timetable
                Expanded(
                  flex: 5,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.schedule, size: 20, color: AppTheme.primary),
                              SizedBox(width: 8),
                              Text("Today's Class Schedule (Grade 10-A)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _periodTile('08:30 - 09:20 AM', 'Advanced Mathematics', 'Dr. Robert Langdon', 'Hall 2B', Colors.blue),
                          _periodTile('09:25 - 10:15 AM', 'Applied Physics Lab', 'Sarah Connor', 'Science Lab 4', Colors.purple),
                          _periodTile('10:30 - 11:20 AM', 'Organic Chemistry', 'Dr. Arthur Pendelton', 'Room 204', Colors.amber),
                          _periodTile('11:25 - 12:15 PM', 'English Literature', 'Margaret Vance', 'Room 102', Colors.teal),
                          _periodTile('01:00 - 02:00 PM', 'Computer Science & AI', 'Marcus Sterling', 'Computer Lab 1', Colors.indigo),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),

                // Quick Navigation & Notices
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.touch_app_outlined, size: 20, color: AppTheme.secondary),
                                  SizedBox(width: 8),
                                  Text('Student Portal Shortcuts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _actionButton(
                                title: 'My Attendance Calendar',
                                icon: Icons.fact_check_outlined,
                                color: const Color(0xFF10B981),
                                onTap: () => context.go('/attendance'),
                              ),
                              const SizedBox(height: 10),
                              _actionButton(
                                title: 'My Report Card & Grades',
                                icon: Icons.assignment_turned_in_outlined,
                                color: const Color(0xFF3B82F6),
                                onTap: () => context.go('/exams'),
                              ),
                              const SizedBox(height: 10),
                              _actionButton(
                                title: 'My Fee Challans & Invoices',
                                icon: Icons.receipt_long_outlined,
                                color: const Color(0xFFF59E0B),
                                onTap: () => context.go('/fees'),
                              ),
                              const SizedBox(height: 10),
                              _actionButton(
                                title: 'Library Catalog Search',
                                icon: Icons.menu_book_outlined,
                                color: const Color(0xFF8B5CF6),
                                onTap: () => context.go('/library'),
                              ),
                              const SizedBox(height: 10),
                              _actionButton(
                                title: 'My Bus Route & Driver Details',
                                icon: Icons.directions_bus_outlined,
                                color: const Color(0xFF06B6D4),
                                onTap: () => context.go('/transport'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 2. PARENT DASHBOARD
  // ===========================================================================
  Widget _buildParentDashboard(BuildContext context, AuthProvider auth) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Parent Banner
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF047857), Color(0xFF10B981)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.family_restroom, size: 36, color: Color(0xFF047857)),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${auth.currentUser?.fullName ?? "Parent / Guardian"}',
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Student Ward: Alexander Wright (Grade 10-A, Roll #1001)',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/fees'),
                    icon: const Icon(Icons.credit_card, size: 16),
                    label: const Text('Fee Receipts'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF047857)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Metrics
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    title: "Child's Attendance",
                    value: "96.5%",
                    icon: Icons.fact_check_outlined,
                    color: const Color(0xFF10B981),
                    subtitle: "44 Days Present in Session",
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _statCard(
                    title: "Academic Grade",
                    value: "A+ (3.88 GPA)",
                    icon: Icons.school_outlined,
                    color: const Color(0xFF3B82F6),
                    subtitle: "Term 1 Examinations",
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _statCard(
                    title: "Fee Status",
                    value: "Paid in Full",
                    icon: Icons.receipt_long,
                    color: const Color(0xFF059669),
                    subtitle: "Sep Tuition Cleared",
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _statCard(
                    title: "School Transport",
                    value: "Route #03",
                    icon: Icons.directions_bus,
                    color: const Color(0xFF06B6D4),
                    subtitle: "Bus 04 (On Schedule)",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Links
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Parent Portal Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _actionButton(
                            title: 'View Child Attendance Log',
                            icon: Icons.calendar_month,
                            color: const Color(0xFF10B981),
                            onTap: () => context.go('/attendance'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _actionButton(
                            title: 'Preview Report Card PDF',
                            icon: Icons.assignment_turned_in_outlined,
                            color: const Color(0xFF3B82F6),
                            onTap: () => DocumentPreviewDialog.showReportCard(
                              context,
                              studentName: 'Alexander Wright',
                              admissionNo: 'ADM-2024-001',
                              rollNo: '1001',
                              className: 'Grade 10 - Section A',
                              session: auth.academicYear,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _actionButton(
                            title: 'Fee Vouchers & Payment',
                            icon: Icons.payment,
                            color: const Color(0xFFF59E0B),
                            onTap: () => context.go('/fees'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _actionButton(
                            title: 'Track Bus Route',
                            icon: Icons.map,
                            color: const Color(0xFF06B6D4),
                            onTap: () => context.go('/transport'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 3. TEACHER DASHBOARD
  // ===========================================================================
  Widget _buildTeacherDashboard(BuildContext context, AuthProvider auth) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6D28D9), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.co_present, size: 36, color: Color(0xFF6D28D9)),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${auth.currentUser?.fullName ?? "Faculty Member"}',
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Department of Science & Physics  •  Assigned Sections: Grade 10-A, 9-B',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/attendance'),
                    icon: const Icon(Icons.fact_check, size: 16),
                    label: const Text('Mark Class Attendance'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF6D28D9)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: _statCard(
                    title: 'My Assigned Students',
                    value: '84',
                    icon: Icons.groups,
                    color: const Color(0xFF8B5CF6),
                    subtitle: 'Across 3 class sections',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _statCard(
                    title: "Today's Attendance",
                    value: 'Pending',
                    icon: Icons.fact_check_outlined,
                    color: const Color(0xFFF59E0B),
                    subtitle: 'Grade 10-A Roll Call',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _statCard(
                    title: 'Pending Marks Entry',
                    value: '14 Papers',
                    icon: Icons.edit_note,
                    color: const Color(0xFF3B82F6),
                    subtitle: 'Mid-term Physics Grade 10',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _statCard(
                    title: 'Active Library Books',
                    value: '4 Books',
                    icon: Icons.menu_book,
                    color: const Color(0xFF10B981),
                    subtitle: 'Curriculum & Reference',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: _actionButton(
                    title: 'Take Daily Class Attendance',
                    icon: Icons.checklist_outlined,
                    color: const Color(0xFF8B5CF6),
                    onTap: () => context.go('/attendance'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _actionButton(
                    title: 'Enter Subject Exam Marks',
                    icon: Icons.assignment_turned_in_outlined,
                    color: const Color(0xFF3B82F6),
                    onTap: () => context.go('/exams'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _actionButton(
                    title: 'View Student Directory',
                    icon: Icons.school_outlined,
                    color: const Color(0xFF10B981),
                    onTap: () => context.go('/students'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 4. ACCOUNTANT DASHBOARD
  // ===========================================================================
  Widget _buildAccountantDashboard(BuildContext context, dynamic metrics, AuthProvider auth) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Finance & Bursary Terminal', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Fee cashiering, challans, payroll disbursements, and ledger', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => context.go('/fees'),
                  icon: const Icon(Icons.point_of_sale, size: 16),
                  label: const Text('Open Cashier Desk'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), foregroundColor: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: _statCard(
                    title: 'Fee Revenue Collected',
                    value: Formatters.formatCurrency(metrics?.revenueCollected ?? 348500),
                    icon: Icons.account_balance,
                    color: const Color(0xFF10B981),
                    subtitle: 'Current Term Receipts',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _statCard(
                    title: 'Outstanding Balances',
                    value: Formatters.formatCurrency(metrics?.pendingFees ?? 42100),
                    icon: Icons.pending_actions,
                    color: const Color(0xFFEF4444),
                    subtitle: 'Pending Fee Challans',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _statCard(
                    title: 'Staff Payroll Register',
                    value: '\$48,500',
                    icon: Icons.badge,
                    color: const Color(0xFF3B82F6),
                    subtitle: 'Monthly faculty salary',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _statCard(
                    title: 'Fee Defaulters',
                    value: '18 Students',
                    icon: Icons.warning_amber,
                    color: const Color(0xFFF59E0B),
                    subtitle: '> 30 days overdue',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: _actionButton(
                    title: 'Fee Cashiering & Receipts',
                    icon: Icons.receipt_long,
                    color: const Color(0xFF10B981),
                    onTap: () => context.go('/fees'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _actionButton(
                    title: 'Student Fee Invoices',
                    icon: Icons.school,
                    color: const Color(0xFF3B82F6),
                    onTap: () => context.go('/students'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _actionButton(
                    title: 'Faculty Payroll Roster',
                    icon: Icons.people,
                    color: const Color(0xFF8B5CF6),
                    onTap: () => context.go('/teachers'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 5. LIBRARIAN DASHBOARD
  // ===========================================================================
  Widget _buildLibrarianDashboard(BuildContext context, AuthProvider auth) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Library Circulation Desk', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Book catalog, issue/return circulation, and overdue fines', style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: _statCard(
                    title: 'Total Catalog Titles',
                    value: '12,450',
                    icon: Icons.auto_stories,
                    color: const Color(0xFFEC4899),
                    subtitle: 'Registered volumes',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _statCard(
                    title: 'Books Issued Today',
                    value: '42 Books',
                    icon: Icons.assignment_return,
                    color: const Color(0xFF3B82F6),
                    subtitle: 'Circulation counter',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _statCard(
                    title: 'Overdue Books',
                    value: '18 Books',
                    icon: Icons.timer_off,
                    color: const Color(0xFFEF4444),
                    subtitle: 'Pending returns',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _statCard(
                    title: 'Overdue Fines Collected',
                    value: '\$285.00',
                    icon: Icons.attach_money,
                    color: const Color(0xFF10B981),
                    subtitle: 'Current Month',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: _actionButton(
                    title: 'Circulation: Issue / Return Book',
                    icon: Icons.menu_book,
                    color: const Color(0xFFEC4899),
                    onTap: () => context.go('/library'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _actionButton(
                    title: 'Browse Library Catalog',
                    icon: Icons.search,
                    color: const Color(0xFF3B82F6),
                    onTap: () => context.go('/library'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _actionButton(
                    title: 'Registered Student Members',
                    icon: Icons.badge,
                    color: const Color(0xFF10B981),
                    onTap: () => context.go('/students'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 6. TRANSPORT MANAGER DASHBOARD
  // ===========================================================================
  Widget _buildTransportDashboard(BuildContext context, AuthProvider auth) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Transport Fleet & Route Command', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('School buses, active routes, drivers, and student commuters', style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: _statCard(
                    title: 'Active Bus Routes',
                    value: '8 Routes',
                    icon: Icons.route,
                    color: const Color(0xFF06B6D4),
                    subtitle: 'Morning & afternoon runs',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _statCard(
                    title: 'Fleet Vehicles',
                    value: '12 Buses',
                    icon: Icons.directions_bus,
                    color: const Color(0xFF3B82F6),
                    subtitle: '10 Active / 2 Maintenance',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _statCard(
                    title: 'Registered Commuters',
                    value: '420 Students',
                    icon: Icons.people_outline,
                    color: const Color(0xFF10B981),
                    subtitle: 'Transport Pass Holders',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _statCard(
                    title: 'Certified Drivers',
                    value: '12 Drivers',
                    icon: Icons.airline_seat_recline_normal,
                    color: const Color(0xFFF59E0B),
                    subtitle: 'On active duty',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: _actionButton(
                    title: 'Manage Bus Routes & Stops',
                    icon: Icons.directions_bus,
                    color: const Color(0xFF06B6D4),
                    onTap: () => context.go('/transport'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _actionButton(
                    title: 'Bus Passenger Roster',
                    icon: Icons.school,
                    color: const Color(0xFF3B82F6),
                    onTap: () => context.go('/students'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 7. RECEPTIONIST DASHBOARD
  // ===========================================================================
  Widget _buildReceptionistDashboard(BuildContext context, dynamic metrics, AuthProvider auth) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Front Desk & Admissions Terminal', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Student admissions inquiries, visitor gate log, and fee receipt desk', style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: _statCard(
                    title: 'Total Enrolled Students',
                    value: '${metrics?.totalStudents ?? 450}',
                    icon: Icons.school,
                    color: const Color(0xFF14B8A6),
                    subtitle: 'Current Active Roster',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _statCard(
                    title: 'Admission Inquiries',
                    value: '14 Inquiries',
                    icon: Icons.contact_page,
                    color: const Color(0xFF3B82F6),
                    subtitle: 'Pending Follow-up',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _statCard(
                    title: 'Today Visitors Logged',
                    value: '22 Visitors',
                    icon: Icons.badge,
                    color: const Color(0xFF8B5CF6),
                    subtitle: 'Gate passes issued',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _statCard(
                    title: 'Fee Cash Desk',
                    value: 'Open',
                    icon: Icons.payments,
                    color: const Color(0xFF10B981),
                    subtitle: 'Counter Ready',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: _actionButton(
                    title: 'Student Admissions Directory',
                    icon: Icons.person_add_alt_1,
                    color: const Color(0xFF14B8A6),
                    onTap: () => context.go('/students'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _actionButton(
                    title: 'Fee Challan Counter',
                    icon: Icons.receipt_long,
                    color: const Color(0xFFF59E0B),
                    onTap: () => context.go('/fees'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _actionButton(
                    title: 'Daily Gate Attendance',
                    icon: Icons.fact_check,
                    color: const Color(0xFF3B82F6),
                    onTap: () => context.go('/attendance'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 8. MASTER ADMIN / PRINCIPAL DASHBOARD
  // ===========================================================================
  Widget _buildAdminDashboard(BuildContext context, dynamic metrics, AuthProvider auth) {
    return Scaffold(
      body: SingleChildScrollView(
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
                      RolePermissions.getRoleDisplayName(auth.currentUser?.role),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Live institutional metrics synced with PostgreSQL database',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () => context.read<DashboardProvider>().fetchMetrics(),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Refresh Data'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: _statCard(
                    title: 'Total Enrolled Students',
                    value: '${metrics?.totalStudents ?? 0}',
                    icon: Icons.school_outlined,
                    color: const Color(0xFF3B82F6),
                    subtitle: 'Active in ${auth.academicYear}',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _statCard(
                    title: 'Faculty & Staff',
                    value: '${metrics?.totalTeachers ?? 0}',
                    icon: Icons.people_outline,
                    color: const Color(0xFF10B981),
                    subtitle: 'Active faculty members',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _statCard(
                    title: 'Revenue Collected',
                    value: Formatters.formatCurrency(metrics?.revenueCollected ?? 0),
                    icon: Icons.account_balance_outlined,
                    color: const Color(0xFF8B5CF6),
                    subtitle: 'Current academic term',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _statCard(
                    title: 'Pending Fee Balances',
                    value: Formatters.formatCurrency(metrics?.pendingFees ?? 0),
                    icon: Icons.pending_actions_outlined,
                    color: const Color(0xFFF59E0B),
                    subtitle: 'Outstanding invoices',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.fact_check_outlined, size: 20, color: AppTheme.secondary),
                              SizedBox(width: 8),
                              Text("Today's Attendance Summary", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.primary.withValues(alpha: 0.1),
                                  border: Border.all(color: AppTheme.primary, width: 3),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${metrics?.attendanceToday.percentage ?? 0}%',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppTheme.primary),
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: Column(
                                  children: [
                                    _attendanceRow('Present Students', '${metrics?.attendanceToday.present ?? 0}', Colors.green),
                                    const SizedBox(height: 8),
                                    _attendanceRow('Absent Students', '${metrics?.attendanceToday.absent ?? 0}', Colors.red),
                                    const SizedBox(height: 8),
                                    _attendanceRow('Late Arrivals', '${metrics?.attendanceToday.late ?? 0}', Colors.orange),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          LinearProgressIndicator(
                            value: ((metrics?.attendanceToday.percentage ?? 0) / 100).clamp(0.0, 1.0),
                            backgroundColor: Colors.grey.withValues(alpha: 0.2),
                            valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),

                Expanded(
                  flex: 4,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.bolt, size: 20, color: AppTheme.accent),
                              SizedBox(width: 8),
                              Text('Administrative Shortcuts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _actionButton(
                            title: 'Admit New Student',
                            icon: Icons.person_add_alt_1_outlined,
                            color: AppTheme.primary,
                            onTap: () => context.go('/students'),
                          ),
                          const SizedBox(height: 10),
                          _actionButton(
                            title: 'Collect Fee & Print Receipt',
                            icon: Icons.receipt_long_outlined,
                            color: AppTheme.secondary,
                            onTap: () => context.go('/fees'),
                          ),
                          const SizedBox(height: 10),
                          _actionButton(
                            title: 'Take Daily Class Attendance',
                            icon: Icons.checklist_outlined,
                            color: AppTheme.accent,
                            onTap: () => context.go('/attendance'),
                          ),
                          const SizedBox(height: 10),
                          _actionButton(
                            title: 'Input Examination Marks',
                            icon: Icons.edit_note_outlined,
                            color: const Color(0xFF8B5CF6),
                            onTap: () => context.go('/exams'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Common Helpers
  Widget _periodTile(String time, String subject, String teacher, String room, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
              child: Text(time, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(subject, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('$teacher  •  $room', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 16),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _attendanceRow(String label, String count, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        const Spacer(),
        Text(count, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _actionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13))),
            Icon(Icons.chevron_right, size: 16, color: color),
          ],
        ),
      ),
    );
  }
}
