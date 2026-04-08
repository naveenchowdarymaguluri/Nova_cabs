import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/desktop_theme.dart';
import '../shared/desktop_widgets.dart';
import '../../../core/models.dart';
import '../../../core/mock_data.dart';

final paymentSearchProvider = StateProvider<String>((ref) => '');

class PaymentManagementDesktopScreen extends ConsumerWidget {
  const PaymentManagementDesktopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final search = ref.watch(paymentSearchProvider);
    final bookings = MockData.bookings.where((b) => 
      b.id.contains(search) || 
      b.customerName.toLowerCase().contains(search.toLowerCase()) ||
      b.customerPhone.contains(search)
    ).toList();
    final totalSuccess = bookings.where((b) => b.paymentStatus == 'Success').toList();
    final totalFailed = bookings.where((b) => b.paymentStatus == 'Failed').toList();
    final totalPending = bookings.where((b) => b.paymentStatus == 'Pending').toList();
    final totalRevenue = totalSuccess.fold<double>(0, (s, b) => s + b.totalFare);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesktopTheme.contentPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(
            title: 'Payment Management',
            subtitle: 'Monitor all transactions and payment activities',
          ),
          const SizedBox(height: 20),

          // Stat cards
          Row(
            children: [
              Expanded(child: _PayStat('Total Revenue', '₹${(totalRevenue / 1000).toStringAsFixed(1)}K', DesktopTheme.successGreen, Icons.payments)),
              const SizedBox(width: 12),
              Expanded(child: _PayStat('Successful', '${totalSuccess.length}', DesktopTheme.primaryBlue, Icons.check_circle)),
              const SizedBox(width: 12),
              Expanded(child: _PayStat('Pending', '${totalPending.length}', DesktopTheme.warningAmber, Icons.hourglass_empty)),
              const SizedBox(width: 12),
              Expanded(child: _PayStat('Failed', '${totalFailed.length}', DesktopTheme.dangerRed, Icons.error)),
              const SizedBox(width: 12),
              Expanded(child: _PayStat('Avg Transaction', '₹${totalSuccess.isEmpty ? 0 : (totalRevenue / totalSuccess.length).toStringAsFixed(0)}', DesktopTheme.accentTeal, Icons.analytics)),
            ],
          ),
          const SizedBox(height: 20),

