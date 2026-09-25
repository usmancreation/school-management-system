import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../views/auth/login_view.dart';
import '../../views/shell/app_shell.dart';
import '../../views/dashboard/dashboard_view.dart';
import '../../views/students/student_list_view.dart';
import '../../views/teachers/teacher_list_view.dart';
import '../../views/attendance/attendance_view.dart';
import '../../views/fees/fee_management_view.dart';
import '../../views/exams/exam_marks_view.dart';
import '../../views/library/library_view.dart';
import '../../views/transport/transport_view.dart';
import '../../views/settings/settings_view.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/dashboard',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginView(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardView(),
          ),
          GoRoute(
            path: '/students',
            builder: (context, state) => const StudentListView(),
          ),
          GoRoute(
            path: '/teachers',
            builder: (context, state) => const TeacherListView(),
          ),
          GoRoute(
            path: '/attendance',
            builder: (context, state) => const AttendanceView(),
          ),
          GoRoute(
            path: '/fees',
            builder: (context, state) => const FeeManagementView(),
          ),
          GoRoute(
            path: '/exams',
            builder: (context, state) => const ExamMarksView(),
          ),
          GoRoute(
            path: '/library',
            builder: (context, state) => const LibraryView(),
          ),
          GoRoute(
            path: '/transport',
            builder: (context, state) => const TransportView(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsView(),
          ),
        ],
      ),
    ],
  );
}
