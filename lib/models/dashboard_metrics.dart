class DashboardMetrics {
  final int totalStudents;
  final int totalTeachers;
  final int totalClasses;
  final double revenueCollected;
  final double pendingFees;
  final AttendanceSummary attendanceToday;

  DashboardMetrics({
    required this.totalStudents,
    required this.totalTeachers,
    required this.totalClasses,
    required this.revenueCollected,
    required this.pendingFees,
    required this.attendanceToday,
  });

  factory DashboardMetrics.fromJson(Map<String, dynamic> json) {
    return DashboardMetrics(
      totalStudents: json['totalStudents'] ?? 0,
      totalTeachers: json['totalTeachers'] ?? 0,
      totalClasses: json['totalClasses'] ?? 0,
      revenueCollected: (json['revenueCollected'] as num?)?.toDouble() ?? 0.0,
      pendingFees: (json['pendingFees'] as num?)?.toDouble() ?? 0.0,
      attendanceToday: AttendanceSummary.fromJson(json['attendanceToday'] ?? {}),
    );
  }
}

class AttendanceSummary {
  final int present;
  final int absent;
  final int late;
  final int totalMarked;
  final double percentage;

  AttendanceSummary({
    required this.present,
    required this.absent,
    required this.late,
    required this.totalMarked,
    required this.percentage,
  });

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) {
    return AttendanceSummary(
      present: json['present'] ?? 0,
      absent: json['absent'] ?? 0,
      late: json['late'] ?? 0,
      totalMarked: json['totalMarked'] ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
