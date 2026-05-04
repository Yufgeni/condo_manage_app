import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/guard_provider.dart';

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
        title: const Text('Guard Dashboard'),
        actions: [
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
            const SizedBox(height: 8),
            if (guardProvider.guard != null)
              Chip(
                avatar: const Icon(Icons.access_time, size: 16),
                label: Text('Turno: ${guardProvider.guard!.shift}'),
              ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(
                        context, AppConstants.routeGuardUpload),
                    icon: const Icon(Icons.upload),
                    label: const Text('Subir reporte'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(
                        context, AppConstants.routeGuardResidents),
                    icon: const Icon(Icons.people),
                    label: const Text('Ver Residentes'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Reportes recientes',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Expanded(
              child: guardProvider.uploads.isEmpty
                  ? const Center(child: Text('Sin reportes aún'))
                  : ListView.builder(
                      itemCount: guardProvider.uploads.length,
                      itemBuilder: (_, i) {
                        final upload = guardProvider.uploads[i];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.image),
                            title: Text(upload['text'] ?? ''),
                            subtitle: Text(upload['date'] ?? ''),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}