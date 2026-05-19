import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/admin_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/models/report_model.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/image_picker_widget.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({Key? key}) : super(key: key);

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1) {
        Provider.of<AdminProvider>(context, listen: false).fetchReports();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _upload() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona una imagen primero')));
      return;
    }
    if (_titleController.text.trim().isEmpty || _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Completa todos los campos')));
      return;
    }

    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await adminProvider.uploadReport(
      image: _selectedImage!,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      authorId: authProvider.currentUser?.id ?? 'admin',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success ? 'Reporte enviado exitosamente' : 'Error al enviar reporte'),
        backgroundColor: success ? Colors.green : Colors.red,
      ));
      if (success) {
        setState(() {
          _selectedImage = null;
          _titleController.clear();
          _descriptionController.clear();
        });
        _tabController.animateTo(1);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Reportes'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.add_a_photo), text: 'Crear'),
            Tab(icon: Icon(Icons.list_alt), text: 'Gestionar'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCreateReportForm(),
          _buildManageReportsList(),
        ],
      ),
    );
  }

  Widget _buildCreateReportForm() {
    final adminProvider = Provider.of<AdminProvider>(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Adjuntar imagen', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          ImagePickerWidget(
            selectedImage: _selectedImage,
            onImageSelected: (file) => setState(() => _selectedImage = file),
          ),
          const SizedBox(height: 24),
          const Text('Detalles del reporte', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          CustomTextField(
            label: 'Título (ej: Fuga de agua)',
            controller: _titleController,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            label: 'Descripción detallada',
            controller: _descriptionController,
            maxLines: 4,
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Enviar Reporte',
            onPressed: _upload,
            isLoading: adminProvider.isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildManageReportsList() {
    final adminProvider = Provider.of<AdminProvider>(context);
    if (adminProvider.isLoading && adminProvider.reports.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (adminProvider.reports.isEmpty) {
      return const Center(child: Text('No hay reportes levantados.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: adminProvider.reports.length,
      itemBuilder: (context, index) {
        final report = adminProvider.reports[index];
        return _ReportCard(report: report, isAdmin: true);
      },
    );
  }
}

class _ReportCard extends StatelessWidget {
  final ReportModel report;
  final bool isAdmin;

  const _ReportCard({required this.report, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final isResolved = report.status == 'resolved';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (report.imageUrl != null)
            Image.network(
              report.imageUrl!,
              height: 200,
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
                    Expanded(
                      child: Text(
                        report.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    _StatusChip(status: report.status),
                  ],
                ),
                const SizedBox(height: 8),
                Text(report.description, style: TextStyle(color: Colors.grey[700])),
                const SizedBox(height: 12),
                Text(
                  'Fecha: ${report.createdAt.day}/${report.createdAt.month}/${report.createdAt.year}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if (isAdmin && !isResolved) ...[
                  const Divider(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () => adminProvider.resolveReport(report.id),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Marcar como Resuelto'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
