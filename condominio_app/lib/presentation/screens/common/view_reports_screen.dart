import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../data/providers/admin_provider.dart';
import '../../../data/providers/guard_provider.dart';
import '../../../data/models/report_model.dart';

class ViewReportsScreen extends StatelessWidget {
  const ViewReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    final guardProvider = Provider.of<GuardProvider>(context);

    // Combine reports from both providers
    final adminReports = adminProvider.reports;
    final guardReports = guardProvider.uploads.map((u) => ReportModel(
      id: u['date'] ?? '',
      description: u['text'] ?? '',
      imageUrl: u['imageUrl'],
      date: DateTime.tryParse(u['date'] ?? '') ?? DateTime.now(),
      authorId: 'Guardia',
    )).toList();

    final allReports = [...adminReports, ...guardReports];
    allReports.sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visualizar Reportes'),
      ),
      body: allReports.isEmpty
          ? const Center(child: Text('No hay reportes registrados'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: allReports.length,
              itemBuilder: (context, index) {
                final report = allReports[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (report.imageUrl != null && report.imageUrl!.isNotEmpty)
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: Image.network(
                            report.imageUrl!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 200,
                              color: Colors.grey[200],
                              child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Chip(
                                  label: Text(
                                    report.authorId == 'Guardia' ? 'Reporte Guardia' : 'Reporte Admin',
                                    style: const TextStyle(fontSize: 12, color: Colors.white),
                                  ),
                                  backgroundColor: report.authorId == 'Guardia' ? Colors.teal : Colors.blue,
                                ),
                                Text(
                                  DateFormat('dd/MM/yyyy HH:mm').format(report.date),
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              report.description,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}