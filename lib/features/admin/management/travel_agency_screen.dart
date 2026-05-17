import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_theme.dart';
import '../../../core/mock_data.dart';
import '../../../core/extended_models.dart';
import '../../../core/app_providers.dart';
import '../../../core/firestore_service.dart';

class TravelAgencyScreen extends ConsumerStatefulWidget {
  const TravelAgencyScreen({super.key});

  @override
  ConsumerState<TravelAgencyScreen> createState() => _TravelAgencyScreenState();
}

class _TravelAgencyScreenState extends ConsumerState<TravelAgencyScreen> {
  String _searchQuery = '';

  List<AgencyModel> _getFilteredAgencies(List<AgencyModel> agencies) {
    return agencies
        .where((a) => a.agencyName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            a.ownerName.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final agenciesAsync = ref.watch(firestoreAgenciesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Agencies'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: AppTheme.primaryColor),
            onPressed: () => _showAgencyDialog(context),
          ),
        ],
      ),
      body: agenciesAsync.when(
        data: (agencies) {
          final filtered = _getFilteredAgencies(agencies);
          return Column(
            children: [
              _buildSearchBar(),
              _buildStats(agencies),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text('No agencies found'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) =>
                            _buildAgencyCard(filtered[index]),
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'Search agencies...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() => _searchQuery = ''),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildStats(List<AgencyModel> agencies) {
    final active = agencies.where((a) => a.status == AccountStatus.active || a.status == AccountStatus.approved).length;
    final inactive = agencies.where((a) => a.status == AccountStatus.inactive || a.status == AccountStatus.suspended).length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildStatChip('Total', '${agencies.length}', Colors.blue),
          const SizedBox(width: 8),
          _buildStatChip('Active', '$active', Colors.green),
          const SizedBox(width: 8),
          _buildStatChip('Inactive', '$inactive', Colors.red),
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

  Widget _buildAgencyCard(AgencyModel agency) {
    final isActive = agency.status == AccountStatus.active || agency.status == AccountStatus.approved;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            leading: CircleAvatar(
              backgroundColor: isActive
                  ? AppTheme.primaryColor.withValues(alpha: 0.1)
                  : Colors.grey.shade100,
              child: Text(
                agency.agencyName[0],
                style: TextStyle(
                  color: isActive ? AppTheme.primaryColor : Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            title: Text(agency.agencyName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            subtitle: Text(agency.ownerName, style: TextStyle(color: Colors.grey.shade600)),
            trailing: Switch(
              value: isActive,
              activeThumbColor: AppTheme.primaryColor,
              onChanged: (val) {
                ref.read(firestoreServiceProvider).updateAgencyStatus(
                  agency.id,
                  val ? AccountStatus.active : AccountStatus.inactive,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: [
                const Divider(),
                Row(
                  children: [
                    _buildInfoItem(Icons.phone, agency.phoneNumber),
                    const SizedBox(width: 16),
                    _buildInfoItem(Icons.email, 'contact@${agency.agencyName.toLowerCase().replaceAll(' ', '')}.com'),
                  ],
                ),
                const SizedBox(height: 8),
                _buildInfoItem(Icons.location_on, agency.businessAddress),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showAgencyDialog(context, agency: agency),
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(minimumSize: const Size(0, 36)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showDeleteConfirm(agency),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showAgencyDialog(BuildContext context, {AgencyModel? agency}) {
    final nameCtrl = TextEditingController(text: agency?.agencyName ?? '');
    final ownerCtrl = TextEditingController(text: agency?.ownerName ?? '');
    final phoneCtrl = TextEditingController(text: agency?.phoneNumber ?? '');
    final addressCtrl = TextEditingController(text: agency?.businessAddress ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
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
                agency == null ? 'Add Travel Agency' : 'Edit Travel Agency',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildField(nameCtrl, 'Agency Name', Icons.business),
              _buildField(ownerCtrl, 'Owner Name', Icons.person),
              _buildField(phoneCtrl, 'Phone Number', Icons.phone),
              _buildField(addressCtrl, 'Address', Icons.location_on),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final newAgency = AgencyModel(
                    id: agency?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                    agencyName: nameCtrl.text,
                    ownerName: ownerCtrl.text,
                    phoneNumber: phoneCtrl.text,
                    businessAddress: addressCtrl.text,
                    status: agency?.status ?? AccountStatus.active,
                    totalDrivers: agency?.totalDrivers ?? 0,
                    totalVehicles: agency?.totalVehicles ?? 0,
                    totalEarnings: agency?.totalEarnings ?? 0,
                    totalBookings: agency?.totalBookings ?? 0,
                    registeredAt: agency?.registeredAt ?? DateTime.now(),
                  );
                  
                  await ref.read(firestoreServiceProvider).saveAgency(newAgency);
                  
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(agency == null ? 'Agency added successfully!' : 'Agency updated!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: Text(agency == null ? 'Add Agency' : 'Update Agency'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
        ),
      ),
    );
  }

  void _showDeleteConfirm(AgencyModel agency) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Agency'),
        content: Text('Are you sure you want to delete "${agency.agencyName}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              // Logic to delete from Firestore would go here
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Delete action simulated'), backgroundColor: Colors.red),
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
