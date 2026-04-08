import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/desktop_theme.dart';
import '../shared/desktop_widgets.dart';

class DashboardOverviewScreen extends ConsumerWidget {
  const DashboardOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesktopTheme.contentPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopBanner(ref),
          const SizedBox(height: 32),
          
          _buildMetricsGrid(ref),
          const SizedBox(height: 32),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildRevenueSection()),
              const SizedBox(width: 32),
              Expanded(flex: 2, child: _buildDriverDistribution()),
            ],
          ),
          const SizedBox(height: 32),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildLiveActivity()),
              const SizedBox(width: 32),
              Expanded(flex: 3, child: _buildRecentBookingsTable()),
            ],
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildTopBanner(WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [DesktopTheme.primaryBlue, DesktopTheme.purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: DesktopTheme.primaryBlue.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 14),
                      const SizedBox(width: 8),
                      Text(
                        'DASHBOARD OVERVIEW',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Welcome, Nova Admin!',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage your fleet, track revenue, and monitor platform performance in real-time.',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white70,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: InkWell( // Added InkWell
              onTap: () => ref.read(desktopNavProvider.notifier).state = AdminSection.drivers, // Added onTap
              child: Column(
                children: [
                  const Icon(Icons.bolt_rounded, color: Colors.white, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    '12 Pending',
                    style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  Text(
                    'APPROVALS',
                    style: GoogleFonts.plusJakartaSans(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200 ? 4 : constraints.maxWidth > 800 ? 2 : 1;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          childAspectRatio: constraints.maxWidth > 1200 ? 1.4 : 2.2,
          children: [
            DesktopStatCard(
              title: 'DAILY REVENUE',
              value: '₹42,850',
              trend: '+12.4%',
              trendUp: true,
              icon: Icons.payments_rounded,
              color: DesktopTheme.success,
              subtitle: 'vs yesterday',
              onTap: () => ref.read(desktopNavProvider.notifier).state = AdminSection.payments,
            ),
            DesktopStatCard(
              title: 'ACTIVE TRIPS',
              value: '37',
              trend: '+5',
              trendUp: true,
              icon: Icons.local_taxi_rounded,
              color: DesktopTheme.info,
              subtitle: 'running now',
              onTap: () => ref.read(desktopNavProvider.notifier).state = AdminSection.bookings,
            ),
            DesktopStatCard(
              title: 'NEW CUSTOMERS',
              value: '184',
              trend: '+24%',
              trendUp: true,
              icon: Icons.people_rounded,
              color: DesktopTheme.purple,
              subtitle: 'this week',
              onTap: () => ref.read(desktopNavProvider.notifier).state = AdminSection.customers,
            ),
            DesktopStatCard(
              title: 'CANCELLED',
              value: '14',
              trend: '-8%',
              trendUp: false,
              icon: Icons.cancel_rounded,
              color: DesktopTheme.danger,
              subtitle: 'last 24h',
              onTap: () => ref.read(desktopNavProvider.notifier).state = AdminSection.bookings,
            ),
          ],
        );
      }
    );
  }

  Widget _buildRevenueSection() {
    return _DashboardCard(
      title: 'Revenue Performance',
      subtitle: 'Analyze platform earnings across months',
      action: _PeriodFilter(),
      child: SizedBox(
        height: 300,
        child: LineChart(_revenueChartData()),
      ),
    );
  }

  Widget _buildDriverDistribution() {
    return _DashboardCard(
      title: 'Fleet Status',
      subtitle: 'Real-time driver availability',
      child: Column(
        children: [
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sectionsSpace: 8,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(value: 40, color: DesktopTheme.success, radius: 25, showTitle: false),
                  PieChartSectionData(value: 30, color: DesktopTheme.info, radius: 25, showTitle: false),
                  PieChartSectionData(value: 30, color: DesktopTheme.textMuted.withOpacity(0.3), radius: 25, showTitle: false),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          _StatusIndicator(label: 'Online', count: '42', color: DesktopTheme.success),
          const SizedBox(height: 12),
          _StatusIndicator(label: 'On Trip', count: '18', color: DesktopTheme.info),
          const SizedBox(height: 12),
          _StatusIndicator(label: 'Offline', count: '124', color: DesktopTheme.textMuted),
        ],
      ),
    );
  }

  Widget _buildLiveActivity() {
    return _DashboardCard(
      title: 'Live Activity',
      subtitle: 'Latest events on the platform',
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) => _ActivityItem(
          title: ['New Driver Request', 'Trip Completed', 'Support Ticket', 'High Demand Alert', 'Payment Failed'][index],
          time: '${(index + 1) * 5} min ago',
          icon: [Icons.person_add, Icons.check_circle, Icons.support_agent, Icons.warning, Icons.error][index],
          color: [DesktopTheme.primaryBlue, DesktopTheme.success, DesktopTheme.info, DesktopTheme.warning, DesktopTheme.danger][index],
        ),
      ),
    );
  }

  Widget _buildRecentBookingsTable() {
    return _DashboardCard(
      title: 'Recent Bookings',
      subtitle: 'Quick overview of last transactions',
      action: TextButton(onPressed: () {}, child: const Text('View All Bookings')),
      child: Column(
        children: [
          _buildTableHeader(),
          const Divider(height: 32),
          ...List.generate(5, (index) => _BookingRow(index)),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Row(
      children: [
        Expanded(flex: 2, child: _HeaderCell('ID')),
        Expanded(flex: 3, child: _HeaderCell('CUSTOMER')),
        Expanded(flex: 4, child: _HeaderCell('LOCATION')),
        Expanded(flex: 2, child: _HeaderCell('AMOUNT')),
        Expanded(flex: 2, child: _HeaderCell('STATUS')),
      ],
    );
  }

  LineChartData _revenueChartData() {
    return LineChartData(
      gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 1, getDrawingHorizontalLine: (_) => FlLine(color: Colors.black.withOpacity(0.05), strokeWidth: 1)),
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32, getTitlesWidget: (val, _) => Padding(padding: const EdgeInsets.only(top: 8), child: Text(['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'][val.toInt() % 6], style: TextStyle(color: DesktopTheme.textMuted, fontSize: 11))))),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          isCurved: true,
          color: DesktopTheme.primaryBlue,
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [DesktopTheme.primaryBlue.withOpacity(0.2), DesktopTheme.primaryBlue.withOpacity(0.0)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          spots: const [FlSpot(0, 3), FlSpot(1, 4), FlSpot(2, 3.5), FlSpot(3, 5), FlSpot(4, 4.2), FlSpot(5, 6)],
        ),
      ],
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  final Widget child;

  const _DashboardCard({required this.title, this.subtitle, this.action, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: DesktopTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: DesktopTheme.textPrimary)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(subtitle!, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: DesktopTheme.textMuted, fontWeight: FontWeight.w500)),
                  ],
                ],
              ),
              if (action != null) action!,
            ],
          ),
          const SizedBox(height: 32),
          child,
        ],
      ),
    );
  }
}

