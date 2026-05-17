import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/providers/admin_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/models/user_model.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class AdminProfilesScreen extends StatefulWidget {
  const AdminProfilesScreen({Key? key}) : super(key: key);

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
              if (valid) {
                Navigator.pop(context, true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Contraseña incorrecta')),
                );
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
  const _NewProfileTab({Key? key}) : super(key: key);

  @override
  State<_NewProfileTab> createState() => _NewProfileTabState();
}

class _NewProfileTabState extends State<_NewProfileTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTime? _birthDate;
  String _selectedRole = AppConstants.roleResident;

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _nameController.clear();
    _lastNameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _ageController.clear();
    _phoneController.clear();
    setState(() {
      _birthDate = null;
      _selectedRole = AppConstants.roleResident;
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
            CustomTextField(
              label: 'Teléfono',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              validator: (v) => v?.isEmpty == true ? 'Campo requerido' : null,
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
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() => _birthDate = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Fecha de nacimiento',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(_birthDate == null 
                        ? 'Seleccionar' 
                        : '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    label: 'Edad',
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    validator: (v) => v?.isEmpty == true ? 'Campo requerido' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: const InputDecoration(
                labelText: 'Perfil',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: AppConstants.roleAdmin, child: Text('Administrador')),
                DropdownMenuItem(value: AppConstants.roleResident, child: Text('Residente')),
                DropdownMenuItem(value: AppConstants.roleGuard, child: Text('Vigilante')),
              ],
              onChanged: (v) => setState(() => _selectedRole = v!),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Crear Perfil',
              isLoading: adminProvider.isLoading,
              onPressed: () async {
                if (!_formKey.currentState!.validate() || _birthDate == null) return;
                final success = await adminProvider.createProfile(
                  email: _emailController.text,
                  password: _passwordController.text,
                  name: _nameController.text,
                  lastName: _lastNameController.text,
                  role: _selectedRole,
                  birthDate: _birthDate!,
                  age: int.parse(_ageController.text),
                  phone: _phoneController.text,
                );
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Perfil creado exitosamente')),
                  );
                  _clearForm();
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
        return _UserCard(user: user);
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
  bool _isAdminCheck = false;
  bool _isOnDutyCheck = false;

  @override
  void initState() {
    super.initState();
    _isOnDutyCheck = widget.user.isOnDuty;
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
                      Row(
                        children: [
                          Text('Perfil: ${widget.user.role}',
                              style: TextStyle(color: Colors.grey[600])),
                          if (widget.user.role == AppConstants.roleGuard) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: widget.user.isOnDuty ? Colors.green[100] : Colors.grey[200],
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
                      if (widget.user.phone != null && widget.user.phone!.isNotEmpty)
                        Text('Tel: ${widget.user.phone}', 
                            style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
                Row(
                  children: [
                    if (widget.user.role == AppConstants.roleResident || 
                        widget.user.role == AppConstants.roleGuard)
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
              if (widget.user.role == AppConstants.roleResident)
                CheckboxListTile(
                  title: const Text('Convertir en Administrador'),
                  value: _isAdminCheck,
                  onChanged: (v) => setState(() => _isAdminCheck = v!),
                ),
              if (widget.user.role == AppConstants.roleGuard)
                SwitchListTile(
                  title: const Text('En turno'),
                  subtitle: Text(_isOnDutyCheck ? 'Vigilante activo (${widget.user.shiftName})' : 'Vigilante inactivo'),
                  value: _isOnDutyCheck,
                  onChanged: (v) => setState(() => _isOnDutyCheck = v!),
                ),
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
    if (widget.user.role == AppConstants.roleGuard) {
      await adminProvider.updateDutyStatus(widget.user.id, _isOnDutyCheck);
      setState(() => _isEditing = false);
      return;
    }

    if (!_isAdminCheck) {
      setState(() => _isEditing = false);
      return;
    }

    final confirmed = await _showConfirmationDialog(context);
    if (confirmed == true) {
      final passConfirmed = await AdminProfilesScreen.showPasswordDialog(context);
      if (passConfirmed == true) {
        await adminProvider.updateUserRole(widget.user.id, AppConstants.roleAdmin);
        
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final currentUserId = authProvider.currentUser?.id;
        if (currentUserId != null) {
          await adminProvider.updateUserRole(currentUserId, AppConstants.roleResident);
        }
        await authProvider.logout();
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(context, AppConstants.routeLogin, (route) => false);
        }
      }
    }
  }

  Future<bool?> _showConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar cambio'),
        content: const Text('¿Está seguro de que desea asignar el perfil de administrador?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sí')),
        ],
      ),
    );
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
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await adminProvider.deleteUser(widget.user.id);
    }
  }
}