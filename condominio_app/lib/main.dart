import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'data/providers/auth_provider.dart';
import 'data/providers/resident_provider.dart';
import 'data/providers/guard_provider.dart';
import 'data/providers/admin_provider.dart';
import 'data/providers/maintenance_provider.dart';
import 'data/providers/visitor_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ResidentProvider()),
        ChangeNotifierProvider(create: (_) => GuardProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => MaintenanceProvider()),
        ChangeNotifierProvider(create: (_) => VisitorProvider()),
      ],
      child: const MyApp(),
    ),
  );
}