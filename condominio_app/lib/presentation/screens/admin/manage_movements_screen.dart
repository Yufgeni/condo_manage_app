import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/finance_provider.dart';

class ManageMovementsScreen extends StatefulWidget {
  const ManageMovementsScreen({super.key});

  @override
  State<ManageMovementsScreen> createState() => _ManageMovementsScreenState();
}

class _ManageMovementsScreenState extends State<ManageMovementsScreen> {
  String? _selectedMonth;
  String? _selectedYear;

  void _fetchData() {
    if (_selectedMonth != null && _selectedYear != null) {
      Provider.of<FinanceProvider>(context, listen: false).fetchMonthlyData(_selectedMonth!, _selectedYear!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final financeProvider = Provider.of<FinanceProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Gestionar Movimientos')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              const SizedBox(height: 24),
              if (_selectedMonth != null && _selectedYear != null)
                financeProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : DefaultTabController(
                        length: 2,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const TabBar(
                              tabs: [
                                Tab(text: 'Ingresos'),
                                Tab(text: 'Egresos'),
                              ],
                              labelColor: Colors.blue,
                              unselectedLabelColor: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.6,
                              child: TabBarView(
                                children: [
                                  _MovementsList(
                                    items: financeProvider.monthlyIncomes,
                                    isIncome: true,
                                    onDelete: (id) => _confirmDelete(context, id, true),
                                  ),
                                  _MovementsList(
                                    items: financeProvider.monthlyExpenses,
                                    isIncome: false,
                                    onDelete: (id) => _confirmDelete(context, id, false),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id, bool isIncome) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar este ${isIncome ? 'ingreso' : 'egreso'}? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final financeProvider = Provider.of<FinanceProvider>(context, listen: false);
              bool success;
              if (isIncome) {
                success = await financeProvider.deleteIncome(id, _selectedMonth!, _selectedYear!);
              } else {
                success = await financeProvider.deleteExpense(id, _selectedMonth!, _selectedYear!);
              }

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Eliminado correctamente' : 'Error al eliminar'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _MovementsList extends StatelessWidget {
  final List<dynamic> items;
  final bool isIncome;
  final Function(String) onDelete;

  const _MovementsList({required this.items, required this.isIncome, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(child: Text('No hay ${isIncome ? 'ingresos' : 'egresos'} registrados'));
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final String title = isIncome ? (item.residentName ?? 'Residente') : item.concept;
        final String subtitle = isIncome ? (item.description ?? 'Pago') : (item.description ?? '');
        
        return Card(
          child: ListTile(
            title: Text(title),
            subtitle: Text('$subtitle\n\$${item.amount.toStringAsFixed(2)}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => onDelete(item.id),
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}
