import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/themes/app_theme.dart';
import 'data/providers/auth_provider.dart';
import 'presentation/routes/app_routes.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/admin/admin_dashboard.dart';
import 'presentation/screens/resident/resident_dashboard.dart';
import 'presentation/screens/guard/guard_dashboard.dart';
import 'core/constants/app_constants.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'),
        Locale('en', 'US'),
      ],
      routes: AppRoutes.routes,
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (!authProvider.isAuthenticated) {
            return const LoginScreen();
          }
          switch (authProvider.userRole) {
            case AppConstants.roleAdmin:
              return const AdminDashboard();
            case AppConstants.roleResident:
              return const ResidentDashboard();
            case AppConstants.roleGuard:
              return const GuardDashboard();
            default:
              return const LoginScreen();
          }
        },
      ),
    );
  }
}