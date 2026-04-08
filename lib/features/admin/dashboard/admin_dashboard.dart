import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_theme.dart';
import '../../../core/mock_data.dart';
import '../../../core/app_providers.dart';
import '../management/manage_cabs_screen.dart';
import '../management/travel_agency_screen.dart';
import '../management/booking_management_screen.dart';
import '../management/payment_management_screen.dart';
import '../management/offers_management_screen.dart';
import '../management/customer_management_screen.dart';
import '../management/ratings_feedback_screen.dart';
import '../management/notification_management_screen.dart';
import '../management/reports_analytics_screen.dart';
import '../management/pricing_management_screen.dart';
import '../management/system_config_screen.dart';
import '../management/admin_driver_management_screen.dart';
import '../management/admin_agency_management_screen.dart';
import '../../role_selection/role_selection_screen.dart';
import '../../customer/home/home_screen.dart';

import 'package:flutter/foundation.dart';
import '../../desktop_admin/screens/desktop_admin_shell.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kIsWeb || defaultTargetPlatform == TargetPlatform.windows || defaultTargetPlatform == TargetPlatform.macOS || defaultTargetPlatform == TargetPlatform.linux) {
      return const DesktopAdminShell();
    }
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.admin_panel_settings, color: AppTheme.accentColor, size: 20),
            ),
            const SizedBox(width: 8),
            const Flexible(
              child: Text('Admin Dashboard', overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Stack(
              children: [
                const Icon(Icons.notifications_none),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  ),
                ),
              ],
            ),
          ),
          const CircleAvatar(
            radius: 15,
            backgroundColor: AppTheme.primaryColor,
            child: Icon(Icons.person, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 16),
        ],
      ),
      drawer: _buildDrawer(context, ref),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeBanner(),
            const SizedBox(height: 20),
            const Text('Overview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildStatGrid(context),
            const SizedBox(height: 24),
            _buildQuickActions(context),
            const SizedBox(height: 24),
            const Text('Recent Bookings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildRecentBookingsList(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, Color(0xFF3949AB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Welcome back,', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const Text('Nova Admin 👋', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  'You have ${MockData.bookings.where((b) => b.status == 'New').length} new bookings today',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_taxi, color: AppTheme.accentColor, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, WidgetRef ref) {
    final items = [
      {'icon': Icons.dashboard, 'title': 'Dashboard', 'screen': null},
      {'icon': Icons.drive_eta, 'title': 'Manage Drivers', 'screen': AdminDriverManagementScreen()},
      {'icon': Icons.business, 'title': 'Manage Agencies', 'screen': AdminAgencyManagementScreen()},
      {'icon': Icons.directions_car, 'title': 'Cab Management', 'screen': ManageCabsScreen()},
      {'icon': Icons.book_online, 'title': 'Bookings', 'screen': BookingManagementScreen()},
      {'icon': Icons.payments, 'title': 'Payments', 'screen': PaymentManagementScreen()},
      {'icon': Icons.local_offer, 'title': 'Offers', 'screen': OffersManagementScreen()},
      {'icon': Icons.people, 'title': 'Customers', 'screen': CustomerManagementScreen()},
      {'icon': Icons.star, 'title': 'Ratings & Feedback', 'screen': RatingsFeedbackScreen()},
      {'icon': Icons.notifications, 'title': 'Notifications', 'screen': NotificationManagementScreen()},
      {'icon': Icons.bar_chart, 'title': 'Reports', 'screen': ReportsAnalyticsScreen()},
      {'icon': Icons.price_change, 'title': 'Pricing', 'screen': PricingManagementScreen()},
      {'icon': Icons.settings, 'title': 'System Config', 'screen': SystemConfigScreen()},
    ];

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppTheme.primaryColor),
            accountName: const Text('Nova Admin', style: TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: const Text('admin@novacabs.com'),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: AppTheme.accentColor,
              child: Icon(Icons.admin_panel_settings, color: AppTheme.primaryColor, size: 36),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ...items.map((item) => ListTile(
                      leading: Icon(item['icon'] as IconData, color: AppTheme.primaryColor, size: 22),
                      title: Text(item['title'] as String, style: const TextStyle(fontSize: 14)),
                      onTap: () {
                        Navigator.pop(context);
                        if (item['screen'] != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => item['screen'] as Widget),
                          );
                        }
                      },
                    )),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.home, color: Colors.blue, size: 22),
                  title: const Text('Customer Portal', style: TextStyle(fontSize: 14)),
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const CustomerHomeScreen()),
                      (route) => false,
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red, size: 22),
                  title: const Text('Logout', style: TextStyle(fontSize: 14, color: Colors.red)),
                  onTap: () {
                    ref.read(authProvider.notifier).logout();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Nova Cabs Admin v1.0',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatGrid(BuildContext context) {
    final stats = [
      {'title': 'Total Bookings', 'value': '${MockData.bookings.length}', 'icon': Icons.book_online, 'color': Colors.blue, 'screen': const BookingManagementScreen()},
      {'title': 'Active Trips', 'value': '${MockData.bookings.where((b) => b.status == 'Ongoing').length}', 'icon': Icons.local_taxi, 'color': Colors.orange, 'screen': const BookingManagementScreen()},
      {'title': 'Total Revenue', 'value': '₹4.2L', 'icon': Icons.payments, 'color': Colors.green, 'screen': const PaymentManagementScreen()},
      {'title': 'Avg. Rating', 'value': '4.6', 'icon': Icons.star, 'color': Colors.amber, 'screen': const RatingsFeedbackScreen()},
      {'title': 'Total Cabs', 'value': '${MockData.cabs.length}', 'icon': Icons.directions_car, 'color': Colors.purple, 'screen': const ManageCabsScreen()},
      {'title': 'Agencies', 'value': '${MockData.agencies.length}', 'icon': Icons.business, 'color': Colors.teal, 'screen': const TravelAgencyScreen()},
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: stats.map((stat) {
        final color = stat['color'] as Color;
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => stat['screen'] as Widget),
          ),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        stat['title'] as String,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(stat['icon'] as IconData, color: color, size: 16),
                    ),
                  ],
                ),
                Text(
                  stat['value'] as String,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {'icon': Icons.add_circle, 'label': 'Add Cab', 'color': Colors.blue, 'screen': const ManageCabsScreen()},
      {'icon': Icons.local_offer, 'label': 'New Offer', 'color': Colors.orange, 'screen': const OffersManagementScreen()},
      {'icon': Icons.bar_chart, 'label': 'Reports', 'color': Colors.green, 'screen': const ReportsAnalyticsScreen()},
      {'icon': Icons.settings, 'label': 'Settings', 'color': Colors.purple, 'screen': const SystemConfigScreen()},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: actions.map((action) {
            final color = action['color'] as Color;
            return Expanded(
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => action['screen'] as Widget),
                ),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      Icon(action['icon'] as IconData, color: color, size: 24),
                      const SizedBox(height: 6),
                      Text(
                        action['label'] as String,
                        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecentBookingsList(BuildContext context) {
    final recentBookings = MockData.bookings.take(5).toList();
    return Column(
      children: [
        ...recentBookings.map((booking) {
          final statusColors = {
            'Completed': Colors.green,
            'Ongoing': Colors.blue,
            'Confirmed': Colors.teal,
            'Cancelled': Colors.red,
            'New': Colors.orange,
          };
          final statusColor = statusColors[booking.status] ?? Colors.grey;

          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BookingManagementScreen()),
            ),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                    child: Text(
                      booking.customerName[0],
                      style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(booking.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text(
                          '${booking.pickupLocation} → ${booking.dropLocation}',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${booking.totalFare.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 14),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          booking.status,
                          style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BookingManagementScreen()),
          ),
          child: const Text('View All Bookings →'),
        ),
      ],
    );
  }
}
