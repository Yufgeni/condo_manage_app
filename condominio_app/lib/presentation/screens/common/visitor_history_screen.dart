import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/providers/visitor_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/models/visitor_model.dart';
import '../../../core/utils/ui_utils.dart';

class VisitorHistoryScreen extends StatefulWidget {
  const VisitorHistoryScreen({super.key});

  @override
  State<VisitorHistoryScreen> createState() => _VisitorHistoryScreenState();
}

class _VisitorHistoryScreenState extends State<VisitorHistoryScreen> {
  DateTimeRange? _selectedDateRange;
  
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDateRange = DateTimeRange(
      start: now.subtract(const Duration(days: 7)),
      end: now,
    );
    _loadHistory();
  }

  void _loadHistory() {
    if (_selectedDateRange == null) return;
    Future.microtask(() => 
      Provider.of<VisitorProvider>(context, listen: false).loadGlobalHistory(
        _selectedDateRange!.start, 
        _selectedDateRange!.end
      )
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedDateRange,
      firstDate: DateTime(2023),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      locale: const Locale('es', 'ES'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
      _loadHistory();
    }
  }

  Future<void> _shareToWhatsApp(String? imageUrl, String visitorName) async {
    if (imageUrl == null || imageUrl.isEmpty) {
      UIUtils.showSnackBar(context, 'No hay imagen para compartir');
      return;
    }

    final message = 'Hola, adjunto imagen de identificación de la visita: $visitorName. Link: $imageUrl';
    final url = 'whatsapp://send?text=${Uri.encodeComponent(message)}';
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      // Fallback a web whatsapp si la app no está instalada
      final webUrl = 'https://wa.me/?text=${Uri.encodeComponent(message)}';
      await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
    }
  }

  void _viewIdImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      UIUtils.showSnackBar(context, 'No hay imagen disponible');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Identificación', style: TextStyle(fontSize: 16)),
              automaticallyImplyLeading: false,
              actions: [IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close))],
            ),
            InteractiveViewer(
              child: Image.network(
                imageUrl,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  );
                },
                errorBuilder: (context, error, stackTrace) => const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('Error al cargar imagen'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visitorProvider = Provider.of<VisitorProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.userRole == AppConstants.roleAdmin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Accesos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () => _selectDateRange(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.filter_list, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Del ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.start)} al ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.end)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          ),
          Expanded(
            child: visitorProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : visitorProvider.globalHistory.isEmpty
                    ? const Center(child: Text('No hay registros en este rango de fechas'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: visitorProvider.globalHistory.length,
                        itemBuilder: (context, index) {
                          final visitor = visitorProvider.globalHistory[index];
                          return _HistoryCard(
                            visitor: visitor,
                            isAdmin: isAdmin,
                            onViewImage: () => _viewIdImage(visitor.idImageUrl),
                            onShareWhatsApp: () => _shareToWhatsApp(visitor.idImageUrl, visitor.name),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final VisitorModel visitor;
  final bool isAdmin;
  final VoidCallback onViewImage;
  final VoidCallback onShareWhatsApp;

  const _HistoryCard({
    required this.visitor,
    required this.isAdmin,
    required this.onViewImage,
    required this.onShareWhatsApp,
  });

  @override
  Widget build(BuildContext context) {
    final hasExit = visitor.exitAt != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ExpansionTile(
        title: Text(visitor.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Casa ${visitor.unitNumber} • ${DateFormat('dd/MM/yyyy').format(visitor.entryAt)}'),
        leading: CircleAvatar(
          backgroundColor: hasExit ? Colors.green.shade50 : Colors.orange.shade50,
          child: Icon(
            hasExit ? Icons.check_circle : Icons.login, 
            color: hasExit ? Colors.green : Colors.orange,
            size: 20,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                _infoRow(Icons.access_time, 'Entrada:', DateFormat('HH:mm').format(visitor.entryAt)),
                if (hasExit) _infoRow(Icons.exit_to_app, 'Salida:', DateFormat('HH:mm').format(visitor.exitAt!)),
                _infoRow(Icons.directions_car, 'Vehículo:', '${visitor.carBrand} ${visitor.carModel}'),
                _infoRow(Icons.color_lens, 'Color:', visitor.carColor),
                _infoRow(Icons.vignette, 'Placas:', visitor.carPlates),
                if (visitor.guardName != null)
                  _infoRow(Icons.security, 'Registrado por:', visitor.guardName!),
                if (visitor.comments != null && visitor.comments!.isNotEmpty)
                  _infoRow(Icons.comment, 'Comentarios:', visitor.comments!),
                
                if (isAdmin) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onViewImage,
                          icon: const Icon(Icons.image),
                          label: const Text('Ver ID'),
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.blue),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onShareWhatsApp,
                          icon: const Icon(Icons.share),
                          label: const Text('WhatsApp'),
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.green),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(width: 4),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
