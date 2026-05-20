import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../../../data/providers/finance_provider.dart';
import '../../widgets/common/custom_button.dart';

class ViewReportsScreen extends StatefulWidget {
  const ViewReportsScreen({super.key});

  @override
  State<ViewReportsScreen> createState() => _ViewReportsScreenState();
}

class _ViewReportsScreenState extends State<ViewReportsScreen> {
  String? _selectedMonth;
  String? _selectedYear;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
  }

  void _fetchData() {
    if (_selectedMonth != null && _selectedYear != null) {
      Provider.of<FinanceProvider>(context, listen: false).fetchMonthlyData(_selectedMonth!, _selectedYear!);
    }
  }

  double get _totalIncomes => Provider.of<FinanceProvider>(context, listen: false).monthlyIncomes.fold(0, (sum, item) => sum + item.amount);
  double get _totalExpenses => Provider.of<FinanceProvider>(context, listen: false).monthlyExpenses.fold(0, (sum, item) => sum + item.amount);
  double get _balance => _totalIncomes - _totalExpenses;

  Future<void> _generateAndSharePDF() async {
    if (_selectedMonth == null || _selectedYear == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor selecciona mes y año')));
      return;
    }

    setState(() => _isGenerating = true);
    final financeProvider = Provider.of<FinanceProvider>(context, listen: false);

    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Text('Reporte Mensual de Finanzas - Condominio App',
                      style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                ),
                pw.SizedBox(height: 10),
                pw.Text('Periodo: $_selectedMonth $_selectedYear'),
                pw.SizedBox(height: 20),
                pw.Text('INGRESOS (PAGOS APROBADOS)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Divider(),
                ...financeProvider.monthlyIncomes.map((i) => pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('${i.residentName ?? 'Residente'} - ${i.description ?? 'Cuota'}'),
                    pw.Text('\$${i.amount.toStringAsFixed(2)}'),
                  ],
                )),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Total Ingresos:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('\$${_totalIncomes.toStringAsFixed(2)}',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 30),
                pw.Text('EGRESOS', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Divider(),
                ...financeProvider.monthlyExpenses.map((e) => pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(e.concept),
                    pw.Text('\$${e.amount.toStringAsFixed(2)}'),
                  ],
                )),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Total Egresos:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('\$${_totalExpenses.toStringAsFixed(2)}',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 30),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.grey200,
                    borderRadius: pw.BorderRadius.all(pw.Radius.circular(5)),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('BALANCE FINAL:',
                          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      pw.Text('\$${_balance.toStringAsFixed(2)}',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: _balance >= 0 ? PdfColors.green : PdfColors.red,
                          )),
                    ],
                  ),
                ),
                pw.Footer(
                  margin: const pw.EdgeInsets.only(top: 50),
                  trailing: pw.Text('Generado el ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}'),
                ),
              ],
            );
          },
        ),
      );

      final output = await getTemporaryDirectory();
      final file = File("${output.path}/Reporte_${_selectedMonth}_$_selectedYear.pdf");
      await file.writeAsBytes(await pdf.save());

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Hola, te comparto el reporte financiero de $_selectedMonth $_selectedYear.',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al generar PDF: $e')));
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final financeProvider = Provider.of<FinanceProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Reportes Financieros')),
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
                    decoration: const InputDecoration(labelText: 'Mes', border: OutlineInputBorder()),
                    initialValue: _selectedMonth,
                    items: financeProvider.months.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                    onChanged: (v) {
                      setState(() => _selectedMonth = v);
                      _fetchData();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Año', border: OutlineInputBorder()),
                    initialValue: _selectedYear,
                    items: financeProvider.years.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
                    onChanged: (v) {
                      setState(() => _selectedYear = v);
                      _fetchData();
                    },
                  ),
                ),
              ],
            ),
            if (_selectedMonth != null && _selectedYear != null) ...[
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              if (financeProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else ...[
                Text(
                  'Resumen de $_selectedMonth $_selectedYear',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                _buildSummaryCard(),
                const SizedBox(height: 32),
                CustomButton(
                  text: 'Enviar reporte por WhatsApp (PDF)',
                  onPressed: _generateAndSharePDF,
                  isLoading: _isGenerating,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSummaryRow('Ingresos Totales', _totalIncomes, Colors.green),
            const SizedBox(height: 12),
            _buildSummaryRow('Egresos Totales', _totalExpenses, Colors.red),
            const Divider(height: 32),
            _buildSummaryRow('Balance Neto', _balance, _balance >= 0 ? Colors.blue : Colors.red, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, Color color, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}