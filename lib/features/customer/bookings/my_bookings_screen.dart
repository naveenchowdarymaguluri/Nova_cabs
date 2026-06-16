import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/app_theme.dart';
import '../../../core/extended_models.dart';
import '../../../core/app_providers.dart';

class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final customerId = authState.userId ?? '';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('My Bookings'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: _buildFilterBar(),
        ),
      ),
      body: customerId.isEmpty
          ? _buildLoginPrompt()
          : ref.watch(firestoreCustomerBookingsProvider(customerId)).when(
              data: (bookings) {
                final filtered = _filter == 'All'
                    ? bookings
                    : bookings.where((b) {
                        if (_filter == 'Completed' &&
                            (b.status == BookingStatus.tripCompleted ||
                                b.status == BookingStatus.paymentCompleted ||
                                b.status == BookingStatus.completed)) return true;
                        if (_filter == 'Cancelled' &&
                            b.status == BookingStatus.cancelled) return true;
                        // "Upcoming" covers all active/in-progress statuses so
                        // no booking ever silently disappears from the list.
                        if (_filter == 'Upcoming' &&
                            (b.status == BookingStatus.booked ||
                                b.status == BookingStatus.newBooking ||
                                b.status == BookingStatus.confirmed ||
                                b.status == BookingStatus.driverAccepted ||
                                b.status == BookingStatus.driverArriving ||
                                b.status == BookingStatus.tripStarted)) return true;
                        return false;
                      }).toList();

                if (filtered.isEmpty) return _buildEmptyState();

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) => _buildBookingCard(filtered[index]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cloud_off_outlined, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(
                        'Could not load bookings',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        err.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
              ),
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

  Widget _buildBookingCard(TripRequest booking) {
    Color statusColor = Colors.green;
    String statusText = 'Completed';
    
    if (booking.status == BookingStatus.cancelled) {
      statusColor = Colors.red;
      statusText = 'Cancelled';
    } else if (booking.status == BookingStatus.booked || booking.status == BookingStatus.driverAccepted) {
      statusColor = Colors.blue;
      statusText = 'Upcoming';
    } else if (booking.status == BookingStatus.tripStarted || booking.status == BookingStatus.driverArriving) {
      statusColor = Colors.orange;
      statusText = 'Ongoing';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
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
                      DateFormat('EEE, dd MMM yyyy').format(booking.tripDate),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        statusText,
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildRouteRow(Icons.my_location, booking.pickupLocation, Colors.green),
                const SizedBox(height: 8),
                _buildRouteRow(Icons.location_on, booking.dropLocation, Colors.red),
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
                    Text(booking.driverId != null ? 'Driver Assigned' : 'Awaiting Driver', style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w600)),
                   ],
                ),
                Text(
                  '₹${booking.estimatedFare.toInt()}',
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

  Widget _buildLoginPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline_rounded, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'Login to view your bookings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Your trip history will appear here once you sign in.',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
