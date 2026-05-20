import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/finance_provider.dart';
import '../../../data/providers/resident_provider.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final residentProvider = Provider.of<ResidentProvider>(context, listen: false);
      final financeProvider = Provider.of<FinanceProvider>(context, listen: false);
      
      final userId = authProvider.currentUser?.id;
      if (userId != null) {
        if (residentProvider.resident == null || residentProvider.resident!.id.isEmpty) {
          await residentProvider.loadResidentData(userId);
        }
        
        if (residentProvider.resident != null && residentProvider.resident!.id.isNotEmpty) {
          financeProvider.fetchResidentPayments(residentProvider.resident!.id);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final financeProvider = Provider.of<FinanceProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Pagos')),
      body: financeProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : financeProvider.residentPayments.isEmpty
              ? const Center(child: Text('No tienes pagos registrados.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: financeProvider.residentPayments.length,
                  itemBuilder: (context, index) {
                    final payment = financeProvider.residentPayments[index];
                    final isPaid = payment.status == 'paid';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isPaid ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                          child: Icon(
                            isPaid ? Icons.check_circle : Icons.pending,
                            color: isPaid ? Colors.green : Colors.orange,
                          ),
                        ),
                        title: Text('Cuota ${payment.month} ${payment.year}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Monto: \$${payment.amount.toStringAsFixed(2)}'),
                            Text('Fecha: ${payment.createdAt.day}/${payment.createdAt.month}/${payment.createdAt.year}'),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isPaid ? Colors.green : Colors.orange,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isPaid ? 'Aprobado' : 'Pendiente',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
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
            Image.network(
              url,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
