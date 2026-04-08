import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/desktop_theme.dart';
import '../shared/desktop_widgets.dart';
import '../../../core/models.dart';
import '../../../core/mock_data.dart';
import '../../../core/app_providers.dart';

final bookingSearchProvider = StateProvider<String>((ref) => '');
final bookingStatusFilterProvider = StateProvider<String>((ref) => 'All');

class BookingManagementDesktopScreen extends ConsumerWidget {
  const BookingManagementDesktopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(bookingProvider);
    final search = ref.watch(bookingSearchProvider);
    final filter = ref.watch(bookingStatusFilterProvider);

    List<Booking> filtered = bookings.where((b) {
      final matchSearch = search.isEmpty ||
          b.customerName.toLowerCase().contains(search.toLowerCase()) ||
          b.id.toLowerCase().contains(search.toLowerCase()) ||
          b.pickupLocation.toLowerCase().contains(search.toLowerCase());
      final matchFilter = filter == 'All' || b.status == filter;
      return matchSearch && matchFilter;
    }).toList();

    final statuses = ['All', 'New', 'Confirmed', 'Ongoing', 'Completed', 'Cancelled'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesktopTheme.contentPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(
            title: 'Booking Management',
            subtitle: 'Monitor and manage all cab bookings on the platform',
          ),
          const SizedBox(height: 20),

          // Stats
          Row(
            children: [
              Expanded(child: _BStat('Total', '${bookings.length}', DesktopTheme.primaryBlue, Icons.book_online)),
              const SizedBox(width: 12),
              Expanded(child: _BStat('Active', '${bookings.where((b) => b.status == 'Ongoing').length}', DesktopTheme.warningAmber, Icons.local_taxi)),
              const SizedBox(width: 12),
              Expanded(child: _BStat('Completed', '${bookings.where((b) => b.status == 'Completed').length}', DesktopTheme.successGreen, Icons.check_circle)),
              const SizedBox(width: 12),
              Expanded(child: _BStat('Cancelled', '${bookings.where((b) => b.status == 'Cancelled').length}', DesktopTheme.dangerRed, Icons.cancel)),
              const SizedBox(width: 12),
              Expanded(child: _BStat('Revenue', '₹${bookings.where((b) => b.status == 'Completed').fold<double>(0, (s, b) => s + b.totalFare).toStringAsFixed(0)}', DesktopTheme.accentTeal, Icons.payments)),
            ],
          ),
          const SizedBox(height: 20),

          // Filters
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: DesktopTheme.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: DesktopTheme.border),
            ),
            child: Row(
              children: [
                DesktopSearchBar(
                  hint: 'Search by ID, customer, location...',
                  width: 300,
                  onChanged: (v) => ref.read(bookingSearchProvider.notifier).state = v,
                ),
                const SizedBox(width: 16),
                ...statuses.map((s) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _StatusChip(label: s, provider: bookingStatusFilterProvider, ref: ref),
                )),
                const Spacer(),
                Text('${filtered.length} bookings', style: const TextStyle(fontSize: 12, color: DesktopTheme.textMuted)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Table
          Container(
            decoration: BoxDecoration(
              color: DesktopTheme.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: DesktopTheme.border),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: const BoxDecoration(
                    color: DesktopTheme.contentBg,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                    border: Border(bottom: BorderSide(color: DesktopTheme.border)),
                  ),
                  child: Row(
                    children: const [
                      Expanded(flex: 2, child: _TH('Booking ID')),
                      Expanded(flex: 3, child: _TH('Customer')),
                      Expanded(flex: 4, child: _TH('Route')),
                      Expanded(flex: 2, child: _TH('Date')),
                      Expanded(flex: 2, child: _TH('Fare')),
                      Expanded(flex: 2, child: _TH('Payment')),
                      Expanded(flex: 2, child: _TH('Status')),
                      Expanded(flex: 2, child: _TH('Actions')),
                    ],
                  ),
                ),
                if (filtered.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: Text('No bookings found', style: TextStyle(color: DesktopTheme.textMuted))),
                  )
                else
                  ...filtered.map((b) => _BookingRow(booking: b, ref: ref, isOdd: filtered.indexOf(b).isOdd)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _BStat(this.label, this.value, this.color, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesktopTheme.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: DesktopTheme.border),
      ),
      child: Row(
        children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 18)),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
          Text(label, style: const TextStyle(fontSize: 11, color: DesktopTheme.textMuted)),
        ]),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final StateProvider<String> provider;
  final WidgetRef ref;
  const _StatusChip({required this.label, required this.provider, required this.ref});

  @override
  Widget build(BuildContext context) {
    final current = ref.watch(provider);
    final isActive = current == label;
    return GestureDetector(
      onTap: () => ref.read(provider.notifier).state = label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? DesktopTheme.primaryBlue : DesktopTheme.contentBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? DesktopTheme.primaryBlue : DesktopTheme.border),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isActive ? Colors.white : DesktopTheme.textSecondary)),
      ),
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

