import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_theme.dart';
import '../../../core/extended_models.dart';
import '../../../core/app_providers.dart';
import '../../../core/extended_mock_data.dart';
import '../../../core/mock_data.dart';
import '../../role_selection/role_selection_screen.dart';
import 'agency_driver_details_screen.dart';

/// Agency Dashboard — READ ONLY access to operational data
/// Agency owners can view but NOT modify pricing or platform settings
class AgencyDashboard extends ConsumerStatefulWidget {
  final AgencyModel agency;

  const AgencyDashboard({super.key, required this.agency});

  @override
  ConsumerState<AgencyDashboard> createState() => _AgencyDashboardState();
}

class _DriverProfile {
  final String icon;
  final String label;
  _DriverProfile(this.icon, this.label);
}

class _AgencyDashboardState extends ConsumerState<AgencyDashboard> {
  int _currentNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHomePage(),
      _buildDriversPage(),
      _buildBookingsPage(),
      _buildReportsPage(),
      _buildProfilePage(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      body: pages[_currentNavIndex],
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: const Color(0xFFE65100).withValues(alpha: 0.15),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentNavIndex,
          onDestinationSelected: (i) => setState(() => _currentNavIndex = i),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.dashboard_outlined),
              selectedIcon: const Icon(Icons.dashboard, color: Color(0xFFE65100)),
              label: 'Overview',
            ),
            NavigationDestination(
              icon: const Icon(Icons.people_outlined),
              selectedIcon: const Icon(Icons.people, color: Color(0xFFE65100)),
              label: 'Drivers',
            ),
            NavigationDestination(
              icon: const Icon(Icons.book_online_outlined),
              selectedIcon: const Icon(Icons.book_online, color: Color(0xFFE65100)),
              label: 'Bookings',
            ),
            NavigationDestination(
              icon: const Icon(Icons.bar_chart_outlined),
              selectedIcon: const Icon(Icons.bar_chart, color: Color(0xFFE65100)),
              label: 'Reports',
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outlined),
              selectedIcon: const Icon(Icons.person, color: Color(0xFFE65100)),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomePage() {
    final agency = widget.agency;
    final driversAsync = ref.watch(firestoreAgencyDriversProvider(agency.id));
    final bookingsAsync = ref.watch(firestoreAllBookingsProvider);

    return driversAsync.when(
      data: (drivers) {
        final onlineDrivers = drivers.where((d) => d.isOnline).length;
        
        return bookingsAsync.when(
          data: (allBookings) {
            final driverIds = drivers.map((d) => d.id).toSet();
            final agencyBookings = allBookings.where((b) => b.driverId != null && driverIds.contains(b.driverId)).toList();
            final totalRevenue = agencyBookings.fold(0.0, (s, b) => s + (b.finalFare ?? b.estimatedFare));

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true, pinned: true, backgroundColor: Colors.white, elevation: 0,
                  automaticallyImplyLeading: false,
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: const Color(0xFFE65100), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.business, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(agency.agencyName, style: const TextStyle(fontSize: 14, color: Color(0xFFE65100), fontWeight: FontWeight.bold)),
                          const Text('Agency Portal', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                  actions: [
                    Container(
                      margin: const EdgeInsets.only(right: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(8)),
                      child: const Row(
                        children: [
                          Icon(Icons.visibility, size: 14, color: Colors.orange),
                          SizedBox(width: 4),
                          Text('Read Only', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orange)),
                        ],
                      ),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFFE65100), Color(0xFFFF9800)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [BoxShadow(color: const Color(0xFFE65100).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Welcome,', style: TextStyle(color: Colors.white70, fontSize: 13)),
                                    Text(agency.ownerName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text(agency.agencyName, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.business, color: Colors.white38, size: 48),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text('Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        GridView.count(
                          crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.5,
                          children: [
                            _buildStatCard('${drivers.length}', 'Total Drivers', Icons.people, Colors.blue),
                            _buildStatCard('$onlineDrivers', 'Online Drivers', Icons.radio_button_checked, Colors.green),
                            _buildStatCard('${agencyBookings.length}', 'Total Bookings', Icons.book_online, Colors.orange),
                            _buildStatCard('₹${(totalRevenue / 1000).toStringAsFixed(totalRevenue >= 1000 ? 1 : 0)}${totalRevenue >= 1000 ? 'K' : ''}', 'Total Revenue', Icons.payments, Colors.purple),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.amber.shade200)),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.amber.shade800, size: 18),
                              const SizedBox(width: 10),
                              Expanded(child: Text('Agency portal is READ ONLY. You can view bookings, drivers, and reports but cannot modify pricing or platform settings.', style: TextStyle(color: Colors.amber.shade900, fontSize: 12, height: 1.4))),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text('Recent Bookings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        ...agencyBookings.take(5).map((b) {
                          final statusColors = {BookingStatus.tripCompleted: Colors.green, BookingStatus.driverAccepted: Colors.blue, BookingStatus.booked: Colors.orange};
                          final color = statusColors[b.status] ?? Colors.grey;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)]),
                            child: Row(
                              children: [
                                CircleAvatar(backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1), child: Text(b.customerName[0], style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold))),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(b.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      Text('${b.pickupLocation} → ${b.dropLocation}', style: TextStyle(color: Colors.grey.shade500, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('₹${(b.finalFare ?? b.estimatedFare).toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                                      child: Text(b.status.name.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Error loading bookings: $e')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error loading drivers: $e')),
    );
  }

  Widget _buildDriversPage() {
    final driversAsync = ref.watch(firestoreAgencyDriversProvider(widget.agency.id));

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('My Drivers'), 
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => _showAddDriverDialog(),
            icon: const Icon(Icons.person_add_alt_1, color: Color(0xFFE65100)),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDriverDialog(),
        backgroundColor: const Color(0xFFE65100),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Individual Driver', style: TextStyle(color: Colors.white)),
      ),
      body: driversAsync.when(
        data: (myDrivers) {
          if (myDrivers.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('No drivers assigned to your agency yet.'),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: myDrivers.length,
            itemBuilder: (context, i) {
              final driver = myDrivers[i];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AgencyDriverDetailsScreen(driver: driver),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.blue.shade50,
                        child: Text(driver.fullName[0], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(driver.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(driver.vehicleModel, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                            Text(driver.vehicleNumber, style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: driver.isOnline ? Colors.green.shade50 : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              driver.isOnline ? 'Online' : 'Offline',
                              style: TextStyle(
                                color: driver.isOnline ? Colors.green : Colors.grey,
                                fontWeight: FontWeight.bold, fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 14),
                              Text(driver.rating.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildBookingsPage() {
    final driversAsync = ref.watch(firestoreAgencyDriversProvider(widget.agency.id));
    final bookingsAsync = ref.watch(firestoreAllBookingsProvider);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(title: const Text('Bookings'), automaticallyImplyLeading: false),
      body: driversAsync.when(
        data: (drivers) {
          final driverIds = drivers.map((d) => d.id).toSet();
          
          return bookingsAsync.when(
            data: (allBookings) {
              final agencyBookings = allBookings.where((b) => b.driverId != null && driverIds.contains(b.driverId)).toList();
              
              if (agencyBookings.isEmpty) {
                return const Center(child: Text('No bookings found for your agency.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: agencyBookings.length,
                itemBuilder: (context, i) {
                  final b = agencyBookings[i];
                  final statusColors = {BookingStatus.tripCompleted: Colors.green, BookingStatus.driverAccepted: Colors.blue, BookingStatus.booked: Colors.orange};
                  final color = statusColors[b.status] ?? Colors.grey;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('#${b.bookingId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                              child: Text(b.status.name.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('${b.pickupLocation} → ${b.dropLocation}', style: TextStyle(color: Colors.grey.shade700, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${b.tripDate.day}/${b.tripDate.month}/${b.tripDate.year} • ${b.tripTime}', style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
                            Text('₹${(b.finalFare ?? b.estimatedFare).toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 14)),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildReportsPage() {
    final driversAsync = ref.watch(firestoreAgencyDriversProvider(widget.agency.id));
    final bookingsAsync = ref.watch(firestoreAllBookingsProvider);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(title: const Text('Reports'), automaticallyImplyLeading: false),
      body: driversAsync.when(
        data: (drivers) {
          final driverIds = drivers.map((d) => d.id).toSet();
          
          return bookingsAsync.when(
            data: (allBookings) {
              final agencyBookings = allBookings.where((b) => b.driverId != null && driverIds.contains(b.driverId)).toList();
              final totalRevenue = agencyBookings.fold(0.0, (s, b) => s + (b.finalFare ?? b.estimatedFare));
              final completed = agencyBookings.where((b) => b.status == BookingStatus.tripCompleted).length;
              final billed = agencyBookings.where((b) => b.status == BookingStatus.paymentCompleted).length; // Map to appropriate statuses
              final ongoing = agencyBookings.where((b) => b.status == BookingStatus.driverAccepted || b.status == BookingStatus.arrived).length;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Agency Performance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildReportCard('Revenue Overview', [
                      _reportRow('Total Revenue', '₹${totalRevenue.toStringAsFixed(0)}', Colors.green),
                      _reportRow('Platform Commission (15%)', '₹${(totalRevenue * 0.15).toStringAsFixed(0)}', Colors.red),
                      _reportRow('Net Earnings', '₹${(totalRevenue * 0.85).toStringAsFixed(0)}', Colors.blue),
                    ]),
                    const SizedBox(height: 16),
                    _buildReportCard('Booking Summary', [
                      _reportRow('Total Bookings', '${agencyBookings.length}', Colors.orange),
                      _reportRow('Completed', '${completed + billed}', Colors.green),
                      _reportRow('Ongoing', '$ongoing', Colors.blue),
                      _reportRow('New/Pending', '${agencyBookings.where((b) => b.status == BookingStatus.booked).length}', Colors.grey),
                    ]),
                    const SizedBox(height: 16),
                    _buildReportCard('Driver Summary', [
                      _reportRow('Total Drivers', '${drivers.length}', Colors.purple),
                      _reportRow('Active (Online)', '${drivers.where((d) => d.isOnline).length}', Colors.green),
                      _reportRow('Avg Driver Rating', '4.6', Colors.amber), // Mock for now
                    ]),
                    const SizedBox(height: 80),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildReportCard(String title, List<Widget> rows) {
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
          ...rows,
        ],
      ),
    );
  }

  Widget _reportRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildProfilePage() {
    final agency = widget.agency;
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(title: const Text('Agency Profile'), automaticallyImplyLeading: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFE65100), Color(0xFFFF9800)]),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                    child: const Icon(Icons.business, color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 12),
                  Text(agency.agencyName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(agency.ownerName, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(20)),
                    child: Text(agency.statusLabel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildInfoCard('Contact Information', [
              _infoRow(Icons.phone, 'Phone', agency.phoneNumber),
              _infoRow(Icons.email, 'Email', agency.email),
              _infoRow(Icons.location_on, 'Address', agency.businessAddress),
            ]),
            const SizedBox(height: 16),
            _buildInfoCard('Business Details', [
              if (agency.gstNumber != null) _infoRow(Icons.receipt, 'GST', agency.gstNumber!),
            ]),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ref.read(authProvider.notifier).logout();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
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

  Widget _buildInfoCard(String title, List<Widget> rows) {
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
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 8),
          ...rows,
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFFE65100)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showAddDriverDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final vehicleCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Individual Driver'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person))),
              const SizedBox(height: 12),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Mobile Number', prefixIcon: Icon(Icons.phone), prefixText: '+91 ')),
              const SizedBox(height: 12),
              TextField(controller: vehicleCtrl, decoration: const InputDecoration(labelText: 'Vehicle Model', prefixIcon: Icon(Icons.car_rental))),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              // Mock success
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Verification link sent to driver!'), backgroundColor: Colors.green),
              );
            },
            child: const Text('Add Driver'),
          ),
        ],
      ),
    );
  }
}
