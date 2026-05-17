import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/user_model.dart';
import '../../../data/providers/admin_provider.dart';

class ResidentsScreen extends StatefulWidget {
  const ResidentsScreen({Key? key}) : super(key: key);

  @override
  State<ResidentsScreen> createState() => _ResidentsScreenState();
}

class _ResidentsScreenState extends State<ResidentsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<AdminProvider>(context, listen: false).fetchUsers());
  }

  void _showResidentInfo(BuildContext context, UserModel resident) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Información de ${resident.fullName}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Email: ${resident.email}'),
              if (resident.age != null) Text('Edad: ${resident.age}'),
              if (resident.birthDate != null) 
                Text('Nacimiento: ${resident.birthDate!.day}/${resident.birthDate!.month}/${resident.birthDate!.year}'),
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
    final adminProvider = Provider.of<AdminProvider>(context);
    final residents = adminProvider.users
        .where((u) => u.role == AppConstants.roleResident)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Residentes')),
      body: adminProvider.isLoading && residents.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : residents.isEmpty
              ? const Center(child: Text('No hay residentes registrados'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: residents.length,
                  itemBuilder: (_, i) {
                    final r = residents[i];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(r.fullName),
                        subtitle: Text(r.email),
                        trailing: const Icon(Icons.info_outline),
                        onTap: () => _showResidentInfo(context, r),
                      ),
                    );
                  },
                ),
    );
  }
}