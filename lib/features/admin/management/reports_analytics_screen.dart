import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../../../core/mock_data.dart';

class ReportsAnalyticsScreen extends StatefulWidget {
  const ReportsAnalyticsScreen({super.key});

  @override
  State<ReportsAnalyticsScreen> createState() => _ReportsAnalyticsScreenState();
}

class _ReportsAnalyticsScreenState extends State<ReportsAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'Monthly';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.download),
            onSelected: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Exporting as $value...')),
              );
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Excel', child: Text('Export as Excel')),
              const PopupMenuItem(value: 'PDF', child: Text('Export as PDF')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildPeriodSelector(),
          _buildKPIRow(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBookingReport(),
                _buildRevenueReport(),
                _buildCabUtilizationReport(),
                _buildCustomerActivityReport(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: ['Today', 'Weekly', 'Monthly', 'Yearly'].map((period) {
          final isSelected = _selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = period),
              child: Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryColor : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  period,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKPIRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _buildKPICard('Total Bookings', '1,284', Icons.book_online, Colors.blue, '+12%')),
          const SizedBox(width: 8),
          Expanded(child: _buildKPICard('Revenue', '₹4.2L', Icons.payments, Colors.green, '+8%')),
          const SizedBox(width: 8),
          Expanded(child: _buildKPICard('Avg Rating', '4.6', Icons.star, Colors.amber, '+0.2')),
        ],
      ),
    );
  }

  Widget _buildKPICard(String label, String value, IconData icon, Color color, String trend) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 9)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(trend, style: const TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(16),
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
          Tab(text: 'Bookings'),
          Tab(text: 'Revenue'),
          Tab(text: 'Cabs'),
          Tab(text: 'Customers'),
        ],
      ),
    );
  }

  Widget _buildBookingReport() {
    final data = [
      {'day': 'Mon', 'count': 45},
      {'day': 'Tue', 'count': 62},
      {'day': 'Wed', 'count': 38},
      {'day': 'Thu', 'count': 71},
      {'day': 'Fri', 'count': 89},
      {'day': 'Sat', 'count': 95},
      {'day': 'Sun', 'count': 78},
    ];
    final maxCount = data.map((d) => d['count'] as int).reduce((a, b) => a > b ? a : b);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Booking Trend', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          SizedBox(
            height: 210,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((d) {
                final count = d['count'] as int;
                final height = (count / maxCount) * 148;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('$count', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Container(
                          height: height,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.primaryColor, Color(0xFF3949AB)],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(d['day'] as String, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Booking by Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          _buildStatusBreakdown(),
        ],
      ),
    );
  }

  Widget _buildStatusBreakdown() {
    final statuses = [
      {'label': 'Completed', 'count': 856, 'color': Colors.green},
      {'label': 'Ongoing', 'count': 42, 'color': Colors.blue},
      {'label': 'Confirmed', 'count': 128, 'color': Colors.teal},
      {'label': 'Cancelled', 'count': 258, 'color': Colors.red},
    ];
    final total = statuses.fold(0, (sum, s) => sum + (s['count'] as int));

    return Column(
      children: statuses.map((s) {
        final count = s['count'] as int;
        final color = s['color'] as Color;
        final percent = (count / total * 100).toStringAsFixed(1);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(s['label'] as String, style: const TextStyle(fontSize: 13)),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: count / total,
                    backgroundColor: color.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 10,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 60,
                child: Text(
                  '$count ($percent%)',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRevenueReport() {
    final agencyRevenue = [
      {'name': 'Quick Travels', 'revenue': 125000.0},
      {'name': 'Elite Cabs', 'revenue': 98000.0},
      {'name': 'City Riders', 'revenue': 76000.0},
      {'name': 'Global Travels', 'revenue': 45000.0},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRevenueSummaryCard(),
          const SizedBox(height: 20),
          const Text('Agency-wise Revenue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          ...agencyRevenue.map((a) => _buildAgencyRevenueRow(a)),
        ],
      ),
    );
  }

  Widget _buildRevenueSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Revenue', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          const Text('₹4,20,000', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildRevenueMini('This Month', '₹1,25,000'),
              const SizedBox(width: 20),
              _buildRevenueMini('Last Month', '₹98,000'),
              const SizedBox(width: 20),
              _buildRevenueMini('Growth', '+27.5%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueMini(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11)),
      ],
    );
  }

  Widget _buildAgencyRevenueRow(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
            child: Text(
              (data['name'] as String)[0],
              style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: (data['revenue'] as double) / 125000,
                  backgroundColor: Colors.grey.shade100,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '₹${((data['revenue'] as double) / 1000).toStringAsFixed(0)}K',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildCabUtilizationReport() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Cab Utilization', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          ...MockData.cabs.map((cab) {
            final utilization = (cab.rating / 5 * 100).toInt();
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(cab.model, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('$utilization% utilized',
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('${cab.type} • ${cab.agencyName}',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: utilization / 100,
                    backgroundColor: Colors.grey.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      utilization > 80 ? Colors.green : utilization > 50 ? Colors.orange : Colors.red,
                    ),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCustomerActivityReport() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Top Customers', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          ...MockData.customers.map((customer) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                    child: Text(
                      customer.name[0],
                      style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(customer.phone, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${customer.totalSpent.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 15),
                      ),
                      Text(
                        '${customer.totalBookings} trips',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
