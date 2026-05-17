import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/guard_provider.dart';

class GuardOnDutyScreen extends StatefulWidget {
  const GuardOnDutyScreen({Key? key}) : super(key: key);

  @override
  State<GuardOnDutyScreen> createState() => _GuardOnDutyScreenState();
}

class _GuardOnDutyScreenState extends State<GuardOnDutyScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<GuardProvider>(context, listen: false).fetchGuardOnDuty());
  }

  @override
  Widget build(BuildContext context) {
    final guardProvider = Provider.of<GuardProvider>(context);
    final guard = guardProvider.guardOnDuty;

    return Scaffold(
      appBar: AppBar(title: const Text('Vigilante en Turno')),
      body: guardProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : guard == null
              ? const Center(
                  child: Text('No hay ningún vigilante en turno actualmente'),
                )
              : Padding(
                  padding: const EdgeInsets.all(24),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: const Color(0xFFE3F2FD),
                            backgroundImage: guard.photoUrl != null
                                ? NetworkImage(guard.photoUrl!)
                                : null,
                            child: guard.photoUrl == null
                                ? const Icon(Icons.security,
                                    size: 50, color: Color(0xFF1565C0))
                                : null,
                          ),
                          const SizedBox(height: 16),
                          Text(guard.fullName,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          _InfoRow(
                              icon: Icons.access_time,
                              text: 'Turno: ${guard.shiftName}'),
                          if (guard.phone != null && guard.phone!.isNotEmpty)
                            _InfoRow(icon: Icons.phone, text: guard.phone!),
                          _InfoRow(
                            icon: Icons.circle,
                            text: guard.isOnDuty
                                ? 'En turno actualmente'
                                : 'Fuera de turno',
                            color: guard.isOnDuty ? Colors.green : Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;

  const _InfoRow({required this.icon, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: color ?? Colors.grey, size: 20),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}