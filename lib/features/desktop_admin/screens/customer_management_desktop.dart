import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/desktop_theme.dart';
import '../shared/desktop_widgets.dart';
import '../../../core/app_providers.dart';
import '../../../core/models.dart';

final customerSearchProvider = StateProvider<String>((ref) => '');

class CustomerManagementDesktopScreen extends ConsumerWidget {
  const CustomerManagementDesktopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customers = ref.watch(customerListProvider);
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
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('CSV export feature coming soon'),
                  behavior: SnackBarBehavior.floating,
                ),
              ),
              outlined: true,
            ),
          ),
          const SizedBox(height: 20),

          // Stats row
          Row(
            children: [
              Expanded(
                child: _CStat(
                  'Total Customers',
                  '${customers.length}',
                  DesktopTheme.primaryBlue,
                  Icons.people,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CStat(
                  'Active',
                  '${customers.where((c) => !c.isBlocked).length}',
                  DesktopTheme.successGreen,
                  Icons.person_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CStat(
                  'Blocked',
                  '${customers.where((c) => c.isBlocked).length}',
                  DesktopTheme.dangerRed,
                  Icons.block,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CStat(
                  'Avg. Bookings',
                  customers.isEmpty
                      ? '0.0'
                      : (customers.fold<int>(
                                0,
                                (s, c) => s + c.totalBookings,
                              ) /
                              customers.length)
                          .toStringAsFixed(1),
                  DesktopTheme.accentTeal,
                  Icons.book_online,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CStat(
                  'Total Revenue',
                  '₹${(customers.fold<double>(0, (s, c) => s + c.totalSpent) / 1000).toStringAsFixed(1)}K',
                  DesktopTheme.successGreen,
                  Icons.payments,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Search bar
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
                  hint: 'Search customers by name, phone, email...',
                  width: 360,
                  onChanged: (v) =>
                      ref.read(customerSearchProvider.notifier).state = v,
                ),
                const Spacer(),
                Text(
                  '${filtered.length} customers',
                  style: const TextStyle(
                    fontSize: 12,
                    color: DesktopTheme.textMuted,
                  ),
                ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: const BoxDecoration(
                    color: DesktopTheme.contentBg,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    border: Border(
                      bottom: BorderSide(color: DesktopTheme.border),
                    ),
                  ),
                  child: const Row(
                    children: [
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
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: Text(
                        'No customers found',
                        style: TextStyle(color: DesktopTheme.textMuted),
                      ),
                    ),
                  )
                else
                  ...filtered.map(
                    (c) => _CustomerRow(
                      customer: c,
                      isOdd: filtered.indexOf(c).isOdd,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stat card ────────────────────────────────────────────────────────────────

class _CStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _CStat(this.label, this.value, this.color, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DesktopTheme.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: DesktopTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          // FIX: Expanded prevents the Column from overflowing the Row's width
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // FIX: don't expand vertically
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: DesktopTheme.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Table header cell ────────────────────────────────────────────────────────

class _TH extends StatelessWidget {
  final String label;
  const _TH(this.label);
  @override
  Widget build(BuildContext context) => Text(
    label,
    style: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: DesktopTheme.textMuted,
    ),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  );
}

// ─── Customer row ─────────────────────────────────────────────────────────────

class _CustomerRow extends ConsumerStatefulWidget {
  final Customer customer;
  final bool isOdd;
  const _CustomerRow({required this.customer, required this.isOdd});

  @override
  ConsumerState<_CustomerRow> createState() => _CustomerRowState();
}

class _CustomerRowState extends ConsumerState<_CustomerRow> {
  bool _hovered = false;

  Widget _buildHistoryRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: DesktopTheme.textMuted),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              color: DesktopTheme.textSecondary,
              fontSize: 13,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.customer;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: _hovered
              ? DesktopTheme.primaryBlue.withValues(alpha: 0.03)
              : widget.isOdd
              ? DesktopTheme.borderLight
              : DesktopTheme.cardBg,
          border: const Border(
            bottom: BorderSide(color: DesktopTheme.borderLight),
          ),
        ),
        child: IntrinsicHeight( // FIX: lets all cells use the tallest child's height
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Customer name + avatar ──────────────────────────────────────
              Expanded(
                flex: 3,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: c.isBlocked
                            ? DesktopTheme.dangerRed.withValues(alpha: 0.1)
                            : DesktopTheme.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          c.name.isEmpty ? '?' : c.name[0].toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: c.isBlocked
                                ? DesktopTheme.dangerRed
                                : DesktopTheme.primaryBlue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // FIX: Expanded + mainAxisSize.min prevents right + bottom overflow
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            c.name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'ID: ${c.id}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: DesktopTheme.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Contact ────────────────────────────────────────────────────
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // FIX: don't expand vertically
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      c.phone,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      c.email.isEmpty ? '—' : c.email,
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

              // ── Total Bookings ─────────────────────────────────────────────
              Expanded(
                flex: 2,
                child: Text(
                  '${c.totalBookings}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // ── Total Spent ────────────────────────────────────────────────
              Expanded(
                flex: 2,
                child: Text(
                  '₹${c.totalSpent.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: DesktopTheme.successGreen,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // ── Status ─────────────────────────────────────────────────────
              Expanded(
                flex: 2,
                child: StatusBadge(c.isBlocked ? 'Blocked' : 'Active'),
              ),

              // ── Actions ────────────────────────────────────────────────────
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisSize: MainAxisSize.min, // FIX: don't stretch the button row
                  children: [
                    Tooltip(
                      message: c.isBlocked ? 'Unblock' : 'Block',
                      child: GestureDetector(
                        onTap: () {
                          ref
                              .read(customerListProvider.notifier)
                              .updateCustomerBlockStatus(c.id, !c.isBlocked);
                        },
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: c.isBlocked
                                ? DesktopTheme.successGreen
                                    .withValues(alpha: 0.1)
                                : DesktopTheme.dangerRed
                                    .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            c.isBlocked
                                ? Icons.lock_open_rounded
                                : Icons.block_rounded,
                            size: 14,
                            color: c.isBlocked
                                ? DesktopTheme.successGreen
                                : DesktopTheme.dangerRed,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Tooltip(
                      message: 'View History',
                      child: GestureDetector(
                        onTap: () => showDialog(
                          context: context,
                          builder: (dlgCtx) => AlertDialog(
                            title: Row(
                              children: [
                                const Icon(
                                  Icons.history_rounded,
                                  color: DesktopTheme.primaryBlue,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    c.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            content: SizedBox(
                              width: 360,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildHistoryRow(
                                    'Phone',
                                    c.phone,
                                    Icons.phone_outlined,
                                  ),
                                  _buildHistoryRow(
                                    'Email',
                                    c.email.isEmpty ? '—' : c.email,
                                    Icons.email_outlined,
                                  ),
                                  _buildHistoryRow(
                                    'Total Bookings',
                                    '${c.totalBookings}',
                                    Icons.book_online,
                                  ),
                                  _buildHistoryRow(
                                    'Total Spent',
                                    '₹${c.totalSpent.toStringAsFixed(0)}',
                                    Icons.payments_outlined,
                                  ),
                                  _buildHistoryRow(
                                    'Status',
                                    c.isBlocked ? 'Blocked' : 'Active',
                                    Icons.verified_user_outlined,
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dlgCtx),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        ),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: DesktopTheme.primaryBlue.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.history_rounded,
                            size: 14,
                            color: DesktopTheme.primaryBlue,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
