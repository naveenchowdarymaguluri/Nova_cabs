import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/desktop_theme.dart';
import '../shared/desktop_widgets.dart';
import '../../../core/extended_models.dart';
import '../../../core/app_providers.dart';

final agencySearchProvider = StateProvider<String>((ref) => '');
final agencyFilterProvider = StateProvider<String>((ref) => 'All');

class AgencyManagementScreen extends ConsumerWidget {
  const AgencyManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agencies = ref.watch(agencyListProvider);
    final search = ref.watch(agencySearchProvider);
    final filter = ref.watch(agencyFilterProvider);

    List<AgencyModel> filtered = agencies.where((a) {
      final matchSearch = search.isEmpty ||
          a.agencyName.toLowerCase().contains(search.toLowerCase()) ||
          a.ownerName.toLowerCase().contains(search.toLowerCase()) ||
          a.phoneNumber.contains(search);
      final matchFilter = filter == 'All' || a.statusLabel == filter;
      return matchSearch && matchFilter;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesktopTheme.contentPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            title: 'Travel Agency Management',
            subtitle: 'Approve, monitor and manage all registered travel agencies',
            action: PrimaryButton(
              label: 'Add Agency',
              icon: Icons.add_rounded,
              onPressed: () {},
            ),
          ),
          const SizedBox(height: 20),

          // Stats
          Row(
            children: [
              Expanded(child: _AgencyStat(label: 'Total Agencies', value: '${agencies.length}', color: DesktopTheme.primaryBlue, icon: Icons.business)),
              const SizedBox(width: 12),
              Expanded(child: _AgencyStat(label: 'Pending Approval', value: '${agencies.where((a) => a.status == AccountStatus.pendingVerification).length}', color: DesktopTheme.warningAmber, icon: Icons.hourglass_empty)),
              const SizedBox(width: 12),
              Expanded(child: _AgencyStat(label: 'Approved', value: '${agencies.where((a) => a.status == AccountStatus.approved).length}', color: DesktopTheme.successGreen, icon: Icons.check_circle)),
              const SizedBox(width: 12),
              Expanded(child: _AgencyStat(label: 'Suspended', value: '${agencies.where((a) => a.status == AccountStatus.suspended).length}', color: DesktopTheme.dangerRed, icon: Icons.block)),
              const SizedBox(width: 12),
              Expanded(child: _AgencyStat(label: 'Total Revenue', value: '₹${(agencies.fold<double>(0, (s, a) => s + a.totalEarnings) / 100000).toStringAsFixed(1)}L', color: DesktopTheme.accentTeal, icon: Icons.payments)),
            ],
          ),
          const SizedBox(height: 20),

          // Search + Filter
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
                  hint: 'Search agencies...',
                  width: 280,
                  onChanged: (v) => ref.read(agencySearchProvider.notifier).state = v,
                ),
                const SizedBox(width: 16),
                for (final label in ['All', 'Pending Approval', 'Approved', 'Suspended', 'Rejected']) ...[
                  _Chip(ref: ref, label: label, provider: agencyFilterProvider),
                  const SizedBox(width: 8),
                ],
                const Spacer(),
                Text('${filtered.length} agencies', style: const TextStyle(fontSize: 12, color: DesktopTheme.textMuted)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Agency Grid Cards
          _AgencyGrid(agencies: filtered, ref: ref),
        ],
      ),
    );
  }
}

class _AgencyStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _AgencyStat({required this.label, required this.value, required this.color, required this.icon});

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
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 18),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
                ),
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: DesktopTheme.textMuted),
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

class _Chip extends StatelessWidget {
  final WidgetRef ref;
  final String label;
  final StateProvider<String> provider;
  const _Chip({required this.ref, required this.label, required this.provider});

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
        child: Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isActive ? Colors.white : DesktopTheme.textSecondary),
        ),
      ),
    );
  }
}

class _AgencyGrid extends StatelessWidget {
  final List<AgencyModel> agencies;
  final WidgetRef ref;
  const _AgencyGrid({required this.agencies, required this.ref});

  @override
  Widget build(BuildContext context) {
    if (agencies.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text('No agencies found', style: TextStyle(color: DesktopTheme.textMuted)),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.4,
      ),
      itemCount: agencies.length,
      itemBuilder: (ctx, i) => _AgencyCard(agency: agencies[i], ref: ref),
    );
  }
}

class _AgencyCard extends StatefulWidget {
  final AgencyModel agency;
  final WidgetRef ref;
  const _AgencyCard({required this.agency, required this.ref});

  @override
  State<_AgencyCard> createState() => _AgencyCardState();
}

