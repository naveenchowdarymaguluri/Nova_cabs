import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_theme.dart';
import '../../../core/extended_models.dart';
import '../../../core/app_providers.dart';
import '../../../core/mock_data.dart';
import '../../role_selection/role_selection_screen.dart';
import '../pricing/driver_pricing_screen.dart';
import '../trips/driver_trip_history_screen.dart';
import '../trips/driver_active_trip_screen.dart';
import '../earnings/driver_earnings_screen.dart';

/// Central Driver Dashboard — Online/Offline toggle, trip requests, stats
class DriverDashboard extends ConsumerStatefulWidget {
  final DriverModel driver;

  const DriverDashboard({super.key, required this.driver});

  @override
  ConsumerState<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends ConsumerState<DriverDashboard>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _hasTripRequest = false;
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Simulate incoming trip request after 5 seconds if online
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && ref.read(driverOnlineStatusProvider)) {
        setState(() => _hasTripRequest = true);
        _showTripRequestBottomSheet();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = ref.watch(driverOnlineStatusProvider);
    final driver = widget.driver;

    final pages = [
      _buildHomePage(isOnline, driver),
      DriverTripHistoryScreen(driverId: driver.id),
      DriverEarningsScreen(driverId: driver.id),
      _buildProfilePage(driver),
    ];

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      body: pages[_currentNavIndex],
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: AppTheme.primaryColor.withValues(alpha: 0.15),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentNavIndex,
          onDestinationSelected: (i) => setState(() => _currentNavIndex = i),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.dashboard_outlined),
              selectedIcon: const Icon(Icons.dashboard, color: AppTheme.primaryColor),
              label: 'Home',
            ),
            NavigationDestination(
              icon: const Icon(Icons.history_outlined),
              selectedIcon: const Icon(Icons.history, color: AppTheme.primaryColor),
              label: 'Trips',
            ),
            NavigationDestination(
              icon: const Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: const Icon(Icons.account_balance_wallet, color: AppTheme.primaryColor),
              label: 'Earnings',
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outlined),
              selectedIcon: const Icon(Icons.person, color: AppTheme.primaryColor),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomePage(bool isOnline, DriverModel driver) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 0,
          floating: true,
          pinned: true,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: null,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.local_taxi, color: AppTheme.accentColor, size: 20),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nova Cabs',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Driver Portal',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: Stack(
                children: [
                  const Icon(Icons.notifications_outlined, color: AppTheme.primaryColor),
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
            const SizedBox(width: 8),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Driver welcome card
                _buildDriverCard(driver, isOnline),
                const SizedBox(height: 20),
                // Online/Offline Toggle
                _buildOnlineToggle(isOnline),
                const SizedBox(height: 20),
                // Today's Stats
                _buildTodayStats(driver),
                const SizedBox(height: 20),
                // Pricing Setup Card (if not configured)
                if (driver.pricing == null) _buildPricingSetupCard(driver),
                if (driver.pricing == null) const SizedBox(height: 20),
                // Quick Actions
                _buildQuickActions(driver),
                const SizedBox(height: 20),
                // Recent Trips
                _buildRecentTrips(),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDriverCard(DriverModel driver, bool isOnline) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Text(
              driver.fullName[0],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${driver.fullName.split(' ').first}!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: AppTheme.accentColor, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      driver.rating > 0 ? '${driver.rating} Rating' : 'No ratings yet',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isOnline ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isOnline ? '🟢 ONLINE' : '🔴 OFFLINE',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnlineToggle(bool isOnline) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Availability Status',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isOnline
                          ? 'You are visible to customers and can receive trip requests'
                          : 'You are offline. Switch on to start accepting rides',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: isOnline ? 1.0 + (_pulseController.value * 0.05) : 1.0,
                    child: GestureDetector(
                      onTap: () {
                        ref.read(driverOnlineStatusProvider.notifier).state = !isOnline;
                        if (!isOnline) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('🟢 You are now ONLINE and visible to customers'),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isOnline ? Colors.green : Colors.grey.shade300,
                          boxShadow: isOnline
                              ? [
                                  BoxShadow(
                                    color: Colors.green.withValues(
                                      alpha: 0.3 + (_pulseController.value * 0.2),
                                    ),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          isOnline ? Icons.power_settings_new : Icons.power_settings_new_outlined,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          if (isOnline) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.green.shade700, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'You are online! Trip requests from nearby customers will appear as notifications.',
                      style: TextStyle(color: Colors.green.shade800, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTodayStats(DriverModel driver) {
    final allBookings = ref.watch(bookingProvider);
    final today = DateFormat('dd MMM yyyy').format(DateTime.now());
    
    final todayCompleted = allBookings.where((b) => 
      b.driverId == driver.id && 
      b.status == 'Completed' && 
      b.date == today
    ).toList();

    final earningsToday = todayCompleted.fold(0.0, (sum, b) => sum + (b.totalFare * 0.85));
    final distanceToday = todayCompleted.fold(0.0, (sum, b) => sum + b.totalDistance);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Today's Overview", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCard('₹${earningsToday.toStringAsFixed(0)}', 'Today\'s Earnings', Icons.account_balance_wallet, Colors.green)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('${todayCompleted.length}', 'Trips Today', Icons.local_taxi, Colors.blue)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('${distanceToday.toStringAsFixed(0)} km', 'Distance', Icons.route, Colors.orange)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 10), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildPricingSetupCard(DriverModel driver) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFC107), Color(0xFFFFD54F)],
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
                const Text(
                  '⚠️ Setup Required',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryColor),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Configure your pricing to start accepting rides',
                  style: TextStyle(fontSize: 12, color: AppTheme.primaryColor),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DriverPricingScreen(driver: driver),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Setup', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(DriverModel driver) {
    final actions = [
      {
        'icon': Icons.price_change_outlined,
        'label': 'Pricing',
        'color': Colors.green,
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DriverPricingScreen(driver: driver)),
        ),
      },
      {
        'icon': Icons.history,
        'label': 'Trip History',
        'color': Colors.blue,
        'onTap': () => setState(() => _currentNavIndex = 1),
      },
      {
        'icon': Icons.account_balance_wallet,
        'label': 'Wallet',
        'color': Colors.purple,
        'onTap': () => setState(() => _currentNavIndex = 2),
      },
      {
        'icon': Icons.support_agent,
        'label': 'Support',
        'color': Colors.orange,
        'onTap': () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Calling support: +91 80000 00000')),
        ),
      },
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
                onTap: action['onTap'] as VoidCallback,
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
                  ),
                  child: Column(
                    children: [
                      Icon(action['icon'] as IconData, color: color, size: 26),
                      const SizedBox(height: 8),
                      Text(
                        action['label'] as String,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
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

  Widget _buildRecentTrips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Trips', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(Icons.route_outlined, size: 48, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text(
                'No recent trips',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'Accept your first trip by going online!',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfilePage(DriverModel driver) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Driver Profile'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: Text(
                      driver.fullName[0],
                      style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(driver.fullName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(driver.mobileNumber, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      driver.statusLabel,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Vehicle info
            _buildProfileSection('Vehicle Details', [
              _buildProfileItem(Icons.directions_car, 'Model', driver.vehicleModel),
              _buildProfileItem(Icons.confirmation_number_outlined, 'Number', driver.vehicleNumber),
              _buildProfileItem(Icons.category_outlined, 'Type', driver.vehicleType),
              _buildProfileItem(Icons.badge_outlined, 'Driver Type', driver.driverType == DriverType.individual ? 'Individual' : 'Agency Driver'),
              if (driver.agencyName != null)
                _buildProfileItem(Icons.business, 'Agency', driver.agencyName!),
            ]),
            const SizedBox(height: 16),
            // Performance
            _buildProfileSection('Performance', [
              _buildProfileItem(Icons.star, 'Rating', driver.rating > 0 ? '${driver.rating}/5.0' : 'No ratings yet'),
              _buildProfileItem(Icons.local_taxi, 'Total Trips', '${driver.totalTrips}'),
              _buildProfileItem(Icons.account_balance_wallet, 'Total Earnings', '₹${driver.totalEarnings.toStringAsFixed(0)}'),
            ]),
            const SizedBox(height: 16),
            // Logout
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ref.read(authProvider.notifier).logout();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text('Logout', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 50),
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(String title, List<Widget> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),
          ...items,
        ],
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  void _showTripRequestBottomSheet() {
    final booking = MockData.bookings.first;
    final fareController = TextEditingController(text: booking.totalFare.toStringAsFixed(0));
    final distanceController = TextEditingController(text: booking.totalDistance.toStringAsFixed(0));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            // Alert header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications_active, color: Colors.green, size: 28),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'New Trip Request!',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        'Customer is waiting for a response',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text('30s', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 14)),
                      Text('left', style: TextStyle(color: Colors.orange.shade400, fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Trip details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildTripDetailRow(Icons.person, 'Customer', booking.customerName),
                  const Divider(height: 20),
                  _buildTripDetailRow(Icons.location_on, 'Pickup', booking.pickupLocation),
                  const Divider(height: 20),
                  _buildTripDetailRow(Icons.flag, 'Drop', booking.dropLocation),
                  const Divider(height: 20),
                  _buildTripDetailRow(Icons.route, 'Est. Distance', '${booking.totalDistance.toStringAsFixed(0)} km'),
                  const Divider(height: 20),
                  _buildTripDetailRow(Icons.currency_rupee, 'Est. Fare', '₹${booking.totalFare.toStringAsFixed(0)}'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: distanceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Offered Distance (km)',
                prefixIcon: const Icon(Icons.route),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: fareController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Offered Fare (₹)',
                prefixIcon: const Icon(Icons.currency_rupee),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() => _hasTripRequest = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Trip request declined'),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.close, color: Colors.red),
                    label: const Text('Decline', style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 52),
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() => _hasTripRequest = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('🎉 Trip accepted! Navigation to active trip.'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DriverActiveTripScreen(booking: booking),
                        ),
                      );
                    },
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text('Accept', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 52),
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildTripDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryColor),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
