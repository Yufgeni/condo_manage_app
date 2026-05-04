import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/resident_provider.dart';

class GuardResidentsScreen extends StatelessWidget {
  const GuardResidentsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final residentProvider = Provider.of<ResidentProvider>(context);
    final residents = residentProvider.allResidents;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Directorio de Residentes'),
      ),
      body: residents.isEmpty
          ? const Center(child: Text('No hay residentes registrados'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: residents.length,
              itemBuilder: (context, index) {
                final resident = residents[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueGrey.shade100,
                      child: Text(
                        resident.unitNumber,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ),
                    title: Text(
                      resident.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Unidad: ${resident.unitNumber}'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(),
                            _infoRow(Icons.phone, 'Teléfono', resident.phone),
                            const SizedBox(height: 8),
                            if (resident.car != null) ...[
                              _infoRow(
                                Icons.directions_car,
                                'Vehículo',
                                '${resident.car!.brand} (${resident.car!.color})',
                              ),
                              const SizedBox(height: 8),
                              _infoRow(
                                Icons.vignette,
                                'Placa',
                                resident.car!.plates,
                              ),
                            ] else ...[
                              _infoRow(
                                Icons.directions_car_outlined,
                                'Vehículo',
                                'Sin vehículo registrado',
                              ),
                            ],
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blueGrey),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        Text(value),
      ],
    );
  }
}