import 'package:flutter/material.dart';
import '../../../data/models/payment_model.dart';
import 'package:intl/intl.dart';

class PaymentCard extends StatelessWidget {
  final PaymentModel payment;

  const PaymentCard({Key? key, required this.payment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPaid = payment.status == 'paid';
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isPaid ? Colors.green[100] : Colors.orange[100],
          child: Icon(
            isPaid ? Icons.check_circle : Icons.pending,
            color: isPaid ? Colors.green : Colors.orange,
          ),
        ),
        title: Text(payment.concept),
        subtitle: Text(
          DateFormat('dd/MM/yyyy').format(payment.date),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${payment.amount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isPaid ? Colors.green[100] : Colors.orange[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isPaid ? 'Pagado' : 'Pendiente',
                style: TextStyle(
                  fontSize: 11,
                  color: isPaid ? Colors.green[800] : Colors.orange[800],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}