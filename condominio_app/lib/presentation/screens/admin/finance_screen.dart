import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/admin/admin_drawer.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finanzas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      drawer: const AdminDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 1,
                childAspectRatio: 2.5,
                mainAxisSpacing: 16,
                children: [
                  _FinanceCard(
                    title: 'Ingresos',
                    subtitle: 'Registro de pagos de residentes',
                    icon: Icons.add_chart,
                    color: Colors.green,
                    onTap: () => _showIngresosMenu(context),
                  ),
                  _FinanceCard(
                    title: 'Egresos',
                    subtitle: 'Registro de gastos administrativos',
                    icon: Icons.analytics_outlined,
                    color: Colors.red,
                    onTap: () => Navigator.pushNamed(context, AppConstants.routeExpense),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showIngresosMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Opciones de Ingresos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.edit_note, color: Colors.green),
              title: const Text('Registrar pago manual'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppConstants.routeIncome);
              },
            ),
            ListTile(
              leading: const Icon(Icons.fact_check_outlined, color: Colors.blue),
              title: const Text('Aprobar pagos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ApprovePaymentsScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ApprovePaymentsScreen extends StatelessWidget {
  const ApprovePaymentsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aprobar Pagos')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getPendingPayments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay pagos pendientes por aprobar'));
          }

          final payments = snapshot.data!;
          return ListView.builder(
            itemCount: payments.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final payment = payments[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.payment, color: Colors.white),
                  ),
                  title: Text(payment['resident_name']),
                  subtitle: Text('${payment['concept']} - \$${payment['amount']}'),
                  trailing: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pago aprobado exitosamente')),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Aprobar', style: TextStyle(color: Colors.white)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getPendingPayments() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      {'id': '1', 'resident_name': 'Juan Pérez', 'amount': 1500, 'concept': 'Mantenimiento Mayo', 'status': 'pending'},
      {'id': '2', 'resident_name': 'María García', 'amount': 1500, 'concept': 'Mantenimiento Mayo', 'status': 'pending'},
      {'id': '3', 'resident_name': 'Carlos Ruiz', 'amount': 1500, 'concept': 'Mantenimiento Mayo', 'status': 'pending'},
    ];
  }
}

class _FinanceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _FinanceCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: color.withValues(alpha: 0.1),
                child: Icon(icon, size: 40, color: color),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
