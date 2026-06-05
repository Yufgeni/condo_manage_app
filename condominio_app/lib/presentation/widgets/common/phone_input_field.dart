import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

class PhoneInputField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final void Function(String)? onFullNumberChanged;

  const PhoneInputField({
    super.key,
    required this.controller,
    required this.label,
    this.onFullNumberChanged,
  });

  @override
  State<PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<PhoneInputField> {
  String _initialCountryCode = 'MX';

  @override
  void initState() {
    super.initState();
    _parseInitialValue();
  }

  void _parseInitialValue() {
    String currentText = widget.controller.text;
    
    // Si el número ya viene con formato internacional, intentamos detectar el país
    if (currentText.startsWith('+')) {
      if (currentText.startsWith('+52')) {
        _initialCountryCode = 'MX';
        widget.controller.text = currentText.substring(3);
      } else if (currentText.startsWith('+57')) {
        _initialCountryCode = 'CO';
        widget.controller.text = currentText.substring(3);
      } else if (currentText.startsWith('+1')) {
        _initialCountryCode = 'US';
        widget.controller.text = currentText.substring(2);
      } else if (currentText.startsWith('+34')) {
        _initialCountryCode = 'ES';
        widget.controller.text = currentText.substring(3);
      }
      // Se pueden agregar más códigos según sea necesario o usar una librería de parsing
    }
  }

  @override
  Widget build(BuildContext context) {
    return IntlPhoneField(
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: widget.label,
        border: const OutlineInputBorder(
          borderSide: BorderSide(),
        ),
      ),
      initialCountryCode: _initialCountryCode,
      languageCode: "es",
      invalidNumberMessage: 'Número de teléfono inválido',
      searchText: "Buscar país",
      onChanged: (phone) {
        if (widget.onFullNumberChanged != null) {
          widget.onFullNumberChanged!(phone.completeNumber);
        }
      },
    );
  }
}
