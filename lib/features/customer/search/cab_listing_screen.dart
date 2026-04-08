import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_theme.dart';
import '../../../core/app_providers.dart';
import '../../../core/extended_models.dart';
import '../booking/cab_details_screen.dart';

class CabListingScreen extends ConsumerStatefulWidget {
  final String pickup;
  final String drop;
  final String cabType;
  final DateTime date;
  final String? rentalPackage;

  const CabListingScreen({
    super.key,
    required this.pickup,
    required this.drop,
    required this.cabType,
    required this.date,
    this.rentalPackage,
  });

  @override
  ConsumerState<CabListingScreen> createState() => _CabListingScreenState();
}

class _CabListingScreenState extends ConsumerState<CabListingScreen> {
  String _sortBy = 'Price'; // Price, Rating, Nearest
  String _selectedFilterType = 'All';

  @override
  void initState() {
    super.initState();
    _selectedFilterType = widget.cabType;
  }

  @override
  Widget build(BuildContext context) {
    final drivers = ref.watch(approvedDriversProvider);
    
    // Filtering
    var filteredDrivers = drivers.where((d) => d.vehicleType == _selectedFilterType).toList();
    
    // Sorting
    if (_sortBy == 'Price') {
      filteredDrivers.sort((a, b) => (a.pricing?.baseFare ?? 0).compareTo(b.pricing?.baseFare ?? 0));
    } else if (_sortBy == 'Rating') {
      filteredDrivers.sort((a, b) => b.rating.compareTo(a.rating));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Available Cabs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(
              widget.rentalPackage != null 
                ? '${widget.pickup} • ${widget.rentalPackage}'
                : '${widget.pickup} → ${widget.drop}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.white70),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: _buildFilterBar(),
        ),
      ),
      body: Column(
        children: [
          _buildSortOptions(),
          Expanded(
            child: filteredDrivers.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredDrivers.length,
                    itemBuilder: (context, index) {
                      return _buildDriverCard(filteredDrivers[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final types = ['4-Seater', '7-Seater', '13-Seater'];
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: types.length,
        itemBuilder: (context, index) {
          bool isSelected = _selectedFilterType == types[index];
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: FilterChip(
              label: Text(types[index]),
              selected: isSelected,
              onSelected: (val) => setState(() => _selectedFilterType = types[index]),
              selectedColor: AppTheme.accentColor,
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.primaryColor : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSortOptions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey.shade50,
      child: Row(
        children: [
          const Icon(Icons.sort, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          const Text('Sort by:', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(width: 12),
          _buildSortChip('Price'),
          _buildSortChip('Rating'),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label) {
    bool isSelected = _sortBy == label;
    return GestureDetector(
      onTap: () => setState(() => _sortBy = label),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildDriverCard(DriverModel driver) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 5)),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    driver.vehicleImages.isNotEmpty 
                      ? driver.vehicleImages[0] 
                      : 'https://images.unsplash.com/photo-1550355291-bbee04a92027?auto=format&fit=crop&q=80&w=200',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              driver.fullName,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  driver.rating.toString(),
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        driver.agencyName ?? 'Individual Driver',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.directions_car, size: 14, color: Colors.grey.shade400),
                          const SizedBox(width: 4),
                          Text(driver.vehicleModel, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Estimated Price', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    const SizedBox(height: 2),
                    Text(
                      '₹${driver.pricing?.baseFare.toInt() ?? 0}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CabDetailsScreen(
                          driver: driver,
                          pickup: widget.pickup,
                          drop: widget.drop,
                          date: widget.date,
                          rentalPackage: widget.rentalPackage,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('View Details'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.no_photography_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No cabs found for $_selectedFilterType',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Try changing the filters or cab type',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
