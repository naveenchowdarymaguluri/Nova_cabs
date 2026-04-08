import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/desktop_theme.dart';
import '../shared/desktop_widgets.dart';

class ReportsAnalyticsDesktopScreen extends StatelessWidget {
  const ReportsAnalyticsDesktopScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                PrimaryButton(label: 'Export Excel', icon: Icons.table_chart, onPressed: () {}, outlined: true),
                const SizedBox(width: 8),
                PrimaryButton(label: 'Export PDF', icon: Icons.picture_as_pdf, onPressed: () {}, outlined: true),
                const SizedBox(width: 8),
                PrimaryButton(label: 'Export CSV', icon: Icons.file_download, onPressed: () {}),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // KPI Summary
          Row(
            children: [
              Expanded(child: _KPICard(label: 'Total Bookings (YTD)', value: '12,847', trend: '+23.4%', trendUp: true, icon: Icons.book_online, color: DesktopTheme.primaryBlue)),
              const SizedBox(width: 16),
              Expanded(child: _KPICard(label: 'Total Revenue (YTD)', value: '₹28.4L', trend: '+18.2%', trendUp: true, icon: Icons.payments, color: DesktopTheme.successGreen)),
              const SizedBox(width: 16),
              Expanded(child: _KPICard(label: 'Avg Trip Distance', value: '87.2 km', trend: '+4.1%', trendUp: true, icon: Icons.route, color: DesktopTheme.accentTeal)),
              const SizedBox(width: 16),
              Expanded(child: _KPICard(label: 'Cancellation Rate', value: '3.2%', trend: '-0.8%', trendUp: false, icon: Icons.cancel, color: DesktopTheme.dangerRed)),
            ],
          ),
          const SizedBox(height: 20),

