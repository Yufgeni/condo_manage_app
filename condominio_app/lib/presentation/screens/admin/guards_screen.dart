import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/providers/admin_provider.dart';

class GuardsScreen extends StatefulWidget {
  const GuardsScreen({super.key});

  @override
  State<GuardsScreen> createState() => _GuardsScreenState();
}

class _GuardsScreenState extends State<GuardsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<AdminProvider>(context, listen: false).fetchUsers());
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    final guards = adminProvider.users
        .where((u) => u.role == AppConstants.roleGuard)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Vigilantes')),
      body: adminProvider.isLoading && guards.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : guards.isEmpty
              ? const Center(child: Text('No hay vigilantes registrados'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: guards.length,
                  itemBuilder: (_, i) {
                    final g = guards[i];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              g.isOnDuty ? Colors.green[100] : Colors.grey[200],
                          child: Icon(Icons.security,
                              color: g.isOnDuty ? Colors.green : Colors.grey),
                        ),
                        title: Text(g.fullName),
                        subtitle: Text('Turno: ${g.isOnDuty ? g.shiftName : "Inactivo"}'),
                        trailing: Chip(
                          label: Text(g.isOnDuty ? 'En turno' : 'Fuera de turno'),
                          backgroundColor:
                              g.isOnDuty ? Colors.green[100] : Colors.grey[200],
                          labelStyle: TextStyle(
                            color: g.isOnDuty ? Colors.green[800] : Colors.grey[600],
                            fontSize: 10,
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}