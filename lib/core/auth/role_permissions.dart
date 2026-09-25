import 'package:flutter/material.dart';

class NavMenuItem {
  final String title;
  final IconData icon;
  final String route;

  const NavMenuItem({
    required this.title,
    required this.icon,
    required this.route,
  });
}

class RolePermissions {
  static const String superAdmin = 'ROLE_SUPER_ADMIN';
  static const String admin = 'ROLE_ADMIN';
  static const String principal = 'ROLE_PRINCIPAL';
  static const String vicePrincipal = 'ROLE_VICE_PRINCIPAL';
  static const String teacher = 'ROLE_TEACHER';
  static const String accountant = 'ROLE_ACCOUNTANT';
  static const String receptionist = 'ROLE_RECEPTIONIST';
  static const String student = 'ROLE_STUDENT';
  static const String parent = 'ROLE_PARENT';
  static const String librarian = 'ROLE_LIBRARY_STAFF';
  static const String transportManager = 'ROLE_TRANSPORT_MANAGER';

  static String getRoleDisplayName(String? role) {
    switch (role) {
      case superAdmin:
        return 'Chief Super Administrator';
      case admin:
        return 'Campus Administrator';
      case principal:
        return 'School Principal';
      case vicePrincipal:
        return 'Vice Principal';
      case teacher:
        return 'Faculty Teacher';
      case accountant:
        return 'Chief Accountant / Bursar';
      case receptionist:
        return 'Front Desk Receptionist';
      case student:
        return 'Enrolled Student';
      case parent:
        return 'Parent / Guardian';
      case librarian:
        return 'Head Librarian';
      case transportManager:
        return 'Transport Fleet Manager';
      default:
        return 'Administrator';
    }
  }

  static String getPortalTitle(String? role) {
    switch (role) {
      case student:
        return 'Student Academic Portal';
      case parent:
        return 'Parent & Guardian Portal';
      case teacher:
        return 'Faculty Academic Terminal';
      case accountant:
        return 'Finance & Bursary Terminal';
      case librarian:
        return 'Library Circulation Terminal';
      case transportManager:
        return 'Transport Fleet Terminal';
      case receptionist:
        return 'Front Desk & Admissions';
      case principal:
      case vicePrincipal:
        return 'Academic Executive Suite';
      case superAdmin:
      case admin:
      default:
        return 'Enterprise ERP Suite';
    }
  }

  static Color getRoleBadgeColor(String? role) {
    switch (role) {
      case student:
        return const Color(0xFF3B82F6); // Blue
      case parent:
        return const Color(0xFF10B981); // Green
      case teacher:
        return const Color(0xFF8B5CF6); // Purple
      case accountant:
        return const Color(0xFFF59E0B); // Amber
      case librarian:
        return const Color(0xFFEC4899); // Pink
      case transportManager:
        return const Color(0xFF06B6D4); // Cyan
      case receptionist:
        return const Color(0xFF14B8A6); // Teal
      case principal:
      case vicePrincipal:
        return const Color(0xFF6366F1); // Indigo
      case superAdmin:
      case admin:
      default:
        return const Color(0xFF1E3A8A); // Navy
    }
  }

