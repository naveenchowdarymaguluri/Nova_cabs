import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_theme.dart';
import '../../../core/app_providers.dart';
import '../../../core/models.dart';

class CustomerManagementScreen extends ConsumerStatefulWidget {
  const CustomerManagementScreen({super.key});

  @override
  ConsumerState<CustomerManagementScreen> createState() => _CustomerManagementScreenState();
}

class _CustomerManagementScreenState extends ConsumerState<CustomerManagementScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(firestoreAllCustomersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Customer Management')),
      body: customersAsync.when(
        data: (customers) {
          final filtered = customers.where((c) =>
            c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            c.phone.contains(_searchQuery) ||
            c.email.toLowerCase().contains(_searchQuery.toLowerCase()),
          ).toList();

          final blocked = customers.where((c) => c.isBlocked).length;
          final totalRevenue = customers.fold(0.0, (sum, c) => sum + c.totalSpent);

          return Column(
            children: [
              _buildSummaryCards(customers.length, blocked, totalRevenue),
              _buildSearchBar(),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text('No customers found'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) => _buildCustomerCard(filtered[index]),
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildSummaryCards(int total, int blocked, double totalRevenue) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(child: _buildMiniCard('Total', '$total', Icons.people, Colors.blue)),
          const SizedBox(width: 8),
          Expanded(child: _buildMiniCard('Blocked', '$blocked', Icons.block, Colors.red)),
          const SizedBox(width: 8),
          Expanded(child: _buildMiniCard('Revenue', '₹${(totalRevenue / 1000).toStringAsFixed(1)}K', Icons.payments, Colors.green)),
        ],
      ),
    );
  }

  Widget _buildMiniCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label, style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'Search by name, phone, email...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _searchQuery = ''))
              : null,
        ),
      ),
    );
  }

  Widget _buildCustomerCard(Customer customer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12, top: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
        border: customer.isBlocked ? Border.all(color: Colors.red.shade200) : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: customer.isBlocked
                      ? Colors.red.shade100
                      : AppTheme.primaryColor.withValues(alpha: 0.1),
                  child: Text(
                    customer.name.isNotEmpty ? customer.name[0] : '?',
                    style: TextStyle(
                      color: customer.isBlocked ? Colors.red : AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          if (customer.isBlocked) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(6)),
                              child: const Text('BLOCKED', style: TextStyle(color: Colors.red, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ],
                      ),
                      Text(customer.phone, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      Text(customer.email, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                    ],
                  ),
                ),
                Text('ID: ${customer.id.length > 8 ? customer.id.substring(0, 8) : customer.id}',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 10)),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('Bookings', '${customer.totalBookings}', Icons.book_online),
                _buildStat('Spent', '₹${customer.totalSpent.toStringAsFixed(0)}', Icons.payments),
                _buildStat(
                  'Avg/Trip',
                  customer.totalBookings > 0
                      ? '₹${(customer.totalSpent / customer.totalBookings).toStringAsFixed(0)}'
                      : '₹0',
                  Icons.trending_up,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showBookingHistory(customer),
                    icon: const Icon(Icons.history, size: 16),
                    label: const Text('History'),
                    style: OutlinedButton.styleFrom(minimumSize: const Size(0, 36)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _toggleBlock(customer),
                    icon: Icon(
                      customer.isBlocked ? Icons.lock_open : Icons.block,
                      size: 16,
                      color: customer.isBlocked ? Colors.green : Colors.red,
                    ),
                    label: Text(
                      customer.isBlocked ? 'Unblock' : 'Block',
                      style: TextStyle(color: customer.isBlocked ? Colors.green : Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 36),
                      side: BorderSide(color: customer.isBlocked ? Colors.green : Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AppTheme.primaryColor),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
      ],
    );
  }

  void _toggleBlock(Customer customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(customer.isBlocked ? 'Unblock Customer' : 'Block Customer'),
        content: Text(
          customer.isBlocked
              ? 'Allow ${customer.name} to use Nova Cabs again?'
              : 'Block ${customer.name} from using Nova Cabs?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(customerListProvider.notifier).updateCustomerBlockStatus(
                customer.id,
                !customer.isBlocked,
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(customer.isBlocked ? '${customer.name} unblocked' : '${customer.name} blocked'),
                  backgroundColor: customer.isBlocked ? Colors.green : Colors.red,
                ));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: customer.isBlocked ? Colors.green : Colors.red),
            child: Text(customer.isBlocked ? 'Unblock' : 'Block'),
          ),
        ],
      ),
    );
  }

  void _showBookingHistory(Customer customer) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final bookingsAsync = ref.watch(firestoreCustomerBookingsProvider(customer.id));
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${customer.name}'s Bookings",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Expanded(
                  child: bookingsAsync.when(
                    data: (bookings) => bookings.isEmpty
                        ? const Center(child: Text('No bookings found'))
                        : ListView.builder(
                            itemCount: bookings.length,
                            itemBuilder: (context, index) {
                              final b = bookings[index];
                              return ListTile(
                                leading: const Icon(Icons.directions_car, color: AppTheme.primaryColor),
                                title: Text('${b.pickupLocation} → ${b.dropLocation}',
                                    style: const TextStyle(fontSize: 13)),
                                subtitle: Text(
                                    '${b.tripDate.day}/${b.tripDate.month}/${b.tripDate.year} • ₹${(b.finalFare ?? b.estimatedFare).toStringAsFixed(0)}'),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(b.status.name,
                                      style: const TextStyle(fontSize: 10, color: Colors.blue)),
                                ),
                              );
                            },
                          ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
