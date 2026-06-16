import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/app_theme.dart';
import 'map_location_picker_screen.dart';

const _kMapsApiKey = 'AIzaSyDdKt_rjoSjVz4k9TXa9nakXo8qTgpy_3I';
const _kRecentKey = 'nova_cabs_recent_locations';
const _kMaxRecent = 5;

class LocationPickerScreen extends StatefulWidget {
  final String title;
  final String hint;
  /// When true (default) results are biased/restricted to the user's current city.
  /// When false results are restricted to India only — use this for drop location.
  final bool restrictToCity;

  const LocationPickerScreen({
    super.key,
    required this.title,
    required this.hint,
    this.restrictToCity = true,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  bool _detectingLocation = false;
  bool _searching = false;

  double? _lat;
  double? _lng;
  static const int _radiusMeters = 30000;

  List<String> _recentLocations = [];
  List<Map<String, String>> _predictions = [];

  @override
  void initState() {
    super.initState();
    _loadRecents();
    _resolveCurrentPosition();
  }

  // ── Persistent recents ───────────────────────────────────────────────────

  Future<void> _loadRecents() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_kRecentKey) ?? [];
    if (mounted) setState(() => _recentLocations = stored);
  }

  Future<void> _saveRecent(String address) async {
    final prefs = await SharedPreferences.getInstance();
    final updated = [
      address,
      ..._recentLocations.where((r) => r != address),
    ].take(_kMaxRecent).toList();
    await prefs.setStringList(_kRecentKey, updated);
    if (mounted) setState(() => _recentLocations = updated);
  }

  Future<void> _clearRecents() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kRecentKey);
    if (mounted) setState(() => _recentLocations = []);
  }

  // Saves to recents then pops with the chosen address
  Future<void> _selectLocation(String address) async {
    await _saveRecent(address);
    if (mounted) Navigator.pop(context, address);
  }

  // ── GPS ──────────────────────────────────────────────────────────────────

  Future<void> _resolveCurrentPosition() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) return;
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      );
      if (mounted) setState(() { _lat = pos.latitude; _lng = pos.longitude; });
    } catch (_) {
      // autocomplete works without bias if location is unavailable
    }
  }

  // ── Search ───────────────────────────────────────────────────────────────

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().length < 3) {
      setState(() => _predictions = []);
      return;
    }
    _debounce = Timer(
      const Duration(milliseconds: 350),
      () => _fetchPredictions(query.trim()),
    );
  }

  Future<void> _fetchPredictions(String input) async {
    setState(() => _searching = true);
    try {
      final params = <String, String>{
        'input': input,
        'key': _kMapsApiKey,
        'language': 'en',
        'types': 'geocode|establishment',
      };
      if (widget.restrictToCity && _lat != null && _lng != null) {
        // Restrict to user's current city
        params['location'] = '$_lat,$_lng';
        params['radius'] = '$_radiusMeters';
        params['strictbounds'] = 'true';
      } else if (!widget.restrictToCity) {
        // Restrict to India only
        params['components'] = 'country:in';
      }
      final uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/place/autocomplete/json',
        params,
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final raw = (data['predictions'] as List<dynamic>? ?? []);
        setState(() {
          _predictions = raw.map((p) => {
            'description': (p['description'] as String?) ?? '',
            'place_id': (p['place_id'] as String?) ?? '',
          }).where((p) => p['description']!.isNotEmpty).toList();
        });
      }
    } catch (_) {
      // ignore network errors
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  // ── Quick picks ──────────────────────────────────────────────────────────

  Future<void> _useCurrentCity() async {
    setState(() => _detectingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied. Enable it in Settings.')),
          );
        }
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      );
      final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (placemarks.isNotEmpty && mounted) {
        final p = placemarks.first;
        final parts = <String>[
          if (p.subLocality != null && p.subLocality!.isNotEmpty) p.subLocality!,
          if (p.locality != null && p.locality!.isNotEmpty) p.locality!,
          if (p.administrativeArea != null && p.administrativeArea!.isNotEmpty) p.administrativeArea!,
        ].where((s) => s.isNotEmpty).toSet().toList();
        await _selectLocation(parts.take(3).join(', '));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not detect location. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _detectingLocation = false);
    }
  }

  Future<void> _pickFromMaps() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => MapLocationPickerScreen(title: widget.title),
      ),
    );
    if (result != null && mounted) await _selectLocation(result);
  }

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // ── UI ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final showPredictions = _predictions.isNotEmpty;

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
          // Search field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: widget.hint,
                prefixIcon: _searching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : const Icon(Icons.search, color: AppTheme.primaryColor),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _predictions = []);
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

          // Quick-pick buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: _QuickPickButton(
                    icon: Icons.my_location,
                    label: 'Current City',
                    color: Colors.green,
                    isLoading: _detectingLocation,
                    onTap: _useCurrentCity,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickPickButton(
                    icon: Icons.map_outlined,
                    label: 'Pick from Maps',
                    color: AppTheme.primaryColor,
                    isLoading: false,
                    onTap: _pickFromMaps,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 24),

          // Predictions list
          if (showPredictions)
            Expanded(
              child: ListView.separated(
                itemCount: _predictions.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final desc = _predictions[index]['description']!;
                  final commaIdx = desc.indexOf(',');
                  final primary = commaIdx > 0 ? desc.substring(0, commaIdx) : desc;
                  final secondary = commaIdx > 0 ? desc.substring(commaIdx + 1).trim() : '';
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.location_on_outlined, color: AppTheme.primaryColor, size: 18),
                    ),
                    title: Text(primary, style: const TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: secondary.isNotEmpty
                        ? Text(secondary, style: TextStyle(color: Colors.grey.shade600, fontSize: 12))
                        : null,
                    onTap: () => _selectLocation(desc),
                  );
                },
              ),
            )
          else ...[
            // Recent locations header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.history, color: Colors.grey, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Recent Locations',
                      style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (_recentLocations.isNotEmpty)
                    TextButton(
                      onPressed: _clearRecents,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Clear', style: TextStyle(fontSize: 12)),
                    ),
                ],
              ),
            ),

            if (_recentLocations.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.history_toggle_off, size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text(
                        'No recent locations yet',
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _recentLocations.length,
                  itemBuilder: (context, index) {
                    final loc = _recentLocations[index];
                    final commaIdx = loc.indexOf(',');
                    final primary = commaIdx > 0 ? loc.substring(0, commaIdx) : loc;
                    final secondary = commaIdx > 0 ? loc.substring(commaIdx + 1).trim() : '';
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.access_time, color: Colors.grey, size: 18),
                      ),
                      title: Text(primary, style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: secondary.isNotEmpty
                          ? Text(secondary, style: TextStyle(color: Colors.grey.shade500, fontSize: 12))
                          : null,
                      onTap: () => _selectLocation(loc),
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

class _QuickPickButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isLoading;
  final VoidCallback onTap;

  const _QuickPickButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: color),
              )
            else
              Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
