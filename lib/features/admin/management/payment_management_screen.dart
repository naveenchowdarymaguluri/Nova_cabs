import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../../../core/mock_data.dart';
import '../../../core/models.dart';

class PaymentManagementScreen extends StatefulWidget {
  const PaymentManagementScreen({super.key});

  @override
  State<PaymentManagementScreen> createState() => _PaymentManagementScreenState();
}

class _PaymentManagementScreenState extends State<PaymentManagementScreen>
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

  double get _totalRevenue => MockData.bookings
      .where((b) => b.paymentStatus == 'Success')
      .fold(0, (sum, b) => sum + b.totalFare);

  double get _pendingAmount => MockData.bookings
      .where((b) => b.paymentStatus == 'Pending')
      .fold(0, (sum, b) => sum + b.totalFare);

  @override
  Widget build(BuildContext context) {
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
      body: Column(
        children: [
          _buildRevenueSummary(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTransactionList('All'),
                _buildTransactionList('Success'),
                _buildTransactionList('Pending'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueSummary() {
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
          Text(
            '₹${_totalRevenue.toStringAsFixed(0)}',
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMiniStat('Transactions', '${MockData.bookings.length}', Colors.white),
              ),
              Container(width: 1, height: 40, color: Colors.white24),
              Expanded(
                child: _buildMiniStat('Pending', '₹${_pendingAmount.toStringAsFixed(0)}', Colors.amber),
              ),
              Container(width: 1, height: 40, color: Colors.white24),
              Expanded(
                child: _buildMiniStat('Refunded', '₹21,000', Colors.redAccent),
              ),
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
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        indicator: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Success'),
          Tab(text: 'Pending'),
        ],
      ),
    );
  }

  Widget _buildTransactionList(String filter) {
    final transactions = MockData.bookings.where((b) {
      if (filter == 'All') return true;
      return b.paymentStatus == filter;
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      itemBuilder: (context, index) => _buildTransactionCard(transactions[index]),
    );
  }

  Widget _buildTransactionCard(Booking booking) {
    final isSuccess = booking.paymentStatus == 'Success';
    final isPending = booking.paymentStatus == 'Pending';
    final isRefunded = booking.paymentStatus == 'Refunded';

    Color statusColor = isSuccess
        ? Colors.green
        : isPending
            ? Colors.orange
            : Colors.red;

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
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSuccess ? Icons.check_circle : isPending ? Icons.pending : Icons.replay,
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.customerName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  '#${booking.id} • ${booking.paymentMethod}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                Text(
                  booking.date,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${booking.totalFare.toStringAsFixed(0)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isRefunded ? Colors.red : Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  booking.paymentStatus,
                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
