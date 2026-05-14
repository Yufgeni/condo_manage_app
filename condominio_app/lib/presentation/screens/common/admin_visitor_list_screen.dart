import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/providers/resident_provider.dart';

class AdminVisitorListScreen extends StatelessWidget {
  const AdminVisitorListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final residentProvider = Provider.of<ResidentProvider>(context);
    final residents = residentProvider.allResidents;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ver Visitantes'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: residents.length,
        itemBuilder: (context, index) {
          final resident = residents[index];
          // Asumiendo que el nombre completo está en resident.name o similar.
          // Si el modelo tiene firstName y lastName, usarlos. 
          // Ajustaré basándome en el modelo ResidentModel.
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: const CircleAvatar(
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(
                'Residente: ${resident.name}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text('ID: ${resident.id}'),
              trailing: const Icon(Icons.calendar_month, color: Colors.blue),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppConstants.routeResidentVisitorCalendar,
                  arguments: resident.id,
                );
              },
            ),
          );
        },
      ),
    );
  }
}