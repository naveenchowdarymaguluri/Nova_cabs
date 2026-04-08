import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_theme.dart';
import '../../../core/app_providers.dart';
import '../../role_selection/role_selection_screen.dart';
import '../support/support_screen.dart';

class CustomerProfileScreen extends ConsumerWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Profile'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(authState),
            const SizedBox(height: 24),
            _buildActionList(context, ref, authState),
            const SizedBox(height: 40),
            _buildVersionInfo(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(AuthState authState) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 46,
                  backgroundColor: AppTheme.accentColor,
                  child: Text(
                    authState.userName?[0] ?? 'N',
                    style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt, color: AppTheme.primaryColor, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            authState.userName ?? 'Loading...',
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            authState.userPhone ?? '',
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildActionList(BuildContext context, WidgetRef ref, AuthState authState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildProfileTile(Icons.person_outline, 'Edit Profile', () {}),
          _buildProfileTile(Icons.payment, 'Payment Methods', () {}),
          _buildProfileTile(Icons.home_outlined, 'Saved Addresses', () {}),
          _buildProfileTile(Icons.help_outline, 'Support & Help', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportScreen()));
          }),
          _buildProfileTile(Icons.info_outline, 'About Nova Cabs', () {}),
          const Divider(height: 32),
          _buildProfileTile(
            Icons.logout, 
            'Logout', 
            () => _handleLogout(context, ref), 
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTile(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDestructive ? Colors.red.withOpacity(0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: isDestructive ? Colors.red : AppTheme.primaryColor, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: isDestructive ? Colors.red : Colors.black87,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildVersionInfo() {
    return Column(
      children: [
        const Text('Nova Cabs Customer', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
        Text('Version 1.0.4 (Production)', style: TextStyle(color: Colors.grey.shade400, fontSize: 10)),
      ],
    );
  }

  void _handleLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                (route) => false,
              );
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