class _BookingRow extends StatefulWidget {
  final Booking booking;
  final WidgetRef ref;
  final bool isOdd;
  const _BookingRow({required this.booking, required this.ref, required this.isOdd});

  @override
  State<_BookingRow> createState() => _BookingRowState();
}

class _BookingRowState extends State<_BookingRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: _hovered
              ? DesktopTheme.primaryBlue.withValues(alpha: 0.03)
              : widget.isOdd ? DesktopTheme.borderLight : DesktopTheme.cardBg,
          border: const Border(bottom: BorderSide(color: DesktopTheme.borderLight)),
        ),
        child: Row(
          children: [
            Expanded(flex: 2, child: Text(b.id, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: DesktopTheme.primaryBlue))),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(b.customerName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  Text(b.customerPhone, style: const TextStyle(fontSize: 11, color: DesktopTheme.textMuted)),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📍 ${b.pickupLocation}', style: const TextStyle(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('🏁 ${b.dropLocation}', style: const TextStyle(fontSize: 11, color: DesktopTheme.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(b.date, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                  Text(b.time, style: const TextStyle(fontSize: 11, color: DesktopTheme.textMuted)),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text('₹${b.totalFare.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: DesktopTheme.textPrimary)),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(b.paymentMethod, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                  StatusBadge(b.paymentStatus, fontSize: 10),
                ],
              ),
            ),
            Expanded(flex: 2, child: StatusBadge(b.status)),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  _ActionBtn(icon: Icons.visibility_rounded, color: DesktopTheme.primaryBlue, tooltip: 'View', onTap: () => _showDetail(context, b)),
                  const SizedBox(width: 6),
                  if (b.status != 'Cancelled' && b.status != 'Completed')
                    _ActionBtn(icon: Icons.cancel_rounded, color: DesktopTheme.dangerRed, tooltip: 'Cancel', onTap: () => widget.ref.read(bookingProvider.notifier).cancelBooking(b.id)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context, Booking b) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: DesktopTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: 560,
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: DesktopTheme.primaryBlue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.book_online_rounded, color: DesktopTheme.primaryBlue, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Booking #${b.id}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          Text('${b.date} at ${b.time}', style: const TextStyle(color: DesktopTheme.textMuted, fontSize: 13)),
                        ],
                      ),
                    ),
                    StatusBadge(b.status),
                    const SizedBox(width: 8),
                    IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: DesktopTheme.border),
                const SizedBox(height: 16),
                _Row2('Customer', b.customerName),
                _Row2('Phone', b.customerPhone),
                _Row2('Pickup', b.pickupLocation),
                _Row2('Drop', b.dropLocation),
                _Row2('Distance', '${b.totalDistance} km'),
                _Row2('Cab', '${b.cab.model} (${b.cab.type})'),
                _Row2('Vehicle No.', b.cab.vehicleNumber),
                _Row2('Agency', b.cab.agencyName),
                const Divider(color: DesktopTheme.border),
                _Row2('Total Fare', '₹${b.totalFare.toStringAsFixed(0)}'),
                _Row2('Payment Method', b.paymentMethod),
                _Row2('Payment Status', b.paymentStatus),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Row2 extends StatelessWidget {
  final String label;
  final String value;
  const _Row2(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        SizedBox(width: 130, child: Text(label, style: const TextStyle(fontSize: 13, color: DesktopTheme.textMuted))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
      ]),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback? onTap;
  const _ActionBtn({required this.icon, required this.color, required this.tooltip, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
          child: Icon(icon, size: 14, color: color),
        ),
      ),
    );
  }
}
