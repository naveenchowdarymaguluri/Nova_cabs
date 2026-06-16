import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/desktop_theme.dart';
import '../shared/desktop_widgets.dart';
import '../../../core/app_providers.dart';
import '../../../core/extended_models.dart';

class VehicleManagementDesktopScreen extends ConsumerStatefulWidget {
  const VehicleManagementDesktopScreen({super.key});

  @override
  ConsumerState<VehicleManagementDesktopScreen> createState() => _VehicleManagementDesktopScreenState();
}

class _VehicleManagementDesktopScreenState extends ConsumerState<VehicleManagementDesktopScreen> {
  String _search = '';
  String _filter = 'All';

  String _statusLabel(AccountStatus status) {
    switch (status) {
      case AccountStatus.active:
      case AccountStatus.approved:
        return 'Active';
      case AccountStatus.pendingVerification:
        return 'Under Verification';
      default:
        return 'Inactive';
    }
  }

  @override
  Widget build(BuildContext context) {
    final driversAsync = ref.watch(firestoreAllDriversProvider);

    return driversAsync.when(
      data: (drivers) {
        final filtered = drivers.where((d) {
          final matchSearch = _search.isEmpty ||
              d.vehicleNumber.toLowerCase().contains(_search.toLowerCase()) ||
              d.vehicleModel.toLowerCase().contains(_search.toLowerCase()) ||
              (d.agencyName ?? d.fullName).toLowerCase().contains(_search.toLowerCase());
          final statusStr = _statusLabel(d.status);
          final matchFilter = _filter == 'All' || d.vehicleType == _filter || statusStr == _filter;
          return matchSearch && matchFilter;
        }).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(DesktopTheme.contentPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionHeader(
                title: 'Vehicle Management',
                subtitle: 'Manage all registered vehicles on the platform',
              ),
              const SizedBox(height: 20),

              // Stats
              Row(
                children: [
                  Expanded(child: _VStat('Total Vehicles', '${drivers.length}', DesktopTheme.primaryBlue, Icons.directions_car)),
                  const SizedBox(width: 12),
                  Expanded(child: _VStat('Active', '${drivers.where((d) => d.status == AccountStatus.active || d.status == AccountStatus.approved).length}', DesktopTheme.successGreen, Icons.check_circle)),
                  const SizedBox(width: 12),
                  Expanded(child: _VStat('Under Verification', '${drivers.where((d) => d.status == AccountStatus.pendingVerification).length}', DesktopTheme.warningAmber, Icons.pending)),
                  const SizedBox(width: 12),
                  Expanded(child: _VStat('Inactive', '${drivers.where((d) => d.status == AccountStatus.inactive || d.status == AccountStatus.suspended || d.status == AccountStatus.rejected).length}', DesktopTheme.dangerRed, Icons.block)),
                  const SizedBox(width: 12),
                  Expanded(child: _VStat('4-Seaters', '${drivers.where((d) => d.vehicleType == '4-Seater').length}', DesktopTheme.accentTeal, Icons.airline_seat_recline_normal)),
                ],
              ),
              const SizedBox(height: 20),

              // Filter row
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: DesktopTheme.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: DesktopTheme.border)),
                child: Row(
                  children: [
                    DesktopSearchBar(
                      hint: 'Search vehicle, model, owner...',
                      width: 300,
                      onChanged: (v) => setState(() => _search = v),
                    ),
                    const SizedBox(width: 16),
                    for (final f in ['All', '4-Seater', '7-Seater', '13-Seater', 'Active', 'Under Verification', 'Inactive']) ...[
                      _FChip(label: f, current: _filter, onTap: () => setState(() => _filter = f)),
                      const SizedBox(width: 8),
                    ],
                    const Spacer(),
                    Text('${filtered.length} vehicles', style: const TextStyle(fontSize: 12, color: DesktopTheme.textMuted)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (filtered.isEmpty)
                Container(
                  padding: const EdgeInsets.all(40),
                  alignment: Alignment.center,
                  child: const Text('No vehicles found', style: TextStyle(color: DesktopTheme.textMuted, fontSize: 14)),
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth > 1400 ? 4 : constraints.maxWidth > 900 ? 3 : 2;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: crossAxisCount == 3 ? 1.6 : 1.4,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (ctx, i) => _VehicleCard(
                        driver: filtered[i],
                        statusLabel: _statusLabel(filtered[i].status),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _VStat extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  const _VStat(this.label, this.value, this.color, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: DesktopTheme.cardBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: DesktopTheme.border)),
      child: Row(children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 18)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
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
      ]),
    );
  }
}

class _FChip extends StatelessWidget {
  final String label, current;
  final VoidCallback onTap;
  const _FChip({required this.label, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isActive = label == current;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? DesktopTheme.primaryBlue : DesktopTheme.contentBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isActive ? DesktopTheme.primaryBlue : DesktopTheme.border),
        ),
        child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: isActive ? Colors.white : DesktopTheme.textSecondary)),
      ),
    );
  }
}

