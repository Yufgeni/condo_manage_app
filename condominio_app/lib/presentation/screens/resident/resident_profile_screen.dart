import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/resident_model.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/resident_provider.dart';
import '../../../core/utils/ui_utils.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class ResidentProfileScreen extends StatefulWidget {
  const ResidentProfileScreen({Key? key}) : super(key: key);

  @override
  State<ResidentProfileScreen> createState() => _ResidentProfileScreenState();
}

class _ResidentProfileScreenState extends State<ResidentProfileScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId =
          Provider.of<AuthProvider>(context, listen: false).currentUser?.id ?? '';
      Provider.of<ResidentProvider>(context, listen: false).loadResidentData(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
      ),
      body: Column(
        children: [
          _buildTabs(),
          Expanded(
            child: _currentIndex == 0
                ? const _MyDataTab()
                : const _ChangePasswordTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          _tabItem('Mis Datos', 0),
          _tabItem('Cambiar Contraseña', 1),
        ],
      ),
    );
  }

  Widget _tabItem(String title, int index) {
    final isSelected = _currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? const Color(0xFF1B5E20) : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? const Color(0xFF1B5E20) : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}

class _MyDataTab extends StatefulWidget {
  const _MyDataTab({Key? key}) : super(key: key);

  @override
  State<_MyDataTab> createState() => _MyDataTabState();
}

class _MyDataTabState extends State<_MyDataTab> {
  final _phoneController = TextEditingController();
  bool _isAddingVehicle = false;

  @override
  void initState() {
    super.initState();
    final resident = Provider.of<ResidentProvider>(context, listen: false).resident;
    if (resident != null) {
      _phoneController.text = resident.phone;
    }
  }

  @override
  void didUpdateWidget(covariant _MyDataTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    final resident = Provider.of<ResidentProvider>(context, listen: false).resident;
    if (resident != null && _phoneController.text != resident.phone) {
      _phoneController.text = resident.phone;
    }
  }

  Future<void> _savePhone() async {
    if (_phoneController.text.isEmpty) {
      UIUtils.showSnackBar(context, 'El teléfono no puede estar vacío');
      return;
    }
    
    final confirmed = await _showConfirmDialog('Actualizar teléfono', '¿Desea cambiar su número de teléfono?');
    if (confirmed != true) return;

    final provider = Provider.of<ResidentProvider>(context, listen: false);
    final success = await provider.updatePhone(_phoneController.text);
    if (mounted) {
      UIUtils.showSnackBar(context, success ? 'Teléfono actualizado' : 'Error al actualizar', isError: !success);
    }
  }

  Future<bool?> _showConfirmDialog(String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirmar')),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ResidentProvider>(context);
    final resident = provider.resident;

    if (provider.isLoading && resident == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Actualizar controlador si los datos cargaron después del init
    if (resident != null && _phoneController.text.isEmpty && resident.phone.isNotEmpty) {
      _phoneController.text = resident.phone;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Información Personal',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
          const SizedBox(height: 12),
          CustomTextField(
            label: 'Número de teléfono',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            prefixIcon: const Icon(Icons.phone),
            suffixIcon: IconButton(
              icon: const Icon(Icons.save, color: Colors.green),
              onPressed: _savePhone,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Mis Automóviles',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
              if (!_isAddingVehicle)
                TextButton.icon(
                  onPressed: () => setState(() => _isAddingVehicle = true),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Agregar vehículo', style: TextStyle(fontSize: 13)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (resident != null) ...[
            if (_isAddingVehicle)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _AddVehicleForm(
                  onCancel: () => setState(() => _isAddingVehicle = false),
                  onSaved: () => setState(() => _isAddingVehicle = false),
                ),
              ),
            ...resident.cars.map((car) => _VehicleCard(car: car)),
            if (resident.cars.isEmpty && !_isAddingVehicle)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No tienes vehículos registrados', style: TextStyle(color: Colors.grey)),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _ChangePasswordTab extends StatefulWidget {
  const _ChangePasswordTab({Key? key}) : super(key: key);

  @override
  State<_ChangePasswordTab> createState() => _ChangePasswordTabState();
}

class _ChangePasswordTabState extends State<_ChangePasswordTab> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future<void> _changePassword() async {
    if (_passwordController.text.isEmpty || _passwordController.text.length < 6) {
      UIUtils.showSnackBar(context, 'La contraseña debe tener al menos 6 caracteres');
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      UIUtils.showSnackBar(context, 'Las contraseñas no coinciden');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar contraseña'),
        content: const Text('¿Está seguro de que desea cambiar su contraseña?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirmar')),
        ],
      ),
    );

    if (confirmed != true) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.updatePassword(_passwordController.text);
    if (mounted) {
      UIUtils.showSnackBar(context, success ? 'Contraseña actualizada correctamente' : 'Error al actualizar', isError: !success);
      if (success) {
        _passwordController.clear();
        _confirmPasswordController.clear();
      }
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Seguridad',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Nueva Contraseña',
            controller: _passwordController,
            obscureText: true,
            prefixIcon: const Icon(Icons.lock_outline),
          ),
          const SizedBox(height: 12),
          CustomTextField(
            label: 'Confirmar Contraseña',
            controller: _confirmPasswordController,
            obscureText: true,
            prefixIcon: const Icon(Icons.lock_reset),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Actualizar Contraseña',
            onPressed: _changePassword,
          ),
        ],
      ),
    );
  }
}