          // Revenue + Bookings side by side
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildAnnualRevenueChart()),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: _buildBookingsByType()),
            ],
          ),
          const SizedBox(height: 16),

          // Driver Earnings + Agency Performance
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildDriverEarnings()),
              const SizedBox(width: 16),
              Expanded(flex: 3, child: _buildAgencyPerformance()),
            ],
          ),
          const SizedBox(height: 16),

          // Report List
          _buildReportList(context),
        ],
      ),
    );
  }

  Widget _buildAnnualRevenueChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: DesktopTheme.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: DesktopTheme.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Annual Revenue Breakdown', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text('Monthly revenue vs commission collected', style: TextStyle(fontSize: 12, color: DesktopTheme.textMuted)),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(LineChartData(
              gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 100000, getDrawingHorizontalLine: (v) => FlLine(color: DesktopTheme.border, strokeWidth: 1)),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 55, getTitlesWidget: (v, m) => Text('₹${(v / 1000).toInt()}K', style: const TextStyle(fontSize: 9, color: DesktopTheme.textMuted)))),
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) {
                  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                  return Text(months[v.toInt() % 12], style: const TextStyle(fontSize: 9, color: DesktopTheme.textMuted));
                })),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: const [FlSpot(0, 180000), FlSpot(1, 220000), FlSpot(2, 260000), FlSpot(3, 310000), FlSpot(4, 280000), FlSpot(5, 350000), FlSpot(6, 380000), FlSpot(7, 320000), FlSpot(8, 410000), FlSpot(9, 370000), FlSpot(10, 430000), FlSpot(11, 480000)],
                  isCurved: true, color: DesktopTheme.primaryBlue, barWidth: 2.5, dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: true, gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [DesktopTheme.primaryBlue.withValues(alpha: 0.15), DesktopTheme.primaryBlue.withValues(alpha: 0)])),
                ),
                LineChartBarData(
                  spots: const [FlSpot(0, 54000), FlSpot(1, 66000), FlSpot(2, 78000), FlSpot(3, 93000), FlSpot(4, 84000), FlSpot(5, 105000), FlSpot(6, 114000), FlSpot(7, 96000), FlSpot(8, 123000), FlSpot(9, 111000), FlSpot(10, 129000), FlSpot(11, 144000)],
                  isCurved: true, color: DesktopTheme.accentTeal, barWidth: 2, dotData: const FlDotData(show: false), dashArray: [5, 4],
                ),
              ],
            )),
          ),
          const SizedBox(height: 12),
          Row(children: [
            _Legend(color: DesktopTheme.primaryBlue, label: 'Revenue'),
            const SizedBox(width: 16),
            _Legend(color: DesktopTheme.accentTeal, label: 'Commission (30%)'),
          ]),
        ],
      ),
    );
  }

  Widget _buildBookingsByType() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: DesktopTheme.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: DesktopTheme.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Bookings by Cab Type', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text('Distribution across cab categories', style: TextStyle(fontSize: 12, color: DesktopTheme.textMuted)),
          const SizedBox(height: 20),
          SizedBox(
            height: 170,
            child: PieChart(PieChartData(
              sections: [
                PieChartSectionData(value: 55, color: DesktopTheme.primaryBlue, title: '55%\n4-Seater', radius: 60, titleStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                PieChartSectionData(value: 30, color: DesktopTheme.accentTeal, title: '30%\n7-Seater', radius: 60, titleStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                PieChartSectionData(value: 15, color: DesktopTheme.purpleAccent, title: '15%\n13-Seater', radius: 60, titleStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
              sectionsSpace: 3,
              centerSpaceRadius: 24,
            )),
          ),
          const SizedBox(height: 16),
          _LegendRow('4-Seater', '7,065 trips', DesktopTheme.primaryBlue),
          const SizedBox(height: 6),
          _LegendRow('7-Seater', '3,854 trips', DesktopTheme.accentTeal),
          const SizedBox(height: 6),
          _LegendRow('13-Seater', '1,928 trips', DesktopTheme.purpleAccent),
        ],
      ),
    );
  }

  Widget _buildDriverEarnings() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: DesktopTheme.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: DesktopTheme.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Top Driver Earnings', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text('This month\'s top performers', style: TextStyle(fontSize: 12, color: DesktopTheme.textMuted)),
          const SizedBox(height: 16),
          ..._driverEarnings().map((d) => _DriverEarnRow(d)),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _driverEarnings() => [
    {'name': 'Rajesh Kumar', 'trips': 48, 'earnings': 28420, 'pct': 0.9},
    {'name': 'Suresh Patel', 'trips': 42, 'earnings': 24850, 'pct': 0.78},
    {'name': 'Amit Singh', 'trips': 38, 'earnings': 21200, 'pct': 0.67},
    {'name': 'Priya Sharma', 'trips': 31, 'earnings': 18600, 'pct': 0.59},
    {'name': 'Vikram Nair', 'trips': 28, 'earnings': 15400, 'pct': 0.49},
  ];

  Widget _buildAgencyPerformance() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: DesktopTheme.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: DesktopTheme.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Agency Performance', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text('Comparative analysis across agencies', style: TextStyle(fontSize: 12, color: DesktopTheme.textMuted)),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 400,
              barGroups: [
                _BG(0, 280),
                _BG(1, 210),
                _BG(2, 180),
                _BG(3, 320),
              ],
              gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 100, getDrawingHorizontalLine: (v) => FlLine(color: DesktopTheme.border, strokeWidth: 1)),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) {
                  const names = ['Quick\nTravels', 'Elite\nCabs', 'Global\nTravels', 'City\nRiders'];
                  return Text(names[v.toInt()], style: const TextStyle(fontSize: 9, color: DesktopTheme.textMuted), textAlign: TextAlign.center);
                })),
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 35, getTitlesWidget: (v, m) => Text('${v.toInt()}', style: const TextStyle(fontSize: 9, color: DesktopTheme.textMuted)))),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
            )),
          ),
          const SizedBox(height: 8),
          const Text('Trips completed this month', style: TextStyle(fontSize: 11, color: DesktopTheme.textMuted)),
        ],
      ),
    );
  }

  BarChartGroupData _BG(int x, double y) {
    return BarChartGroupData(x: x, barRods: [
      BarChartRodData(toY: y, gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [DesktopTheme.primaryBlue, DesktopTheme.accentTeal]), width: 32, borderRadius: const BorderRadius.vertical(top: Radius.circular(6))),
    ]);
  }

  Widget _buildReportList(BuildContext context) {
    final reports = [
      {'title': 'Daily Revenue Report', 'desc': 'Detailed breakdown of today\'s revenue', 'icon': Icons.today_rounded, 'color': DesktopTheme.primaryBlue},
      {'title': 'Monthly Revenue Report', 'desc': 'Consolidated monthly revenue analysis', 'icon': Icons.calendar_month_rounded, 'color': DesktopTheme.successGreen},
      {'title': 'Driver Earnings Report', 'desc': 'Earnings breakdown per driver', 'icon': Icons.person_pin_rounded, 'color': DesktopTheme.accentTeal},
      {'title': 'Agency Performance Report', 'desc': 'KPIs and metrics per agency', 'icon': Icons.business_rounded, 'color': DesktopTheme.purpleAccent},
      {'title': 'Cab Utilization Report', 'desc': 'Fleet usage and idle time analysis', 'icon': Icons.directions_car_rounded, 'color': DesktopTheme.warningAmber},
      {'title': 'Customer Analytics Report', 'desc': 'Customer behavior and loyalty metrics', 'icon': Icons.people_rounded, 'color': DesktopTheme.dangerRed},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Available Reports', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 3.5),
          itemCount: reports.length,
          itemBuilder: (ctx, i) {
            final r = reports[i];
            final color = r['color'] as Color;
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: DesktopTheme.cardBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: DesktopTheme.border)),
              child: Row(
                children: [
                  Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(r['icon'] as IconData, color: color, size: 20)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(r['title'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    Text(r['desc'] as String, style: const TextStyle(fontSize: 11, color: DesktopTheme.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ])),
                  Row(children: [
                    _ExportBtn('Excel'),
                    const SizedBox(width: 6),
                    _ExportBtn('PDF'),
                  ]),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _KPICard extends StatelessWidget {
  final String label, value, trend;
  final bool trendUp;
  final IconData icon;
  final Color color;
  const _KPICard({required this.label, required this.value, required this.trend, required this.trendUp, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: DesktopTheme.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: DesktopTheme.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(width: 38, height: 38, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 18)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: (trendUp ? DesktopTheme.successGreen : DesktopTheme.dangerRed).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(trendUp ? Icons.trending_up : Icons.trending_down, size: 12, color: trendUp ? DesktopTheme.successGreen : DesktopTheme.dangerRed),
              const SizedBox(width: 2),
              Text(trend, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: trendUp ? DesktopTheme.successGreen : DesktopTheme.dangerRed)),
            ]),
          ),
        ]),
        const SizedBox(height: 12),
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: DesktopTheme.textPrimary)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: DesktopTheme.textMuted)),
      ]),
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
      child: Row(children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(color: DesktopTheme.primaryBlue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Center(child: Text((data['name'] as String)[0], style: const TextStyle(fontWeight: FontWeight.bold, color: DesktopTheme.primaryBlue, fontSize: 12))),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(data['name'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          LinearProgressIndicator(
            value: data['pct'] as double,
            backgroundColor: DesktopTheme.border,
            valueColor: const AlwaysStoppedAnimation(DesktopTheme.primaryBlue),
            borderRadius: BorderRadius.circular(4),
          ),
        ])),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('₹${(data['earnings'] as int).toString().substring(0, 2)}K', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: DesktopTheme.successGreen)),
          Text('${data['trips']} trips', style: const TextStyle(fontSize: 10, color: DesktopTheme.textMuted)),
        ]),
      ]),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontSize: 12, color: DesktopTheme.textSecondary)),
    ]);
  }
}

class _LegendRow extends StatelessWidget {
  final String label, value;
  final Color color;
  const _LegendRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 8),
      Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: DesktopTheme.textSecondary))),
      Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: DesktopTheme.textPrimary)),
    ]);
  }
}

class _ExportBtn extends StatelessWidget {
  final String label;
  const _ExportBtn(this.label);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: DesktopTheme.contentBg, borderRadius: BorderRadius.circular(5), border: Border.all(color: DesktopTheme.border)),
        child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: DesktopTheme.textSecondary)),
      ),
    );
  }
}
