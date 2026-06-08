import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/visitor_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/providers/visitor_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/admin_provider.dart';
import '../../../core/utils/ui_utils.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/image_picker_widget.dart';

class GuardVisitorRegistrationScreen extends StatefulWidget {
  const GuardVisitorRegistrationScreen({super.key});

  @override
  State<GuardVisitorRegistrationScreen> createState() => _GuardVisitorRegistrationScreenState();
}

class _GuardVisitorRegistrationScreenState extends State<GuardVisitorRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _carBrandController = TextEditingController();
  final _carModelController = TextEditingController();
  final _carColorController = TextEditingController();
  final _carPlatesController = TextEditingController();
  final _commentsController = TextEditingController();
  
  UserModel? _selectedResident;
  File? _idImage;
  bool _isPeatonal = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<AdminProvider>(context, listen: false).fetchUsers());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _carBrandController.dispose();
    _carModelController.dispose();
    _carColorController.dispose();
    _carPlatesController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedResident == null) {
      UIUtils.showSnackBar(context, 'Por favor seleccione la casa/residente que visita');
      return;
    }

    if (_idImage == null) {
      UIUtils.showSnackBar(context, 'Por favor tome una foto de la identificación');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final visitorProvider = Provider.of<VisitorProvider>(context, listen: false);

    final guardId = authProvider.currentUser?.id;

    final newVisitor = VisitorModel(
      id: '',
      residentId: _selectedResident!.id,
      name: _nameController.text.trim(),
      carBrand: _isPeatonal ? 'PEATONAL' : _carBrandController.text.trim(),
      carModel: _isPeatonal ? '' : _carModelController.text.trim(),
      carColor: _isPeatonal ? '' : _carColorController.text.trim(),
      carPlates: _isPeatonal ? 'N/A' : _carPlatesController.text.trim(),
      entryAt: DateTime.now(),
      guardId: guardId,
      comments: _commentsController.text.trim(),
      unitNumber: _selectedResident!.unitNumber,
    );

    final success = await visitorProvider.registerVisitor(newVisitor, idImage: _idImage);

    if (mounted) {
      if (success) {
        UIUtils.showSnackBar(context, 'Visita registrada correctamente', isError: false);
        Navigator.pop(context);
      } else {
        UIUtils.showSnackBar(context, 'Error al registrar la visita');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final visitorProvider = Provider.of<VisitorProvider>(context);
    final adminProvider = Provider.of<AdminProvider>(context);
    
    final allResidents = adminProvider.users
        .where((u) => u.role == AppConstants.roleResident || 
                     (u.role == AppConstants.roleAdmin && u.livesInCondo == true))
        .toList();
        
    // Eliminar duplicados por ID por si acaso el provider tiene datos repetidos
    final residents = <String, UserModel>{};
    for (var r in allResidents) {
      residents[r.id] = r;
    }
    final residentList = residents.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Entrada'),
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Nombre completo',
                controller: _nameController,
                prefixIcon: const Icon(Icons.person),
                validator: (v) => v?.isEmpty == true ? 'Nombre requerido' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<UserModel>(
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Casa que visita',
                  prefixIcon: Icon(Icons.home),
                  border: OutlineInputBorder(),
                ),
                value: _selectedResident != null && residentList.any((r) => r.id == _selectedResident!.id) 
                    ? residentList.firstWhere((r) => r.id == _selectedResident!.id) 
                    : null,
                items: residentList.map((r) => DropdownMenuItem(
                  value: r,
                  child: Text(
                    'Casa ${r.unitNumber} - ${r.fullName}',
                    overflow: TextOverflow.ellipsis,
                  ),
                )).toList(),
                onChanged: (val) => setState(() => _selectedResident = val),
                validator: (val) => val == null ? 'Seleccione una casa' : null,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text('¿Ingreso Peatonal?', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Switch(
                    value: _isPeatonal,
                    onChanged: (val) => setState(() => _isPeatonal = val),
                  ),
                ],
              ),
              if (!_isPeatonal) ...[
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Marca del auto',
                  controller: _carBrandController,
                  prefixIcon: const Icon(Icons.directions_car),
                  validator: (v) => !_isPeatonal && v?.isEmpty == true ? 'Marca requerida' : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Modelo',
                  controller: _carModelController,
                  prefixIcon: const Icon(Icons.model_training),
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Color',
                  controller: _carColorController,
                  prefixIcon: const Icon(Icons.color_lens),
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Placas',
                  controller: _carPlatesController,
                  prefixIcon: const Icon(Icons.vignette),
                  validator: (v) => !_isPeatonal && v?.isEmpty == true ? 'Placas requeridas' : null,
                ),
              ],
              const SizedBox(height: 20),
              const Text('Foto de Identificación (INE)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ImagePickerWidget(
                selectedImage: _idImage,
                onImageSelected: (file) => setState(() => _idImage = file),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Comentarios (Opcional)',
                controller: _commentsController,
                prefixIcon: const Icon(Icons.comment),
                maxLines: 2,
              ),
              const SizedBox(height: 30),
              CustomButton(
                text: 'Registrar Entrada',
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
