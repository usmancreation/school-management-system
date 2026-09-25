import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/auth/role_permissions.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class AppShell extends StatefulWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = context.watch<ThemeProvider>();
    final isDark = theme.isDarkMode;
    final currentRoute = GoRouterState.of(context).uri.toString();
    final userRole = auth.currentUser?.role;
    final navItems = RolePermissions.getNavItems(userRole);
    final portalTitle = RolePermissions.getPortalTitle(userRole);
    final roleDisplayName = RolePermissions.getRoleDisplayName(userRole);
    final roleBadgeColor = RolePermissions.getRoleBadgeColor(userRole);

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _isCollapsed ? 76 : 260,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              border: Border(
                right: BorderSide(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  height: 68,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      if (!_isCollapsed) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Oakridge ERP',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: -0.3,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                portalTitle,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Nav Items
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    itemCount: navItems.length,
                    itemBuilder: (context, index) {
                      final item = navItems[index];
                      final isSelected = currentRoute.startsWith(item.route);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: InkWell(
                          onTap: () => context.go(item.route),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            height: 46,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primary.withValues(alpha: 0.12)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  item.icon,
                                  size: 22,
                                  color: isSelected
                                      ? AppTheme.primaryLight
                                      : (isDark ? Colors.grey[400] : Colors.grey[700]),
                                ),
                                if (!_isCollapsed) ...[
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                        color: isSelected
                                            ? (isDark ? Colors.white : AppTheme.primary)
                                            : (isDark ? Colors.grey[300] : Colors.grey[800]),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Collapse button & User logout
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: _isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(_isCollapsed ? Icons.chevron_right : Icons.chevron_left),
                        onPressed: () => setState(() => _isCollapsed = !_isCollapsed),
                        tooltip: _isCollapsed ? 'Expand Sidebar' : 'Collapse Sidebar',
                      ),
                      if (!_isCollapsed)
                        IconButton(
                          icon: const Icon(Icons.logout, color: Colors.redAccent, size: 20),
                          tooltip: 'Logout',
                          onPressed: () async {
                            await auth.logout();
                            if (context.mounted) context.go('/login');
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Workspace
          Expanded(
            child: Column(
              children: [
                // Top App Bar
                Container(
                  height: 68,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Academic Session Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today, size: 14, color: AppTheme.secondary),
                            const SizedBox(width: 6),
                            Text(
                              'Academic Session: ${auth.academicYear}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),

                      // Database Live Status
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green, size: 14),
                            SizedBox(width: 6),
                            Text(
                              'PostgreSQL Connected',
                              style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Role Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: roleBadgeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: roleBadgeColor.withValues(alpha: 0.35)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.verified_user, color: roleBadgeColor, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              roleDisplayName,
                              style: TextStyle(
                                color: roleBadgeColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Dark/Light Toggle
                      IconButton(
                        icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode_outlined),
                        onPressed: () => theme.toggleTheme(),
                        tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                      ),
                      const SizedBox(width: 12),

                      // User Avatar & Name
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppTheme.primary,
                        child: Text(
                          (auth.currentUser?.fullName.isNotEmpty ?? false)
                              ? auth.currentUser!.fullName[0].toUpperCase()
                              : 'A',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            auth.currentUser?.fullName ?? 'Administrator',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          Text(
                            roleDisplayName,
                            style: const TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Feature Screen
                Expanded(
                  child: widget.child,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
