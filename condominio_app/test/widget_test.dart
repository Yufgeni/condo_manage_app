import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:condominio_app/main.dart';

void main() {
  testWidgets('App should display login screen', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('Admin dashboard should be displayed after login', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // Simulate login
    await tester.enterText(find.byKey(Key('emailField')), 'admin@example.com');
    await tester.enterText(find.byKey(Key('passwordField')), 'password');
    await tester.tap(find.byKey(Key('loginButton')));
    await tester.pumpAndSettle();

    expect(find.text('Admin Dashboard'), findsOneWidget);
  });

  testWidgets('Resident dashboard should be displayed after login', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // Simulate login
    await tester.enterText(find.byKey(Key('emailField')), 'resident@example.com');
    await tester.enterText(find.byKey(Key('passwordField')), 'password');
    await tester.tap(find.byKey(Key('loginButton')));
    await tester.pumpAndSettle();

    expect(find.text('Resident Dashboard'), findsOneWidget);
  });

  testWidgets('Guard dashboard should be displayed after login', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // Simulate login
    await tester.enterText(find.byKey(Key('emailField')), 'guard@example.com');
    await tester.enterText(find.byKey(Key('passwordField')), 'password');
    await tester.tap(find.byKey(Key('loginButton')));
    await tester.pumpAndSettle();

    expect(find.text('Guard Dashboard'), findsOneWidget);
  });
}