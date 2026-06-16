import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/desktop_theme.dart';
import '../shared/desktop_widgets.dart';
import '../../../core/app_providers.dart';
import '../../../core/extended_models.dart';

class DashboardOverviewScreen extends ConsumerWidget {
  const DashboardOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(bookingProvider);
    final drivers = ref.watch(driverListProvider);
    final customers = ref.watch(customerListProvider);
    final pendingApprovals =
        ref.watch(pendingDriversProvider).length +
        ref.watch(pendingAgenciesProvider).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesktopTheme.contentPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopBanner(ref, pendingApprovals),
          const SizedBox(height: 32),

          _buildMetricsGrid(ref, bookings, customers.length),
          const SizedBox(height: 32),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildRevenueSection(bookings)),
              const SizedBox(width: 32),
              Expanded(
                flex: 2,
                child: _buildDriverDistribution(drivers, bookings),
              ),
            ],
          ),
          const SizedBox(height: 32),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _buildLiveActivity(bookings, pendingApprovals),
              ),
              const SizedBox(width: 32),
              Expanded(
                flex: 3,
                child: _buildRecentBookingsTable(ref, bookings),
              ),
            ],
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildTopBanner(WidgetRef ref, int pendingApprovals) {
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
            color: DesktopTheme.primaryBlue.withValues(alpha: 0.3),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
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
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: InkWell(
              // Added InkWell
              onTap: () => ref.read(desktopNavProvider.notifier).state =
                  AdminSection.drivers, // Added onTap
              child: Column(
                children: [
                  const Icon(Icons.bolt_rounded, color: Colors.white, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    '$pendingApprovals Pending',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'APPROVALS',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white54,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(
    WidgetRef ref,
    List<TripRequest> bookings,
    int customerCount,
  ) {
    final today = DateTime.now();
    final todaysBookings = bookings
        .where(
          (b) =>
              b.createdAt.year == today.year &&
              b.createdAt.month == today.month &&
              b.createdAt.day == today.day,
        )
        .toList();
    final dailyRevenue = todaysBookings
        .where((b) => b.paymentStatus == PaymentStatus.success)
        .fold<double>(0, (sum, b) => sum + _tripAmount(b));
    final activeTrips = bookings.where(_isActiveTrip).length;
    final cancelledToday = todaysBookings
        .where((b) => b.status == BookingStatus.cancelled)
        .length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200
            ? 4
            : constraints.maxWidth > 800
            ? 2
            : 1;
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
              value: '₹${dailyRevenue.toStringAsFixed(0)}',
              trend: '${todaysBookings.length}',
              trendUp: true,
              icon: Icons.payments_rounded,
              color: DesktopTheme.success,
              subtitle: 'vs yesterday',
              onTap: () => ref.read(desktopNavProvider.notifier).state =
                  AdminSection.payments,
            ),
            DesktopStatCard(
              title: 'ACTIVE TRIPS',
              value: '$activeTrips',
              trend: '+0',
              trendUp: true,
              icon: Icons.local_taxi_rounded,
              color: DesktopTheme.info,
              subtitle: 'running now',
              onTap: () => ref.read(desktopNavProvider.notifier).state =
                  AdminSection.bookings,
            ),
            DesktopStatCard(
              title: 'NEW CUSTOMERS',
              value: '$customerCount',
              trend: '+0%',
              trendUp: true,
              icon: Icons.people_rounded,
              color: DesktopTheme.purple,
              subtitle: 'this week',
              onTap: () => ref.read(desktopNavProvider.notifier).state =
                  AdminSection.customers,
            ),
            DesktopStatCard(
              title: 'CANCELLED',
              value: '$cancelledToday',
              trend: '$cancelledToday',
              trendUp: false,
              icon: Icons.cancel_rounded,
              color: DesktopTheme.danger,
              subtitle: 'last 24h',
              onTap: () => ref.read(desktopNavProvider.notifier).state =
                  AdminSection.bookings,
            ),
          ],
        );
      },
    );
  }

  Widget _buildRevenueSection(List<TripRequest> bookings) {
    return _DashboardCard(
      title: 'Revenue Performance',
      subtitle: 'Analyze platform earnings across months',
      action: _PeriodFilter(),
      child: SizedBox(
        height: 300,
        child: LineChart(_revenueChartData(bookings)),
      ),
    );
  }

  Widget _buildDriverDistribution(
    List<DriverModel> drivers,
    List<TripRequest> bookings,
  ) {
    final online = drivers.where((d) => d.isOnline).length;
    final onTrip = bookings.where(_isActiveTrip).length;
    final offline = (drivers.length - online).clamp(0, drivers.length);
    final total = drivers.isEmpty ? 1.0 : drivers.length.toDouble();

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
                  PieChartSectionData(
                    value: online / total,
                    color: DesktopTheme.success,
                    radius: 25,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    value: onTrip / total,
                    color: DesktopTheme.info,
                    radius: 25,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    value: offline / total,
                    color: DesktopTheme.textMuted.withValues(alpha: 0.3),
                    radius: 25,
                    showTitle: false,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          _StatusIndicator(
            label: 'Online',
            count: '$online',
            color: DesktopTheme.success,
          ),
          const SizedBox(height: 12),
          _StatusIndicator(
            label: 'On Trip',
            count: '$onTrip',
            color: DesktopTheme.info,
          ),
          const SizedBox(height: 12),
          _StatusIndicator(
            label: 'Offline',
            count: '$offline',
            color: DesktopTheme.textMuted,
          ),
        ],
      ),
    );
  }

  Widget _buildLiveActivity(List<TripRequest> bookings, int pendingApprovals) {
    final recent = bookings.take(4).toList();
    final events = [
      if (pendingApprovals > 0)
        _ActivityData(
          '$pendingApprovals Pending Approvals',
          'needs review',
          Icons.person_add,
          DesktopTheme.primaryBlue,
        ),
      for (final booking in recent)
        _ActivityData(
          '${_bookingStatusLabel(booking.status)}: ${booking.customerName}',
          _timeAgo(booking.createdAt),
          booking.status == BookingStatus.cancelled
              ? Icons.error
              : Icons.local_taxi,
          booking.status == BookingStatus.cancelled
              ? DesktopTheme.danger
              : DesktopTheme.success,
        ),
    ];

    return _DashboardCard(
      title: 'Live Activity',
      subtitle: 'Latest events on the platform',
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: events.isEmpty ? 1 : events.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          if (events.isEmpty) {
            return const Text(
              'No recent activity',
              style: TextStyle(color: DesktopTheme.textMuted),
            );
          }
          final event = events[index];
          return _ActivityItem(
            title: event.title,
            time: event.time,
            icon: event.icon,
            color: event.color,
          );
        },
      ),
    );
  }

  Widget _buildRecentBookingsTable(WidgetRef ref, List<TripRequest> bookings) {
    final recent = bookings.take(5).toList();
    return _DashboardCard(
      title: 'Recent Bookings',
      subtitle: 'Quick overview of last transactions',
      action: TextButton(
        onPressed: () =>
            ref.read(desktopNavProvider.notifier).state = AdminSection.bookings,
        child: const Text('View All Bookings'),
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          const Divider(height: 32),
          if (recent.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'No bookings yet',
                style: TextStyle(color: DesktopTheme.textMuted),
              ),
            )
          else
            ...recent.map((booking) => _BookingRow(booking)),
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

  LineChartData _revenueChartData(List<TripRequest> bookings) {
    final months = _lastSixMonthRevenue(bookings);
    final maxY = months
        .map((e) => e.total)
        .fold<double>(0, (m, v) => v > m ? v : m);

    return LineChartData(
      minY: 0,
      maxY: maxY <= 0 ? 1000 : maxY * 1.2,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxY <= 0 ? 250 : maxY / 4,
        getDrawingHorizontalLine: (_) =>
            FlLine(color: Colors.black.withValues(alpha: 0.05), strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            getTitlesWidget: (val, _) {
              final i = val.toInt();
              if (i < 0 || i >= months.length) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  months[i].label,
                  style: TextStyle(color: DesktopTheme.textMuted, fontSize: 11),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          isCurved: true,
          color: DesktopTheme.primaryBlue,
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                DesktopTheme.primaryBlue.withValues(alpha: 0.2),
                DesktopTheme.primaryBlue.withValues(alpha: 0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          spots: [
            for (var i = 0; i < months.length; i++)
              FlSpot(i.toDouble(), months[i].total),
          ],
        ),
      ],
    );
  }
}

bool _isActiveTrip(TripRequest booking) {
  return booking.status == BookingStatus.driverAccepted ||
      booking.status == BookingStatus.driverArriving ||
      booking.status == BookingStatus.tripStarted ||
      booking.status == BookingStatus.ongoing;
}

double _tripAmount(TripRequest trip) {
  return trip.finalFare ?? trip.estimatedFare;
}

String _bookingStatusLabel(BookingStatus status) {
  switch (status) {
    case BookingStatus.searched:
      return 'Searched';
    case BookingStatus.booked:
    case BookingStatus.newBooking:
      return 'Booked';
    case BookingStatus.driverAccepted:
    case BookingStatus.confirmed:
      return 'Confirmed';
    case BookingStatus.driverArriving:
      return 'Driver Arriving';
    case BookingStatus.tripStarted:
    case BookingStatus.ongoing:
      return 'Ongoing';
    case BookingStatus.tripCompleted:
    case BookingStatus.completed:
      return 'Completed';
    case BookingStatus.paymentCompleted:
      return 'Paid';
    case BookingStatus.cancelled:
      return 'Cancelled';
  }
}

List<_MonthlyRevenue> _lastSixMonthRevenue(List<TripRequest> bookings) {
  final now = DateTime.now();
  final months = <_MonthlyRevenue>[];

  for (var offset = 5; offset >= 0; offset--) {
    final month = DateTime(now.year, now.month - offset);
    final total = bookings
        .where(
          (b) =>
              b.paymentStatus == PaymentStatus.success &&
              b.createdAt.year == month.year &&
              b.createdAt.month == month.month,
        )
        .fold<double>(0, (sum, b) => sum + _tripAmount(b));
    months.add(_MonthlyRevenue(_monthLabel(month.month), total));
  }

  return months;
}

String _monthLabel(int month) {
  const labels = [
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
  return labels[month - 1];
}

String _timeAgo(DateTime dateTime) {
  final diff = DateTime.now().difference(dateTime);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inHours < 1) return '${diff.inMinutes} min ago';
  if (diff.inDays < 1) return '${diff.inHours} hr ago';
  return '${diff.inDays} days ago';
}

class _MonthlyRevenue {
  final String label;
  final double total;

  const _MonthlyRevenue(this.label, this.total);
}

class _ActivityData {
  final String title;
  final String time;
  final IconData icon;
  final Color color;

  const _ActivityData(this.title, this.time, this.icon, this.color);
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  final Widget child;

  const _DashboardCard({
    required this.title,
    this.subtitle,
    this.action,
    required this.child,
  });

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
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: DesktopTheme.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: DesktopTheme.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
      decoration: BoxDecoration(
        color: DesktopTheme.contentBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: ['7D', '1M', '6M', '1Y']
            .map(
              (t) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: t == '6M' ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: t == '6M'
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  t,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: t == '6M'
                        ? DesktopTheme.primaryBlue
                        : DesktopTheme.textMuted,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final String label;
  final String count;
  final Color color;
  const _StatusIndicator({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const Spacer(),
        Text(
          count,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
        ),
      ],
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String title;
  final String time;
  final IconData icon;
  final Color color;
  const _ActivityItem({
    required this.title,
    required this.time,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                time,
                style: TextStyle(color: DesktopTheme.textMuted, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BookingRow extends StatelessWidget {
  final TripRequest booking;
  const _BookingRow(this.booking);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              booking.bookingId.isEmpty ? booking.id : booking.bookingId,
              style: const TextStyle(
                color: DesktopTheme.primaryBlue,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              booking.customerName,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 4,
            child: const Text(
              'Indiranagar → Airport',
              style: TextStyle(color: DesktopTheme.textSecondary, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '₹${_tripAmount(booking).toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 2,
            child: StatusBadge(_bookingStatusLabel(booking.status)),
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  const _HeaderCell(this.label);
  @override
  Widget build(BuildContext context) => Text(
    label,
    style: TextStyle(
      color: DesktopTheme.textMuted,
      fontWeight: FontWeight.w800,
      fontSize: 11,
      letterSpacing: 1,
    ),
  );
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
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 11),
        ),
      ],
    );
  }
}

class _PieLegend extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  const _PieLegend({
    required this.color,
    required this.label,
    required this.value,
  });

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
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: DesktopTheme.textSecondary,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: DesktopTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _DriverMiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _DriverMiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: DesktopTheme.textMuted),
        ),
      ],
    );
  }
}

class _ApprovalItem extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  final Color color;
  const _ApprovalItem({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
  });

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
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: count > 0 ? color : DesktopTheme.textMuted,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: DesktopTheme.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
