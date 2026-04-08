import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/app_theme.dart';
import '../../../core/extended_models.dart';

class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen> {
  String _filter = 'All';

  final List<Map<String, dynamic>> _mockBookings = [
    {
      'id': 'BK1002',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'pickup': 'Indiranagar, Bangalore',
      'drop': 'Kempegowda Int. Airport',
      'fare': 1250.0,
      'driver': 'Ramesh Kumar',
      'status': 'Completed',
    },
    {
      'id': 'BK1005',
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'pickup': 'Koramangala 5th Block',
      'drop': 'MG Road Metro Station',
      'fare': 350.0,
      'driver': 'Suresh Patel',
      'status': 'Cancelled',
    },
    {
      'id': 'BK1008',
      'date': DateTime.now().add(const Duration(days: 2)),
      'pickup': 'Whitefield, ITPL',
      'drop': 'Electronic City Phase 1',
      'fare': 850.0,
      'driver': 'Priya Devi',
      'status': 'Upcoming',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _filter == 'All' 
        ? _mockBookings 
        : _mockBookings.where((b) => b['status'] == _filter).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('My Bookings'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: _buildFilterBar(),
        ),
      ),
      body: filtered.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                return _buildBookingCard(filtered[index]);
              },
            ),
    );
  }

  Widget _buildFilterBar() {
    final filters = ['All', 'Upcoming', 'Completed', 'Cancelled'];
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          bool isSelected = _filter == filters[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filters[index]),
              selected: isSelected,
              onSelected: (val) => setState(() => _filter = filters[index]),
              selectedColor: AppTheme.accentColor,
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.primaryColor : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    Color statusColor = Colors.green;
    if (booking['status'] == 'Cancelled') statusColor = Colors.red;
    if (booking['status'] == 'Upcoming') statusColor = Colors.blue;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('EEE, dd MMM yyyy').format(booking['date']),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        booking['status'],
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildRouteRow(Icons.my_location, booking['pickup'], Colors.green),
                const SizedBox(height: 8),
                _buildRouteRow(Icons.location_on, booking['drop'], Colors.red),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(booking['driver'], style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                  ],
                ),
                Text(
                  '₹${booking['fare'].toInt()}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteRow(IconData icon, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 12),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.directions_car_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('No $_filter bookings found', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
        ],
      ),
    );
  }
}
