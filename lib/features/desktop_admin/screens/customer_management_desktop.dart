import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/desktop_theme.dart';
import '../shared/desktop_widgets.dart';
import '../../../core/models.dart';
import '../../../core/mock_data.dart';

final customerSearchProvider = StateProvider<String>((ref) => '');

class CustomerManagementDesktopScreen extends ConsumerWidget {
  const CustomerManagementDesktopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customers = MockData.customers;
    final search = ref.watch(customerSearchProvider);

    final filtered = customers.where((c) {
      return search.isEmpty ||
          c.name.toLowerCase().contains(search.toLowerCase()) ||
          c.phone.contains(search) ||
          c.email.toLowerCase().contains(search.toLowerCase());
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesktopTheme.contentPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            title: 'Customer Management',
            subtitle: 'View and manage all registered customers',
            action: PrimaryButton(
              label: 'Export CSV',
              icon: Icons.file_download_rounded,
              onPressed: () {},
              outlined: true,
            ),
          ),
          const SizedBox(height: 20),

          // Stats
          Row(
            children: [
              Expanded(child: _CStat('Total Customers', '${customers.length}', DesktopTheme.primaryBlue, Icons.people)),
              const SizedBox(width: 12),
              Expanded(child: _CStat('Active', '${customers.where((c) => !c.isBlocked).length}', DesktopTheme.successGreen, Icons.person_rounded)),
              const SizedBox(width: 12),
              Expanded(child: _CStat('Blocked', '${customers.where((c) => c.isBlocked).length}', DesktopTheme.dangerRed, Icons.block)),
              const SizedBox(width: 12),
              Expanded(child: _CStat('Avg. Bookings', '${(customers.fold<int>(0, (s, c) => s + c.totalBookings) / customers.length).toStringAsFixed(1)}', DesktopTheme.accentTeal, Icons.book_online)),
              const SizedBox(width: 12),
              Expanded(child: _CStat('Total Revenue', '₹${(customers.fold<double>(0, (s, c) => s + c.totalSpent) / 1000).toStringAsFixed(1)}K', DesktopTheme.successGreen, Icons.payments)),
            ],
          ),
          const SizedBox(height: 20),

          // Search
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: DesktopTheme.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: DesktopTheme.border)),
            child: Row(
              children: [
                DesktopSearchBar(
                  hint: 'Search customers by name, phone, email...',
                  width: 360,
                  onChanged: (v) => ref.read(customerSearchProvider.notifier).state = v,
                ),
                const Spacer(),
                Text('${filtered.length} customers', style: const TextStyle(fontSize: 12, color: DesktopTheme.textMuted)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Table
          Container(
            decoration: BoxDecoration(color: DesktopTheme.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: DesktopTheme.border)),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: const BoxDecoration(
                    color: DesktopTheme.contentBg,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                    border: Border(bottom: BorderSide(color: DesktopTheme.border)),
                  ),
                  child: Row(
                    children: const [
                      Expanded(flex: 3, child: _TH('Customer')),
                      Expanded(flex: 3, child: _TH('Contact')),
                      Expanded(flex: 2, child: _TH('Total Bookings')),
                      Expanded(flex: 2, child: _TH('Total Spent')),
                      Expanded(flex: 2, child: _TH('Status')),
                      Expanded(flex: 2, child: _TH('Actions')),
                    ],
                  ),
                ),
                if (filtered.isEmpty)
                  const Padding(padding: EdgeInsets.all(40), child: Center(child: Text('No customers found', style: TextStyle(color: DesktopTheme.textMuted))))
                else
                  ...filtered.map((c) => _CustomerRow(customer: c, isOdd: filtered.indexOf(c).isOdd)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _CStat(this.label, this.value, this.color, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: DesktopTheme.cardBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: DesktopTheme.border)),
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
  Widget build(BuildContext context) => Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: DesktopTheme.textMuted));
}

class _CustomerRow extends StatefulWidget {
  final Customer customer;
  final bool isOdd;
  const _CustomerRow({required this.customer, required this.isOdd});

  @override
  State<_CustomerRow> createState() => _CustomerRowState();
}

class _CustomerRowState extends State<_CustomerRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.customer;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: _hovered ? DesktopTheme.primaryBlue.withValues(alpha: 0.03) : widget.isOdd ? DesktopTheme.borderLight : DesktopTheme.cardBg,
          border: const Border(bottom: BorderSide(color: DesktopTheme.borderLight)),
        ),
        child: Row(
          children: [
            Expanded(flex: 3, child: Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: c.isBlocked ? DesktopTheme.dangerRed.withValues(alpha: 0.1) : DesktopTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: Text(c.name[0], style: TextStyle(fontWeight: FontWeight.bold, color: c.isBlocked ? DesktopTheme.dangerRed : DesktopTheme.primaryBlue))),
              ),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(c.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                Text('ID: ${c.id}', style: const TextStyle(fontSize: 11, color: DesktopTheme.textMuted)),
              ]),
            ])),
            Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c.phone, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              Text(c.email, style: const TextStyle(fontSize: 11, color: DesktopTheme.textMuted)),
            ])),
            Expanded(flex: 2, child: Text('${c.totalBookings}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
            Expanded(flex: 2, child: Text('₹${c.totalSpent.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: DesktopTheme.successGreen))),
            Expanded(flex: 2, child: StatusBadge(c.isBlocked ? 'Blocked' : 'Active')),
            Expanded(flex: 2, child: Row(children: [
              Tooltip(
                message: c.isBlocked ? 'Unblock' : 'Block',
                child: GestureDetector(
                  onTap: () => setState(() => c.isBlocked = !c.isBlocked),
                  child: Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: c.isBlocked ? DesktopTheme.successGreen.withValues(alpha: 0.1) : DesktopTheme.dangerRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(c.isBlocked ? Icons.lock_open_rounded : Icons.block_rounded, size: 14, color: c.isBlocked ? DesktopTheme.successGreen : DesktopTheme.dangerRed),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Tooltip(
                message: 'View History',
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(color: DesktopTheme.primaryBlue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                    child: const Icon(Icons.history_rounded, size: 14, color: DesktopTheme.primaryBlue),
                  ),
                ),
              ),
            ])),
          ],
        ),
      ),
    );
  }
}
