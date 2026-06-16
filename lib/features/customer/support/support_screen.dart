import 'package:flutter/material.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  int? _expandedIndex;

  static const List<MapEntry<String, String>> _faqs = [
    MapEntry(
      'Payment issues during trip',
      'Please try a different payment method. If the payment failed after the trip, contact our support at +91 80000 00000 and we will resolve it within 24 hours.',
    ),
    MapEntry(
      'Driver behavior concerns',
      'We take driver conduct very seriously. Please rate your experience and add a comment. Our safety team reviews all low-rated trips within 48 hours.',
    ),
    MapEntry(
      'Cancellation charges enquiry',
      'Cancellation is free within 5 minutes of booking. After that, a charge of ₹50 applies. If the driver cancelled, no charge is applied. View our full policy in Settings → Terms & Conditions.',
    ),
    MapEntry(
      'Lost item in vehicle',
      'Contact your driver directly via the trip history screen. If unreachable, our support team can assist within 24 hours at +91 80000 00000 or support@novacabs.com.',
    ),
    MapEntry(
      'Refund status',
      'Refunds for cancelled trips are processed within 5–7 business days. Wallet refunds are instant. Check your bank statement or contact us with your booking ID for a faster update.',
    ),
  ];

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
            ...List.generate(
              _faqs.length,
              (i) => _buildFaqItem(i, _faqs[i].key, _faqs[i].value),
            ),
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
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.1)),
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

  Widget _buildFaqItem(int index, String question, String answer) {
    final isExpanded = _expandedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _expandedIndex = isExpanded ? null : index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isExpanded ? Colors.blue.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isExpanded ? Colors.blue.shade200 : Colors.transparent,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      question,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isExpanded ? FontWeight.bold : FontWeight.w500,
                        color: isExpanded ? Colors.blue.shade800 : Colors.black87,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: isExpanded ? Colors.blue.shade600 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isExpanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  answer,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.blue.shade900,
                    height: 1.5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
