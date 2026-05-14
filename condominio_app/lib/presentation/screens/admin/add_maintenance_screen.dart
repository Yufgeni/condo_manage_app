import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../data/models/maintenance_model.dart';
import '../../../data/providers/maintenance_provider.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';

class AddMaintenanceScreen extends StatefulWidget {
  const AddMaintenanceScreen({Key? key}) : super(key: key);

  @override
  State<AddMaintenanceScreen> createState() => _AddMaintenanceScreenState();
}

class _AddMaintenanceScreenState extends State<AddMaintenanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final conceptController = TextEditingController();
  final amountController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  @override
  void dispose() {
    conceptController.dispose();
    amountController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final record = MaintenanceModel(
        id: DateTime.now().toString(),
        concept: conceptController.text,
        amount: double.tryParse(amountController.text) ?? 0,
        date: selectedDate,
      );
      Provider.of<MaintenanceProvider>(context, listen: false).addRecord(record);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Nuevo Gasto de Mantenimiento'),
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
                'Detalles del Pago',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
              ),
              const SizedBox(height: 15),
              CustomTextField(
                label: 'Concepto',
                controller: conceptController,
                prefixIcon: const Icon(Icons.description_outlined),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Monto',
                controller: amountController,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.attach_money_outlined),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => selectedDate = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, color: Colors.grey),
                      const SizedBox(width: 12),
                      Text(
                        'Fecha: ${DateFormat('dd/MM/yyyy').format(selectedDate)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              CustomButton(
                text: 'Guardar Registro',
                onPressed: _save,
                color: Colors.orange,
              ),
            ],
          ),
        ),
      ),
    );
  }
}