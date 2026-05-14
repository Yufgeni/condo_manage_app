import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/visitor_model.dart';
import '../../../data/providers/visitor_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';

class AddVisitorScreen extends StatefulWidget {
  const AddVisitorScreen({Key? key}) : super(key: key);

  @override
  State<AddVisitorScreen> createState() => _AddVisitorScreenState();
}

class _AddVisitorScreenState extends State<AddVisitorScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final carBrandController = TextEditingController();
  final carColorController = TextEditingController();
  final carPlatesController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    carBrandController.dispose();
    carColorController.dispose();
    carPlatesController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final newVisitor = VisitorModel(
        id: DateTime.now().toString(),
        residentId: authProvider.currentUser?.id ?? '',
        name: nameController.text,
        carBrand: carBrandController.text,
        carColor: carColorController.text,
        carPlates: carPlatesController.text,
        date: DateTime.now(),
      );
      Provider.of<VisitorProvider>(context, listen: false).addVisitor(newVisitor);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Registrar Visitante'),
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
                'Datos del Visitante',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              const SizedBox(height: 15),
              CustomTextField(
                label: 'Nombre completo',
                controller: nameController,
                prefixIcon: const Icon(Icons.person_outline),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Marca del Automóvil',
                controller: carBrandController,
                prefixIcon: const Icon(Icons.directions_car_outlined),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Color',
                controller: carColorController,
                prefixIcon: const Icon(Icons.color_lens_outlined),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Placas',
                controller: carPlatesController,
                prefixIcon: const Icon(Icons.confirmation_number_outlined),
              ),
              const SizedBox(height: 40),
              CustomButton(
                text: 'Registrar Visita',
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}