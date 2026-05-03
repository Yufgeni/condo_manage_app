class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'El correo es requerido';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Correo inválido';
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'La contraseña es requerida';
    if (value.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) return '$fieldName es requerido';
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'El teléfono es requerido';
    final phoneRegex = RegExp(r'^\d{10}$');
    if (!phoneRegex.hasMatch(value)) return 'Teléfono inválido (10 dígitos)';
    return null;
  }
}