import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/finance_provider.dart';
import '../../../data/providers/resident_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/image_picker_widget.dart';

class UploadPaymentScreen extends StatefulWidget {
  const UploadPaymentScreen({super.key});

  @override
  State<UploadPaymentScreen> createState() => _UploadPaymentScreenState();
}

class _UploadPaymentScreenState extends State<UploadPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedMonth;
  String? _selectedYear;
  File? _selectedImage;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor adjunta el comprobante')));
      return;
    }
    if (_selectedMonth == null || _selectedYear == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona el periodo del pago')));
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final financeProvider = Provider.of<FinanceProvider>(context, listen: false);
    final residentProvider = Provider.of<ResidentProvider>(context, listen: false);

    // Ensure resident data is loaded to get the correct resident_id
    if (residentProvider.resident == null || residentProvider.resident!.id.isEmpty) {
      await residentProvider.loadResidentData(authProvider.currentUser!.id);
    }

    if (residentProvider.resident == null || residentProvider.resident!.id.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('No se pudo encontrar el ID de residente. Contacta al administrador.'),
          backgroundColor: Colors.red,
        ));
      }
      return;
    }

    final success = await financeProvider.registerPayment(
      residentId: residentProvider.resident!.id,
      amount: double.parse(_amountController.text),
      month: _selectedMonth!,
      year: _selectedYear!,
      image: _selectedImage,
      description: _descriptionController.text.trim(),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success ? 'Comprobante subido exitosamente' : 'Error al subir comprobante'),
        backgroundColor: success ? Colors.green : Colors.red,
      ));
      if (success) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final financeProvider = Provider.of<FinanceProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Subir Comprobante')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Imagen del Comprobante', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              ImagePickerWidget(
                selectedImage: _selectedImage,
                onImageSelected: (file) => setState(() => _selectedImage = file),
              ),
              const SizedBox(height: 24),
              const Text('Detalles del Pago', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Mes', border: OutlineInputBorder()),
                      initialValue: _selectedMonth,
                      items: financeProvider.months.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                      onChanged: (v) => setState(() => _selectedMonth = v),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Año', border: OutlineInputBorder()),
                      initialValue: _selectedYear,
                      items: financeProvider.years.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
                      onChanged: (v) => setState(() => _selectedYear = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Monto pagado',
                controller: _amountController,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.attach_money),
                validator: (v) => (v == null || v.isEmpty) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Descripción (Opcional)',
                controller: _descriptionController,
                maxLines: 2,
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Enviar Comprobante',
                onPressed: _submit,
                isLoading: financeProvider.isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
