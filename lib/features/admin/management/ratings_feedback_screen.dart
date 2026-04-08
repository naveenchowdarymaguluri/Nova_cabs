import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../../../core/mock_data.dart';
import '../../../core/models.dart';

class RatingsFeedbackScreen extends StatefulWidget {
  const RatingsFeedbackScreen({super.key});

  @override
  State<RatingsFeedbackScreen> createState() => _RatingsFeedbackScreenState();
}

class _RatingsFeedbackScreenState extends State<RatingsFeedbackScreen> {
  List<CustomerFeedback> _feedbacks = List.from(MockData.feedbacks);
  String _filterType = 'All'; // All, Flagged, High, Low

  List<CustomerFeedback> get _filteredFeedbacks {
    switch (_filterType) {
      case 'Flagged':
        return _feedbacks.where((f) => f.isFlagged).toList();
      case 'High':
        return _feedbacks.where((f) => f.rating >= 4).toList();
      case 'Low':
        return _feedbacks.where((f) => f.rating < 3).toList();
      default:
        return _feedbacks;
    }
  }

  double get _averageRating {
    if (_feedbacks.isEmpty) return 0;
    return _feedbacks.fold(0.0, (sum, f) => sum + f.rating) / _feedbacks.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ratings & Feedback'),
      ),
      body: Column(
        children: [
          _buildRatingSummary(),
          _buildFilterRow(),
          Expanded(
            child: _filteredFeedbacks.isEmpty
                ? const Center(child: Text('No feedback found'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredFeedbacks.length,
                    itemBuilder: (context, index) =>
                        _buildFeedbackCard(_filteredFeedbacks[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSummary() {
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
                  Text(
                    _averageRating.toStringAsFixed(1),
                    style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8, left: 4),
                    child: Text('/5.0', style: TextStyle(color: Colors.white60, fontSize: 16)),
                  ),
                ],
              ),
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    i < _averageRating.floor() ? Icons.star : Icons.star_border,
                    color: AppTheme.accentColor,
                    size: 18,
                  );
                }),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildRatingBar('5★', _feedbacks.where((f) => f.rating == 5).length),
              _buildRatingBar('4★', _feedbacks.where((f) => f.rating >= 4 && f.rating < 5).length),
              _buildRatingBar('3★', _feedbacks.where((f) => f.rating >= 3 && f.rating < 4).length),
              _buildRatingBar('2★', _feedbacks.where((f) => f.rating >= 2 && f.rating < 3).length),
              _buildRatingBar('1★', _feedbacks.where((f) => f.rating < 2).length),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(String label, int count) {
    return Row(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(width: 6),
        Container(
          width: 60,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _feedbacks.isEmpty ? 0 : count / _feedbacks.length,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.accentColor,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
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
                    feedback.customerName[0],
                    style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(feedback.customerName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(feedback.date,
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                    ],
                  ),
                ),
                if (feedback.isFlagged)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('FLAGGED',
                        style: TextStyle(color: Colors.red, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ...List.generate(5, (i) {
                  return Icon(
                    i < feedback.rating ? Icons.star : Icons.star_border,
                    color: AppTheme.accentColor,
                    size: 16,
                  );
                }),
                const SizedBox(width: 6),
                Text(
                  feedback.rating.toStringAsFixed(1),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.directions_car, size: 13, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${feedback.cabModel} • ${feedback.agencyName}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              feedback.comment,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() => feedback.isFlagged = !feedback.isFlagged);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(feedback.isFlagged ? 'Review flagged' : 'Flag removed'),
                          backgroundColor: feedback.isFlagged ? Colors.orange : Colors.green,
                        ),
                      );
                    },
                    icon: Icon(
                      feedback.isFlagged ? Icons.flag : Icons.flag_outlined,
                      size: 16,
                      color: feedback.isFlagged ? Colors.orange : Colors.grey,
                    ),
                    label: Text(
                      feedback.isFlagged ? 'Unflag' : 'Flag',
                      style: TextStyle(color: feedback.isFlagged ? Colors.orange : Colors.grey),
                    ),
                    style: OutlinedButton.styleFrom(minimumSize: const Size(0, 36)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() => _feedbacks.remove(feedback));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Review disabled'), backgroundColor: Colors.red),
                      );
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
