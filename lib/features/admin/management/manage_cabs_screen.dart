import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_theme.dart';
import '../../../core/extended_models.dart';
import '../../../core/app_providers.dart';
import '../../../core/firestore_service.dart';

class ManageCabsScreen extends ConsumerStatefulWidget {
  const ManageCabsScreen({super.key});

  @override
  ConsumerState<ManageCabsScreen> createState() => _ManageCabsScreenState();
}

class _ManageCabsScreenState extends ConsumerState<ManageCabsScreen> {
  String _searchQuery = '';
  String _filterType = 'All';

  List<DriverModel> _getFilteredDrivers(List<DriverModel> drivers) {
    return drivers.where((d) {
      final matchesSearch = d.vehicleModel.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (d.agencyName ?? 'Individual').toLowerCase().contains(_searchQuery.toLowerCase()) ||
          d.vehicleNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          d.fullName.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesType = _filterType == 'All' || d.vehicleType == _filterType;
      return matchesSearch && matchesType;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final driversAsync = ref.watch(firestoreAllDriversProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Cabs'),
        actions: [
          IconButton(
            onPressed: () => _showCabDialog(context),
            icon: const Icon(Icons.add_circle, color: AppTheme.primaryColor),
          ),
        ],
      ),
      body: driversAsync.when(
        data: (drivers) {
          final filtered = _getFilteredDrivers(drivers);
          return Column(
            children: [
              _buildSearchAndFilter(),
              _buildStats(drivers),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text('No cabs found'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) => _buildCabCard(filtered[index]),
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: 'Search by model, agency, vehicle no...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _searchQuery = ''),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', '4-Seater', '7-Seater', '13-Seater'].map((type) {
                final isSelected = _filterType == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _filterType = type),
                    selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                    checkmarkColor: AppTheme.primaryColor,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(List<DriverModel> drivers) {
    final available = drivers.where((d) => d.status == AccountStatus.approved || d.isOnline).length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildStatChip('Total', '${drivers.length}', Colors.blue),
          const SizedBox(width: 8),
          _buildStatChip('Available', '$available', Colors.green),
          const SizedBox(width: 8),
          _buildStatChip('Inactive', '${drivers.length - available}', Colors.red),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildCabCard(DriverModel driver) {
    final isApproved = driver.status == AccountStatus.approved;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
        border: !isApproved ? Border.all(color: Colors.red.shade200) : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                child: Image.network(
                  driver.vehicleImages.isNotEmpty ? driver.vehicleImages[0] : '',
                  width: 100,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 100,
                    height: 90,
                    color: Colors.grey.shade100,
                    child: const Icon(Icons.directions_car, color: Colors.grey, size: 36),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              driver.vehicleModel,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Switch(
                            value: isApproved,
                            activeThumbColor: AppTheme.primaryColor,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            onChanged: (val) {
                              ref.read(firestoreServiceProvider).updateDriverStatus(
                                driver.id,
                                val ? AccountStatus.approved : AccountStatus.suspended,
                              );
                            },
                          ),
                        ],
                      ),
                      Text(
                        '${driver.vehicleType} • ${driver.agencyName ?? 'Individual'}',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        driver.vehicleNumber,
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 13, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(driver.rating.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 12),
                          const Icon(Icons.person, size: 13, color: Colors.grey),
                          const SizedBox(width: 2),
                          Text(driver.fullName, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                          const Spacer(),
                          Text(
                            '₹${driver.pricing?.baseFare.toInt() ?? 0}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showCabDialog(context, driver: driver),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(minimumSize: const Size(0, 36)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _deleteCab(driver),
                    icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                    label: const Text('Delete', style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 36),
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCabDialog(BuildContext context, {DriverModel? driver}) {
    final modelCtrl = TextEditingController(text: driver?.vehicleModel ?? '');
    final nameCtrl = TextEditingController(text: driver?.fullName ?? '');
    final phoneCtrl = TextEditingController(text: driver?.mobileNumber ?? '');
    final agencyCtrl = TextEditingController(text: driver?.agencyName ?? '');
    final vehicleCtrl = TextEditingController(text: driver?.vehicleNumber ?? '');
    final priceCtrl = TextEditingController(text: driver?.pricing?.baseFare.toString() ?? '');
    final imageCtrl = TextEditingController(text: driver?.vehicleImages.isNotEmpty == true ? driver!.vehicleImages[0] : '');
    
    String selectedType = driver?.vehicleType ?? '4-Seater';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driver == null ? 'Add New Cab & Driver' : 'Edit Cab & Driver',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Driver Full Name', prefixIcon: Icon(Icons.person)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(labelText: 'Mobile Number', prefixIcon: Icon(Icons.phone)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: modelCtrl,
                  decoration: const InputDecoration(labelText: 'Vehicle Model', prefixIcon: Icon(Icons.directions_car)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: agencyCtrl,
                  decoration: const InputDecoration(labelText: 'Agency Name (Optional)', prefixIcon: Icon(Icons.business)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: vehicleCtrl,
                  decoration: const InputDecoration(labelText: 'Vehicle Number', prefixIcon: Icon(Icons.pin)),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedType,
                        decoration: const InputDecoration(labelText: 'Cab Type'),
                        items: ['4-Seater', '7-Seater', '13-Seater']
                            .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                            .toList(),
                        onChanged: (v) => setModalState(() => selectedType = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: priceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Base Fare (₹)', prefixIcon: Icon(Icons.payments)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: imageCtrl,
                  decoration: const InputDecoration(labelText: 'Image URL', prefixIcon: Icon(Icons.image)),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (modelCtrl.text.isNotEmpty && nameCtrl.text.isNotEmpty) {
                      final newDriver = DriverModel(
                        id: driver?.id ?? 'D${DateTime.now().millisecondsSinceEpoch}',
                        fullName: nameCtrl.text,
                        mobileNumber: phoneCtrl.text,
                        aadhaarNumber: driver?.aadhaarNumber ?? '',
                        drivingLicense: driver?.drivingLicense ?? '',
                        vehicleNumber: vehicleCtrl.text,
                        vehicleRc: driver?.vehicleRc ?? '',
                        insuranceNumber: driver?.insuranceNumber ?? '',
                        vehicleType: selectedType,
                        vehicleModel: modelCtrl.text,
                        agencyName: agencyCtrl.text.isEmpty ? null : agencyCtrl.text,
                        driverType: agencyCtrl.text.isEmpty ? DriverType.individual : DriverType.agency,
                        status: driver?.status ?? AccountStatus.pendingVerification,
                        registeredAt: driver?.registeredAt ?? DateTime.now(),
                        vehicleImages: imageCtrl.text.isNotEmpty ? [imageCtrl.text] : [],
                        pricing: DriverPricing(
                          baseFare: double.tryParse(priceCtrl.text) ?? 500.0,
                        ),
                      );

                      await ref.read(firestoreServiceProvider).saveDriver(newDriver);
                      
                      if (context.mounted) Navigator.pop(context);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(driver == null ? 'Cab & Driver added successfully!' : 'Updated successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  },
                  child: Text(driver == null ? 'Add Cab/Driver' : 'Update Cab/Driver'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _deleteCab(DriverModel driver) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Cab/Driver'),
        content: Text('Delete "${driver.vehicleModel}" (${driver.vehicleNumber})?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              // Note: Ideally we add a delete method to FirestoreService
              // For now we'll simulate or just pop
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Delete action needs implementation in FirestoreService'), backgroundColor: Colors.orange),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
