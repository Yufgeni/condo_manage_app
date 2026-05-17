import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/providers/auth_provider.dart';
import '../../screens/admin/admin_profiles_screen.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF1565C0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.admin_panel_settings,
                      size: 36, color: Color(0xFF1565C0)),
                ),
                const SizedBox(height: 8),
                Text(
                  authProvider.currentUser?.name ?? 'Administrador',
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
                context, AppConstants.routeAdminDashboard),
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Residentes'),
            onTap: () => Navigator.pushNamed(context, AppConstants.routeResidents),
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Vigilantes'),
            onTap: () => Navigator.pushNamed(context, AppConstants.routeGuards),
          ),
          ListTile(
            leading: const Icon(Icons.build),
            title: const Text('Mantenimiento'),
            onTap: () => Navigator.pushNamed(context, AppConstants.routeMaintenance),
          ),
          ListTile(
            leading: const Icon(Icons.group_add_outlined),
            title: const Text('Ver visitantes'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppConstants.routeAdminVisitors);
            },
          ),
          ListTile(
            leading: const Icon(Icons.assignment_outlined),
            title: const Text('Visualizar Reportes'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppConstants.routeViewReports);
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Reportes'),
            onTap: () => Navigator.pushNamed(context, AppConstants.routeAdminReports),
          ),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('Perfiles'),
            onTap: () async {
              Navigator.pop(context);
              final confirmed = await AdminProfilesScreen.showPasswordDialog(context);
              if (confirmed == true && context.mounted) {
                Navigator.pushNamed(context, AppConstants.routeAdminProfiles);
              }
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