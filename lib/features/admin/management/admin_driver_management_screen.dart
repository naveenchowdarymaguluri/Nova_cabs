import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_theme.dart';
import '../../../core/extended_models.dart';
import '../../../core/app_providers.dart';

/// Admin: Driver Approval & Management Screen
class AdminDriverManagementScreen extends ConsumerStatefulWidget {
  const AdminDriverManagementScreen({super.key});

  @override
  ConsumerState<AdminDriverManagementScreen> createState() =>
      _AdminDriverManagementScreenState();
}

class _AdminDriverManagementScreenState
    extends ConsumerState<AdminDriverManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allDrivers = ref.watch(driverListProvider);
    final pending = allDrivers.where((d) => d.status == AccountStatus.pendingVerification).toList();
    final approved = allDrivers.where((d) => d.status == AccountStatus.approved).toList();
    final rejected = allDrivers.where((d) => d.status == AccountStatus.rejected).toList();
    final suspended = allDrivers.where((d) => d.status == AccountStatus.suspended).toList();

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Driver Management'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Pending (${pending.length})'),
            Tab(text: 'Approved (${approved.length})'),
            Tab(text: 'Rejected (${rejected.length})'),
            Tab(text: 'Suspended (${suspended.length})'),
          ],
          isScrollable: true,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryColor,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDriverList(pending, showApprovalActions: true),
          _buildDriverList(approved, showSuspendAction: true),
          _buildDriverList(rejected),
          _buildDriverList(suspended, showReactivateAction: true),
        ],
      ),
    );
  }

  Widget _buildDriverList(
    List<DriverModel> drivers, {
    bool showApprovalActions = false,
    bool showSuspendAction = false,
    bool showReactivateAction = false,
  }) {
    if (drivers.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('No drivers in this category', style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: drivers.length,
      itemBuilder: (context, i) {
        return _buildDriverCard(
          drivers[i],
          showApprovalActions: showApprovalActions,
          showSuspendAction: showSuspendAction,
          showReactivateAction: showReactivateAction,
        );
      },
    );
  }

  Widget _buildDriverCard(
    DriverModel driver, {
    bool showApprovalActions = false,
    bool showSuspendAction = false,
    bool showReactivateAction = false,
  }) {
    final statusColors = {
      AccountStatus.pendingVerification: Colors.orange,
      AccountStatus.approved: Colors.green,
      AccountStatus.rejected: Colors.red,
      AccountStatus.suspended: Colors.purple,
    };
    final color = statusColors[driver.status] ?? Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(14),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Text(
            driver.fullName[0],
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(driver.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(driver.mobileNumber, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                driver.statusLabel,
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10),
              ),
            ),
          ],
        ),
        children: [
          // Document details
          _buildDetailRow(Icons.confirmation_number, 'Vehicle No', driver.vehicleNumber),
          _buildDetailRow(Icons.directions_car, 'Vehicle Model', driver.vehicleModel),
          _buildDetailRow(Icons.category, 'Vehicle Type', driver.vehicleType),
          _buildDetailRow(Icons.badge, 'Driver Type', driver.driverType == DriverType.individual ? 'Individual' : 'Agency Driver'),
          if (driver.agencyName != null)
            _buildDetailRow(Icons.business, 'Agency', driver.agencyName!),
          _buildDetailRow(Icons.credit_card, 'DL Number', driver.drivingLicense),
          _buildDetailRow(Icons.badge_outlined, 'Aadhaar', driver.aadhaarNumber),
          _buildDetailRow(Icons.article, 'RC Number', driver.vehicleRc),
          _buildDetailRow(Icons.security, 'Insurance', driver.insuranceNumber),
          if (driver.adminRemarks != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.comment, color: Colors.red.shade700, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Remarks: ${driver.adminRemarks}',
                      style: TextStyle(color: Colors.red.shade800, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          // Action buttons
          if (showApprovalActions) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showRejectDialog(driver.id),
                    icon: const Icon(Icons.close, color: Colors.red, size: 18),
                    label: const Text('Reject', style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _approveDriver(driver.id),
                    icon: const Icon(Icons.check, color: Colors.white, size: 18),
                    label: const Text('Approve', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (showSuspendAction)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _suspendDriver(driver.id),
                icon: const Icon(Icons.block, color: Colors.orange, size: 18),
                label: const Text('Suspend Driver', style: TextStyle(color: Colors.orange)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.orange),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          if (showReactivateAction)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _approveDriver(driver.id),
                icon: const Icon(Icons.check_circle, color: Colors.white, size: 18),
                label: const Text('Reactivate', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade500),
          const SizedBox(width: 8),
          Text('$label:', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _approveDriver(String driverId) {
    ref.read(driverListProvider.notifier).approveDriver(driverId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Driver approved successfully!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _suspendDriver(String driverId) {
    ref.read(driverListProvider.notifier).suspendDriver(driverId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Driver suspended.'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showRejectDialog(String driverId) {
    final remarksController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reject Driver'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: 12),
            TextField(
              controller: remarksController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'e.g. Documents not clear, license expired...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(driverListProvider.notifier).rejectDriver(driverId, remarksController.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Driver rejected'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
