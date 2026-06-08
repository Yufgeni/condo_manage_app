import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/providers/auth_provider.dart';

class ResidentDrawer extends StatelessWidget {
  const ResidentDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF1B5E20)), // Verde para Residente
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person,
                      size: 36, color: Color(0xFF1B5E20)),
                ),
                const SizedBox(height: 8),
                Text(
                  authProvider.currentUser?.name ?? 'Residente',
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
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, AppConstants.routeResidentDashboard);
            },
          ),
          ListTile(
            leading: const Icon(Icons.history_edu, color: Colors.indigo),
            title: const Text('Historial de Accesos'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppConstants.routeVisitorHistory);
            },
          ),
          ListTile(
            leading: const Icon(Icons.group_add_outlined, color: Colors.orange),
            title: const Text('Agendar Visita'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppConstants.routeVisitors);
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long, color: Colors.blue),
            title: const Text('Mis Pagos'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppConstants.routeResidentPaymentsMenu);
            },
          ),
          ListTile(
            leading: const Icon(Icons.security, color: Colors.green),
            title: const Text('Vigilante en Turno'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppConstants.routeGuardOnDuty);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.purple),
            title: const Text('Mi Perfil'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppConstants.routeResidentProfile);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Cerrar sesión',
                style: TextStyle(color: Colors.red)),
            onTap: () async {
              await authProvider.logout();
              Navigator.pushNamedAndRemoveUntil(
                  context, AppConstants.routeLogin, (route) => false);
            },
          ),
        ],
      ),
    );
  }
}