import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/providers/auth_provider.dart';

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
            leading: const Icon(Icons.people, color: Colors.blue),
            title: const Text('Residentes'),
            onTap: () => Navigator.pushNamed(context, AppConstants.routeResidents),
          ),
          ListTile(
            leading: const Icon(Icons.security, color: Colors.green),
            title: const Text('Vigilantes'),
            onTap: () => Navigator.pushNamed(context, AppConstants.routeGuards),
          ),
          ListTile(
            leading: const Icon(Icons.payments, color: Colors.orange),
            title: const Text('Finanzas'),
            onTap: () => Navigator.pushNamed(context, AppConstants.routeFinance),
          ),
          ListTile(
            leading: const Icon(Icons.group_add_outlined, color: Colors.redAccent),
            title: const Text('Ver visitantes'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppConstants.routeAdminVisitors);
            },
          ),
          ListTile(
            leading: const Icon(Icons.assignment_outlined, color: Colors.teal),
            title: const Text('Reportes Financieros'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppConstants.routeViewReports);
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart, color: Colors.purple),
            title: const Text('Reportes'),
            onTap: () => Navigator.pushNamed(context, AppConstants.routeAdminReports),
          ),
          ListTile(
            leading: const Icon(Icons.account_circle, color: Colors.indigo),
            title: const Text('Perfiles'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppConstants.routeAdminProfiles);
            },
          ),
          ListTile(
            leading: const Icon(Icons.group_add, color: Colors.teal),
            title: const Text('Mis Visitas'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppConstants.routeVisitors);
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