import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/ui_utils.dart';
import '../../../data/providers/admin_provider.dart';
import '../../../data/models/user_model.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/phone_input_field.dart';

class AdminProfilesScreen extends StatefulWidget {
  const AdminProfilesScreen({super.key});

  static Future<bool?> showPasswordDialog(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Seguridad requerida'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ingrese su contraseña para continuar'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final adminProvider = Provider.of<AdminProvider>(context, listen: false);
              final valid = await adminProvider.verifyPassword(controller.text);
              if (valid && context.mounted) {
                Navigator.pop(context, true);
              } else {
                if (context.mounted) {
                  UIUtils.showSnackBar(context, 'Contraseña incorrecta');
                }
              }
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  @override
  State<AdminProfilesScreen> createState() => _AdminProfilesScreenState();
}

class _AdminProfilesScreenState extends State<AdminProfilesScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<AdminProvider>(context, listen: false).fetchUsers());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Perfiles'),
      ),
      body: Column(
        children: [
          _buildTabs(),
          Expanded(
            child: _currentIndex == 0
                ? const _NewProfileTab()
                : const _ModifyProfileTab(),
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
          _tabItem('Nuevo perfil', 0),
          _tabItem('Modificar perfil', 1),
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
                color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}

class _NewProfileTab extends StatefulWidget {
  const _NewProfileTab({super.key});

  @override
  State<_NewProfileTab> createState() => _NewProfileTabState();
}

class _NewProfileTabState extends State<_NewProfileTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _unitNumberController = TextEditingController();
  String _fullPhoneNumber = '';
  String _selectedRole = AppConstants.roleResident;
  bool _livesInCondo = true;

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _unitNumberController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _nameController.clear();
    _lastNameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _phoneController.clear();
    _unitNumberController.clear();
    setState(() {
      _selectedRole = AppConstants.roleResident;
      _livesInCondo = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              label: 'Nombres',
              controller: _nameController,
              validator: (v) => v?.isEmpty == true ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              label: 'Apellidos',
              controller: _lastNameController,
              validator: (v) => v?.isEmpty == true ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 12),
            PhoneInputField(
              label: 'Teléfono',
              controller: _phoneController,
              onFullNumberChanged: (full) => _fullPhoneNumber = full,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              label: 'Correo',
              controller: _emailController,
              validator: (v) => v?.isEmpty == true ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              label: 'Contraseña',
              controller: _passwordController,
              obscureText: true,
              validator: (v) => v?.isEmpty == true ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedRole,
              decoration: const InputDecoration(
                labelText: 'Perfil',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: AppConstants.roleAdmin, child: Text('Administrador')),
                DropdownMenuItem(value: AppConstants.roleResident, child: Text('Residente')),
                DropdownMenuItem(value: AppConstants.roleGuard, child: Text('Vigilante')),
              ],
              onChanged: (v) => setState(() => _selectedRole = v ?? AppConstants.roleResident),
            ),
            if (_selectedRole != AppConstants.roleGuard) ...[
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('¿Vive en el condominio?'),
                value: _livesInCondo,
                onChanged: (v) => setState(() => _livesInCondo = v),
              ),
            ],
            if (_selectedRole == AppConstants.roleResident || (_selectedRole == AppConstants.roleAdmin && _livesInCondo)) ...[
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Número de Casa',
                controller: _unitNumberController,
                hint: 'Ej. 212-A o S/N',
                validator: (v) => ((_selectedRole == AppConstants.roleResident || (_selectedRole == AppConstants.roleAdmin && _livesInCondo)) && (v == null || v.isEmpty))
                  ? 'El número de casa es requerido'
                  : null,
              ),
            ],
            const SizedBox(height: 24),
            CustomButton(
              text: 'Crear Perfil',
              isLoading: adminProvider.isLoading,
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirmar creación'),
                    content: const Text('¿Desea crear este nuevo perfil?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirmar')),
                    ],
                  ),
                );
                
                if (confirmed != true) return;

                final success = await adminProvider.createProfile(
                  email: _emailController.text.trim(),
                  password: _passwordController.text,
                  name: _nameController.text.trim(),
                  lastName: _lastNameController.text.trim(),
                  role: _selectedRole,
                  birthDate: DateTime.now(), 
                  age: 0, 
                  phone: _fullPhoneNumber.isNotEmpty ? _fullPhoneNumber : _phoneController.text.trim(),
                  unitNumber: (_selectedRole == AppConstants.roleResident || (_selectedRole == AppConstants.roleAdmin && _livesInCondo)) ? _unitNumberController.text.trim() : null,
                  livesInCondo: _livesInCondo,
                );
                if (success && mounted) {
                  UIUtils.showSnackBar(context, 'Perfil creado exitosamente', isError: false);
                  _clearForm();
                } else if (!mounted) {
                  return;
                } else {
                  UIUtils.showSnackBar(context, adminProvider.errorMessage ?? 'Error al crear el perfil');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ModifyProfileTab extends StatelessWidget {
  const _ModifyProfileTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);

    if (adminProvider.isLoading && adminProvider.users.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: adminProvider.users.length,
      itemBuilder: (context, index) {
        final user = adminProvider.users[index];
        return _UserCard(
          key: ValueKey(user.id),
          user: user,
        );
      },
    );
  }
}

