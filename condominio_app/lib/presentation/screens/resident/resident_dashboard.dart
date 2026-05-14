import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/providers/auth_provider.dart';
import '../../widgets/common/panic_button.dart';

class ResidentDashboard extends StatelessWidget {
  const ResidentDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resident Dashboard'),
        actions: [
          const PanicButton(),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              Navigator.pushReplacementNamed(context, AppConstants.routeLogin);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hola, ${authProvider.currentUser?.name ?? ''}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _ResidentCard(
                    title: 'Mis Pagos',
                    icon: Icons.receipt_long,
                    color: Colors.blue,
                    onTap: () => Navigator.pushNamed(
                        context, AppConstants.routePaymentHistory),
                  ),
                  _ResidentCard(
                    title: 'Mis Visitantes',
                    icon: Icons.group_add_outlined,
                    color: Colors.orange,
                    onTap: () => Navigator.pushNamed(
                        context, AppConstants.routeVisitors),
                  ),
                  _ResidentCard(
                    title: 'Vigilante en Turno',
                    icon: Icons.security,
                    color: Colors.green,
                    onTap: () => Navigator.pushNamed(
                        context, AppConstants.routeGuardOnDuty),
                  ),
                  _ResidentCard(
                    title: 'Mi Perfil',
                    icon: Icons.person,
                    color: Colors.purple,
                    onTap: () => Navigator.pushNamed(
                        context, AppConstants.routeResidentProfile),
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

class _ResidentCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ResidentCard({
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