class _VehicleCard extends StatefulWidget {
  final CarInfo car;
  const _VehicleCard({required this.car, Key? key}) : super(key: key);

  @override
  State<_VehicleCard> createState() => _VehicleCardState();
}

class _VehicleCardState extends State<_VehicleCard> {
  bool _isEditing = false;
  final _brandController = TextEditingController();
  final _yearController = TextEditingController();
  final _colorController = TextEditingController();
  final _platesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _brandController.text = widget.car.brand;
    _yearController.text = widget.car.year;
    _colorController.text = widget.car.color;
    _platesController.text = widget.car.plates;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ResidentProvider>(context, listen: false);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.directions_car, color: Color(0xFF1B5E20)),
                if (!_isEditing)
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                    onPressed: () => setState(() => _isEditing = true),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            CustomTextField(
              label: 'Marca',
              controller: _brandController,
              enabled: _isEditing,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'Año',
                    controller: _yearController,
                    enabled: _isEditing,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    label: 'Color',
                    controller: _colorController,
                    enabled: _isEditing,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            CustomTextField(
              label: 'Placas',
              controller: _platesController,
              enabled: _isEditing,
            ),
            if (_isEditing) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isEditing = false;
                        _brandController.text = widget.car.brand;
                        _yearController.text = widget.car.year;
                        _colorController.text = widget.car.color;
                        _platesController.text = widget.car.plates;
                      });
                    },
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final updatedCar = CarInfo(
                        id: widget.car.id,
                        brand: _brandController.text,
                        year: _yearController.text,
                        color: _colorController.text,
                        plates: _platesController.text,
                      );
                      final success = await provider.updateVehicle(updatedCar);
                      if (mounted) {
                        UIUtils.showSnackBar(context, success ? 'Vehículo actualizado' : 'Error al guardar', isError: !success);
                        if (success) setState(() => _isEditing = false);
                      }
                    },
                    child: const Text('Guardar'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AddVehicleForm extends StatefulWidget {
  final VoidCallback onCancel;
  final VoidCallback onSaved;
  const _AddVehicleForm({required this.onCancel, required this.onSaved, Key? key}) : super(key: key);

  @override
  State<_AddVehicleForm> createState() => _AddVehicleFormState();
}

class _AddVehicleFormState extends State<_AddVehicleForm> {
  final _brandController = TextEditingController();
  final _yearController = TextEditingController();
  final _colorController = TextEditingController();
  final _platesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ResidentProvider>(context, listen: false);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Nuevo Automóvil', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          CustomTextField(label: 'Marca', controller: _brandController),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: CustomTextField(label: 'Año', controller: _yearController, keyboardType: TextInputType.number)),
              const SizedBox(width: 12),
              Expanded(child: CustomTextField(label: 'Color', controller: _colorController)),
            ],
          ),
          const SizedBox(height: 12),
          CustomTextField(label: 'Placas', controller: _platesController),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: widget.onCancel, child: const Text('Cancelar')),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  if (_brandController.text.isEmpty || _platesController.text.isEmpty) {
                    UIUtils.showSnackBar(context, 'Complete los campos obligatorios');
                    return;
                  }
                  final newCar = CarInfo(
                    brand: _brandController.text,
                    year: _yearController.text,
                    color: _colorController.text,
                    plates: _platesController.text,
                  );
                  final success = await provider.addVehicle(newCar);
                  if (mounted) {
                    UIUtils.showSnackBar(context, success ? 'Automóvil agregado' : 'Error al guardar', isError: !success);
                    if (success) widget.onSaved();
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}