class _AgencyCardState extends State<_AgencyCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.agency;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: DesktopTheme.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _hovered ? DesktopTheme.primaryBlue.withOpacity(0.3) : DesktopTheme.border),
          boxShadow: _hovered
              ? [BoxShadow(color: DesktopTheme.primaryBlue.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 4))]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [DesktopTheme.accentTeal, DesktopTheme.primaryBlue]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(a.agencyName[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.agencyName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DesktopTheme.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(a.ownerName, style: const TextStyle(fontSize: 12, color: DesktopTheme.textMuted)),
                    ],
                  ),
                ),
                StatusBadge(a.statusLabel),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(color: DesktopTheme.border, height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _AgencyStat2(label: 'Drivers', value: '${a.totalDrivers}'),
                _AgencyStat2(label: 'Bookings', value: '${a.totalBookings}'),
                _AgencyStat2(label: 'Revenue', value: '₹${(a.totalEarnings / 1000).toStringAsFixed(0)}K'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (a.status == AccountStatus.pendingVerification) ...[
                  Expanded(
                    child: SizedBox(
                      height: 32,
                      child: ElevatedButton(
                        onPressed: () => widget.ref.read(agencyListProvider.notifier).approveAgency(a.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DesktopTheme.successGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        child: const Text('Approve', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 32,
                      child: OutlinedButton(
                        onPressed: () => widget.ref.read(agencyListProvider.notifier).rejectAgency(a.id, 'Documents missing'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: DesktopTheme.dangerRed,
                          side: const BorderSide(color: DesktopTheme.dangerRed),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        child: const Text('Reject', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ] else if (a.status == AccountStatus.approved)
                  Expanded(
                    child: SizedBox(
                      height: 32,
                      child: OutlinedButton(
                        onPressed: () => widget.ref.read(agencyListProvider.notifier).suspendAgency(a.id),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: DesktopTheme.warningAmber,
                          side: const BorderSide(color: DesktopTheme.warningAmber),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        child: const Text('Suspend', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  )
                else if (a.status == AccountStatus.suspended || a.status == AccountStatus.rejected)
                  Expanded(
                    child: SizedBox(
                      height: 32,
                      child: ElevatedButton(
                        onPressed: () => widget.ref.read(agencyListProvider.notifier).approveAgency(a.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DesktopTheme.successGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        child: const Text('Activate', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 32,
                  width: 32,
                  child: OutlinedButton(
                    onPressed: () => _showDetails(context, a),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      foregroundColor: DesktopTheme.primaryBlue,
                      side: const BorderSide(color: DesktopTheme.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Icon(Icons.visibility_rounded, size: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDetails(BuildContext context, AgencyModel a) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: DesktopTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: 540,
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(gradient: const LinearGradient(colors: [DesktopTheme.accentTeal, DesktopTheme.primaryBlue]), borderRadius: BorderRadius.circular(14)),
                      child: Center(child: Text(a.agencyName[0], style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a.agencyName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                          Text(a.ownerName, style: const TextStyle(color: DesktopTheme.textMuted, fontSize: 13)),
                        ],
                      ),
                    ),
                    StatusBadge(a.statusLabel),
                    const SizedBox(width: 8),
                    IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: DesktopTheme.border),
                const SizedBox(height: 16),
                _DetailRow2('Phone', a.phoneNumber),
                _DetailRow2('Email', a.email),
                _DetailRow2('Address', a.businessAddress),
                if (a.gstNumber != null) _DetailRow2('GST Number', a.gstNumber!),
                _DetailRow2('Bank Details', a.bankDetails),
                _DetailRow2('Registered', '${a.registeredAt.day}/${a.registeredAt.month}/${a.registeredAt.year}'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _StatChip('${a.totalDrivers} Drivers'),
                    const SizedBox(width: 8),
                    _StatChip('${a.totalBookings} Trips'),
                    const SizedBox(width: 8),
                    _StatChip('₹${(a.totalEarnings / 1000).toStringAsFixed(0)}K Revenue'),
                  ],
                ),
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

class _AgencyStat2 extends StatelessWidget {
  final String label;
  final String value;
  const _AgencyStat2({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: DesktopTheme.textPrimary)),
        Text(label, style: const TextStyle(fontSize: 10, color: DesktopTheme.textMuted)),
      ],
    );
  }
}

class _DetailRow2 extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow2(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text(label, style: const TextStyle(fontSize: 13, color: DesktopTheme.textMuted))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: DesktopTheme.textPrimary))),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  const _StatChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: DesktopTheme.contentBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: DesktopTheme.border),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: DesktopTheme.textSecondary)),
    );
  }
}
