import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/resident_provider.dart';
import '../../../data/providers/finance_provider.dart';
import '../../widgets/resident/payment_card.dart';
import '../../widgets/common/custom_button.dart';

class PaymentHistoryScreen extends StatefulWidget {
  final String? residentId;
  const PaymentHistoryScreen({Key? key, this.residentId}) : super(key: key);

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  String? _selectedMonth;
  String? _selectedYear;
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
  }

  void _loadPayments() {
    if (_selectedMonth == null || _selectedYear == null) return;

    setState(() => _showResults = true);

    final id = widget.residentId ??
        Provider.of<AuthProvider>(context, listen: false).currentUser?.id ??
        '';
    Provider.of<ResidentProvider>(context, listen: false)
        .loadResidentData(id);
  }

  @override
  Widget build(BuildContext context) {
    final residentProvider = Provider.of<ResidentProvider>(context);
    final financeProvider = Provider.of<FinanceProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Pagos')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Selecciona el periodo',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                        labelText: 'Mes', border: OutlineInputBorder()),
                    value: _selectedMonth,
                    items: financeProvider.months
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (v) => setState(() {
                      _selectedMonth = v;
                      _showResults = false;
                    }),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                        labelText: 'Año', border: OutlineInputBorder()),
                    value: _selectedYear,
                    items: financeProvider.years
                        .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                        .toList(),
                    onChanged: (v) => setState(() {
                      _selectedYear = v;
                      _showResults = false;
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Ver mis pagos del periodo seleccionado',
              onPressed: (_selectedMonth != null && _selectedYear != null)
                  ? _loadPayments
                  : null,
            ),
            if (_showResults) ...[
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Pagos de $_selectedMonth $_selectedYear',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (residentProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (residentProvider.payments.isEmpty)
                const Center(child: Text('Sin pagos registrados en este periodo'))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: residentProvider.payments.length,
                  itemBuilder: (_, i) =>
                      PaymentCard(payment: residentProvider.payments[i]),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
