import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';

class LocationPickerScreen extends StatefulWidget {
  final String title;
  final String hint;

  const LocationPickerScreen({
    super.key,
    required this.title,
    required this.hint,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final _searchController = TextEditingController();
  final List<String> _recentLocations = [
    'Indiranagar, Bangalore',
    'Koramangala 5th Block, Bangalore',
    'Kempegowda International Airport (BLR)',
    'MG Road Metro Station',
    'Whitefield, ITPL Bangalore',
  ];

  List<String> _searchResults = [];

  void _handleSearch(String query) {
    if (query.length > 2) {
      setState(() {
        _searchResults = [
          '$query Main Road',
          '$query Cross Street',
          '$query Layout',
          '$query Phase 1',
          '$query Junction',
        ];
      });
    } else {
      setState(() {
        _searchResults = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryColor,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: _handleSearch,
              decoration: InputDecoration(
                hintText: widget.hint,
                prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchResults = []);
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          if (_searchResults.isNotEmpty)
            Expanded(
              child: ListView.separated(
                itemCount: _searchResults.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.location_on_outlined, color: Colors.grey),
                    title: Text(_searchResults[index]),
                    onTap: () => Navigator.pop(context, _searchResults[index]),
                  );
                },
              ),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.history, color: Colors.grey, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Recent Locations',
                    style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _recentLocations.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.access_time, color: Colors.grey),
                    title: Text(_recentLocations[index]),
                    onTap: () => Navigator.pop(context, _recentLocations[index]),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
