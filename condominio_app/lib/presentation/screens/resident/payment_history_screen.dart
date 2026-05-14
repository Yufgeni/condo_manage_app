import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/resident_provider.dart';
import '../../widgets/resident/payment_card.dart';

class PaymentHistoryScreen extends StatefulWidget {
  final String? residentId;
  const PaymentHistoryScreen({Key? key, this.residentId}) : super(key: key);

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = widget.residentId ??
          Provider.of<AuthProvider>(context, listen: false).currentUser?.id ??
          '';
      Provider.of<ResidentProvider>(context, listen: false)
          .loadResidentData(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ResidentProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Pagos')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.payments.isEmpty
              ? const Center(child: Text('Sin pagos registrados'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.payments.length,
                  itemBuilder: (_, i) =>
                      PaymentCard(payment: provider.payments[i]),
                ),
    );
  }
}