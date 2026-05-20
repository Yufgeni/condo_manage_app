import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/providers/visitor_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/models/visitor_model.dart';
import '../../../core/utils/ui_utils.dart';

class VisitorsScreen extends StatefulWidget {
  const VisitorsScreen({super.key});

  @override
  State<VisitorsScreen> createState() => _VisitorsScreenState();
}

class _VisitorsScreenState extends State<VisitorsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    
    _loadData();
  }

  void _loadData() {
    Future.microtask(() {
      if (!mounted) return;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final visitorProvider = Provider.of<VisitorProvider>(context, listen: false);
      if (authProvider.currentUser != null) {
        visitorProvider.loadAllVisitorsByResident(authProvider.currentUser!.id);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Visitantes'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Agendar visitantes'),
            Tab(text: 'Mis visitas'),
          ],
        ),
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.pushNamed(context, AppConstants.routeAddVisitor);
                _loadData(); 
              },
              backgroundColor: const Color(0xFF1B5E20),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: TabBarView(
        controller: _tabController,
        children: [
          const _FullVisitorsList(), 
          const _CalendarVisitorsView(), 
        ],
      ),
    );
  }
}

class _FullVisitorsList extends StatelessWidget {
  const _FullVisitorsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final visitorProvider = Provider.of<VisitorProvider>(context);
    final visitors = visitorProvider.visitors;

    if (visitorProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (visitors.isEmpty) {
      return const Center(
        child: Text(
          'No tienes visitas registradas',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: visitors.length,
      itemBuilder: (context, index) {
        return _VisitorCard(visitor: visitors[index]);
      },
    );
  }
}

class _CalendarVisitorsView extends StatefulWidget {
  const _CalendarVisitorsView({Key? key}) : super(key: key);

  @override
  State<_CalendarVisitorsView> createState() => _CalendarVisitorsViewState();
}

class _CalendarVisitorsViewState extends State<_CalendarVisitorsView> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<VisitorModel> _dayVisitors = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final allVisitors = Provider.of<VisitorProvider>(context).visitors;
    _dayVisitors = allVisitors.where((v) => isSameDay(v.date, _selectedDay)).toList();

    return Column(
      children: [
        TableCalendar(
          locale: 'es_ES',
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          availableCalendarFormats: const {CalendarFormat.month: 'Mes'},
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          calendarStyle: const CalendarStyle(
            todayDecoration: BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
            selectedDecoration: BoxDecoration(color: Color(0xFF1B5E20), shape: BoxShape.circle),
          ),
          headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
        ),
        const Divider(),
        Expanded(
          child: _dayVisitors.isEmpty
              ? const Center(child: Text('No hay visitas este día', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _dayVisitors.length,
                  itemBuilder: (context, index) => _VisitorCard(visitor: _dayVisitors[index]),
                ),
        ),
      ],
    );
  }
}

class _VisitorCard extends StatelessWidget {
  final VisitorModel visitor;
  const _VisitorCard({Key? key, required this.visitor}) : super(key: key);

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar visita'),
        content: const Text('¿Está seguro de que desea eliminar este registro de visita?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final visitorProvider = Provider.of<VisitorProvider>(context, listen: false);
      final success = await visitorProvider.removeVisitor(visitor.id);
      
      if (context.mounted) {
        UIUtils.showSnackBar(
          context, 
          success ? 'Visita eliminada correctamente' : 'Error al eliminar la visita',
          isError: !success
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lógica para permitir eliminar solo si la fecha es hoy o futura
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final visitorDay = DateTime(visitor.date.year, visitor.date.month, visitor.date.day);
    final canDelete = !visitorDay.isBefore(today);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFE8F5E9),
          child: Icon(Icons.person, color: Color(0xFF1B5E20), size: 20),
        ),
        trailing: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (canDelete)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                onPressed: () => _confirmDelete(context),
              ),
            const Icon(Icons.expand_more),
          ],
        ),
        title: Text(visitor.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text('Fecha: ${DateFormat('dd/MM/yyyy').format(visitor.date)}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const Text(
                  'Información del Vehículo',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                _infoRow(Icons.directions_car, 'Marca/Modelo', visitor.carBrand),
                const SizedBox(height: 8),
                _infoRow(Icons.color_lens, 'Color', visitor.carColor),
                const SizedBox(height: 8),
                _infoRow(Icons.vignette, 'Placas', visitor.carPlates),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF1B5E20)),
        const SizedBox(width: 12),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        Text(value.isEmpty ? 'N/A' : value, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}