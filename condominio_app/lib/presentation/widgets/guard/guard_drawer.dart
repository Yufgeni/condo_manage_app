import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/providers/auth_provider.dart';

class GuardDrawer extends StatelessWidget {
  const GuardDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blueGrey),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.security,
                      size: 36, color: Colors.blueGrey),
                ),
                const SizedBox(height: 8),
                Text(
                  authProvider.currentUser?.name ?? 'Vigilante',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                Text(
                  authProvider.currentUser?.email ?? '',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () => Navigator.pushReplacementNamed(
                context, AppConstants.routeGuardDashboard),
          ),
          ListTile(
            leading: const Icon(Icons.upload_file, color: Colors.blue),
            title: const Text('Subir Reporte'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppConstants.routeGuardUpload);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people_alt, color: Colors.blueGrey),
            title: const Text('Ver Residentes'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppConstants.routeGuardResidents);
            },
          ),
          ListTile(
            leading: const Icon(Icons.group_add_outlined, color: Colors.orange),
            title: const Text('Ver Visitantes'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppConstants.routeAdminVisitors);
            },
          ),
          ListTile(
            leading: const Icon(Icons.history, color: Colors.teal),
            title: const Text('Mis Reportes'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppConstants.routeGuardReports);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Cerrar sesión',
                style: TextStyle(color: Colors.red)),
            onTap: () async {
              await authProvider.logout();
              Navigator.pushReplacementNamed(context, AppConstants.routeLogin);
            },
          ),
        ],
      ),
    );
  }
}