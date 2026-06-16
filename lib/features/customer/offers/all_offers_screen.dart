import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_theme.dart';
import '../../../core/app_providers.dart';
import '../../../core/models.dart';

class AllOffersScreen extends ConsumerStatefulWidget {
  const AllOffersScreen({super.key});

  @override
  ConsumerState<AllOffersScreen> createState() => _AllOffersScreenState();
}

class _AllOffersScreenState extends ConsumerState<AllOffersScreen> {
  String? _selectedCabType;

  void _showFilterSheet(List<String> cabTypes) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (_, setSheetState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Filter by Cab Type', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() => _selectedCabType = null);
                      Navigator.pop(context);
                    },
                    child: const Text('Clear'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _filterChip('All', null, _selectedCabType, (v) {
                    setSheetState(() {});
                    setState(() => _selectedCabType = v);
                    Navigator.pop(context);
                  }),
                  ...cabTypes.map((t) => _filterChip(t, t, _selectedCabType, (v) {
                    setSheetState(() {});
                    setState(() => _selectedCabType = v);
                    Navigator.pop(context);
                  })),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterChip(String label, String? value, String? selected, void Function(String?) onTap) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final offersAsync = ref.watch(firestoreOffersProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Offers'),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: _selectedCabType != null,
              child: const Icon(Icons.filter_list),
            ),
            onPressed: () {
              final offers = offersAsync.maybeWhen(data: (o) => o, orElse: () => <BookingOffer>[]);
              final cabTypes = offers.expand((o) => o.applicableCabTypes).toSet().toList()..sort();
              _showFilterSheet(cabTypes);
            },
          ),
        ],
      ),
      body: offersAsync.when(
        data: (offers) {
          var active = offers.where((o) => o.isActive).toList();
          if (_selectedCabType != null) {
            active = active.where((o) => o.applicableCabTypes.contains(_selectedCabType)).toList();
          }
          if (active.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_offer_outlined, size: 48, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text(
                    _selectedCabType != null ? 'No offers for "$_selectedCabType"' : 'No active offers right now.',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                  if (_selectedCabType != null) ...[
                    const SizedBox(height: 8),
                    TextButton(onPressed: () => setState(() => _selectedCabType = null), child: const Text('Clear Filter')),
                  ],
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: active.length,
            itemBuilder: (context, index) => _buildOfferCard(context, active[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildOfferCard(BuildContext ctx, BookingOffer offer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(
              children: [
                Image.network(
                  offer.imageUrl,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 160,
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    child: const Icon(Icons.local_offer, size: 60, color: AppTheme.primaryColor),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      offer.discount,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      offer.validity,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: offer.applicableCabTypes.map((type) {
                    return Chip(
                      label: Text(type, style: const TextStyle(fontSize: 11)),
                      backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.08),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(
                          content: Text('Offer "${offer.title}" applied!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 44),
                    ),
                    child: const Text('Grab This Offer'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
