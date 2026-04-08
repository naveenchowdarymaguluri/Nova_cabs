import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_theme.dart';
import '../../../core/extended_models.dart';
import '../../../core/app_providers.dart';

/// Admin: Agency Approval & Management Screen
class AdminAgencyManagementScreen extends ConsumerStatefulWidget {
  const AdminAgencyManagementScreen({super.key});

  @override
  ConsumerState<AdminAgencyManagementScreen> createState() =>
      _AdminAgencyManagementScreenState();
}

class _AdminAgencyManagementScreenState
    extends ConsumerState<AdminAgencyManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(agencyListProvider);
    final pending = all.where((a) => a.status == AccountStatus.pendingVerification).toList();
    final approved = all.where((a) => a.status == AccountStatus.approved).toList();
    final suspended = all.where((a) => a.status == AccountStatus.suspended || a.status == AccountStatus.rejected).toList();

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Agency Management'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Pending (${pending.length})'),
            Tab(text: 'Approved (${approved.length})'),
            Tab(text: 'Suspended/Rejected (${suspended.length})'),
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
          _buildList(pending, showApprovalActions: true),
          _buildList(approved, showSuspendAction: true),
          _buildList(suspended, showReactivateAction: true),
        ],
      ),
    );
  }

  Widget _buildList(
    List<AgencyModel> agencies, {
    bool showApprovalActions = false,
    bool showSuspendAction = false,
    bool showReactivateAction = false,
  }) {
    if (agencies.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.business_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('No agencies in this category', style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: agencies.length,
      itemBuilder: (_, i) => _buildAgencyCard(
        agencies[i],
        showApprovalActions: showApprovalActions,
        showSuspendAction: showSuspendAction,
        showReactivateAction: showReactivateAction,
      ),
    );
  }

  Widget _buildAgencyCard(
    AgencyModel agency, {
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
    final color = statusColors[agency.status] ?? Colors.grey;

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
          child: Icon(Icons.business, color: color, size: 22),
        ),
        title: Text(agency.agencyName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(agency.ownerName, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(agency.statusLabel, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10)),
            ),
          ],
        ),
        children: [
          _detailRow(Icons.phone, 'Phone', agency.phoneNumber),
          _detailRow(Icons.email, 'Email', agency.email),
          _detailRow(Icons.location_on, 'Address', agency.businessAddress),
          if (agency.gstNumber != null) _detailRow(Icons.receipt, 'GST', agency.gstNumber!),
          _detailRow(Icons.account_balance, 'Bank', agency.bankDetails),
          _detailRow(Icons.calendar_today, 'Registered', agency.registeredAt.toString().substring(0, 10)),
          if (agency.adminRemarks != null && agency.adminRemarks!.isNotEmpty) ...[
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
                  Expanded(child: Text('Remarks: ${agency.adminRemarks}', style: TextStyle(color: Colors.red.shade800, fontSize: 12))),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (showApprovalActions) Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _rejectAgency(agency.id),
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
                  onPressed: () => _approveAgency(agency.id),
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
          if (showSuspendAction) SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _suspendAgency(agency.id),
              icon: const Icon(Icons.block, color: Colors.orange, size: 18),
              label: const Text('Suspend Agency', style: TextStyle(color: Colors.orange)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.orange),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          if (showReactivateAction) SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _approveAgency(agency.id),
              icon: const Icon(Icons.check_circle, color: Colors.white, size: 18),
              label: const Text('Reactivate Agency', style: TextStyle(color: Colors.white)),
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

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade500),
          const SizedBox(width: 8),
          Text('$label:', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  void _approveAgency(String id) {
    ref.read(agencyListProvider.notifier).approveAgency(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Agency approved!'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
    );
  }

  void _rejectAgency(String id) {
    ref.read(agencyListProvider.notifier).rejectAgency(id, 'Documents incomplete or invalid.');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Agency rejected.'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
    );
  }

  void _suspendAgency(String id) {
    ref.read(agencyListProvider.notifier).suspendAgency(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Agency suspended.'), backgroundColor: Colors.orange, behavior: SnackBarBehavior.floating),
    );
  }
}
