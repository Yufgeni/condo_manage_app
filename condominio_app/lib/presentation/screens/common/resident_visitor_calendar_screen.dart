import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/visitor_provider.dart';
import '../../../data/providers/admin_provider.dart';
import '../../../data/models/user_model.dart';

class ResidentVisitorCalendarScreen extends StatefulWidget {
  final String residentId;

  const ResidentVisitorCalendarScreen({super.key, required this.residentId});

  @override
  State<ResidentVisitorCalendarScreen> createState() => _ResidentVisitorCalendarScreenState();
}

class _ResidentVisitorCalendarScreenState extends State<ResidentVisitorCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  UserModel? _selectedUser;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    Future.microtask(() {
      if (!mounted) return;
      final provider = Provider.of<VisitorProvider>(context, listen: false);
      provider.loadVisitorsByDay(widget.residentId, _selectedDay!);
      provider.loadAllVisitorsByResident(widget.residentId); // Load all for markers
      
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      try {
        _selectedUser = adminProvider.users.firstWhere((u) => u.id == widget.residentId);
      } catch (_) {
        _selectedUser = null;
      }
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final visitorProvider = Provider.of<VisitorProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedUser != null 
          ? 'Visitas: ${_selectedUser!.name}' 
          : 'Calendario de Visitas'),
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: 'es_ES',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: (day) {
              return visitorProvider.allResidentVisitors.where((visitor) {
                return isSameDay(visitor.entryAt, day);
              }).toList();
            },
            availableCalendarFormats: const {CalendarFormat.month: 'Mes'},
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              visitorProvider.loadVisitorsByDay(widget.residentId, selectedDay);
            },
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Color(0xFF1B5E20),
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
                  return Positioned(
                    right: 1,
                    bottom: 1,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
          const Divider(),
          Expanded(
            child: visitorProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : visitorProvider.visitors.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay visitas este día',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: visitorProvider.visitors.length,
                        itemBuilder: (context, index) {
                          final visitor = visitorProvider.visitors[index];
                          return Card(
                            elevation: 3,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Color(0xFFE8F5E9),
                                child: Icon(Icons.person, color: Color(0xFF1B5E20)),
                              ),
                              title: Text(visitor.name, 
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Vehículo: ${visitor.carBrand} - ${visitor.carColor}'),
                                  Text('Placas: ${visitor.carPlates}', 
                                      style: const TextStyle(fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}