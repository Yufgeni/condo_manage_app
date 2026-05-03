import 'package:flutter/material.dart';

class GuardsScreen extends StatelessWidget {
  const GuardsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final guards = [
      {'name': 'Carlos López', 'shift': 'Nocturno', 'status': true},
      {'name': 'Pedro Ramírez', 'shift': 'Diurno', 'status': false},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Vigilantes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: guards.length,
        itemBuilder: (_, i) {
          final g = guards[i];
          final onDuty = g['status'] as bool;
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    onDuty ? Colors.green[100] : Colors.grey[200],
                child: Icon(Icons.security,
                    color: onDuty ? Colors.green : Colors.grey),
              ),
              title: Text(g['name'] as String),
              subtitle: Text('Turno: ${g['shift']}'),
              trailing: Chip(
                label: Text(onDuty ? 'En turno' : 'Fuera de turno'),
                backgroundColor:
                    onDuty ? Colors.green[100] : Colors.grey[200],
              ),
            ),
          );
        },
      ),
    );
  }
}