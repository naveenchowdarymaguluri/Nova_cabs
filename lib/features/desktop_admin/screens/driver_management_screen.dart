import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/desktop_theme.dart';
import '../shared/desktop_widgets.dart';
import '../../../core/extended_models.dart';
import '../../../core/app_providers.dart';

final driverSearchProvider = StateProvider<String>((ref) => '');
final driverStatusFilterProvider = StateProvider<String>((ref) => 'All');

class DriverManagementScreen extends ConsumerWidget {
  const DriverManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drivers = ref.watch(driverListProvider);
    final search = ref.watch(driverSearchProvider);
    final filter = ref.watch(driverStatusFilterProvider);

    List<DriverModel> filtered = drivers.where((d) {
      final matchSearch = search.isEmpty ||
          d.fullName.toLowerCase().contains(search.toLowerCase()) ||
          d.mobileNumber.contains(search) ||
          d.vehicleNumber.toLowerCase().contains(search.toLowerCase());
      final matchFilter = filter == 'All' || d.statusLabel == filter;
      return matchSearch && matchFilter;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesktopTheme.contentPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            title: 'Driver Management',
            subtitle: 'Manage, approve, and monitor all drivers on the platform',
            action: PrimaryButton(
              label: 'Add Driver',
              icon: Icons.add_rounded,
              onPressed: () {},
            ),
          ),
          const SizedBox(height: 20),

          // Stats
          Row(
            children: [
              Expanded(child: _DriverStatCard(label: 'Total Drivers', value: '${drivers.length}', color: DesktopTheme.primaryBlue, icon: Icons.people)),
              const SizedBox(width: 12),
              Expanded(child: _DriverStatCard(label: 'Pending', value: '${drivers.where((d) => d.status == AccountStatus.pendingVerification).length}', color: DesktopTheme.warningAmber, icon: Icons.hourglass_empty)),
              const SizedBox(width: 12),
              Expanded(child: _DriverStatCard(label: 'Approved', value: '${drivers.where((d) => d.status == AccountStatus.approved).length}', color: DesktopTheme.successGreen, icon: Icons.check_circle)),
              const SizedBox(width: 12),
              Expanded(child: _DriverStatCard(label: 'Online Now', value: '${drivers.where((d) => d.isOnline && d.status == AccountStatus.approved).length}', color: DesktopTheme.accentTeal, icon: Icons.wifi)),
              const SizedBox(width: 12),
              Expanded(child: _DriverStatCard(label: 'Suspended', value: '${drivers.where((d) => d.status == AccountStatus.suspended).length}', color: DesktopTheme.dangerRed, icon: Icons.block)),
            ],
          ),
          const SizedBox(height: 20),

          // Filter + Search
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: DesktopTheme.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: DesktopTheme.border),
            ),
            child: Row(
              children: [
                DesktopSearchBar(
                  hint: 'Search by name, phone, vehicle...',
                  width: 300,
                  onChanged: (v) => ref.read(driverSearchProvider.notifier).state = v,
                ),
                const SizedBox(width: 16),
                _FilterChip(ref: ref, label: 'All', filterProvider: driverStatusFilterProvider),
                const SizedBox(width: 8),
                _FilterChip(ref: ref, label: 'Pending Verification', filterProvider: driverStatusFilterProvider),
                const SizedBox(width: 8),
                _FilterChip(ref: ref, label: 'Approved', filterProvider: driverStatusFilterProvider),
                const SizedBox(width: 8),
                _FilterChip(ref: ref, label: 'Rejected', filterProvider: driverStatusFilterProvider),
                const SizedBox(width: 8),
                _FilterChip(ref: ref, label: 'Suspended', filterProvider: driverStatusFilterProvider),
                const Spacer(),
                Text('${filtered.length} records', style: const TextStyle(fontSize: 12, color: DesktopTheme.textMuted)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Data Table
          _DriverTable(drivers: filtered, ref: ref),
        ],
      ),
    );
  }
}

class _DriverStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _DriverStatCard({required this.label, required this.value, required this.color, required this.icon});

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

class _FilterChip extends StatelessWidget {
  final WidgetRef ref;
  final String label;
  final StateProvider<String> filterProvider;
  const _FilterChip({required this.ref, required this.label, required this.filterProvider});

