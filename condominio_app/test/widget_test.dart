import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:condominio_app/app.dart';
import 'package:condominio_app/data/providers/auth_provider.dart';
import 'package:condominio_app/data/providers/resident_provider.dart';
import 'package:condominio_app/data/providers/guard_provider.dart';
import 'package:condominio_app/data/providers/admin_provider.dart';
import 'package:condominio_app/data/providers/maintenance_provider.dart';
import 'package:condominio_app/data/providers/visitor_provider.dart';
import 'package:condominio_app/data/providers/finance_provider.dart';

// Mock the AuthProvider to avoid Supabase initialization issues in tests
class MockAuthProvider extends Mock implements AuthProvider {}
class MockResidentProvider extends Mock implements ResidentProvider {}
class MockGuardProvider extends Mock implements GuardProvider {}
class MockAdminProvider extends Mock implements AdminProvider {}
class MockMaintenanceProvider extends Mock implements MaintenanceProvider {}
class MockVisitorProvider extends Mock implements VisitorProvider {}
class MockFinanceProvider extends Mock implements FinanceProvider {}

Widget createTestWidget({
  required AuthProvider authProvider,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
      ChangeNotifierProvider<ResidentProvider>(create: (_) => MockResidentProvider()),
      ChangeNotifierProvider<GuardProvider>(create: (_) => MockGuardProvider()),
      ChangeNotifierProvider<AdminProvider>(create: (_) => MockAdminProvider()),
      ChangeNotifierProvider<MaintenanceProvider>(create: (_) => MockMaintenanceProvider()),
      ChangeNotifierProvider<VisitorProvider>(create: (_) => MockVisitorProvider()),
      ChangeNotifierProvider<FinanceProvider>(create: (_) => MockFinanceProvider()),
    ],
    child: const MyApp(),
  );
}

void main() {
  late MockAuthProvider mockAuthProvider;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    // Default values for common properties
    when(() => mockAuthProvider.isAuthenticated).thenReturn(false);
    when(() => mockAuthProvider.isLoading).thenReturn(false);
    when(() => mockAuthProvider.errorMessage).thenReturn(null);
  });

  testWidgets('App should display login screen when not authenticated', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(authProvider: mockAuthProvider));
    await tester.pumpAndSettle();

    // Verify that the login screen title or specific text is present
    expect(find.text('Inicia sesión para continuar'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });
}