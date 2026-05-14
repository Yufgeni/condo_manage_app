import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/resident_model.dart';
import '../../../data/providers/resident_provider.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';

class AddResidentScreen extends StatefulWidget {
  const AddResidentScreen({Key? key}) : super(key: key);

  @override
  State<AddResidentScreen> createState() => _AddResidentScreenState();
}

class _AddResidentScreenState extends State<AddResidentScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final lastNameController = TextEditingController();
  final unitController = TextEditingController();
  
  final carBrandController = TextEditingController();
  final carModelController = TextEditingController();
  final carColorController = TextEditingController();
  final carPlatesController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    lastNameController.dispose();
    unitController.dispose();
    carBrandController.dispose();
    carModelController.dispose();
    carColorController.dispose();
    carPlatesController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final newResident = ResidentModel(
        id: DateTime.now().toString(),
        userId: DateTime.now().toString(),
        name: '${nameController.text} ${lastNameController.text}',
        email: '',
        phone: '',
        unitNumber: unitController.text,
        cars: [
          CarInfo(
            brand: carBrandController.text,
            year: carModelController.text,
            color: carColorController.text,
            plates: carPlatesController.text,
          )
        ],
      );
      Provider.of<ResidentProvider>(context, listen: false).addResident(newResident);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Nuevo Residente'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Datos Personales',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
              const SizedBox(height: 15),
              CustomTextField(
                label: 'Nombre',
                controller: nameController,
                prefixIcon: const Icon(Icons.person_outline),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Apellidos',
                controller: lastNameController,
                prefixIcon: const Icon(Icons.person_outline),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Número de casa',
                controller: unitController,
                prefixIcon: const Icon(Icons.home_outlined),
              ),
              const SizedBox(height: 30),
              const Text(
                'Datos del Automóvil',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
              const SizedBox(height: 15),
              CustomTextField(
                label: 'Marca',
                controller: carBrandController,
                prefixIcon: const Icon(Icons.directions_car_outlined),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Modelo (Año)',
                controller: carModelController,
                prefixIcon: const Icon(Icons.calendar_today_outlined),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Color',
                controller: carColorController,
                prefixIcon: const Icon(Icons.color_lens_outlined),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Placa',
                controller: carPlatesController,
                prefixIcon: const Icon(Icons.confirmation_number_outlined),
              ),
              const SizedBox(height: 40),
              CustomButton(
                text: 'Guardar Residente',
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}