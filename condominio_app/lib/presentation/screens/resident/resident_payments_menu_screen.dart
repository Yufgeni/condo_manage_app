import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

class ResidentPaymentsMenuScreen extends StatelessWidget {
  const ResidentPaymentsMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Pagos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  _MenuCard(
                    title: 'Subir un pago',
                    subtitle: 'Registra un nuevo comprobante',
                    icon: Icons.upload_file,
                    color: Colors.blue,
                    onTap: () => Navigator.pushNamed(context, AppConstants.routeUploadPayment),
                  ),
                  const SizedBox(height: 16),
                  _MenuCard(
                    title: 'Ver historial de pagos',
                    subtitle: 'Consulta tus pagos anteriores',
                    icon: Icons.history,
                    color: Colors.purple,
                    onTap: () => Navigator.pushNamed(context, AppConstants.routePaymentHistory),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
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
