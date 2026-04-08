import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Support'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How can we help you?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Our support team is available 24/7 to assist you.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),
            _buildContactOptions(),
            const SizedBox(height: 32),
            const Text('Common Issues', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildFaqItem('Payment issues during trip'),
            _buildFaqItem('Driver behavior concerns'),
            _buildFaqItem('Cancellation charges enquiry'),
            _buildFaqItem('Lost item in vehicle'),
            _buildFaqItem('Refund status'),
          ],
        ),
      ),
    );
  }

  Widget _buildContactOptions() {
    return Row(
      children: [
        _buildSupportCard(Icons.chat_bubble_outline, 'Chat', 'Start Live Chat', Colors.blue),
        const SizedBox(width: 16),
        _buildSupportCard(Icons.call_outlined, 'Call', 'Speak to Expert', Colors.green),
      ],
    );
  }

  Widget _buildSupportCard(IconData icon, String title, String subtitle, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(question, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.keyboard_arrow_down, size: 20),
        onTap: () {},
      ),
    );
  }
}
