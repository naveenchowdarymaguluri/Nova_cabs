import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/mock_data.dart';
import '../../../core/app_providers.dart';

/// Driver Trip History Screen
class DriverTripHistoryScreen extends ConsumerWidget {
  final String driverId;
  const DriverTripHistoryScreen({super.key, required this.driverId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allBookings = ref.watch(bookingProvider);
    final trips = allBookings.where((b) => b.driverId == driverId).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Trip History'),
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: trips.isEmpty
          ? const Center(child: Text('No trips yet'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: trips.length,
              itemBuilder: (context, index) {
                final trip = trips[index];
                final statusColors = {
                  'Completed': Colors.green,
                  'Ongoing': Colors.blue,
                  'Confirmed': Colors.teal,
                  'Cancelled': Colors.red,
                  'New': Colors.orange,
                };
                final color = statusColors[trip.status] ?? Colors.grey;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '#${trip.id}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              trip.status,
                              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, color: Colors.green, size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              trip.pickupLocation,
                              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(Icons.more_vert, size: 14, color: Colors.grey),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.flag_outlined, color: Colors.red, size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              trip.dropLocation,
                              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${trip.date} • ${trip.time}',
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.currency_rupee, color: Colors.green, size: 16),
                              Text(
                                trip.totalFare.toStringAsFixed(0),
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
