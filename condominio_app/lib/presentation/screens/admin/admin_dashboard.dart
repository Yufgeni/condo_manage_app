import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/providers/auth_provider.dart';
import '../../widgets/admin/admin_drawer.dart';
import '../../widgets/common/panic_button.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: const [PanicButton()],
      ),
      drawer: const AdminDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenido, ${authProvider.currentUser?.name ?? ''}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, AppConstants.routeAdminSignature),
                icon: const Icon(Icons.gesture),
                label: const Text('REGISTRAR FIRMA DIGITAL'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: [
                  _DashboardCard(
                    title: 'Historial de Accesos',
                    icon: Icons.history_edu,
                    color: Colors.redAccent,
                    onTap: () => Navigator.pushNamed(
                        context, AppConstants.routeVisitorHistory),
                  ),
                  _DashboardCard(
                    title: 'Residentes',
                    icon: Icons.people,
                    color: Colors.blue,
                    onTap: () => Navigator.pushNamed(
                        context, AppConstants.routeResidents),
                  ),
                  _DashboardCard(
                    title: 'Vigilantes',
                    icon: Icons.security,
                    color: Colors.green,
                    onTap: () => Navigator.pushNamed(
                        context, AppConstants.routeGuards),
                  ),
                  _DashboardCard(
                    title: 'Finanzas',
                    icon: Icons.payments,
                    color: Colors.orange,
                    onTap: () => Navigator.pushNamed(
                        context, AppConstants.routeFinance),
                  ),
                  _DashboardCard(
                    title: 'Reportes Financieros',
                    icon: Icons.assignment_outlined,
                    color: Colors.teal,
                    onTap: () => Navigator.pushNamed(
                        context, AppConstants.routeViewReports),
                  ),
                  _DashboardCard(
                    title: 'Reportes',
                    icon: Icons.bar_chart,
                    color: Colors.purple,
                    onTap: () => Navigator.pushNamed(
                        context, AppConstants.routeAdminReports),
                  ),
                  _DashboardCard(
                    title: 'Perfiles',
                    icon: Icons.account_circle,
                    color: Colors.indigo,
                    onTap: () => Navigator.pushNamed(
                        context, AppConstants.routeAdminProfiles),
                  ),
                  _DashboardCard(
                    title: 'Mis Visitas',
                    icon: Icons.group_add,
                    color: Colors.teal,
                    onTap: () => Navigator.pushNamed(
                        context, AppConstants.routeVisitors),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}