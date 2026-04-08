import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../../../core/mock_data.dart';
import '../../../core/models.dart';

class OffersManagementScreen extends StatefulWidget {
  const OffersManagementScreen({super.key});

  @override
  State<OffersManagementScreen> createState() => _OffersManagementScreenState();
}

class _OffersManagementScreenState extends State<OffersManagementScreen> {
  List<BookingOffer> _offers = List.from(MockData.offers);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offers & Promotions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: AppTheme.primaryColor),
            onPressed: () => _showOfferDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryRow(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _offers.length,
              itemBuilder: (context, index) => _buildOfferCard(_offers[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow() {
    final active = _offers.where((o) => o.isActive).length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          _buildStatChip('Total Offers', '${_offers.length}', Colors.blue),
          const SizedBox(width: 8),
          _buildStatChip('Active', '$active', Colors.green),
          const SizedBox(width: 8),
          _buildStatChip('Inactive', '${_offers.length - active}', Colors.grey),
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

  Widget _buildOfferCard(BookingOffer offer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12, top: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(
              children: [
                Image.network(
                  offer.imageUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 120,
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    child: const Icon(Icons.local_offer, size: 48, color: AppTheme.primaryColor),
                  ),
                ),
                if (!offer.isActive)
                  Container(
                    height: 120,
                    color: Colors.black.withValues(alpha: 0.5),
                    child: const Center(
                      child: Text('INACTIVE',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                    ),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      offer.discount,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.primaryColor),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        offer.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    Switch(
                      value: offer.isActive,
                      activeThumbColor: AppTheme.primaryColor,
                      onChanged: (val) => setState(() => offer.isActive = val),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(offer.validity, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildTag(offer.discountType, Colors.purple),
                    const SizedBox(width: 6),
                    ...offer.applicableCabTypes.map((t) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: _buildTag(t, Colors.blue),
                        )),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showOfferDialog(context, offer: offer),
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(minimumSize: const Size(0, 36)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _deleteOffer(offer),
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

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  void _showOfferDialog(BuildContext context, {BookingOffer? offer}) {
    final titleCtrl = TextEditingController(text: offer?.title ?? '');
    final discountCtrl = TextEditingController(text: offer?.discount ?? '');
    final validityCtrl = TextEditingController(text: offer?.validity ?? '');
    String discountType = offer?.discountType ?? 'Percentage';
    final discountValueCtrl = TextEditingController(text: offer?.discountValue.toString() ?? '');
    List<String> selectedCabTypes = List.from(offer?.applicableCabTypes ?? ['4-Seater', '7-Seater', '13-Seater']);

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
                  offer == null ? 'Create New Offer' : 'Edit Offer',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Offer Title', prefixIcon: Icon(Icons.title)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: discountCtrl,
                  decoration: const InputDecoration(labelText: 'Discount Label (e.g. 20% OFF)', prefixIcon: Icon(Icons.discount)),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: discountType,
                        decoration: const InputDecoration(labelText: 'Discount Type'),
                        items: ['Flat', 'Percentage']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) => setModalState(() => discountType = v!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: discountValueCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Value (₹ or %)'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: validityCtrl,
                  decoration: const InputDecoration(labelText: 'Validity Period', prefixIcon: Icon(Icons.calendar_today)),
                ),
                const SizedBox(height: 12),
                const Text('Applicable Cab Types', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['4-Seater', '7-Seater', '13-Seater'].map((type) {
                    final isSelected = selectedCabTypes.contains(type);
                    return FilterChip(
                      label: Text(type),
                      selected: isSelected,
                      onSelected: (val) {
                        setModalState(() {
                          if (val) {
                            selectedCabTypes.add(type);
                          } else {
                            selectedCabTypes.remove(type);
                          }
                        });
                      },
                      selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                      checkmarkColor: AppTheme.primaryColor,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (offer == null) {
                      setState(() {
                        _offers.add(BookingOffer(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: titleCtrl.text,
                          discount: discountCtrl.text,
                          validity: validityCtrl.text,
                          imageUrl: 'https://images.unsplash.com/photo-1621944190310-e3cca1564bd7?auto=format&fit=crop&q=80&w=400',
                          discountType: discountType,
                          discountValue: double.tryParse(discountValueCtrl.text) ?? 0,
                          applicableCabTypes: selectedCabTypes,
                        ));
                      });
                    }
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(offer == null ? 'Offer created!' : 'Offer updated!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  child: Text(offer == null ? 'Create Offer' : 'Update Offer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _deleteOffer(BookingOffer offer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Offer'),
        content: Text('Delete "${offer.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() => _offers.remove(offer));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
