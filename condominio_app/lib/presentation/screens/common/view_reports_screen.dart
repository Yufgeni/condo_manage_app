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
  double get _previousBalance => Provider.of<FinanceProvider>(context, listen: false).previousBalance;
  double get _balance => _totalIncomes - _totalExpenses;
  double get _finalBalance => _previousBalance + _balance;

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
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          header: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('PRIVADA ACACIAS',
                            style: pw.TextStyle(
                              fontSize: 24,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blue900,
                            )),
                        pw.Text('Reporte Financiero Mensual',
                            style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Periodo:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('$_selectedMonth $_selectedYear', style: const pw.TextStyle(fontSize: 16)),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Divider(thickness: 2, color: PdfColors.blue900),
                pw.SizedBox(height: 20),
              ],
            );
          },
          footer: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Generado el ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}'),
                    pw.Text('Página ${context.pageNumber} de ${context.pagesCount}'),
                  ],
                ),
              ],
            );
          },
          build: (pw.Context context) {
            return [
              // --- RESUMEN EJECUTIVO ---
              pw.Text('Resumen Ejecutivo', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 12),
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  children: [
                    _pdfSummaryRow('Saldo Mes Anterior:', _previousBalance, isImportant: true),
                    pw.SizedBox(height: 8),
                    _pdfSummaryRow('(+) Ingresos del Mes:', _totalIncomes, color: PdfColors.green),
                    _pdfSummaryRow('(-) Egresos del Mes:', _totalExpenses, color: PdfColors.red),
                    pw.Divider(),
                    _pdfSummaryRow('SALDO FINAL ACUMULADO:', _finalBalance, 
                        isBold: true, 
                        fontSize: 16,
                        color: _finalBalance >= 0 ? PdfColors.blue900 : PdfColors.red900),
                  ],
                ),
              ),

              pw.SizedBox(height: 30),

              // --- DETALLE DE INGRESOS ---
              pw.Text('Detalle de Ingresos', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(1),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.blue50),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Concepto / Residente', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Monto', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
                      ),
                    ],
                  ),
                  ...financeProvider.monthlyIncomes.map((i) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('${i.residentName ?? 'Residente'} - ${i.description ?? 'Cuota'}'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('\$${i.amount.toStringAsFixed(2)}', textAlign: pw.TextAlign.right),
                      ),
                    ],
                  )),
                ],
              ),

              pw.SizedBox(height: 30),

              // --- DETALLE DE EGRESOS ---
              pw.Text('Detalle de Egresos', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(1),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.red50),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Concepto', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Monto', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
                      ),
                    ],
                  ),
                  ...financeProvider.monthlyExpenses.map((e) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(e.concept),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('\$${e.amount.toStringAsFixed(2)}', textAlign: pw.TextAlign.right),
                      ),
                    ],
                  )),
                ],
              ),
            ];
          },
        ),
      );

      final output = await getTemporaryDirectory();
      final file = File("${output.path}/Reporte_Financiero_Acacias_${_selectedMonth}_$_selectedYear.pdf");
      await file.writeAsBytes(await pdf.save());

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Hola, te comparto el reporte financiero de Privada Acacias para el periodo $_selectedMonth $_selectedYear.',
      );
    } catch (e) {
      debugPrint('Error al generar PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al generar PDF: $e')));
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  pw.Widget _pdfSummaryRow(String label, double amount, {PdfColor? color, bool isImportant = false, bool isBold = false, double fontSize = 12}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(
            fontSize: fontSize,
            fontWeight: isBold || isImportant ? pw.FontWeight.bold : pw.FontWeight.normal,
          )),
          pw.Text('\$${amount.toStringAsFixed(2)}', style: pw.TextStyle(
            fontSize: fontSize,
            fontWeight: pw.FontWeight.bold,
            color: color ?? PdfColors.black,
          )),
        ],
      ),
    );
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
            _buildSummaryRow('Saldo Mes Anterior', _previousBalance, Colors.blueGrey),
            const SizedBox(height: 8),
            _buildSummaryRow('Ingresos del Mes', _totalIncomes, Colors.green),
            _buildSummaryRow('Egresos del Mes', _totalExpenses, Colors.red),
            const Divider(height: 32),
            _buildSummaryRow('Saldo Final Acumulado', _finalBalance, 
                _finalBalance >= 0 ? Colors.blue : Colors.red, 
                isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, Color color, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
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