          // Charts row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildPaymentMethodChart()),
              const SizedBox(width: 16),
              Expanded(flex: 3, child: _buildMonthlyPaymentsChart()),
            ],
          ),
          const SizedBox(height: 20),

          // Transaction table
          _buildTransactionTable(bookings, ref),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DesktopTheme.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DesktopTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Payment Methods', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: DesktopTheme.textPrimary)),
          const SizedBox(height: 4),
          const Text('Distribution by method', style: TextStyle(fontSize: 12, color: DesktopTheme.textMuted)),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(value: 65, color: DesktopTheme.primaryBlue, title: '65%\nUPI', radius: 55, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                  PieChartSectionData(value: 22, color: DesktopTheme.accentTeal, title: '22%\nOnline', radius: 55, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                  PieChartSectionData(value: 13, color: DesktopTheme.warningAmber, title: '13%\nCash', radius: 55, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
                sectionsSpace: 4,
                centerSpaceRadius: 28,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _Legend(color: DesktopTheme.primaryBlue, label: 'UPI', value: '65%'),
          const SizedBox(height: 6),
          _Legend(color: DesktopTheme.accentTeal, label: 'Online', value: '22%'),
          const SizedBox(height: 6),
          _Legend(color: DesktopTheme.warningAmber, label: 'Cash', value: '13%'),
        ],
      ),
    );
  }

  Widget _buildMonthlyPaymentsChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DesktopTheme.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DesktopTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Monthly Revenue Trend', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: DesktopTheme.textPrimary)),
          const SizedBox(height: 4),
          const Text('Last 6 months breakdown', style: TextStyle(fontSize: 12, color: DesktopTheme.textMuted)),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 500000,
                barGroups: [
                  _bg(0, 280000, 180000),
                  _bg(1, 310000, 210000),
                  _bg(2, 260000, 170000),
                  _bg(3, 380000, 240000),
                  _bg(4, 350000, 220000),
                  _bg(5, 421850, 260000),
                ],
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 100000,
                  getDrawingHorizontalLine: (v) => FlLine(color: DesktopTheme.border, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, m) {
                        const months = ['Oct', 'Nov', 'Dec', 'Jan', 'Feb', 'Mar'];
                        return Text(months[v.toInt()], style: const TextStyle(fontSize: 10, color: DesktopTheme.textMuted));
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (v, m) => Text('₹${(v / 1000).toInt()}K', style: const TextStyle(fontSize: 9, color: DesktopTheme.textMuted)),
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Legend(color: DesktopTheme.primaryBlue, label: 'Total Revenue', value: ''),
              const SizedBox(width: 20),
              _Legend(color: DesktopTheme.accentTeal, label: 'Platform Commission', value: ''),
            ],
          ),
        ],
      ),
    );
  }

  BarChartGroupData _bg(int x, double total, double commission) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(toY: total, color: DesktopTheme.primaryBlue, width: 16, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
        BarChartRodData(toY: commission, color: DesktopTheme.accentTeal, width: 16, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
      ],
      barsSpace: 4,
    );
  }

  Widget _buildTransactionTable(List<Booking> bookings, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: DesktopTheme.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DesktopTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: DesktopTheme.contentBg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              border: Border(bottom: BorderSide(color: DesktopTheme.border)),
            ),
            child: Row(
              children: [
                const Text('All Transactions', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(width: 24),
                DesktopSearchBar(
                  hint: 'Search by ID, customer...',
                  width: 320,
                  onChanged: (v) => ref.read(paymentSearchProvider.notifier).state = v,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: DesktopTheme.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${bookings.length} records', style: const TextStyle(fontSize: 12, color: DesktopTheme.primaryBlue, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          // Table headers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: const [
                Expanded(flex: 2, child: _TH('Booking ID')),
                Expanded(flex: 3, child: _TH('Customer')),
                Expanded(flex: 3, child: _TH('Driver / Agency')),
                Expanded(flex: 2, child: _TH('Amount')),
                Expanded(flex: 2, child: _TH('Method')),
                Expanded(flex: 2, child: _TH('Status')),
              ],
            ),
          ),
          const Divider(color: DesktopTheme.border, height: 1),
          ...bookings.map((b) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: DesktopTheme.borderLight)),
            ),
            child: Row(
              children: [
                Expanded(flex: 2, child: Text(b.id, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: DesktopTheme.primaryBlue))),
                Expanded(flex: 3, child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(b.customerName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                    Text(b.customerPhone, style: const TextStyle(fontSize: 11, color: DesktopTheme.textMuted)),
                  ],
                )),
                Expanded(flex: 3, child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(b.cab.agencyName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                    Text(b.cab.model, style: const TextStyle(fontSize: 11, color: DesktopTheme.textMuted)),
                  ],
                )),
                Expanded(flex: 2, child: Text('₹${b.totalFare.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700))),
                Expanded(flex: 2, child: Text(b.paymentMethod, style: const TextStyle(fontSize: 12))),
                Expanded(flex: 2, child: StatusBadge(b.paymentStatus)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _PayStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _PayStat(this.label, this.value, this.color, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesktopTheme.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: DesktopTheme.border),
      ),
      child: Row(children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 18)),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
          Text(label, style: const TextStyle(fontSize: 11, color: DesktopTheme.textMuted)),
        ]),
      ]),
    );
  }
}

class _TH extends StatelessWidget {
  final String label;
  const _TH(this.label);
  @override
  Widget build(BuildContext context) {
    return Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: DesktopTheme.textMuted, letterSpacing: 0.5));
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  const _Legend({required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: DesktopTheme.textSecondary)),
        if (value.isNotEmpty) ...[
          const SizedBox(width: 4),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: DesktopTheme.textPrimary)),
        ],
      ],
    );
  }
}
