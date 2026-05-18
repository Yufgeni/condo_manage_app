import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/resident_model.dart';
import '../../../data/providers/admin_provider.dart';
import '../../../data/providers/resident_provider.dart';

class GuardResidentsScreen extends StatefulWidget {
  const GuardResidentsScreen({Key? key}) : super(key: key);

  @override
  State<GuardResidentsScreen> createState() => _GuardResidentsScreenState();
}

class _GuardResidentsScreenState extends State<GuardResidentsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<AdminProvider>(context, listen: false).fetchUsers();
      Provider.of<ResidentProvider>(context, listen: false).fetchAllResidents();
    });
  }

  void _showResidentDetails(BuildContext context, UserModel userProfile) {
    final residentProvider = Provider.of<ResidentProvider>(context, listen: false);
    
    // Buscar información extendida del residente
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
        title: const Text('Detalle de Residente / Admin', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow(Icons.person, 'Nombre', userProfile.fullName),
              _detailRow(Icons.phone, 'Teléfono', userProfile.phone ?? 'No disponible'),
              const Divider(height: 32),
              const Text('Vehículos registrados:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (residentData.cars.isEmpty)
                const Text('Sin vehículo registrado', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))
              else
                ...residentData.cars.map((car) => Card(
                      color: Colors.grey.shade100,
                      child: ListTile(
                        leading: const Icon(Icons.directions_car),
                        title: Text('${car.brand} - ${car.year}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        subtitle: Text('Color: ${car.color} | Placas: ${car.plates}', style: const TextStyle(fontSize: 12)),
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

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    final residentProvider = Provider.of<ResidentProvider>(context);
    
    // Filtramos para obtener Residentes y Administradores únicamente
    final users = adminProvider.users
        .where((u) => u.role == AppConstants.roleResident || u.role == AppConstants.roleAdmin)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ver Residentes'),
      ),
      body: (adminProvider.isLoading || residentProvider.isLoading) && users.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : users.isEmpty
              ? const Center(child: Text('No hay registros encontrados'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        onTap: () => _showResidentDetails(context, user),
                        leading: CircleAvatar(
                          radius: 20,
                          backgroundColor: user.role == AppConstants.roleAdmin ? Colors.blue.shade100 : Colors.green.shade100,
                          backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                          child: user.photoUrl == null 
                            ? Icon(user.role == AppConstants.roleAdmin ? Icons.admin_panel_settings : Icons.person, size: 20) 
                            : null,
                        ),
                        title: Text(
                          user.fullName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                      ),
                    );
                  },
                ),
    );
  }
}