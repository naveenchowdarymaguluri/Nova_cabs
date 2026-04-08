import 'package:flutter/material.dart';
import '../core/desktop_theme.dart';
import '../shared/desktop_widgets.dart';

class VehicleManagementDesktopScreen extends StatefulWidget {
  const VehicleManagementDesktopScreen({super.key});

  @override
  State<VehicleManagementDesktopScreen> createState() => _VehicleManagementDesktopScreenState();
}

class _VehicleManagementDesktopScreenState extends State<VehicleManagementDesktopScreen> {
  String _search = '';
  String _filter = 'All';

  final List<Map<String, dynamic>> _vehicles = [
    {'id': 'V001', 'number': 'KA-01-MJ-1234', 'model': 'Toyota Camry', 'type': '4-Seater', 'owner': 'Quick Travels', 'ownerType': 'Agency', 'fuel': 'Petrol', 'status': 'Active', 'rc': 'RC123456', 'insurance': 'INS789012', 'year': 2022},
    {'id': 'V002', 'number': 'KA-02-AB-5678', 'model': 'Toyota Innova', 'type': '7-Seater', 'owner': 'Elite Cabs', 'ownerType': 'Agency', 'fuel': 'Diesel', 'status': 'Active', 'rc': 'RC234567', 'insurance': 'INS890123', 'year': 2021},
    {'id': 'V003', 'number': 'KA-03-CD-9012', 'model': 'Force Traveller', 'type': '13-Seater', 'owner': 'Global Travels', 'ownerType': 'Agency', 'fuel': 'Diesel', 'status': 'Under Verification', 'rc': 'RC345678', 'insurance': 'INS901234', 'year': 2020},
    {'id': 'V004', 'number': 'KA-04-EF-3456', 'model': 'Honda City', 'type': '4-Seater', 'owner': 'Rajesh Kumar', 'ownerType': 'Individual', 'fuel': 'Petrol', 'status': 'Active', 'rc': 'RC456789', 'insurance': 'INS012345', 'year': 2023},
    {'id': 'V005', 'number': 'KA-05-GH-7890', 'model': 'Maruti Ertiga', 'type': '7-Seater', 'owner': 'Quick Travels', 'ownerType': 'Agency', 'fuel': 'CNG', 'status': 'Inactive', 'rc': 'RC567890', 'insurance': 'INS123456', 'year': 2019},
    {'id': 'V006', 'number': 'KA-06-IJ-2345', 'model': 'Tata Nexon', 'type': '4-Seater', 'owner': 'Suresh Patel', 'ownerType': 'Individual', 'fuel': 'Electric', 'status': 'Active', 'rc': 'RC678901', 'insurance': 'INS234567', 'year': 2024},
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _vehicles.where((v) {
      final matchSearch = _search.isEmpty ||
          (v['number'] as String).toLowerCase().contains(_search.toLowerCase()) ||
          (v['model'] as String).toLowerCase().contains(_search.toLowerCase()) ||
          (v['owner'] as String).toLowerCase().contains(_search.toLowerCase());
      final matchFilter = _filter == 'All' || v['type'] == _filter || v['status'] == _filter;
      return matchSearch && matchFilter;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesktopTheme.contentPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            title: 'Vehicle Management',
            subtitle: 'Manage all registered vehicles on the platform',
            action: PrimaryButton(label: 'Add Vehicle', icon: Icons.add_rounded, onPressed: () {}),
          ),
          const SizedBox(height: 20),

          // Stats
          Row(
            children: [
              Expanded(child: _VStat('Total Vehicles', '${_vehicles.length}', DesktopTheme.primaryBlue, Icons.directions_car)),
              const SizedBox(width: 12),
              Expanded(child: _VStat('Active', '${_vehicles.where((v) => v['status'] == 'Active').length}', DesktopTheme.successGreen, Icons.check_circle)),
              const SizedBox(width: 12),
              Expanded(child: _VStat('Under Verification', '${_vehicles.where((v) => v['status'] == 'Under Verification').length}', DesktopTheme.warningAmber, Icons.pending)),
              const SizedBox(width: 12),
              Expanded(child: _VStat('Inactive', '${_vehicles.where((v) => v['status'] == 'Inactive').length}', DesktopTheme.dangerRed, Icons.block)),
              const SizedBox(width: 12),
              Expanded(child: _VStat('4-Seaters', '${_vehicles.where((v) => v['type'] == '4-Seater').length}', DesktopTheme.accentTeal, Icons.airline_seat_recline_normal)),
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

          // Grid
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
                  childAspectRatio: crossAxisCount == 3 ? 1.5 : 1.35,
                ),
                itemCount: filtered.length,
                itemBuilder: (ctx, i) => _VehicleCard(vehicle: filtered[i]),
              );
            },
          ),
        ],
      ),
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
      child:      Row(children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 18)),
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
  final Map<String, dynamic> vehicle;
  const _VehicleCard({required this.vehicle});

  @override
  State<_VehicleCard> createState() => _VehicleCardState();
}

class _VehicleCardState extends State<_VehicleCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final v = widget.vehicle;
    final typeColors = {'4-Seater': DesktopTheme.primaryBlue, '7-Seater': DesktopTheme.accentTeal, '13-Seater': DesktopTheme.purpleAccent};
    final typeColor = typeColors[v['type']] ?? DesktopTheme.primaryBlue;

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
                  Text(v['model'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(v['number'] as String, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: typeColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                ])),
                const SizedBox(width: 8),
                StatusBadge(v['status'] as String),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: DesktopTheme.border, height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _VInfo(label: 'Type', value: v['type'] as String)),
                Expanded(child: _VInfo(label: 'Fuel', value: v['fuel'] as String)),
                Expanded(child: _VInfo(label: 'Year', value: '${v['year']}')),
              ],
            ),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.business_rounded, size: 12, color: DesktopTheme.textMuted),
              const SizedBox(width: 4),
              Expanded(child: Text(v['owner'] as String, style: const TextStyle(fontSize: 12, color: DesktopTheme.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: DesktopTheme.contentBg, borderRadius: BorderRadius.circular(4)),
                child: Text(v['ownerType'] as String, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: DesktopTheme.textMuted)),
              ),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _DocBadge(label: 'RC', value: v['rc'] as String)),
              const SizedBox(width: 8),
              Expanded(child: _DocBadge(label: 'Insurance', value: v['insurance'] as String)),
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