class _VehicleCard extends StatefulWidget {
  final DriverModel driver;
  final String statusLabel;
  const _VehicleCard({required this.driver, required this.statusLabel});

  @override
  State<_VehicleCard> createState() => _VehicleCardState();
}

class _VehicleCardState extends State<_VehicleCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final d = widget.driver;
    final typeColors = {'4-Seater': DesktopTheme.primaryBlue, '7-Seater': DesktopTheme.accentTeal, '13-Seater': DesktopTheme.purpleAccent};
    final typeColor = typeColors[d.vehicleType] ?? DesktopTheme.primaryBlue;
    final ownerName = d.agencyName ?? d.fullName;
    final ownerType = d.driverType == DriverType.agency ? 'Agency' : 'Individual';

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: DesktopTheme.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _hovered ? typeColor.withValues(alpha: 0.4) : DesktopTheme.border),
          boxShadow: _hovered ? [BoxShadow(color: typeColor.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))] : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: typeColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.directions_car_rounded, color: typeColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(d.vehicleModel.isEmpty ? 'Unknown Model' : d.vehicleModel, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(d.vehicleNumber, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: typeColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                ])),
                const SizedBox(width: 8),
                StatusBadge(widget.statusLabel),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: DesktopTheme.border, height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _VInfo(label: 'Type', value: d.vehicleType)),
                Expanded(child: _VInfo(label: 'Driver', value: d.fullName)),
              ],
            ),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.business_rounded, size: 12, color: DesktopTheme.textMuted),
              const SizedBox(width: 4),
              Expanded(child: Text(ownerName, style: const TextStyle(fontSize: 12, color: DesktopTheme.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: DesktopTheme.contentBg, borderRadius: BorderRadius.circular(4)),
                child: Text(ownerType, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: DesktopTheme.textMuted)),
              ),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _DocBadge(label: 'RC', value: d.vehicleRc)),
              const SizedBox(width: 8),
              Expanded(child: _DocBadge(label: 'Insurance', value: d.insuranceNumber)),
            ]),
          ],
        ),
      ),
    );
  }
}

class _VInfo extends StatelessWidget {
  final String label, value;
  const _VInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 9, color: DesktopTheme.textMuted, letterSpacing: 0.5, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
      Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: DesktopTheme.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
    ]);
  }
}

class _DocBadge extends StatelessWidget {
  final String label, value;
  const _DocBadge({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: DesktopTheme.successGreen.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(6), border: Border.all(color: DesktopTheme.successGreen.withValues(alpha: 0.2))),
      child: Row(children: [
        const Icon(Icons.verified_rounded, size: 11, color: DesktopTheme.successGreen),
        const SizedBox(width: 4),
        Expanded(child: Text('$label: $value', style: const TextStyle(fontSize: 10, color: DesktopTheme.successGreen, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)),
      ]),
    );
  }
}
