import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/providers/maintenance_provider.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final maintenanceProvider = Provider.of<MaintenanceProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Mantenimiento')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppConstants.routeAddMaintenance),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: maintenanceProvider.maintenanceRecords.length,
        itemBuilder: (context, index) {
          final record = maintenanceProvider.maintenanceRecords[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(record.concept),
              subtitle: Text(DateFormat('dd MMMM yyyy').format(record.date)),
              trailing: Text(
                '\$${record.amount}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}