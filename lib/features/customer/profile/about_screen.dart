import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(title: const Text('About Nova Cabs')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Logo / branding
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.local_taxi, color: Colors.white, size: 56),
            ),
            const SizedBox(height: 20),
            const Text(
              'Nova Cabs',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('Version 1.0.4 (Production)', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            const SizedBox(height: 32),

            // Mission
            _buildCard(
              icon: Icons.emoji_objects_outlined,
              color: Colors.orange,
              title: 'Our Mission',
              body: 'To provide safe, reliable and affordable cab services across India — connecting passengers with trusted drivers and professional agencies.',
            ),

            const SizedBox(height: 16),

            // Features
            _buildCard(
              icon: Icons.star_outline,
              color: Colors.amber,
              title: 'Key Features',
              body: '• Real-time trip tracking\n'
                  '• OTP-verified ride start\n'
                  '• Advance & final payment support\n'
                  '• Multi-role: Customer, Driver, Agency & Admin\n'
                  '• Verified drivers only\n'
                  '• 24 × 7 customer support',
            ),

            const SizedBox(height: 16),

            // Contact
            _buildCard(
              icon: Icons.support_agent,
              color: Colors.blue,
              title: 'Contact & Support',
              body: 'Email: support@novacabs.in\nPhone: +91 98765 43210\nHours: Mon–Sat, 9 AM – 9 PM',
            ),

            const SizedBox(height: 16),

            // Legal
            _buildCard(
              icon: Icons.gavel_outlined,
              color: Colors.purple,
              title: 'Legal',
              body: 'By using Nova Cabs you agree to our Terms of Service and Privacy Policy available at novacabs.in/legal.',
            ),

            const SizedBox(height: 32),
            Text(
              '© 2025 Nova Cabs. All rights reserved.',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required Color color,
    required String title,
    required String body,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(body, style: TextStyle(color: Colors.grey.shade700, fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }
}
