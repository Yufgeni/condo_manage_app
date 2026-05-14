import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../data/providers/visitor_provider.dart';
import '../../../data/models/visitor_model.dart';

class ResidentVisitorCalendarScreen extends StatefulWidget {
  final String residentId;

  const ResidentVisitorCalendarScreen({Key? key, required this.residentId}) : super(key: key);

  @override
  State<ResidentVisitorCalendarScreen> createState() => _ResidentVisitorCalendarScreenState();
}

class _ResidentVisitorCalendarScreenState extends State<ResidentVisitorCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  List<VisitorModel> _getVisitorsForDay(DateTime day, List<VisitorModel> allVisitors) {
    return allVisitors.where((v) => 
      v.residentId == widget.residentId &&
      isSameDay(v.date, day)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final visitorProvider = Provider.of<VisitorProvider>(context);
    final selectedDayVisitors = _getVisitorsForDay(_selectedDay ?? _focusedDay, visitorProvider.visitors);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario de Visitas'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
          const Divider(),
          Expanded(
            child: selectedDayVisitors.isEmpty
                ? const Center(
                    child: Text(
                      'no hubo visitas registradas',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: selectedDayVisitors.length,
                    itemBuilder: (context, index) {
                      final visitor = selectedDayVisitors[index];
                      return Card(
                        child: ListTile(
                          title: Text(visitor.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${visitor.carBrand} - ${visitor.carColor} [${visitor.carPlates}]'),
                          trailing: Text(DateFormat('HH:mm').format(visitor.date)),
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