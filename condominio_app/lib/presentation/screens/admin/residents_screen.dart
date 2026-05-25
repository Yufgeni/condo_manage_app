import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/resident_model.dart';
import '../../../data/providers/admin_provider.dart';
import '../../../data/providers/resident_provider.dart';

class ResidentsScreen extends StatefulWidget {
  const ResidentsScreen({super.key});

  @override
  State<ResidentsScreen> createState() => _ResidentsScreenState();
}

class _ResidentsScreenState extends State<ResidentsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<AdminProvider>(context, listen: false).fetchUsers();
      Provider.of<ResidentProvider>(context, listen: false).fetchAllResidents();
    });
  }

  void _showResidentInfo(BuildContext context, UserModel userProfile) {
    final residentProvider = Provider.of<ResidentProvider>(context, listen: false);
    
    final residentData = residentProvider.allResidents.firstWhere(
      (r) => r.profileId == userProfile.id,
      orElse: () => ResidentModel(
        id: '',
        profileId: userProfile.id,
        name: userProfile.name,
        email: userProfile.email,
        phone: userProfile.phone ?? 'Sin teléfono',
        unitNumber: 'S/N',
        cars: [],
      ),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Información de ${userProfile.fullName}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _infoRow(Icons.email, 'Email', userProfile.email),
              _infoRow(Icons.phone, 'Teléfono', userProfile.phone ?? 'Sin registro'),
              const Divider(height: 30),
              const Text(
                'Automóviles Registrados',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              if (residentData.cars.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'Sin automóvil registrado',
                    style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                )
              else
                ...residentData.cars.map((car) => Card(
                  color: Colors.grey[50],
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• ${car.brand} - ${car.year}', 
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text('  Color: ${car.color} | Placas: ${car.plates}',
                            style: const TextStyle(fontSize: 12)),
                      ],
                    ),
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

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blueGrey),
          const SizedBox(width: 10),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
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
                        title: Row(
                          children: [
                            Expanded(child: Text(r.fullName)),
                            if (r.unitNumber != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.blue.shade200),
                                ),
                                child: Text(
                                  'Casa ${r.unitNumber}',
                                  style: TextStyle(fontSize: 12, color: Colors.blue.shade800, fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
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