import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/guard_provider.dart';
import '../../widgets/common/panic_button.dart';
import '../../widgets/guard/guard_drawer.dart';

class GuardDashboard extends StatefulWidget {
  const GuardDashboard({Key? key}) : super(key: key);

  @override
  State<GuardDashboard> createState() => _GuardDashboardState();
}

class _GuardDashboardState extends State<GuardDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId =
          Provider.of<AuthProvider>(context, listen: false).currentUser?.id ?? '';
      Provider.of<GuardProvider>(context, listen: false).loadGuardData(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final guardProvider = Provider.of<GuardProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Vigilancia'),
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
      drawer: const GuardDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hola, ${authProvider.currentUser?.name ?? ''}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (guardProvider.guard != null)
                      Text(
                        'Turno: ${guardProvider.guard!.shiftName}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                  ],
                ),
                CircleAvatar(
                  radius: 25,
                  backgroundImage: guardProvider.guard?.photoUrl != null
                      ? NetworkImage(guardProvider.guard!.photoUrl!)
                      : null,
                  child: guardProvider.guard?.photoUrl == null
                      ? const Icon(Icons.security)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _GuardCard(
                    title: 'Subir Reporte',
                    icon: Icons.upload_file,
                    color: Colors.blue,
                    onTap: () => Navigator.pushNamed(
                        context, AppConstants.routeGuardUpload),
                  ),
                  _GuardCard(
                    title: 'Ver Residentes',
                    icon: Icons.people_alt,
                    color: Colors.blueGrey,
                    onTap: () => Navigator.pushNamed(
                        context, AppConstants.routeGuardResidents),
                  ),
                  _GuardCard(
                    title: 'Ver Visitantes',
                    icon: Icons.group_add_outlined,
                    color: Colors.orange,
                    onTap: () => Navigator.pushNamed(
                        context, AppConstants.routeAdminVisitors),
                  ),
                  _GuardCard(
                    title: 'Visualizar Reportes',
                    icon: Icons.assignment_outlined,
                    color: Colors.teal,
                    onTap: () => Navigator.pushNamed(
                        context, AppConstants.routeViewReports),
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

class _GuardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _GuardCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}