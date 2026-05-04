import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../screens/auth/login_screen.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/residents_screen.dart';
import '../screens/admin/guards_screen.dart';
import '../screens/admin/payments_screens.dart';
import '../screens/resident/resident_dashboard.dart';
import '../screens/resident/payment_history_screen.dart';
import '../screens/resident/guard_on_duty_screen.dart';
import '../screens/resident/resident_profile_screen.dart';
import '../screens/guard/guard_dashboard.dart';
import '../screens/guard/guard_upload_screen.dart';

import '../screens/admin/admin_reports_screen.dart';
import '../screens/guard/guard_residents_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> get routes => {
        AppConstants.routeLogin: (_) => const LoginScreen(),
        AppConstants.routeAdminDashboard: (_) => const AdminDashboard(),
        AppConstants.routeResidents: (_) => const ResidentsScreen(),
        AppConstants.routeGuards: (_) => const GuardsScreen(),
        AppConstants.routePayments: (_) => const PaymentsScreen(),
        AppConstants.routeAdminReports: (_) => const AdminReportsScreen(),
        AppConstants.routeResidentDashboard: (_) => const ResidentDashboard(),
        AppConstants.routePaymentHistory: (_) => const PaymentHistoryScreen(),
        AppConstants.routeGuardOnDuty: (_) => const GuardOnDutyScreen(),
        AppConstants.routeResidentProfile: (_) => const ResidentProfileScreen(),
        AppConstants.routeGuardDashboard: (_) => const GuardDashboard(),
        AppConstants.routeGuardUpload: (_) => const GuardUploadScreen(),
        AppConstants.routeGuardResidents: (_) => const GuardResidentsScreen(),
      };
}