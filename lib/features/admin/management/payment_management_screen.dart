import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_theme.dart';
import '../../../core/app_providers.dart';
import '../../../core/extended_models.dart';

class PaymentManagementScreen extends ConsumerStatefulWidget {
  const PaymentManagementScreen({super.key});

  @override
  ConsumerState<PaymentManagementScreen> createState() => _PaymentManagementScreenState();
}

class _PaymentManagementScreenState extends ConsumerState<PaymentManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(firestoreAllBookingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Exporting report...')),
            ),
          ),
        ],
      ),
      body: bookingsAsync.when(
        data: (bookings) {
          final revenue = bookings
              .where((b) => b.paymentStatus == PaymentStatus.success)
              .fold(0.0, (sum, b) => sum + (b.finalFare ?? b.estimatedFare));
          final pending = bookings
              .where((b) => b.paymentStatus == PaymentStatus.pending)
              .fold(0.0, (sum, b) => sum + (b.finalFare ?? b.estimatedFare));

          return Column(
            children: [
              _buildRevenueSummary(revenue, pending, bookings.length),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildList(bookings, 'All'),
                    _buildList(bookings, 'Success'),
                    _buildList(bookings, 'Pending'),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildRevenueSummary(double revenue, double pending, int count) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, Color(0xFF3949AB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text('Total Revenue', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Text('₹${revenue.toStringAsFixed(0)}',
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildMiniStat('Transactions', '$count', Colors.white)),
              Container(width: 1, height: 40, color: Colors.white24),
              Expanded(child: _buildMiniStat('Pending', '₹${pending.toStringAsFixed(0)}', Colors.amber)),
              Container(width: 1, height: 40, color: Colors.white24),
              Expanded(child: _buildMiniStat('Refunded', '₹0', Colors.redAccent)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11)),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        indicator: BoxDecoration(color: AppTheme.primaryColor, borderRadius: BorderRadius.circular(12)),
        tabs: const [Tab(text: 'All'), Tab(text: 'Success'), Tab(text: 'Pending')],
      ),
    );
  }

  Widget _buildList(List<TripRequest> all, String filter) {
    final items = all.where((b) {
      if (filter == 'All') return true;
      if (filter == 'Success') return b.paymentStatus == PaymentStatus.success;
      return b.paymentStatus == PaymentStatus.pending;
    }).toList();

    if (items.isEmpty) {
      return Center(child: Text('No $filter transactions'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) => _buildTransactionCard(items[index]),
    );
  }

  Widget _buildTransactionCard(TripRequest booking) {
    final isSuccess = booking.paymentStatus == PaymentStatus.success;
    final color = isSuccess ? Colors.green : Colors.orange;
    final fare = booking.finalFare ?? booking.estimatedFare;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(isSuccess ? Icons.check_circle : Icons.pending, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(booking.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text('#${booking.bookingId} • ${booking.paymentMethod.name.toUpperCase()}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                Text('${booking.tripDate.day}/${booking.tripDate.month}/${booking.tripDate.year}',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('₹${fare.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Text(booking.paymentStatus.name.toUpperCase(),
                    style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
