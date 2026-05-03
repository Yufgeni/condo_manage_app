import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/resident_provider.dart';
import '../../widgets/resident/payment_card.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({Key? key}) : super(key: key);

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ResidentProvider>(context, listen: false)
          .loadResidentData('2');
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ResidentProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Pagos')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.payments.length,
              itemBuilder: (_, i) => PaymentCard(payment: provider.payments[i]),
            ),
    );
  }
}