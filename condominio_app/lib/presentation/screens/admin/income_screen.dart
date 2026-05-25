import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/income_model.dart';
import '../../../data/models/resident_model.dart';
import '../../../data/providers/finance_provider.dart';
import '../../../data/providers/resident_provider.dart';
import '../../../core/utils/validators.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedMonth;
  String? _selectedYear;
  ResidentModel? _selectedResident;
  String? _selectedConcept;
  final _customConceptController = TextEditingController();
  final _amountController = TextEditingController();
  bool _showCustomConcept = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ResidentProvider>(context, listen: false).fetchAllResidents();
      Provider.of<FinanceProvider>(context, listen: false).fetchConcepts();
    });
  }

  void _onRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMonth == null || _selectedYear == null || _selectedResident == null || _selectedConcept == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    final financeProvider = Provider.of<FinanceProvider>(context, listen: false);

    String concept;
    if (_showCustomConcept) {
      concept = _customConceptController.text.trim();
      await financeProvider.addConcept(concept, 'income');
    } else {
      concept = _selectedConcept!;
    }

    final income = IncomeModel(
      id: '',
      residentId: _selectedResident!.id,
      residentName: _selectedResident!.name,
      month: _selectedMonth!,
      year: _selectedYear!,
      concept: concept,
      amount: double.tryParse(_amountController.text) ?? 0.0,
      date: DateTime.now(),
    );

    final success = await financeProvider.registerIncome(income);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pago registrado exitosamente'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al registrar pago'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final financeProvider = Provider.of<FinanceProvider>(context);
    final residentProvider = Provider.of<ResidentProvider>(context);
    final residents = residentProvider.allResidents;

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Ingreso')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Periodo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
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
              const SizedBox(height: 24),
              if (_selectedMonth != null && _selectedYear != null) ...[
                const Text('Detalles del Pago', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                DropdownButtonFormField<ResidentModel>(
                  decoration: const InputDecoration(labelText: 'Residente', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
                  value: _selectedResident,
                  items: residents.map((r) => DropdownMenuItem(value: r, child: Text('${r.name} (${r.unitNumber})'))).toList(),
                  onChanged: (v) => setState(() {
                    _selectedResident = v;
                    print('Residente seleccionado: ${v?.name}, ID: ${v?.id}');
                  }),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Concepto', border: OutlineInputBorder(), prefixIcon: Icon(Icons.list)),
                  value: _selectedConcept,
                  items: [
                    ...financeProvider.incomeConcepts.map((c) => DropdownMenuItem(value: c, child: Text(c))),
                    const DropdownMenuItem(value: 'ADD_NEW', child: Text('+ Añadir concepto')),
                  ],
                  onChanged: (v) {
                    setState(() {
                      _selectedConcept = v;
                      _showCustomConcept = v == 'ADD_NEW';
                    });
                  },
                ),
                if (_showCustomConcept) ...[
                  const SizedBox(height: 12),
                  CustomTextField(
                    label: 'Nuevo concepto',
                    controller: _customConceptController,
                    onChanged: (v) => setState(() {}),
                    validator: (v) => _showCustomConcept ? Validators.validateRequired(v, 'Concepto') : null,
                  ),
                ],
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Monto',
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.attach_money),
                  onChanged: (v) => setState(() {}),
                  validator: (v) {
                    final res = Validators.validateRequired(v, 'Monto');
                    if (res != null) return res;
                    if (double.tryParse(v!) == null) return 'Monto inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: 'Registrar Pago',
                  onPressed: (_selectedResident != null &&
                             (_selectedConcept != null && (_selectedConcept != 'ADD_NEW' || _customConceptController.text.isNotEmpty)) &&
                             _amountController.text.isNotEmpty)
                             ? _onRegister : null,
                  isLoading: financeProvider.isLoading,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
