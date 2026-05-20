import 'package:flutter/material.dart';
import '../../../data/models/payment_model.dart';

class PaymentCard extends StatelessWidget {
  final PaymentModel payment;

  const PaymentCard({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    final isPaid = payment.status == 'paid';
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isPaid
              ? Colors.green.withValues(alpha: 0.1)
              : Colors.orange.withValues(alpha: 0.1),
          child: Icon(
            isPaid ? Icons.check_circle : Icons.pending,
            color: isPaid ? Colors.green : Colors.orange,
          ),
        ),
        title: Text('Cuota ${payment.month} ${payment.year}'),
        subtitle: Text(
          '${payment.createdAt.day}/${payment.createdAt.month}/${payment.createdAt.year}',
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
                color: isPaid
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isPaid ? 'Pagado' : 'Pendiente',
                style: TextStyle(
                  fontSize: 11,
                  color: isPaid ? Colors.green : Colors.orange,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
