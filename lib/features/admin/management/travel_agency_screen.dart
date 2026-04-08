import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../../../core/mock_data.dart';
import '../../../core/models.dart';

class TravelAgencyScreen extends StatefulWidget {
  const TravelAgencyScreen({super.key});

  @override
  State<TravelAgencyScreen> createState() => _TravelAgencyScreenState();
}

class _TravelAgencyScreenState extends State<TravelAgencyScreen> {
  List<TravelAgency> _agencies = List.from(MockData.agencies);
  String _searchQuery = '';

  List<TravelAgency> get _filteredAgencies => _agencies
      .where((a) => a.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          a.contactPerson.toLowerCase().contains(_searchQuery.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
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
      body: Column(
        children: [
          _buildSearchBar(),
          _buildStats(),
          Expanded(
            child: _filteredAgencies.isEmpty
                ? const Center(child: Text('No agencies found'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredAgencies.length,
                    itemBuilder: (context, index) =>
                        _buildAgencyCard(_filteredAgencies[index]),
                  ),
          ),
        ],
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

  Widget _buildStats() {
    final active = _agencies.where((a) => a.isActive).length;
    final inactive = _agencies.where((a) => !a.isActive).length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildStatChip('Total', '${_agencies.length}', Colors.blue),
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

  Widget _buildAgencyCard(TravelAgency agency) {
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
              backgroundColor: agency.isActive
                  ? AppTheme.primaryColor.withValues(alpha: 0.1)
                  : Colors.grey.shade100,
              child: Text(
                agency.name[0],
                style: TextStyle(
                  color: agency.isActive ? AppTheme.primaryColor : Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            title: Text(agency.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            subtitle: Text(agency.contactPerson, style: TextStyle(color: Colors.grey.shade600)),
            trailing: Switch(
              value: agency.isActive,
              activeThumbColor: AppTheme.primaryColor,
              onChanged: (val) => setState(() => agency.isActive = val),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: [
                const Divider(),
                Row(
                  children: [
                    _buildInfoItem(Icons.phone, agency.mobileNumber),
                    const SizedBox(width: 16),
                    _buildInfoItem(Icons.email, agency.email),
                  ],
                ),
                const SizedBox(height: 8),
                _buildInfoItem(Icons.location_on, agency.address),
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

  void _showAgencyDialog(BuildContext context, {TravelAgency? agency}) {
    final nameCtrl = TextEditingController(text: agency?.name ?? '');
    final contactCtrl = TextEditingController(text: agency?.contactPerson ?? '');
    final mobileCtrl = TextEditingController(text: agency?.mobileNumber ?? '');
    final whatsappCtrl = TextEditingController(text: agency?.whatsappNumber ?? '');
    final emailCtrl = TextEditingController(text: agency?.email ?? '');
    final addressCtrl = TextEditingController(text: agency?.address ?? '');
    final gstCtrl = TextEditingController(text: agency?.gstNumber ?? '');
    final bankCtrl = TextEditingController(text: agency?.bankDetails ?? '');

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
              _buildField(contactCtrl, 'Contact Person', Icons.person),
              _buildField(mobileCtrl, 'Mobile Number', Icons.phone),
              _buildField(whatsappCtrl, 'WhatsApp Number', Icons.message),
              _buildField(emailCtrl, 'Email ID', Icons.email),
              _buildField(addressCtrl, 'Address', Icons.location_on),
              _buildField(gstCtrl, 'GST Number (Optional)', Icons.receipt),
              _buildField(bankCtrl, 'Bank/UPI Details', Icons.account_balance),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (agency == null) {
                    setState(() {
                      _agencies.add(TravelAgency(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameCtrl.text,
                        contactPerson: contactCtrl.text,
                        mobileNumber: mobileCtrl.text,
                        whatsappNumber: whatsappCtrl.text,
                        email: emailCtrl.text,
                        address: addressCtrl.text,
                        gstNumber: gstCtrl.text,
                        bankDetails: bankCtrl.text,
                      ));
                    });
                  }
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

  void _showDeleteConfirm(TravelAgency agency) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Agency'),
        content: Text('Are you sure you want to delete "${agency.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() => _agencies.remove(agency));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Agency deleted'), backgroundColor: Colors.red),
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
