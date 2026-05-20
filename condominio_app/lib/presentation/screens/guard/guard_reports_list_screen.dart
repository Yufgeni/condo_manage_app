import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/guard_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/models/report_model.dart';

class GuardReportsListScreen extends StatefulWidget {
  const GuardReportsListScreen({super.key});

  @override
  State<GuardReportsListScreen> createState() => _GuardReportsListScreenState();
}

class _GuardReportsListScreenState extends State<GuardReportsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchMyReports();
    });
  }

  void _fetchMyReports() {
    final userId = Provider.of<AuthProvider>(context, listen: false).currentUser?.id;
    if (userId != null) {
      Provider.of<GuardProvider>(context, listen: false).fetchMyReports(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final guardProvider = Provider.of<GuardProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Reportes de Incidencias'),
      ),
      body: guardProvider.isLoading && guardProvider.myReports.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : guardProvider.myReports.isEmpty
              ? const Center(child: Text('Aún no has subido reportes.'))
              : RefreshIndicator(
                  onRefresh: () async => _fetchMyReports(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: guardProvider.myReports.length,
                    itemBuilder: (context, index) {
                      final report = guardProvider.myReports[index];
                      return _SimpleReportCard(report: report);
                    },
                  ),
                ),
    );
  }
}

class _SimpleReportCard extends StatelessWidget {
  final ReportModel report;
  const _SimpleReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final isResolved = report.status == 'resolved';
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (report.imageUrl != null)
            Image.network(
              report.imageUrl!,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 150,
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image, size: 50),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(report.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isResolved ? Colors.green : Colors.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isResolved ? 'Resuelto' : 'Pendiente',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(report.description, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                Text(
                  'Fecha: ${report.createdAt.day}/${report.createdAt.month}/${report.createdAt.year}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
