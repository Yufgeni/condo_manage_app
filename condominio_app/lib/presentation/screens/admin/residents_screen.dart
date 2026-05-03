import 'package:flutter/material.dart';

class ResidentsScreen extends StatelessWidget {
  const ResidentsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final residents = [
      {'name': 'Juan Pérez', 'unit': 'A-101', 'email': 'residente@condominio.com'},
      {'name': 'María García', 'unit': 'B-202', 'email': 'maria@condominio.com'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Residentes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
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
              title: Text(r['name']!),
              subtitle: Text('Unidad: ${r['unit']} • ${r['email']}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}