import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/desktop_theme.dart';
import '../shared/desktop_widgets.dart';
import '../widgets/desktop_sidebar.dart';
import '../widgets/desktop_header.dart';
import 'dashboard_overview.dart';
import 'driver_management_screen.dart';
import 'agency_management_screen.dart';
import 'vehicle_management_desktop.dart';
import 'booking_management_desktop.dart';
import 'payment_management_desktop.dart';
import 'customer_management_desktop.dart';
import 'reports_analytics_desktop.dart';
import 'notification_desktop_screen.dart';
import 'system_settings_desktop.dart';

class DesktopAdminShell extends ConsumerWidget {
  const DesktopAdminShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSection = ref.watch(desktopNavProvider);
    final isCollapsed = ref.watch(sidebarCollapsedProvider);

    return Scaffold(
      backgroundColor: DesktopTheme.contentBg,
      body: Row(
        children: [
          // Sidebar with fixed width but animated transition
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: isCollapsed ? DesktopTheme.sidebarCollapsedWidth : DesktopTheme.sidebarWidth,
            child: const DesktopSidebar(),
          ),

          // Main Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                const DesktopHeader(),

                // Page Content
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.01, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        ),
                        child: Container(
                          key: ValueKey(currentSection),
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                          color: DesktopTheme.contentBg,
                          child: _buildScreen(currentSection),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreen(AdminSection section) {
    switch (section) {
      case AdminSection.dashboard:
        return const DashboardOverviewScreen(key: ValueKey('dashboard'));
      case AdminSection.drivers:
        return const DriverManagementScreen(key: ValueKey('drivers'));
      case AdminSection.agencies:
        return const AgencyManagementScreen(key: ValueKey('agencies'));
      case AdminSection.vehicles:
        return const VehicleManagementDesktopScreen(key: ValueKey('vehicles'));
      case AdminSection.bookings:
        return const BookingManagementDesktopScreen(key: ValueKey('bookings'));
      case AdminSection.payments:
        return const PaymentManagementDesktopScreen(key: ValueKey('payments'));
      case AdminSection.customers:
        return const CustomerManagementDesktopScreen(key: ValueKey('customers'));
      case AdminSection.reports:
        return const ReportsAnalyticsDesktopScreen(key: ValueKey('reports'));
      case AdminSection.notifications:
        return const NotificationDesktopScreen(key: ValueKey('notifications'));
      case AdminSection.settings:
        return const SystemSettingsDesktopScreen(key: ValueKey('settings'));
    }
  }
}
