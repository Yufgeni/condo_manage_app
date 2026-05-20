import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/guard_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/image_picker_widget.dart';

class GuardUploadScreen extends StatefulWidget {
  const GuardUploadScreen({super.key});

  @override
  State<GuardUploadScreen> createState() => _GuardUploadScreenState();
}

class _GuardUploadScreenState extends State<GuardUploadScreen> with SingleTickerProviderStateMixin {
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
        _fetchMyReports();
      }
    });
  }

  void _fetchMyReports() {
    final userId = Provider.of<AuthProvider>(context, listen: false).currentUser?.id;
    if (userId != null) {
      Provider.of<GuardProvider>(context, listen: false).fetchMyReports(userId);
    }
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

    final guardProvider = Provider.of<GuardProvider>(context, listen: false);
    final userId = Provider.of<AuthProvider>(context, listen: false).currentUser?.id;

    if (userId == null) return;

    final success = await guardProvider.uploadReport(
      image: _selectedImage!,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      authorId: userId,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success ? 'Reporte subido exitosamente' : 'Error al subir reporte'),
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
        title: const Text('Reportes de Incidencias'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.add_a_photo), text: 'Subir'),
            Tab(icon: Icon(Icons.history), text: 'Mis Reportes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUploadForm(),
          _buildMyReportsList(),
        ],
      ),
    );
  }

  Widget _buildUploadForm() {
    final guardProvider = Provider.of<GuardProvider>(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Imagen de la incidencia', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          ImagePickerWidget(
            selectedImage: _selectedImage,
            onImageSelected: (file) => setState(() => _selectedImage = file),
          ),
          const SizedBox(height: 24),
          const Text('Detalles', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          CustomTextField(
            label: 'Título breve',
            controller: _titleController,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            label: 'Descripción de lo sucedido',
            controller: _descriptionController,
            maxLines: 4,
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Subir reporte',
            onPressed: _upload,
            isLoading: guardProvider.isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildMyReportsList() {
    final guardProvider = Provider.of<GuardProvider>(context);
    if (guardProvider.isLoading && guardProvider.myReports.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (guardProvider.myReports.isEmpty) {
      return const Center(child: Text('Aún no has subido reportes.'));
    }

    return RefreshIndicator(
      onRefresh: () async => _fetchMyReports(),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: guardProvider.myReports.length,
        itemBuilder: (context, index) {
          final report = guardProvider.myReports[index];
          // Using a local version of ReportCard to avoid circular dependencies or keep it simple
          return _SimpleReportCard(report: report);
        },
      ),
    );
  }
}

class _SimpleReportCard extends StatelessWidget {
  final dynamic report; // Using dynamic or ReportModel
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
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(report.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isResolved ? Colors.green : Colors.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isResolved ? 'Resuelto' : 'Pendiente',
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(report.description, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
