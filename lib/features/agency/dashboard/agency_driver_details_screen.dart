import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/app_theme.dart';
import '../../../core/extended_models.dart';
import '../../../core/mock_data.dart';
import '../../../core/models.dart';

class AgencyDriverDetailsScreen extends ConsumerWidget {
  final DriverModel driver;

  const AgencyDriverDetailsScreen({super.key, required this.driver});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driverBookings = MockData.bookings.where((b) => b.driverId == driver.id).toList();

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      body: CustomScrollView(
        slivers: [
          // Premium Header
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: const Color(0xFFE65100),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE65100), Color(0xFFFF9800)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: Text(
                        driver.fullName[0],
                        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      driver.fullName,
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: driver.isOnline ? Colors.green : Colors.grey.shade700,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            driver.isOnline ? 'ONLINE' : 'OFFLINE',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          driver.rating.toString(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Operational Stats
                  _buildSectionTitle('Operational Statistics'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildStatBox('Total Trips', '${driver.totalTrips}', Icons.route, Colors.blue),
                      const SizedBox(width: 12),
                      _buildStatBox('Earnings', '₹${(driver.totalEarnings / 1000).toStringAsFixed(1)}K', Icons.payments, Colors.green),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildStatBox('Completion', '98%', Icons.check_circle, Colors.orange),
                      const SizedBox(width: 12),
                      _buildStatBox('Member Since', 'Jan 2024', Icons.calendar_today, Colors.purple),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Vehicle Details
                  _buildSectionTitle('Vehicle Information'),
                  const SizedBox(height: 12),
                  _buildDetailsCard([
                    _buildDetailRow(Icons.directions_car, 'Model', driver.vehicleModel),
                    _buildDetailRow(Icons.tag, 'Reg Number', driver.vehicleNumber),
                    _buildDetailRow(Icons.event_seat, 'Type', driver.vehicleType),
                    _buildDetailRow(Icons.verified_user, 'RC Number', driver.vehicleRc),
                    _buildDetailRow(Icons.security, 'Insurance', driver.insuranceNumber),
                  ]),

                  const SizedBox(height: 24),

                  // Driver Identifiers
                  _buildSectionTitle('Personal Identifiers'),
                  const SizedBox(height: 12),
                  _buildDetailsCard([
                    _buildDetailRow(Icons.badge, 'ID', driver.id),
                    _buildDetailRow(Icons.phone, 'Mobile', driver.mobileNumber),
                    _buildDetailRow(Icons.credit_card, 'Aadhaar', driver.aadhaarNumber),
                    _buildDetailRow(Icons.card_membership, 'License', driver.drivingLicense),
                  ]),

                  const SizedBox(height: 24),

                  // Pricing Configuration
                  _buildSectionTitle('Pricing Setup'),
                  const SizedBox(height: 12),
                  _buildDetailsCard([
                    _buildDetailRow(Icons.home, 'Base Fare', '₹${driver.pricing?.baseFare.toStringAsFixed(0) ?? '100'}'),
                    _buildDetailRow(Icons.speed, 'Price/KM', '₹${driver.pricing?.pricePerKm.toStringAsFixed(0) ?? '12'}'),
                    _buildDetailRow(Icons.nights_stay, 'Night Charges', '₹${driver.pricing?.nightCharges.toStringAsFixed(0) ?? '150'}'),
                    _buildDetailRow(Icons.toll, 'Toll Policy', driver.pricing?.tollPolicy ?? 'Extra'),
                  ]),

                  const SizedBox(height: 24),

                  // Recent Trips
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle('Recent Assigned Trips'),
                      TextButton(onPressed: () {}, child: const Text('View All')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (driverBookings.isEmpty)
                    _buildEmptyState('No recent trips assigned to this driver.')
                  else
                    ...driverBookings.map((b) => _buildTripListItem(b)),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      // Floating Action Button for contacting or quick actions
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final phone = driver.mobileNumber.replaceAll(' ', '');
          final Uri launchUri = Uri(
            scheme: 'tel',
            path: phone,
          );
          if (await canLaunchUrl(launchUri)) {
            await launchUrl(launchUri);
          } else {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Unable to open dialer')),
            );
          }
        },
        backgroundColor: const Color(0xFFE65100),
        icon: const Icon(Icons.phone, color: Colors.white),
        label: const Text('Contact Driver', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFE65100)),
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          final isLast = entry.key == children.length - 1;
          return Column(
            children: [
              entry.value,
              if (!isLast) const Divider(height: 1, indent: 48),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade400),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildTripListItem(Booking b) {
    final statusColor = {
      'Completed': Colors.green, 'Ongoing': Colors.blue,
      'Confirmed': Colors.teal, 'Cancelled': Colors.red, 'New': Colors.orange,
    }[b.status] ?? Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.map, color: Color(0xFFE65100), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('#${b.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text('${b.pickupLocation} → ${b.dropLocation}', style: TextStyle(color: Colors.grey.shade500, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('₹${b.totalFare.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(b.status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Icon(Icons.history_toggle_off, color: Colors.grey.shade300, size: 48),
          const SizedBox(height: 12),
          Text(message, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        ],
      ),
    );
  }
}
