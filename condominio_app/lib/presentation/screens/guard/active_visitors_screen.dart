import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../data/providers/visitor_provider.dart';
import '../../../core/utils/ui_utils.dart';

class ActiveVisitorsScreen extends StatefulWidget {
  const ActiveVisitorsScreen({super.key});

  @override
  State<ActiveVisitorsScreen> createState() => _ActiveVisitorsScreenState();
}

class _ActiveVisitorsScreenState extends State<ActiveVisitorsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<VisitorProvider>(context, listen: false).loadActiveVisitors());
  }

  Future<void> _confirmExit(BuildContext context, String visitorId, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registrar Salida'),
        content: Text('¿Confirmar salida de $name?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Confirmar Salida', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await Provider.of<VisitorProvider>(context, listen: false).markExit(visitorId);
      if (context.mounted) {
        UIUtils.showSnackBar(context, success ? 'Salida registrada' : 'Error al registrar salida', isError: !success);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final visitorProvider = Provider.of<VisitorProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visitas en el Condominio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => visitorProvider.loadActiveVisitors(),
          ),
        ],
      ),
      body: visitorProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : visitorProvider.activeVisitors.isEmpty
              ? const Center(child: Text('No hay visitas activas actualmente'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: visitorProvider.activeVisitors.length,
                  itemBuilder: (context, index) {
                    final visitor = visitorProvider.activeVisitors[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    visitor.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Casa ${visitor.unitNumber}',
                                    style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            _detailRow(Icons.access_time, 'Entrada:', DateFormat('HH:mm - dd/MM').format(visitor.entryAt)),
                            const SizedBox(height: 8),
                            _detailRow(Icons.directions_car, 'Vehículo:', '${visitor.carBrand} ${visitor.carModel} (${visitor.carColor})'),
                            const SizedBox(height: 8),
                            _detailRow(Icons.vignette, 'Placas:', visitor.carPlates),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _confirmExit(context, visitor.id, visitor.name),
                                icon: const Icon(Icons.exit_to_app),
                                label: const Text('REGISTRAR SALIDA'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(width: 4),
        Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
      ],
    );
  }
}
