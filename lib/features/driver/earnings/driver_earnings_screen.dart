import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/extended_models.dart';
import '../../../core/app_providers.dart';
import '../../../core/firestore_service.dart';

class DriverEarningsScreen extends ConsumerWidget {
  final String driverId;

  const DriverEarningsScreen({super.key, required this.driverId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsyncValue = ref.watch(firestoreDriverTripsProvider(driverId));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Earnings & Wallet'),
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: tripsAsyncValue.when(
        data: (trips) {
          final completedTrips = trips
              .where((b) => b.status == BookingStatus.tripCompleted)
              .toList();

          final totalEarned = completedTrips.fold(0.0, (sum, b) => sum + (b.finalFare ?? b.estimatedFare));
          final platformFee = totalEarned * 0.15;
          final netEarnings = totalEarned - platformFee;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ===== NET EARNINGS CARD =====
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Net Earnings',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₹${netEarnings.toStringAsFixed(0)}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(child: _buildEarningChip(
                              'Gross', '₹${totalEarned.toStringAsFixed(0)}')),
                          const SizedBox(width: 12),
                          Expanded(child: _buildEarningChip(
                              'Platform Fee', '₹${platformFee.toStringAsFixed(0)}')),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                /// ===== STATS =====
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        '${completedTrips.length}',
                        'Completed Trips',
                        Icons.check_circle,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        completedTrips.isEmpty
                            ? '-'
                            : '₹${(netEarnings / completedTrips.length).toStringAsFixed(0)}',
                        'Avg Per Trip',
                        Icons.trending_up,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        '₹0',
                        'Pending',
                        Icons.pending,
                        Colors.purple,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                /// ===== WITHDRAW SECTION (FIXED) =====
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Available for Withdrawal',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              '₹${netEarnings.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green),
                            ),
                          ],
                        ),
                      ),

                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 120,
                          maxWidth: 140,
                          minHeight: 45,
                        ),
                        child: ElevatedButton.icon(
                          onPressed: netEarnings <= 0
                              ? null
                              : () => _showWithdrawalDialog(context, ref, netEarnings),
                          icon: const Icon(Icons.account_balance, size: 18, color: Colors.white),
                          label: const Text('Withdraw', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Earning History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                if (completedTrips.isEmpty)
                  _emptyState(),

                ...completedTrips.map((trip) {
                  final fare = trip.finalFare ?? trip.estimatedFare;
                  final netAmount = fare * 0.85;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.local_taxi, color: Colors.green),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                trip.rentalPackage != null 
                                  ? '${trip.pickupLocation} • ${trip.rentalPackage}'
                                  : '${trip.pickupLocation} → ${trip.dropLocation}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              Text(
                                '${trip.tripDate.day}/${trip.tripDate.month}/${trip.tripDate.year}',
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                              ),
                            ],
                          ),
                        ),

                        Text(
                          '+₹${netAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading earnings: $err')),
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(child: Text('No earnings yet')),
    );
  }

  Widget _buildEarningChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Future<void> _showWithdrawalDialog(
    BuildContext context,
    WidgetRef ref,
    double availableAmount,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Request Withdrawal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('You are requesting a withdrawal of:'),
            const SizedBox(height: 8),
            Text(
              '₹${availableAmount.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 12),
            Text(
              'Amount will be transferred to your registered bank account within 1–2 business days.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(firestoreServiceProvider).requestWithdrawal(
        driverId: driverId,
        amount: availableAmount,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Withdrawal request submitted! You\'ll receive it within 1–2 business days.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to request withdrawal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildStatCard(
      String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}
