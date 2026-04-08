import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../../../core/mock_data.dart';
import '../../../core/models.dart';

class ManageCabsScreen extends StatefulWidget {
  const ManageCabsScreen({super.key});

  @override
  State<ManageCabsScreen> createState() => _ManageCabsScreenState();
}

class _ManageCabsScreenState extends State<ManageCabsScreen> {
  List<Cab> _cabs = List.from(MockData.cabs);
  String _searchQuery = '';
  String _filterType = 'All';

  List<Cab> get _filteredCabs => _cabs.where((cab) {
        final matchesSearch = cab.model.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            cab.agencyName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            cab.vehicleNumber.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesType = _filterType == 'All' || cab.type == _filterType;
        return matchesSearch && matchesType;
      }).toList();

  @override
  Widget build(BuildContext context) {
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
      body: Column(
        children: [
          _buildSearchAndFilter(),
          _buildStats(),
          Expanded(
            child: _filteredCabs.isEmpty
                ? const Center(child: Text('No cabs found'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredCabs.length,
                    itemBuilder: (context, index) => _buildCabCard(_filteredCabs[index]),
                  ),
          ),
        ],
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

  Widget _buildStats() {
    final available = _cabs.where((c) => c.isAvailable).length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildStatChip('Total', '${_cabs.length}', Colors.blue),
          const SizedBox(width: 8),
          _buildStatChip('Available', '$available', Colors.green),
          const SizedBox(width: 8),
          _buildStatChip('Unavailable', '${_cabs.length - available}', Colors.red),
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

  Widget _buildCabCard(Cab cab) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
        border: !cab.isAvailable ? Border.all(color: Colors.red.shade200) : null,
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
                  cab.imageUrl,
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
                              cab.model,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Switch(
                            value: cab.isAvailable,
                            activeThumbColor: AppTheme.primaryColor,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            onChanged: (val) => setState(() => cab.isAvailable = val),
                          ),
                        ],
                      ),
                      Text(
                        '${cab.type} • ${cab.agencyName}',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cab.vehicleNumber,
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 13, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(cab.rating.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 12),
                          const Icon(Icons.local_gas_station, size: 13, color: Colors.grey),
                          const SizedBox(width: 2),
                          Text(cab.fuelType, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                          const Spacer(),
                          Text(
                            '₹${cab.pricePerKm}/km',
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
                    onPressed: () => _showCabDialog(context, cab: cab),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(minimumSize: const Size(0, 36)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _deleteCab(cab),
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

  void _showCabDialog(BuildContext context, {Cab? cab}) {
    final modelCtrl = TextEditingController(text: cab?.model ?? '');
    final agencyCtrl = TextEditingController(text: cab?.agencyName ?? '');
    final vehicleCtrl = TextEditingController(text: cab?.vehicleNumber ?? '');
    final priceCtrl = TextEditingController(text: cab?.pricePerKm.toString() ?? '');
    final imageCtrl = TextEditingController(text: cab?.imageUrl ?? '');
    final arrivalCtrl = TextEditingController(text: cab?.estimatedArrival ?? '');
    String selectedType = cab?.type ?? '4-Seater';
    String selectedFuel = cab?.fuelType ?? 'Petrol';

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
                  cab == null ? 'Add New Cab' : 'Edit Cab',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: modelCtrl,
                  decoration: const InputDecoration(labelText: 'Cab Model', prefixIcon: Icon(Icons.directions_car)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: agencyCtrl,
                  decoration: const InputDecoration(labelText: 'Agency Name', prefixIcon: Icon(Icons.business)),
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedFuel,
                        decoration: const InputDecoration(labelText: 'Fuel Type'),
                        items: ['Petrol', 'Diesel', 'CNG', 'Electric']
                            .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                            .toList(),
                        onChanged: (v) => setModalState(() => selectedFuel = v!),
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
                        decoration: const InputDecoration(labelText: 'Price/KM (₹)', prefixIcon: Icon(Icons.payments)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: arrivalCtrl,
                        decoration: const InputDecoration(labelText: 'Est. Arrival', prefixIcon: Icon(Icons.timer)),
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
                  onPressed: () {
                    if (modelCtrl.text.isNotEmpty) {
                      if (cab == null) {
                        setState(() {
                          _cabs.add(Cab(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            model: modelCtrl.text,
                            type: selectedType,
                            agencyName: agencyCtrl.text,
                            imageUrl: imageCtrl.text.isNotEmpty
                                ? imageCtrl.text
                                : 'https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?auto=format&fit=crop&q=80&w=400',
                            rating: 4.5,
                            pricePerKm: double.tryParse(priceCtrl.text) ?? 12.0,
                            estimatedArrival: arrivalCtrl.text.isNotEmpty ? arrivalCtrl.text : '10 mins',
                            vehicleNumber: vehicleCtrl.text,
                            fuelType: selectedFuel,
                          ));
                        });
                      } else {
                        setState(() {
                          cab.isAvailable = cab.isAvailable;
                        });
                      }
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(cab == null ? 'Cab added successfully!' : 'Cab updated!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  child: Text(cab == null ? 'Add Cab' : 'Update Cab'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _deleteCab(Cab cab) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Cab'),
        content: Text('Delete "${cab.model}" (${cab.vehicleNumber})?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() => _cabs.remove(cab));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cab deleted'), backgroundColor: Colors.red),
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