class _UserCard extends StatefulWidget {
  final UserModel user;
  const _UserCard({required this.user, Key? key}) : super(key: key);

  @override
  State<_UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<_UserCard> {
  bool _isEditing = false;
  bool _isOnDutyCheck = false;
  bool _livesInCondoCheck = true;
  final _newPasswordController = TextEditingController();
  final _unitNumberController = TextEditingController();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String _fullPhoneNumber = '';
  String _editingRole = AppConstants.roleResident;

  @override
  void initState() {
    super.initState();
    _isOnDutyCheck = widget.user.isOnDuty;
    _livesInCondoCheck = widget.user.livesInCondo;
    _unitNumberController.text = widget.user.unitNumber ?? '';
    _nameController.text = widget.user.name;
    _lastNameController.text = widget.user.lastName;
    _emailController.text = widget.user.email;
    _phoneController.text = widget.user.phone ?? '';
    _fullPhoneNumber = widget.user.phone ?? '';
    _editingRole = widget.user.role;
  }

  @override
  void didUpdateWidget(_UserCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.user != oldWidget.user && !_isEditing) {
      _isOnDutyCheck = widget.user.isOnDuty;
      _livesInCondoCheck = widget.user.livesInCondo;
      _unitNumberController.text = widget.user.unitNumber ?? '';
      _nameController.text = widget.user.name;
      _lastNameController.text = widget.user.lastName;
      _emailController.text = widget.user.email;
      _phoneController.text = widget.user.phone ?? '';
      _fullPhoneNumber = widget.user.phone ?? '';
      _editingRole = widget.user.role;
    }
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _unitNumberController.dispose();
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${widget.user.name} ${widget.user.lastName}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text('Perfil: ${widget.user.role}',
                              style: TextStyle(color: Colors.grey[600])),
                          if ((widget.user.role == AppConstants.roleResident || widget.user.role == AppConstants.roleAdmin) && widget.user.unitNumber != null) ...[
                            const SizedBox(width: 8),
                            Text('| Casa: ${widget.user.unitNumber}',
                                style: TextStyle(color: Colors.grey[600])),
                          ],
                          if (widget.user.role == AppConstants.roleGuard) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: widget.user.isOnDuty ? Colors.green.withValues(alpha: 0.1) : Colors.grey[200],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                widget.user.isOnDuty ? widget.user.shiftName : 'Fuera de turno',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: widget.user.isOnDuty ? Colors.green[800] : Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (widget.user.email.isNotEmpty)
                        Text('Correo: ${widget.user.email}', 
                            style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      if (widget.user.phone != null && widget.user.phone!.isNotEmpty)
                        Text('Tel: ${widget.user.phone}', 
                            style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      if (widget.user.role != AppConstants.roleGuard)
                        Text('¿Vive en el condominio?: ${widget.user.livesInCondo ? "Sí" : "No"}',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => setState(() => _isEditing = !_isEditing),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(context, adminProvider),
                    ),
                  ],
                ),
              ],
            ),
            if (_isEditing) ...[
              const Divider(),
              CustomTextField(
                label: 'Nombres',
                controller: _nameController,
              ),
              const SizedBox(height: 8),
              CustomTextField(
                label: 'Apellidos',
                controller: _lastNameController,
              ),
              const SizedBox(height: 8),
              CustomTextField(
                label: 'Correo',
                controller: _emailController,
              ),
              const SizedBox(height: 8),
              PhoneInputField(
                label: 'Teléfono',
                controller: _phoneController,
                onFullNumberChanged: (full) => _fullPhoneNumber = full,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _editingRole,
                decoration: const InputDecoration(
                  labelText: 'Perfil',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: AppConstants.roleAdmin, child: Text('Administrador')),
                  DropdownMenuItem(value: AppConstants.roleResident, child: Text('Residente')),
                  DropdownMenuItem(value: AppConstants.roleGuard, child: Text('Vigilante')),
                ],
                onChanged: (v) => setState(() => _editingRole = v ?? _editingRole),
              ),
              const SizedBox(height: 8),
              if (_editingRole == AppConstants.roleGuard)
                SwitchListTile(
                  title: const Text('En turno'),
                  subtitle: Text(_isOnDutyCheck ? 'Vigilante activo (${widget.user.shiftName})' : 'Vigilante inactivo'),
                  value: _isOnDutyCheck,
                  onChanged: (v) => setState(() => _isOnDutyCheck = v),
                ),
              if (_editingRole != AppConstants.roleGuard)
                SwitchListTile(
                  title: const Text('¿Vive en el condominio?'),
                  value: _livesInCondoCheck,
                  onChanged: (v) => setState(() => _livesInCondoCheck = v),
                ),
              if (_editingRole == AppConstants.roleResident || (_editingRole == AppConstants.roleAdmin && _livesInCondoCheck)) ...[
                const SizedBox(height: 8),
                CustomTextField(
                  label: 'Número de Casa',
                  controller: _unitNumberController,
                  hint: 'Modificar número de casa',
                ),
              ],
              const SizedBox(height: 8),
              CustomTextField(
                label: 'Actualizar Contraseña',
                controller: _newPasswordController,
                obscureText: true,
                hint: 'Dejar vacío para no cambiar',
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => setState(() => _isEditing = false),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () => _handleSave(context, adminProvider),
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

  Future<void> _handleSave(BuildContext context, AdminProvider adminProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar cambios'),
        content: const Text('¿Desea guardar los cambios en este perfil?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirmar')),
        ],
      ),
    );

    if (confirmed != true) return;

    // 1. Password Update Logic
    if (_newPasswordController.text.isNotEmpty) {
      final passConfirmed = await AdminProfilesScreen.showPasswordDialog(context);
      if (passConfirmed == true) {
        final passSuccess = await adminProvider.adminUpdatePassword(widget.user.id, _newPasswordController.text);
        if (context.mounted) {
          UIUtils.showSnackBar(
            context, 
            passSuccess ? 'Contraseña actualizada' : 'Error al actualizar contraseña',
            isError: !passSuccess
          );
        }
      } else {
        return; 
      }
    }

    // 2. Full Profile Update
    final success = await adminProvider.updateFullProfile(
      userId: widget.user.id,
      name: _nameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _fullPhoneNumber.isNotEmpty ? _fullPhoneNumber : _phoneController.text.trim(),
      role: _editingRole,
      livesInCondo: _livesInCondoCheck,
      unitNumber: (_editingRole == AppConstants.roleResident || (_editingRole == AppConstants.roleAdmin && _livesInCondoCheck)) 
          ? _unitNumberController.text.trim() 
          : null,
    );

    if (success) {
      setState(() => _isEditing = false);
      if (context.mounted) {
        UIUtils.showSnackBar(context, 'Perfil actualizado exitosamente', isError: false);
      }
    } else {
      if (context.mounted) {
        UIUtils.showSnackBar(context, adminProvider.errorMessage ?? 'Error al actualizar el perfil');
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context, AdminProvider adminProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar perfil'),
        content: const Text('¿Está seguro de que desea eliminar este perfil?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context, true);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await adminProvider.deleteUser(widget.user.id);
      if (success && context.mounted) {
        UIUtils.showSnackBar(context, 'Perfil eliminado', isError: false);
      }
    }
  }
}
