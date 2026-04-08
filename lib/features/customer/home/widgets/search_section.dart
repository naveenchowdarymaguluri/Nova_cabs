import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/app_theme.dart';
import '../../search/location_picker_screen.dart';

class SearchSection extends StatefulWidget {
  final Function(String) onPickupChanged;
  final Function(String) onDropChanged;
  final Function(String) onCabTypeChanged;
  final Function(DateTime) onDateChanged;
  final Function(String) onRentalPackageChanged;
  final String pickupLocation;
  final String dropLocation;
  final String selectedCabType;
  final DateTime selectedDate;
  final String selectedRentalPackage;
  final VoidCallback onSearch;
  final String? selectedTab;

  const SearchSection({
    super.key,
    required this.onPickupChanged,
    required this.onDropChanged,
    required this.onCabTypeChanged,
    required this.onDateChanged,
    required this.onRentalPackageChanged,
    required this.pickupLocation,
    required this.dropLocation,
    required this.selectedCabType,
    required this.selectedDate,
    required this.selectedRentalPackage,
    required this.onSearch,
    this.selectedTab,
  });

  @override
  State<SearchSection> createState() => _SearchSectionState();
}

class _SearchSectionState extends State<SearchSection> {
  @override
  Widget build(BuildContext context) {
    final isRental = widget.selectedTab == 'Rental Cabs';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSelectionField(
            label: 'Leaving From',
            value: widget.pickupLocation,
            hint: 'Pickup location',
            icon: Icons.my_location,
            color: Colors.green,
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LocationPickerScreen(
                    title: 'Pickup Location',
                    hint: 'Where should we pick you up?',
                  ),
                ),
              );
              if (result != null) widget.onPickupChanged(result);
            },
          ),
          const SizedBox(height: 16),
          if (isRental)
            _buildSelectionField(
              label: 'Select Rental Package (Hrs | KM)',
              value: widget.selectedRentalPackage,
              hint: 'Choose Hours and Distance',
              icon: Icons.timer_outlined,
              color: Colors.orange,
              onTap: _showRentalPackagePicker,
            )
          else
            _buildSelectionField(
              label: 'Going To',
              value: widget.dropLocation,
              hint: 'Drop location',
              icon: Icons.location_on,
              color: Colors.red,
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LocationPickerScreen(
                      title: 'Drop Location',
                      hint: 'Where are you going?',
                    ),
                  ),
                );
                if (result != null) widget.onDropChanged(result);
              },
            ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSmallSelector(
                  label: 'Trip Date',
                  value: DateFormat('dd MMM, yyyy').format(widget.selectedDate),
                  icon: Icons.calendar_today,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: widget.selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (picked != null) widget.onDateChanged(picked);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSmallSelector(
                  label: 'Cab Type',
                  value: widget.selectedCabType,
                  icon: Icons.directions_car,
                  onTap: _showCabTypePicker,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: widget.onSearch,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                'Search ${widget.selectedTab ?? "Cabs"}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRentalPackagePicker() {
    final packages = [
      {'hrs': 2, 'km': 20},
      {'hrs': 4, 'km': 40},
      {'hrs': 6, 'km': 60},
      {'hrs': 8, 'km': 80},
      {'hrs': 12, 'km': 120},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Select Rental Package', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text(
                      'Packages are based on Hours and Distance',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    ...packages.map((pkg) {
                      final label = '${pkg['hrs']} Hrs | ${pkg['km']} KM';
                      return ListTile(
                        leading: const Icon(Icons.timer_outlined, color: AppTheme.primaryColor),
                        title: Text(label),
                        subtitle: Text('Base fare covers up to ${pkg['hrs']} hours and ${pkg['km']} km'),
                        trailing: widget.selectedRentalPackage == label ? const Icon(Icons.check_circle, color: AppTheme.primaryColor) : null,
                        onTap: () {
                          widget.onRentalPackageChanged(label);
                          Navigator.pop(context);
                        },
                      );
                    }),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSelectionField({
    required String label,
    required String value,
    required String hint,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value.isEmpty ? hint : value,
                    style: TextStyle(
                      fontSize: 15,
                      color: value.isEmpty ? Colors.grey.shade500 : Colors.black87,
                      fontWeight: value.isEmpty ? FontWeight.normal : FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.unfold_more, color: Colors.grey.shade400, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSmallSelector({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppTheme.primaryColor, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showCabTypePicker() {
    final types = ['4-Seater', '7-Seater', '13-Seater'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select Cab Type', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ...types.map((type) => ListTile(
                    leading: const Icon(Icons.directions_car),
                    title: Text(type),
                    trailing: widget.selectedCabType == type ? const Icon(Icons.check_circle, color: AppTheme.primaryColor) : null,
                    onTap: () {
                      widget.onCabTypeChanged(type);
                      Navigator.pop(context);
                    },
                  )),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
