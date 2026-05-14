import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/resident_model.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/resident_provider.dart';
import '../../../core/utils/validators.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class ResidentProfileScreen extends StatefulWidget {
  const ResidentProfileScreen({Key? key}) : super(key: key);

  @override
  State<ResidentProfileScreen> createState() => _ResidentProfileScreenState();
}

class _ResidentProfileScreenState extends State<ResidentProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _brandController = TextEditingController();
  final _yearController = TextEditingController();
  final _colorController = TextEditingController();
  final _platesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId =
          Provider.of<AuthProvider>(context, listen: false).currentUser?.id ?? '';
      Provider.of<ResidentProvider>(context, listen: false)
          .loadResidentData(userId)
          .then((_) => _populateFields());
    });
  }

  void _populateFields() {
    final resident =
        Provider.of<ResidentProvider>(context, listen: false).resident;
    if (resident != null) {
      _phoneController.text = resident.phone;
      if (resident.cars.isNotEmpty) {
        final car = resident.cars.first;
        _brandController.text = car.brand;
        _yearController.text = car.year;
        _colorController.text = car.color;
        _platesController.text = car.plates;
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = Provider.of<ResidentProvider>(context, listen: false);
    final success = await provider.updateProfile(
      phone: _phoneController.text,
      cars: [
        CarInfo(
          brand: _brandController.text,
          year: _yearController.text,
          color: _colorController.text,
          plates: _platesController.text,
        ),
      ],
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success ? 'Perfil actualizado' : 'Error al actualizar'),
        backgroundColor: success ? Colors.green : Colors.red,
      ));
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _brandController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _platesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ResidentProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Información Personal',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Número de teléfono',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      prefixIcon: const Icon(Icons.phone),
                      validator: Validators.validatePhone,
                    ),
                    const SizedBox(height: 24),
                    const Text('Información del Automóvil',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Marca',
                      controller: _brandController,
                      prefixIcon: const Icon(Icons.directions_car),
                      validator: (v) =>
                          Validators.validateRequired(v, 'Marca'),
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Año',
                      controller: _yearController,
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.calendar_today),
                      validator: (v) =>
                          Validators.validateRequired(v, 'Año'),
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Color',
                      controller: _colorController,
                      prefixIcon: const Icon(Icons.color_lens),
                      validator: (v) =>
                          Validators.validateRequired(v, 'Color'),
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Placas',
                      controller: _platesController,
                      prefixIcon: const Icon(Icons.confirmation_number),
                      validator: (v) =>
                          Validators.validateRequired(v, 'Placas'),
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Guardar cambios',
                      onPressed: _save,
                      isLoading: provider.isLoading,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}