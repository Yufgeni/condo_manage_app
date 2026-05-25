import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/providers/admin_provider.dart';
import '../../../data/models/user_model.dart';

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
                        trailing: g.isOnDuty 
                          ? Chip(
                              label: const Text('En turno'),
                              backgroundColor: Colors.green[100],
                              labelStyle: TextStyle(
                                color: Colors.green[800],
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : ElevatedButton(
                              onPressed: () => _confirmSetOnDuty(context, g),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[50],
                                foregroundColor: Colors.blue[700],
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                              ),
                              child: const Text('Marcar en turno', style: TextStyle(fontSize: 10)),
                            ),
                      ),
                    );
                  },
                ),
    );
  }

  Future<void> _confirmSetOnDuty(BuildContext context, UserModel guard) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar vigilante en turno'),
        content: Text('¿Desea marcar a ${guard.fullName} como el vigilante en turno? Los demás vigilantes pasarán a estar fuera de turno.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await Provider.of<AdminProvider>(context, listen: false)
          .setGuardOnDuty(guard.id);
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Turno actualizado correctamente')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al actualizar el turno'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
}
