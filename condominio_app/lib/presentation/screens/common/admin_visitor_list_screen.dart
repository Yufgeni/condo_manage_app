import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/providers/admin_provider.dart';

class AdminVisitorListScreen extends StatefulWidget {
  const AdminVisitorListScreen({super.key});

  @override
  State<AdminVisitorListScreen> createState() => _AdminVisitorListScreenState();
}

class _AdminVisitorListScreenState extends State<AdminVisitorListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<AdminProvider>(context, listen: false).fetchUsers());
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    
    // Filtramos para obtener Residentes y Administradores para el listado de visitas
    final users = adminProvider.users
        .where((u) => u.role == AppConstants.roleResident || u.role == AppConstants.roleAdmin)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ver Visitantes'),
      ),
      body: adminProvider.isLoading && users.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : users.isEmpty
              ? const Center(child: Text('No hay residentes registrados'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppConstants.routeResidentVisitorCalendar,
                            arguments: user.id,
                          );
                        },
                        leading: CircleAvatar(
                          radius: 20,
                          backgroundColor: user.role == AppConstants.roleAdmin ? Colors.blue.shade100 : Colors.green.shade100,
                          backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                          child: user.photoUrl == null 
                            ? Icon(user.role == AppConstants.roleAdmin ? Icons.admin_panel_settings : Icons.person, size: 20) 
                            : null,
                        ),
                        title: Text(
                          user.fullName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: const Icon(Icons.calendar_month, color: Colors.blueGrey),
                      ),
                    );
                  },
                ),
    );
  }
}