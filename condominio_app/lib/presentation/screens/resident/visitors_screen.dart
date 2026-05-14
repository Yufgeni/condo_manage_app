import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/providers/visitor_provider.dart';
import '../../../data/models/visitor_model.dart';

class VisitorsScreen extends StatefulWidget {
  const VisitorsScreen({Key? key}) : super(key: key);

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
            Tab(text: 'Hoy'),
            Tab(text: 'Visitas Pasadas'),
          ],
        ),
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: () => Navigator.pushNamed(context, AppConstants.routeAddVisitor),
              child: const Icon(Icons.add),
            )
          : null,
      body: TabBarView(
        controller: _tabController,
        children: const [
          _TodayVisitorsList(),
          _PastVisitorsList(),
        ],
      ),
    );
  }
}

class _TodayVisitorsList extends StatelessWidget {
  const _TodayVisitorsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final visitorProvider = Provider.of<VisitorProvider>(context);
    final visitors = visitorProvider.todayVisitors;

    if (visitors.isEmpty) {
      return const Center(
        child: Text(
          'No hay visitas registradas hoy',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: visitors.length,
      itemBuilder: (context, index) {
        final visitor = visitors[index];
        return _VisitorCard(visitor: visitor, canDelete: true);
      },
    );
  }
}

class _PastVisitorsList extends StatelessWidget {
  const _PastVisitorsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final visitorProvider = Provider.of<VisitorProvider>(context);
    final visitors = visitorProvider.pastVisitors;

    if (visitors.isEmpty) {
      return const Center(
        child: Text(
          'No hay visitas pasadas',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: visitors.length,
      itemBuilder: (context, index) {
        final visitor = visitors[index];
        return _VisitorCard(visitor: visitor, canDelete: false);
      },
    );
  }
}

class _VisitorCard extends StatelessWidget {
  final VisitorModel visitor;
  final bool canDelete;

  const _VisitorCard({
    Key? key,
    required this.visitor,
    required this.canDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: Text(visitor.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vehículo: ${visitor.carBrand} - ${visitor.carColor}'),
            Text('Placas: ${visitor.carPlates}'),
            Text('Fecha: ${DateFormat('dd/MM/yyyy').format(visitor.date)}'),
          ],
        ),
        trailing: canDelete
            ? IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  Provider.of<VisitorProvider>(context, listen: false).removeVisitor(visitor.id);
                },
              )
            : null,
      ),
    );
  }
}