  static List<NavMenuItem> getNavItems(String? role) {
    switch (role) {
      case student:
        return const [
          NavMenuItem(title: 'My Student Portal', icon: Icons.dashboard_outlined, route: '/dashboard'),
          NavMenuItem(title: 'My Attendance', icon: Icons.fact_check_outlined, route: '/attendance'),
          NavMenuItem(title: 'My Report Card & Marks', icon: Icons.assignment_turned_in_outlined, route: '/exams'),
          NavMenuItem(title: 'My Fee Challans', icon: Icons.account_balance_wallet_outlined, route: '/fees'),
          NavMenuItem(title: 'Library Catalog', icon: Icons.menu_book_outlined, route: '/library'),
          NavMenuItem(title: 'My Bus & Transport', icon: Icons.directions_bus_outlined, route: '/transport'),
        ];

      case parent:
        return const [
          NavMenuItem(title: 'Parent Portal', icon: Icons.dashboard_outlined, route: '/dashboard'),
          NavMenuItem(title: 'Child Attendance', icon: Icons.fact_check_outlined, route: '/attendance'),
          NavMenuItem(title: 'Academic Results', icon: Icons.assignment_turned_in_outlined, route: '/exams'),
          NavMenuItem(title: 'Fee Vouchers & Receipts', icon: Icons.account_balance_wallet_outlined, route: '/fees'),
          NavMenuItem(title: 'Bus Route Tracking', icon: Icons.directions_bus_outlined, route: '/transport'),
        ];

      case teacher:
        return const [
          NavMenuItem(title: 'Faculty Portal', icon: Icons.dashboard_outlined, route: '/dashboard'),
          NavMenuItem(title: 'Student Directory', icon: Icons.school_outlined, route: '/students'),
          NavMenuItem(title: 'Mark Daily Attendance', icon: Icons.fact_check_outlined, route: '/attendance'),
          NavMenuItem(title: 'Enter Exam Marks', icon: Icons.assignment_turned_in_outlined, route: '/exams'),
          NavMenuItem(title: 'Library Resources', icon: Icons.menu_book_outlined, route: '/library'),
        ];

      case accountant:
        return const [
          NavMenuItem(title: 'Finance Dashboard', icon: Icons.dashboard_outlined, route: '/dashboard'),
          NavMenuItem(title: 'Fee Management & Cashier', icon: Icons.account_balance_wallet_outlined, route: '/fees'),
          NavMenuItem(title: 'Student Fee Invoices', icon: Icons.school_outlined, route: '/students'),
          NavMenuItem(title: 'Staff Payroll Register', icon: Icons.badge_outlined, route: '/teachers'),
        ];

      case librarian:
        return const [
          NavMenuItem(title: 'Library Dashboard', icon: Icons.dashboard_outlined, route: '/dashboard'),
          NavMenuItem(title: 'Books & Circulation', icon: Icons.menu_book_outlined, route: '/library'),
          NavMenuItem(title: 'Library Members', icon: Icons.school_outlined, route: '/students'),
        ];

      case transportManager:
        return const [
          NavMenuItem(title: 'Transport Dashboard', icon: Icons.dashboard_outlined, route: '/dashboard'),
          NavMenuItem(title: 'Fleet & Bus Routes', icon: Icons.directions_bus_outlined, route: '/transport'),
          NavMenuItem(title: 'Bus Passengers Roster', icon: Icons.school_outlined, route: '/students'),
        ];

      case receptionist:
        return const [
          NavMenuItem(title: 'Front Desk Dashboard', icon: Icons.dashboard_outlined, route: '/dashboard'),
          NavMenuItem(title: 'Admissions & Inquiries', icon: Icons.school_outlined, route: '/students'),
          NavMenuItem(title: 'Daily Gate Attendance', icon: Icons.fact_check_outlined, route: '/attendance'),
          NavMenuItem(title: 'Fee Payment Counter', icon: Icons.account_balance_wallet_outlined, route: '/fees'),
        ];

      case principal:
      case vicePrincipal:
        return const [
          NavMenuItem(title: 'Executive Dashboard', icon: Icons.dashboard_outlined, route: '/dashboard'),
          NavMenuItem(title: 'Student Body', icon: Icons.school_outlined, route: '/students'),
          NavMenuItem(title: 'Faculty & Staff', icon: Icons.badge_outlined, route: '/teachers'),
          NavMenuItem(title: 'Attendance Analytics', icon: Icons.fact_check_outlined, route: '/attendance'),
          NavMenuItem(title: 'Exams & Approvals', icon: Icons.assignment_turned_in_outlined, route: '/exams'),
          NavMenuItem(title: 'Bursary & Revenue', icon: Icons.account_balance_wallet_outlined, route: '/fees'),
          NavMenuItem(title: 'Library Oversight', icon: Icons.menu_book_outlined, route: '/library'),
          NavMenuItem(title: 'Transport Overview', icon: Icons.directions_bus_outlined, route: '/transport'),
        ];

      case superAdmin:
      case admin:
      default:
        return const [
          NavMenuItem(title: 'Dashboard', icon: Icons.dashboard_outlined, route: '/dashboard'),
          NavMenuItem(title: 'Students', icon: Icons.school_outlined, route: '/students'),
          NavMenuItem(title: 'Teachers & Staff', icon: Icons.badge_outlined, route: '/teachers'),
          NavMenuItem(title: 'Attendance', icon: Icons.fact_check_outlined, route: '/attendance'),
          NavMenuItem(title: 'Fee Management', icon: Icons.account_balance_wallet_outlined, route: '/fees'),
          NavMenuItem(title: 'Exams & Marks', icon: Icons.assignment_turned_in_outlined, route: '/exams'),
          NavMenuItem(title: 'Library', icon: Icons.menu_book_outlined, route: '/library'),
          NavMenuItem(title: 'Transport', icon: Icons.directions_bus_outlined, route: '/transport'),
          NavMenuItem(title: 'System Settings', icon: Icons.settings_outlined, route: '/settings'),
        ];
    }
  }

  // Permission checkers
  static bool canAdmitStudents(String? role) {
    return role == superAdmin || role == admin || role == receptionist || role == principal;
  }

  static bool canCollectFees(String? role) {
    return role == superAdmin || role == admin || role == accountant || role == receptionist;
  }

  static bool canEditAttendance(String? role) {
    return role == superAdmin || role == admin || role == teacher || role == principal || role == vicePrincipal;
  }

  static bool canEnterMarks(String? role) {
    return role == superAdmin || role == admin || role == teacher || role == principal || role == vicePrincipal;
  }

  static bool canManageLibrary(String? role) {
    return role == superAdmin || role == admin || role == librarian;
  }

  static bool canManageTransport(String? role) {
    return role == superAdmin || role == admin || role == transportManager;
  }

  static bool canAccessSystemSettings(String? role) {
    return role == superAdmin || role == admin;
  }
}
