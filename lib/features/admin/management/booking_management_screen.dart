import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../../../core/mock_data.dart';
import '../../../core/models.dart';

class BookingManagementScreen extends StatefulWidget {
  const BookingManagementScreen({super.key});

  @override
  State<BookingManagementScreen> createState() => _BookingManagementScreenState();
}

class _BookingManagementScreenState extends State<BookingManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Booking> _filterByStatus(String status) {
    final bookings = MockData.bookings.where((b) {
      final matchesSearch = b.id.contains(_searchQuery) ||
          b.customerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          b.pickupLocation.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = status == 'All' || b.status == status;
      return matchesSearch && matchesStatus;
    }).toList();
    return bookings;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Management'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'New'),
            Tab(text: 'Confirmed'),
            Tab(text: 'Ongoing'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBookingList(_filterByStatus('All')),
                _buildBookingList(_filterByStatus('New')),
                _buildBookingList(_filterByStatus('Confirmed')),
                _buildBookingList(_filterByStatus('Ongoing')),
                _buildBookingList(_filterByStatus('Completed')),
              ],
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
          hintText: 'Search by booking ID, customer, location...',
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

  Widget _buildBookingList(List<Booking> bookings) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_online_outlined, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('No bookings found', style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: bookings.length,
      itemBuilder: (context, index) => _buildBookingCard(bookings[index]),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    final statusColor = _getStatusColor(booking.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showBookingDetails(booking),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '#${booking.id}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      booking.status,
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(booking.customerName, style: const TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(width: 12),
                  const Icon(Icons.phone, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(booking.customerPhone, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.my_location, size: 14, color: Colors.green),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      booking.pickupLocation,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: Colors.red),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      booking.dropLocation,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('${booking.date} ${booking.time}',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                    ],
                  ),
                  Text(
                    '₹${booking.totalFare.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed': return Colors.green;
      case 'Ongoing': return Colors.blue;
      case 'Confirmed': return Colors.teal;
      case 'Cancelled': return Colors.red;
      case 'New': return Colors.orange;
      default: return Colors.grey;
    }
  }

  void _showBookingDetails(Booking booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Booking #${booking.id}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(booking.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      booking.status,
                      style: TextStyle(
                        color: _getStatusColor(booking.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildSection('Customer Details', [
                _buildDetailRow('Name', booking.customerName),
                _buildDetailRow('Phone', booking.customerPhone),
              ]),
              _buildSection('Trip Details', [
                _buildDetailRow('Pickup', booking.pickupLocation),
                _buildDetailRow('Drop', booking.dropLocation),
                _buildDetailRow('Date', booking.date),
                _buildDetailRow('Time', booking.time),
                _buildDetailRow('Distance', '${booking.totalDistance} KM'),
              ]),
              _buildSection('Cab & Agency', [
                _buildDetailRow('Cab Model', booking.cab.model),
                _buildDetailRow('Cab Type', booking.cab.type),
                _buildDetailRow('Vehicle No', booking.cab.vehicleNumber),
                _buildDetailRow('Agency', booking.cab.agencyName),
              ]),
              _buildSection('Fare Breakup', [
                _buildDetailRow('Distance', '${booking.totalDistance} KM'),
                _buildDetailRow('Rate', '₹${booking.cab.pricePerKm}/KM'),
                _buildDetailRow('Base Fare', '₹${booking.totalFare.toStringAsFixed(0)}'),
                _buildDetailRow('Total Fare', '₹${booking.totalFare.toStringAsFixed(0)}',
                    isBold: true),
              ]),
              _buildSection('Payment', [
                _buildDetailRow('Method', booking.paymentMethod),
                _buildDetailRow('Status', booking.paymentStatus),
              ]),
              const SizedBox(height: 20),
              if (booking.status != 'Completed' && booking.status != 'Cancelled') ...[
                const Text('Update Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: ['Confirmed', 'Ongoing', 'Completed', 'Cancelled'].map((status) {
                    return ElevatedButton(
                      onPressed: () {
                        setState(() => booking.status = status);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Status updated to $status'), backgroundColor: Colors.green),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getStatusColor(status),
                        minimumSize: const Size(0, 36),
                      ),
                      child: Text(status),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryColor)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              fontSize: isBold ? 15 : 13,
              color: isBold ? AppTheme.primaryColor : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
