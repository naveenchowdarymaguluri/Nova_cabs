import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_theme.dart';
import '../../../core/app_providers.dart';
import '../../../core/firestore_service.dart';
import '../../../core/models.dart';

class RatingsFeedbackScreen extends ConsumerStatefulWidget {
  const RatingsFeedbackScreen({super.key});

  @override
  ConsumerState<RatingsFeedbackScreen> createState() => _RatingsFeedbackScreenState();
}

class _RatingsFeedbackScreenState extends ConsumerState<RatingsFeedbackScreen> {
  String _filterType = 'All';

  @override
  Widget build(BuildContext context) {
    final feedbacksAsync = ref.watch(firestoreFeedbacksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ratings & Feedback')),
      body: feedbacksAsync.when(
        data: (feedbacks) {
          final filtered = _applyFilter(feedbacks);
          return Column(
            children: [
              _buildRatingSummary(feedbacks),
              _buildFilterRow(),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text('No feedback found'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) => _buildFeedbackCard(filtered[index]),
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

  List<CustomerFeedback> _applyFilter(List<CustomerFeedback> feedbacks) {
    switch (_filterType) {
      case 'Flagged': return feedbacks.where((f) => f.isFlagged).toList();
      case 'High': return feedbacks.where((f) => f.rating >= 4).toList();
      case 'Low': return feedbacks.where((f) => f.rating < 3).toList();
      default: return feedbacks;
    }
  }

  Widget _buildRatingSummary(List<CustomerFeedback> feedbacks) {
    final avg = feedbacks.isEmpty
        ? 0.0
        : feedbacks.fold(0.0, (sum, f) => sum + f.rating) / feedbacks.length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, Color(0xFF3949AB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Overall Rating', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(avg.toStringAsFixed(1),
                      style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8, left: 4),
                    child: Text('/5.0', style: TextStyle(color: Colors.white60, fontSize: 16)),
                  ),
                ],
              ),
              Row(
                children: List.generate(5, (i) => Icon(
                  i < avg.floor() ? Icons.star : Icons.star_border,
                  color: AppTheme.accentColor,
                  size: 18,
                )),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [5, 4, 3, 2, 1].map((star) {
              final count = feedbacks.where((f) => f.rating.floor() == star).length;
              return _buildRatingBar('$star★', count, feedbacks.length);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(String label, int count, int total) {
    return Row(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(width: 6),
        Container(
          width: 60, height: 6,
          decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(3)),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: total == 0 ? 0 : count / total,
            child: Container(decoration: BoxDecoration(color: AppTheme.accentColor, borderRadius: BorderRadius.circular(3))),
          ),
        ),
        const SizedBox(width: 4),
        Text('$count', style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: ['All', 'High', 'Low', 'Flagged'].map((filter) {
            final isSelected = _filterType == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(filter),
                selected: isSelected,
                onSelected: (_) => setState(() => _filterType = filter),
                selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                checkmarkColor: AppTheme.primaryColor,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFeedbackCard(CustomerFeedback feedback) {
    final fs = ref.read(firestoreServiceProvider);
    return Container(
      margin: const EdgeInsets.only(bottom: 12, top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
        border: feedback.isFlagged ? Border.all(color: Colors.red.shade200) : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  child: Text(
                    feedback.customerName.isNotEmpty ? feedback.customerName[0] : '?',
                    style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(feedback.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(feedback.date, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                    ],
                  ),
                ),
                if (feedback.isFlagged)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                    child: const Text('FLAGGED', style: TextStyle(color: Colors.red, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ...List.generate(5, (i) => Icon(
                  i < feedback.rating ? Icons.star : Icons.star_border,
                  color: AppTheme.accentColor,
                  size: 16,
                )),
                const SizedBox(width: 6),
                Text(feedback.rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.directions_car, size: 13, color: Colors.grey),
                const SizedBox(width: 4),
                Text('${feedback.cabModel} • ${feedback.agencyName}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            Text(feedback.comment, style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.4)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await fs.updateFeedbackFlag(feedback.id, !feedback.isFlagged);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(feedback.isFlagged ? 'Flag removed' : 'Review flagged'),
                          backgroundColor: feedback.isFlagged ? Colors.green : Colors.orange,
                        ));
                      }
                    },
                    icon: Icon(feedback.isFlagged ? Icons.flag : Icons.flag_outlined,
                        size: 16, color: feedback.isFlagged ? Colors.orange : Colors.grey),
                    label: Text(feedback.isFlagged ? 'Unflag' : 'Flag',
                        style: TextStyle(color: feedback.isFlagged ? Colors.orange : Colors.grey)),
                    style: OutlinedButton.styleFrom(minimumSize: const Size(0, 36)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await fs.deleteFeedback(feedback.id);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Review removed'), backgroundColor: Colors.red),
                        );
                      }
                    },
                    icon: const Icon(Icons.visibility_off, size: 16, color: Colors.red),
                    label: const Text('Disable', style: TextStyle(color: Colors.red)),
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
    );
  }
}
