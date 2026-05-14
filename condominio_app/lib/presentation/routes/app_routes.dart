import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../screens/auth/login_screen.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/residents_screen.dart';
import '../screens/admin/guards_screen.dart';
import '../screens/admin/maintenance_screen.dart';
import '../screens/admin/add_resident_screen.dart';
import '../screens/admin/add_maintenance_screen.dart';
import '../screens/resident/visitors_screen.dart';
import '../screens/resident/add_visitor_screen.dart';
import '../screens/common/admin_visitor_list_screen.dart';
import '../screens/common/resident_visitor_calendar_screen.dart';
import '../screens/common/view_reports_screen.dart';
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
        AppConstants.routeMaintenance: (_) => const MaintenanceScreen(),
        AppConstants.routeAddResident: (_) => const AddResidentScreen(),
        AppConstants.routeAddMaintenance: (_) => const AddMaintenanceScreen(),
        AppConstants.routeAdminReports: (_) => const AdminReportsScreen(),
        AppConstants.routeResidentDashboard: (_) => const ResidentDashboard(),
        AppConstants.routePaymentHistory: (_) => const PaymentHistoryScreen(),
        AppConstants.routeVisitors: (_) => const VisitorsScreen(),
        AppConstants.routeAdminVisitors: (_) => const AdminVisitorListScreen(),
        AppConstants.routeViewReports: (_) => const ViewReportsScreen(),
        AppConstants.routeResidentVisitorCalendar: (context) {
          final residentId = ModalRoute.of(context)!.settings.arguments as String;
          return ResidentVisitorCalendarScreen(residentId: residentId);
        },
        AppConstants.routeAddVisitor: (_) => const AddVisitorScreen(),
        AppConstants.routeGuardOnDuty: (_) => const GuardOnDutyScreen(),
        AppConstants.routeResidentProfile: (_) => const ResidentProfileScreen(),
        AppConstants.routeGuardDashboard: (_) => const GuardDashboard(),
        AppConstants.routeGuardUpload: (_) => const GuardUploadScreen(),
        AppConstants.routeGuardResidents: (_) => const GuardResidentsScreen(),
      };
}