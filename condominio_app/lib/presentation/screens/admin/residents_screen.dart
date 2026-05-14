import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/resident_model.dart';
import '../../../data/providers/resident_provider.dart';
import '../resident/payment_history_screen.dart';

class ResidentsScreen extends StatelessWidget {
  const ResidentsScreen({Key? key}) : super(key: key);

  void _showOptions(BuildContext context, ResidentModel resident) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text('Ver historial de pagos'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PaymentHistoryScreen(residentId: resident.id),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Ver información'),
            onTap: () {
              Navigator.pop(context);
              _showResidentInfo(context, resident);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showResidentInfo(BuildContext context, ResidentModel resident) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Información de ${resident.name}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Unidad: ${resident.unitNumber}'),
              Text('Email: ${resident.email}'),
              Text('Teléfono: ${resident.phone}'),
              const Divider(),
              const Text(
                'Automóviles:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              if (resident.cars.isEmpty)
                const Text('No hay automóviles registrados.')
              else
                ...resident.cars.map((car) => Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• ${car.brand} (${car.year})'),
                          Text('  Color: ${car.color}'),
                          Text('  Placas: ${car.plates}'),
                        ],
                      ),
                    )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final residents = Provider.of<ResidentProvider>(context).allResidents;

    return Scaffold(
      appBar: AppBar(title: const Text('Residentes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppConstants.routeAddResident),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: residents.length,
        itemBuilder: (_, i) {
          final r = residents[i];
          return Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(r.name),
              subtitle: Text('Unidad: ${r.unitNumber} • ${r.email}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showOptions(context, r),
            ),
          );
        },
      ),
    );
  }
}