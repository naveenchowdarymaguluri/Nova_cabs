import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/desktop_theme.dart';
import '../shared/desktop_widgets.dart';
import '../../../core/app_providers.dart';
import '../../../core/extended_models.dart';

class ReportsAnalyticsDesktopScreen extends ConsumerWidget {
  const ReportsAnalyticsDesktopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(bookingProvider);
    final drivers = ref.watch(driverListProvider);
    final agencies = ref.watch(agencyListProvider);
    final totalRevenue = bookings
        .where((b) => b.paymentStatus == PaymentStatus.success)
        .fold<double>(0, (sum, b) => sum + _tripAmount(b));
    final totalDistance = bookings.fold<double>(
      0,
      (sum, b) => sum + (b.actualDistance ?? b.estimatedDistance),
    );
    final avgDistance = bookings.isEmpty ? 0 : totalDistance / bookings.length;
    final cancellationRate = bookings.isEmpty
        ? 0
        : bookings.where((b) => b.status == BookingStatus.cancelled).length /
              bookings.length *
              100;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesktopTheme.contentPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            title: 'Reports & Analytics',
            subtitle: 'Comprehensive platform analytics and export tools',
            action: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PrimaryButton(
                  label: 'Export Excel',
                  icon: Icons.table_chart,
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Excel export coming soon'), behavior: SnackBarBehavior.floating),
                  ),
                  outlined: true,
                ),
                const SizedBox(width: 8),
                PrimaryButton(
                  label: 'Export PDF',
                  icon: Icons.picture_as_pdf,
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PDF export coming soon'), behavior: SnackBarBehavior.floating),
                  ),
                  outlined: true,
                ),
                const SizedBox(width: 8),
                PrimaryButton(
                  label: 'Export CSV',
                  icon: Icons.file_download,
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('CSV export coming soon'), behavior: SnackBarBehavior.floating),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // KPI Summary
          Row(
            children: [
              Expanded(
                child: _KPICard(
                  label: 'Total Bookings',
                  value: '${bookings.length}',
                  trend: '+0%',
                  trendUp: true,
                  icon: Icons.book_online,
                  color: DesktopTheme.primaryBlue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _KPICard(
                  label: 'Total Revenue',
                  value: '₹${(totalRevenue / 100000).toStringAsFixed(1)}L',
                  trend: '+0%',
                  trendUp: true,
                  icon: Icons.payments,
                  color: DesktopTheme.successGreen,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _KPICard(
                  label: 'Avg Trip Distance',
                  value: '${avgDistance.toStringAsFixed(1)} km',
                  trend: '+0%',
                  trendUp: true,
                  icon: Icons.route,
                  color: DesktopTheme.accentTeal,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _KPICard(
                  label: 'Cancellation Rate',
                  value: '${cancellationRate.toStringAsFixed(1)}%',
                  trend: '${cancellationRate.toStringAsFixed(1)}%',
                  trendUp: false,
                  icon: Icons.cancel,
                  color: DesktopTheme.dangerRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Revenue + Bookings side by side
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildAnnualRevenueChart(bookings)),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: _buildBookingsByType(bookings)),
            ],
          ),
          const SizedBox(height: 16),

          // Driver Earnings + Agency Performance
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildDriverEarnings(drivers)),
              const SizedBox(width: 16),
              Expanded(flex: 3, child: _buildAgencyPerformance(agencies)),
            ],
          ),
          const SizedBox(height: 16),

          // Report List
          _buildReportList(context),
        ],
      ),
    );
  }

  Widget _buildAnnualRevenueChart(List<TripRequest> bookings) {
    final monthly = _monthlyRevenue(bookings, 12);

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
          const Text(
            'Annual Revenue Breakdown',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          const Text(
            'Monthly revenue vs commission collected',
            style: TextStyle(fontSize: 12, color: DesktopTheme.textMuted),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 100000,
                  getDrawingHorizontalLine: (v) =>
                      FlLine(color: DesktopTheme.border, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 55,
                      getTitlesWidget: (v, m) => Text(
                        '₹${(v / 1000).toInt()}K',
                        style: const TextStyle(
                          fontSize: 9,
                          color: DesktopTheme.textMuted,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, m) {
                        const months = [
                          'Jan',
                          'Feb',
                          'Mar',
                          'Apr',
                          'May',
                          'Jun',
                          'Jul',
                          'Aug',
                          'Sep',
                          'Oct',
                          'Nov',
                          'Dec',
                        ];
                        return Text(
                          months[v.toInt() % 12],
                          style: const TextStyle(
                            fontSize: 9,
                            color: DesktopTheme.textMuted,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      for (var i = 0; i < monthly.length; i++)
                        FlSpot(i.toDouble(), monthly[i].total),
                    ],
                    isCurved: true,
                    color: DesktopTheme.primaryBlue,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          DesktopTheme.primaryBlue.withValues(alpha: 0.15),
                          DesktopTheme.primaryBlue.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                  LineChartBarData(
                    spots: [
                      for (var i = 0; i < monthly.length; i++)
                        FlSpot(i.toDouble(), monthly[i].total * 0.30),
                    ],
                    isCurved: true,
                    color: DesktopTheme.accentTeal,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    dashArray: [5, 4],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Legend(color: DesktopTheme.primaryBlue, label: 'Revenue'),
              const SizedBox(width: 16),
              _Legend(
                color: DesktopTheme.accentTeal,
                label: 'Commission (30%)',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsByType(List<TripRequest> bookings) {
    final four = bookings.where((b) => b.cabType == '4-Seater').length;
    final seven = bookings.where((b) => b.cabType == '7-Seater').length;
    final thirteen = bookings.where((b) => b.cabType == '13-Seater').length;
    final total = bookings.isEmpty ? 1 : bookings.length;
    String pct(int count) => ((count / total) * 100).toStringAsFixed(0);

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
          const Text(
            'Bookings by Cab Type',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          const Text(
            'Distribution across cab categories',
            style: TextStyle(fontSize: 12, color: DesktopTheme.textMuted),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 170,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: four.toDouble(),
                    color: DesktopTheme.primaryBlue,
                    title: '${pct(four)}%\n4-Seater',
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: seven.toDouble(),
                    color: DesktopTheme.accentTeal,
                    title: '${pct(seven)}%\n7-Seater',
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: thirteen.toDouble(),
                    color: DesktopTheme.purpleAccent,
                    title: '${pct(thirteen)}%\n13-Seater',
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
                sectionsSpace: 3,
                centerSpaceRadius: 24,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _LegendRow('4-Seater', '$four trips', DesktopTheme.primaryBlue),
          const SizedBox(height: 6),
          _LegendRow('7-Seater', '$seven trips', DesktopTheme.accentTeal),
          const SizedBox(height: 6),
          _LegendRow('13-Seater', '$thirteen trips', DesktopTheme.purpleAccent),
        ],
      ),
    );
  }

  Widget _buildDriverEarnings(List<DriverModel> drivers) {
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
          const Text(
            'Top Driver Earnings',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          const Text(
            'This month\'s top performers',
            style: TextStyle(fontSize: 12, color: DesktopTheme.textMuted),
          ),
          const SizedBox(height: 16),
          ..._driverEarnings(drivers).map((d) => _DriverEarnRow(d)),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _driverEarnings(List<DriverModel> drivers) {
    final sorted = [...drivers]
      ..sort((a, b) => b.totalEarnings.compareTo(a.totalEarnings));
    final maxEarnings = sorted.isEmpty
        ? 1.0
        : sorted.first.totalEarnings.clamp(1.0, double.infinity);
    return sorted.take(5).map((driver) {
      return {
        'name': driver.fullName,
        'trips': driver.totalTrips,
        'earnings': driver.totalEarnings,
        'pct': (driver.totalEarnings / maxEarnings).clamp(0.0, 1.0),
      };
    }).toList();
  }

  Widget _buildAgencyPerformance(List<AgencyModel> agencies) {
    final visibleAgencies = agencies.take(4).toList();
    final maxY = visibleAgencies
        .map((a) => a.totalBookings.toDouble())
        .fold<double>(0, (m, v) => v > m ? v : m);

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
          const Text(
            'Agency Performance',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          const Text(
            'Comparative analysis across agencies',
            style: TextStyle(fontSize: 12, color: DesktopTheme.textMuted),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY <= 0 ? 10 : maxY * 1.2,
                barGroups: [
                  for (var i = 0; i < visibleAgencies.length; i++)
                    _BG(i, visibleAgencies[i].totalBookings.toDouble()),
                ],
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 100,
                  getDrawingHorizontalLine: (v) =>
                      FlLine(color: DesktopTheme.border, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, m) {
                        final i = v.toInt();
                        if (i < 0 || i >= visibleAgencies.length)
                          return const SizedBox.shrink();
                        return Text(
                          visibleAgencies[i].agencyName,
                          style: const TextStyle(
                            fontSize: 9,
                            color: DesktopTheme.textMuted,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                      getTitlesWidget: (v, m) => Text(
                        '${v.toInt()}',
                        style: const TextStyle(
                          fontSize: 9,
                          color: DesktopTheme.textMuted,
                        ),
                      ),
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Trips completed this month',
            style: TextStyle(fontSize: 11, color: DesktopTheme.textMuted),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _BG(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [DesktopTheme.primaryBlue, DesktopTheme.accentTeal],
          ),
          width: 32,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ],
    );
  }

  Widget _buildReportList(BuildContext context) {
    final reports = [
      {
        'title': 'Daily Revenue Report',
        'desc': 'Detailed breakdown of today\'s revenue',
        'icon': Icons.today_rounded,
        'color': DesktopTheme.primaryBlue,
      },
      {
        'title': 'Monthly Revenue Report',
        'desc': 'Consolidated monthly revenue analysis',
        'icon': Icons.calendar_month_rounded,
        'color': DesktopTheme.successGreen,
      },
      {
        'title': 'Driver Earnings Report',
        'desc': 'Earnings breakdown per driver',
        'icon': Icons.person_pin_rounded,
        'color': DesktopTheme.accentTeal,
      },
      {
        'title': 'Agency Performance Report',
        'desc': 'KPIs and metrics per agency',
        'icon': Icons.business_rounded,
        'color': DesktopTheme.purpleAccent,
      },
      {
        'title': 'Cab Utilization Report',
        'desc': 'Fleet usage and idle time analysis',
        'icon': Icons.directions_car_rounded,
        'color': DesktopTheme.warningAmber,
      },
      {
        'title': 'Customer Analytics Report',
        'desc': 'Customer behavior and loyalty metrics',
        'icon': Icons.people_rounded,
        'color': DesktopTheme.dangerRed,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Reports',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 3.5,
          ),
          itemCount: reports.length,
          itemBuilder: (ctx, i) {
            final r = reports[i];
            final color = r['color'] as Color;
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: DesktopTheme.cardBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: DesktopTheme.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(r['icon'] as IconData, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r['title'] as String,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          r['desc'] as String,
                          style: const TextStyle(
                            fontSize: 11,
                            color: DesktopTheme.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      _ExportBtn('Excel'),
                      const SizedBox(width: 6),
                      _ExportBtn('PDF'),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

double _tripAmount(TripRequest trip) {
  return trip.finalFare ?? trip.estimatedFare;
}

List<_MonthlyRevenue> _monthlyRevenue(List<TripRequest> bookings, int count) {
  final now = DateTime.now();
  final months = <_MonthlyRevenue>[];

  for (var offset = count - 1; offset >= 0; offset--) {
    final month = DateTime(now.year, now.month - offset);
    final total = bookings
        .where(
          (b) =>
              b.paymentStatus == PaymentStatus.success &&
              b.createdAt.year == month.year &&
              b.createdAt.month == month.month,
        )
        .fold<double>(0, (sum, b) => sum + _tripAmount(b));
    months.add(_MonthlyRevenue(total));
  }

  return months;
}

class _MonthlyRevenue {
  final double total;
  const _MonthlyRevenue(this.total);
}

class _KPICard extends StatelessWidget {
  final String label, value, trend;
  final bool trendUp;
  final IconData icon;
  final Color color;
  const _KPICard({
    required this.label,
    required this.value,
    required this.trend,
    required this.trendUp,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      (trendUp
                              ? DesktopTheme.successGreen
                              : DesktopTheme.dangerRed)
                          .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      trendUp ? Icons.trending_up : Icons.trending_down,
                      size: 12,
                      color: trendUp
                          ? DesktopTheme.successGreen
                          : DesktopTheme.dangerRed,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      trend,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: trendUp
                            ? DesktopTheme.successGreen
                            : DesktopTheme.dangerRed,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: DesktopTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: DesktopTheme.textMuted),
          ),
        ],
      ),
    );
  }
}

class _DriverEarnRow extends StatelessWidget {
  final Map<String, dynamic> data;
  const _DriverEarnRow(this.data);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: DesktopTheme.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                (data['name'] as String).isEmpty
                    ? '?'
                    : (data['name'] as String)[0],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: DesktopTheme.primaryBlue,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['name'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                LinearProgressIndicator(
                  value: data['pct'] as double,
                  backgroundColor: DesktopTheme.border,
                  valueColor: const AlwaysStoppedAnimation(
                    DesktopTheme.primaryBlue,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${((data['earnings'] as double) / 1000).toStringAsFixed(1)}K',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: DesktopTheme.successGreen,
                ),
              ),
              Text(
                '${data['trips']} trips',
                style: const TextStyle(
                  fontSize: 10,
                  color: DesktopTheme.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: DesktopTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  final String label, value;
  final Color color;
  const _LegendRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: DesktopTheme.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: DesktopTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ExportBtn extends StatelessWidget {
  final String label;
  const _ExportBtn(this.label);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exporting $label...'),
          behavior: SnackBarBehavior.floating,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: DesktopTheme.contentBg,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: DesktopTheme.border),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: DesktopTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