  @override
  Widget build(BuildContext context) {
    final current = ref.watch(filterProvider);
    final isActive = current == label;
    return GestureDetector(
      onTap: () => ref.read(filterProvider.notifier).state = label,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? DesktopTheme.primaryBlue : DesktopTheme.contentBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? DesktopTheme.primaryBlue : DesktopTheme.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isActive ? Colors.white : DesktopTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _DriverTable extends StatelessWidget {
  final List<DriverModel> drivers;
  final WidgetRef ref;
  const _DriverTable({required this.drivers, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DesktopTheme.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DesktopTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: DesktopTheme.contentBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              border: const Border(bottom: BorderSide(color: DesktopTheme.border)),
            ),
            child: Row(
              children: const [
                SizedBox(width: 40),
                Expanded(flex: 3, child: _TH('Driver')),
                Expanded(flex: 2, child: _TH('Contact')),
                Expanded(flex: 2, child: _TH('Vehicle')),
                Expanded(flex: 2, child: _TH('Type')),
                Expanded(flex: 2, child: _TH('Status')),
                Expanded(flex: 1, child: _TH('Online')),
                Expanded(flex: 2, child: _TH('Rating')),
                Expanded(flex: 2, child: _TH('Actions')),
              ],
            ),
          ),

          if (drivers.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: Text('No drivers found', style: TextStyle(color: DesktopTheme.textMuted))),
            )
          else
            ...drivers.map((d) => _DriverRow(driver: d, ref: ref, isOdd: drivers.indexOf(d).isOdd)),
        ],
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

class _DriverRow extends StatefulWidget {
  final DriverModel driver;
  final WidgetRef ref;
  final bool isOdd;
  const _DriverRow({required this.driver, required this.ref, required this.isOdd});

  @override
  State<_DriverRow> createState() => _DriverRowState();
}

class _DriverRowState extends State<_DriverRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final d = widget.driver;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: _hovered
              ? DesktopTheme.primaryBlue.withOpacity(0.03)
              : widget.isOdd
                  ? DesktopTheme.borderLight
                  : DesktopTheme.cardBg,
          border: const Border(bottom: BorderSide(color: DesktopTheme.borderLight)),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [DesktopTheme.primaryBlue, DesktopTheme.purpleAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(d.fullName.isEmpty ? '?' : d.fullName[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),

            // Name
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(d.fullName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: DesktopTheme.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('ID: ${d.id}', style: const TextStyle(fontSize: 11, color: DesktopTheme.textMuted)),
                ],
              ),
            ),

            // Phone
            Expanded(
              flex: 2,
              child: Text(d.mobileNumber, style: const TextStyle(fontSize: 12, color: DesktopTheme.textSecondary)),
            ),

            // Vehicle
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(d.vehicleNumber, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: DesktopTheme.textPrimary)),
                  Text(d.vehicleType, style: const TextStyle(fontSize: 11, color: DesktopTheme.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),

            // Type
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: d.driverType == DriverType.individual
                      ? DesktopTheme.primaryBlue.withOpacity(0.08)
                      : DesktopTheme.accentTeal.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: d.driverType == DriverType.individual
                        ? DesktopTheme.primaryBlue.withOpacity(0.2)
                        : DesktopTheme.accentTeal.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  d.driverType == DriverType.individual ? 'Individual' : 'Agency',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: d.driverType == DriverType.individual ? DesktopTheme.primaryBlue : DesktopTheme.accentTeal,
                  ),
                ),
              ),
            ),

            // Status
            Expanded(flex: 2, child: StatusBadge(d.statusLabel)),

            // Online
            Expanded(
              flex: 1,
              child: Center(
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: d.isOnline ? DesktopTheme.successGreen : DesktopTheme.textMuted,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),

            // Rating
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  const Icon(Icons.star_rounded, size: 14, color: DesktopTheme.warningAmber),
                  const SizedBox(width: 4),
                  Text('${d.rating.toStringAsFixed(1)} (${d.totalTrips})', style: const TextStyle(fontSize: 12, color: DesktopTheme.textSecondary)),
                ],
              ),
            ),

            // Actions
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  if (d.status == AccountStatus.pendingVerification) ...[
                    _ActionIconButton(
                      icon: Icons.check_circle_rounded,
                      color: DesktopTheme.successGreen,
                      tooltip: 'Approve',
                      onTap: () => widget.ref.read(driverListProvider.notifier).approveDriver(d.id),
                    ),
                    const SizedBox(width: 6),
                    _ActionIconButton(
                      icon: Icons.cancel_rounded,
                      color: DesktopTheme.dangerRed,
                      tooltip: 'Reject',
                      onTap: () => widget.ref.read(driverListProvider.notifier).rejectDriver(d.id, 'Documents missing'),
                    ),
                  ],
                  if (d.status == AccountStatus.approved)
                    _ActionIconButton(
                      icon: Icons.block_rounded,
                      color: DesktopTheme.warningAmber,
                      tooltip: 'Suspend',
                      onTap: () => widget.ref.read(driverListProvider.notifier).suspendDriver(d.id),
                    ),
                  if (d.status == AccountStatus.suspended || d.status == AccountStatus.rejected)
                    _ActionIconButton(
                      icon: Icons.check_circle_rounded,
                      color: DesktopTheme.successGreen,
                      tooltip: 'Activate',
                      onTap: () => widget.ref.read(driverListProvider.notifier).activateDriver(d.id),
                    ),
                  const SizedBox(width: 6),
                  _ActionIconButton(
                    icon: Icons.visibility_rounded,
                    color: DesktopTheme.primaryBlue,
                    tooltip: 'View Details',
                    onTap: () => _showDriverDetails(context, d),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDriverDetails(BuildContext context, DriverModel driver) {
    showDialog(
      context: context,
      builder: (ctx) => _DriverDetailDialog(driver: driver),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback? onTap;

  const _ActionIconButton({required this.icon, required this.color, required this.tooltip, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
      ),
    );
  }
}

class _DriverDetailDialog extends StatelessWidget {
  final DriverModel driver;
  const _DriverDetailDialog({required this.driver});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: DesktopTheme.cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [DesktopTheme.primaryBlue, DesktopTheme.purpleAccent]),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(child: Text(driver.fullName[0], style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(driver.fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        Text(driver.mobileNumber, style: const TextStyle(color: DesktopTheme.textMuted, fontSize: 13)),
                      ],
                    ),
                  ),
                  StatusBadge(driver.statusLabel),
                  const SizedBox(width: 12),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(color: DesktopTheme.border),
              const SizedBox(height: 16),

              _Section('Personal Info'),
              _DetailRow('Driver ID', driver.id),
              _DetailRow('Full Name', driver.fullName),
              _DetailRow('Mobile', driver.mobileNumber),
              _DetailRow('Aadhaar', driver.aadhaarNumber),
              _DetailRow('License', driver.drivingLicense),
              _DetailRow('Driver Type', driver.driverType == DriverType.individual ? 'Individual' : 'Agency'),
              if (driver.agencyName != null) _DetailRow('Agency', driver.agencyName!),

              const SizedBox(height: 16),
              _Section('Vehicle Info'),
              _DetailRow('Vehicle No.', driver.vehicleNumber),
              _DetailRow('Vehicle Model', driver.vehicleModel),
              _DetailRow('Vehicle Type', driver.vehicleType),
              _DetailRow('RC Number', driver.vehicleRc),
              _DetailRow('Insurance No.', driver.insuranceNumber),

              const SizedBox(height: 16),
              _Section('Performance'),
              _DetailRow('Rating', '${driver.rating.toStringAsFixed(1)} ⭐'),
              _DetailRow('Total Trips', '${driver.totalTrips}'),
              _DetailRow('Total Earnings', '₹${driver.totalEarnings.toStringAsFixed(0)}'),
              _DetailRow('Currently Online', driver.isOnline ? 'Yes 🟢' : 'No ⚫'),

              if (driver.adminRemarks != null) ...[
                const SizedBox(height: 12),
                _Section('Admin Remarks'),
                Text(driver.adminRemarks!, style: const TextStyle(color: DesktopTheme.textSecondary, fontSize: 13)),
              ],

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  const _Section(this.title);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: DesktopTheme.primaryBlue, letterSpacing: 0.5)),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 140, child: Text(label, style: const TextStyle(fontSize: 13, color: DesktopTheme.textMuted))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: DesktopTheme.textPrimary))),
        ],
      ),
    );
  }
}
