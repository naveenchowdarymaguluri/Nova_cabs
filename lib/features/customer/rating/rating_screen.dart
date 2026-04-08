import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../../../core/extended_models.dart';

class RatingScreen extends StatefulWidget {
  final TripRequest trip;
  final DriverModel driver;

  const RatingScreen({
    super.key,
    required this.trip,
    required this.driver,
  });

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _rating = 0;
  final Set<String> _selectedCategories = {};
  final _commentController = TextEditingController();

  final List<String> _categories = [
    'Driver Behavior',
    'Vehicle Cleanliness',
    'Driving Safety',
    'Overall Experience',
    'On-time Pickup',
    'Smooth Ride',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Rate Your Ride'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Skip', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildDriverHeader(),
            const SizedBox(height: 32),
            const Text('How was your trip?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildStarRating(),
            const SizedBox(height: 32),
            if (_rating > 0) ...[
              const Text('What did you like?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              _buildCategoryChips(),
              const SizedBox(height: 32),
              _buildCommentField(),
            ],
          ],
        ),
      ),
      bottomNavigationBar: _buildSubmitButton(),
    );
  }

  Widget _buildDriverHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey.shade100,
          child: const Icon(Icons.person, size: 50, color: AppTheme.primaryColor),
        ),
        const SizedBox(height: 16),
        Text(widget.driver.fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text('${widget.driver.vehicleModel} • ${widget.driver.vehicleNumber}', style: TextStyle(color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < _rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 40,
          ),
          onPressed: () => setState(() => _rating = index + 1),
        );
      }),
    );
  }

  Widget _buildCategoryChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _categories.map((cat) {
        bool isSelected = _selectedCategories.contains(cat);
        return FilterChip(
          label: Text(cat),
          selected: isSelected,
          onSelected: (val) {
            setState(() {
              if (val) _selectedCategories.add(cat);
              else _selectedCategories.remove(cat);
            });
          },
          selectedColor: AppTheme.accentColor,
          labelStyle: TextStyle(
            color: isSelected ? AppTheme.primaryColor : Colors.black87,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCommentField() {
    return TextField(
      controller: _commentController,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: 'Add a comment (Optional)',
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _rating == 0 ? null : () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Thank you for your feedback!'), backgroundColor: Colors.green),
              );
              Navigator.pop(context); // Go back to Home
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Submit Feedback', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
