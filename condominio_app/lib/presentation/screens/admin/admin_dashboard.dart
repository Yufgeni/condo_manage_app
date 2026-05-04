import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/providers/auth_provider.dart';
import '../../widgets/admin/admin_drawer.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
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
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
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
                    title: 'Pagos',
                    icon: Icons.payment,
                    color: Colors.orange,
                    onTap: () => Navigator.pushNamed(
                        context, AppConstants.routePayments),
                  ),
                  _DashboardCard(
                    title: 'Reportes',
                    icon: Icons.bar_chart,
                    color: Colors.purple,
                    onTap: () => Navigator.pushNamed(
                        context, AppConstants.routeAdminReports),
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
              backgroundColor: color.withOpacity(0.15),
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