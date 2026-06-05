import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/receipt_pdf_utils.dart';
import '../../../data/providers/finance_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/resident_provider.dart';
import '../../widgets/admin/admin_drawer.dart';
import 'manage_movements_screen.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});
// ... (rest of FinanceScreen)

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
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _FinanceCard(
            title: 'Ingresos',
            subtitle: 'Registro de pagos de residentes',
            icon: Icons.add_chart,
            color: Colors.green,
            onTap: () => _showIngresosMenu(context),
          ),
          const SizedBox(height: 16),
          _FinanceCard(
            title: 'Egresos',
            subtitle: 'Registro de gastos administrativos',
            icon: Icons.analytics_outlined,
            color: Colors.red,
            onTap: () => Navigator.pushNamed(context, AppConstants.routeExpense),
          ),
          const SizedBox(height: 16),
          _FinanceCard(
            title: 'Gestionar Movimientos',
            subtitle: 'Corregir ingresos y egresos',
            icon: Icons.settings_backup_restore,
            color: Colors.orange,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ManageMovementsScreen()),
            ),
          ),
        ],
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

class ApprovePaymentsScreen extends StatefulWidget {
  const ApprovePaymentsScreen({super.key});

  @override
  State<ApprovePaymentsScreen> createState() => _ApprovePaymentsScreenState();
}

class _ApprovePaymentsScreenState extends State<ApprovePaymentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FinanceProvider>(context, listen: false).fetchPendingPayments();
      Provider.of<ResidentProvider>(context, listen: false).fetchAllResidents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final financeProvider = Provider.of<FinanceProvider>(context);
    final residentProvider = Provider.of<ResidentProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Aprobar Pagos')),
      body: financeProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : financeProvider.pendingPayments.isEmpty
              ? const Center(child: Text('No hay pagos pendientes por aprobar'))
              : ListView.builder(
                  itemCount: financeProvider.pendingPayments.length,
                  padding: const EdgeInsets.all(12),
                  itemBuilder: (context, index) {
                    final payment = financeProvider.pendingPayments[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          child: Icon(Icons.payment, color: Colors.white),
                        ),
                        title: Text(payment.residentName ?? 'Residente Desconocido'),
                        subtitle: Text('Cuota ${payment.month} ${payment.year} - \$${payment.amount}'),
                        trailing: ElevatedButton(
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            final success = await financeProvider.approvePayment(payment.id);
                            if (mounted && success) {
                              messenger.showSnackBar(
                                const SnackBar(content: Text('Pago aprobado exitosamente'), backgroundColor: Colors.green),
                              );

                              // Preguntar por enviar recibo
                              final confirmed = await showDialog<bool>(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  title: const Column(
                                    children: [
                                      Icon(Icons.verified, color: Colors.blue, size: 60),
                                      SizedBox(height: 10),
                                      Text('¡Pago aprobado!', textAlign: TextAlign.center),
                                    ],
                                  ),
                                  content: const Text(
                                    '¿Desea generar el recibo PDF con su firma y enviarlo por WhatsApp ahora mismo?',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  actionsAlignment: MainAxisAlignment.center,
                                  actions: [
                                    Column(
                                      children: [
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            onPressed: () => Navigator.pop(context, true),
                                            icon: const Icon(Icons.send, color: Colors.white),
                                            label: const Text('SÍ, ENVIAR AHORA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(vertical: 16),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        SizedBox(
                                          width: double.infinity,
                                          child: TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('NO ENVIAR', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                            style: TextButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );

                              if (confirmed == true && mounted) {
                                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                final resident = residentProvider.allResidents.firstWhere(
                                  (r) => r.id == payment.residentId,
                                  orElse: () => residentProvider.allResidents.firstWhere((r) => r.profileId == payment.residentId, orElse: () => residentProvider.allResidents.first),
                                );
                                
                                await ReceiptPdfUtils.generateAndShareReceipt(
                                  context: context,
                                  payment: payment,
                                  admin: authProvider.currentUser!,
                                  residentUnit: resident.unitNumber,
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: const Text('Aprobar', style: TextStyle(color: Colors.white)),
                        ),
                        onTap: payment.receiptUrl != null
                            ? () => _showReceipt(context, payment.receiptUrl!)
                            : null,
                      ),
                    );
                  },
                ),
    );
  }

  void _showReceipt(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Comprobante'),
              leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ),
            Image.network(url, fit: BoxFit.contain),
          ],
        ),
      ),
    );
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
