import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../data/models/visitor_model.dart';
import '../../../data/providers/visitor_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/resident_provider.dart';
import '../../../core/utils/ui_utils.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';

class AddVisitorScreen extends StatefulWidget {
  const AddVisitorScreen({super.key});

  @override
  State<AddVisitorScreen> createState() => _AddVisitorScreenState();
}

class _AddVisitorScreenState extends State<AddVisitorScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final carBrandController = TextEditingController();
  final carColorController = TextEditingController();
  final carPlatesController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void dispose() {
    nameController.dispose();
    carBrandController.dispose();
    carColorController.dispose();
    carPlatesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('es', 'ES'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedDate == null) {
      UIUtils.showSnackBar(context, 'Por favor seleccione una fecha para la visita');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final residentProvider = Provider.of<ResidentProvider>(context, listen: false);
    final visitorProvider = Provider.of<VisitorProvider>(context, listen: false);

    // Si la información de residente no está cargada, intentamos cargarla ahora
    if (residentProvider.resident == null) {
      await residentProvider.loadResidentData(authProvider.currentUser?.id ?? '');
    }

    final residentId = residentProvider.resident?.id;
    final profileId = authProvider.currentUser?.id;

    if (profileId == null) return;

    final newVisitor = VisitorModel(
      id: '', 
      residentId: residentId ?? '', // El provider se encargará de resolverlo si está vacío
      name: nameController.text.trim(),
      carBrand: carBrandController.text.trim(),
      carColor: carColorController.text.trim(),
      carPlates: carPlatesController.text.trim(),
      entryAt: _selectedDate!,
    );

    final success = await visitorProvider.addVisitor(newVisitor, profileId);

    if (mounted) {
      if (success) {
        UIUtils.showSnackBar(context, 'Visita agendada correctamente', isError: false);
        Navigator.pop(context);
      } else {
        UIUtils.showSnackBar(context, 'Error al agendar la visita. Verifique su conexión.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final visitorProvider = Provider.of<VisitorProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Agendar Visitante'),
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Nombre completo',
                controller: nameController,
                prefixIcon: const Icon(Icons.person_outline),
                validator: (v) => v?.isEmpty == true ? 'Nombre requerido' : null,
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha de visita',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(_selectedDate == null 
                    ? 'Seleccionar fecha' 
                    : DateFormat('dd/MM/yyyy').format(_selectedDate!)),
                ),
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
                text: 'Agendar Visita',
                onPressed: _save,
                isLoading: visitorProvider.isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}