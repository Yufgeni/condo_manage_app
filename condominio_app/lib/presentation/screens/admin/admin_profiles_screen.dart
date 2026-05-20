import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/ui_utils.dart';
import '../../../data/providers/admin_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/models/user_model.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

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
              if (valid) {
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
  final _phoneController = TextEditingController();
  String _selectedRole = AppConstants.roleResident;

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _nameController.clear();
    _lastNameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _phoneController.clear();
    setState(() {
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
                  phone: _phoneController.text.trim(),
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
  final _newPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isOnDutyCheck = widget.user.isOnDuty;
    _isAdminCheck = widget.user.role == AppConstants.roleAdmin;
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
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
                      Row(
                        children: [
                          Text('Perfil: ${widget.user.role}',
                              style: TextStyle(color: Colors.grey[600])),
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
                      if (widget.user.phone != null && widget.user.phone!.isNotEmpty)
                        Text('Tel: ${widget.user.phone}', 
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

    // Password Update Logic
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

    // Role Update Logic (Resident -> Admin)
    if (widget.user.role == AppConstants.roleResident && _isAdminCheck) {
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
          return;
        }
      } else {
        return;
      }
    }

    // Duty Status Logic (Guard)
    if (widget.user.role == AppConstants.roleGuard) {
      await adminProvider.updateDutyStatus(widget.user.id, _isOnDutyCheck);
    }

    setState(() => _isEditing = false);
    if (context.mounted) {
      UIUtils.showSnackBar(context, 'Perfil actualizado exitosamente', isError: false);
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