class _PeriodFilter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: DesktopTheme.contentBg, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: ['7D', '1M', '6M', '1Y'].map((t) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: t == '6M' ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: t == '6M' ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : null,
          ),
          child: Text(t, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: t == '6M' ? DesktopTheme.primaryBlue : DesktopTheme.textMuted)),
        )).toList(),
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final String label;
  final String count;
  final Color color;
  const _StatusIndicator({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const Spacer(),
        Text(count, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
      ],
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String title;
  final String time;
  final IconData icon;
  final Color color;
  const _ActivityItem({required this.title, required this.time, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text(time, style: TextStyle(color: DesktopTheme.textMuted, fontSize: 12)),
          ]),
        ),
      ],
    );
  }
}

class _BookingRow extends StatelessWidget {
  final int index;
  const _BookingRow(this.index);

  @override
  Widget build(BuildContext context) {
    final names = ['Arjun Singh', 'Priya Rao', 'Rahul Dev', 'Sanjay M.', 'Anjali K.'];
    final fares = ['₹542', '₹1,284', '₹230', '₹4,821', '₹318'];
    final statuses = ['Completed', 'Ongoing', 'Completed', 'Cancelled', 'New'];
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text('#NC02${840+index}', style: const TextStyle(color: DesktopTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 13))),
          Expanded(flex: 3, child: Text(names[index], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
          Expanded(flex: 4, child: const Text('Indiranagar → Airport', style: TextStyle(color: DesktopTheme.textSecondary, fontSize: 13))),
          Expanded(flex: 2, child: Text(fares[index], style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13))),
          Expanded(flex: 2, child: StatusBadge(statuses[index])),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  const _HeaderCell(this.label);
  @override
  Widget build(BuildContext context) => Text(label, style: TextStyle(color: DesktopTheme.textMuted, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 1));
}

class _BannerStat extends StatelessWidget {
  final String label;
  final String value;
  const _BannerStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
      ],
    );
  }
}

class _PieLegend extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  const _PieLegend({required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: DesktopTheme.textSecondary)),
        const SizedBox(width: 6),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: DesktopTheme.textPrimary)),
      ],
    );
  }
}

class _DriverMiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _DriverMiniStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
        Text(label, style: const TextStyle(fontSize: 10, color: DesktopTheme.textMuted)),
      ],
    );
  }
}

class _ApprovalItem extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  final Color color;
  const _ApprovalItem({required this.label, required this.count, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$count', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: count > 0 ? color : DesktopTheme.textMuted)),
                Text(label, style: const TextStyle(fontSize: 11, color: DesktopTheme.textMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
