import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../providers/transport_provider.dart';

import '../../core/auth/role_permissions.dart';
import '../../providers/auth_provider.dart';

class TransportView extends StatefulWidget {
  const TransportView({super.key});

  @override
  State<TransportView> createState() => _TransportViewState();
}

class _TransportViewState extends State<TransportView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransportProvider>().fetchRoutes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final role = auth.currentUser?.role;
    final isStudentOrParent = role == RolePermissions.student || role == RolePermissions.parent;
    final provider = context.watch<TransportProvider>();
    final routes = provider.routes;

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
                      isStudentOrParent ? 'My Bus Route & Commute Details' : 'Transportation & Fleet Routes',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isStudentOrParent
                          ? 'Assigned morning and afternoon route schedule and driver contacts'
                          : 'Bus logistics, transit waypoints, and monthly transportation tariffs',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () => context.read<TransportProvider>().fetchRoutes(),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Refresh'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (isStudentOrParent) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0E7490), Color(0xFF06B6D4)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.directions_bus, color: Color(0xFF0E7490), size: 28),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Assigned Commute: Route #03 - Downtown Express (Bus #04)',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Driver: Mike Wheeler (+1-555-0188)  •  Pickup: 07:15 AM (Oak St & 5th Ave)  •  Dropoff: 03:30 PM',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                      child: const Text('Pass Active', style: TextStyle(color: Color(0xFF0E7490), fontWeight: FontWeight.bold, fontSize: 11)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            Expanded(
              child: Card(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : routes.isEmpty
                        ? const Center(child: Text('No routes configured.'))
                        : ListView.separated(
                            itemCount: routes.length,
                            separatorBuilder: (_, _) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final r = routes[index];
                              return ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.secondary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.directions_bus, color: AppTheme.secondary),
                                ),
                                title: Text(r.routeName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                subtitle: Text('From: ${r.startPoint}  ➔  To: ${r.endPoint}', style: const TextStyle(fontSize: 12)),
                                trailing: Text(
                                  'Fare: ${Formatters.formatCurrency(r.monthlyFee)}/mo',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blue),
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
