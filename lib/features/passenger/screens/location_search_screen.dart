import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:waseel/core/mapbox_env.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:waseel/core/theme.dart';
import 'package:waseel/features/passenger/models/location_data.dart';
import 'package:waseel/features/passenger/providers/settings_provider.dart';
import 'package:waseel/features/passenger/strings/passenger_flow_strings.dart';

class LocationSearchScreen extends StatefulWidget {
  const LocationSearchScreen({
    super.key,
    required this.title,
    required this.onLocationSelected,
    this.currentValue,
    this.showUseCurrentLocation = false,
  });

  final String title;
  final void Function(LocationData) onLocationSelected;
  final String? currentValue;
  final bool showUseCurrentLocation;

  @override
  State<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  final _searchController = TextEditingController();

  Timer? _debounce;
  bool _loading = false;
  String? _error;
  List<LocationData> _results = [];

  String get _mapboxAccessToken => MapboxEnv.accessToken;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.currentValue ?? '';
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();

    _debounce?.cancel();

    if (query.length < 2) {
      setState(() {
        _results = [];
        _error = null;
        _loading = false;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 450), () {
      _searchMapboxPlaces(query);
    });
  }

  Future<void> _searchMapboxPlaces(String query) async {
    if (_mapboxAccessToken.isEmpty) {
      setState(() {
        _error = 'Mapbox access token is missing.';
        _loading = false;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final encodedQuery = Uri.encodeComponent(query);

      final uri = Uri.parse(
        'https://api.mapbox.com/geocoding/v5/mapbox.places/'
        '$encodedQuery.json'
        '?access_token=$_mapboxAccessToken'
        '&autocomplete=true'
        '&limit=8'
        '&country=LB'
        '&language=en',
      );

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception('Could not search locations.');
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final features = body['features'] as List<dynamic>? ?? [];

      final locations = <LocationData>[];

      for (final item in features) {
        if (item is! Map<String, dynamic>) continue;

        final center = item['center'];
        if (center is! List || center.length < 2) continue;

        final lng = (center[0] as num).toDouble();
        final lat = (center[1] as num).toDouble();

        final address =
            item['place_name']?.toString() ?? item['text']?.toString() ?? query;

        locations.add(
          LocationData(
            lat: lat,
            lng: lng,
            address: address,
          ),
        );
      }

      if (!mounted) return;

      setState(() {
        _results = locations;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _error = 'Could not search locations.';
        _loading = false;
      });
    }
  }

  Future<void> _useCurrentLocation() async {
    final lang = context.read<SettingsProvider>().language;
    final f = PassengerFlowStrings(lang);

    try {
      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (!context.mounted) return;

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.unableToDetermine) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(f.locationPermissionRequired)),
        );
        return;
      }

      final serviceOn = await Geolocator.isLocationServiceEnabled();

      if (!context.mounted) return;

      if (!serviceOn) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(f.enableLocationServices)),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition();

      if (!context.mounted) return;

      widget.onLocationSelected(
        LocationData(
          lat: position.latitude,
          lng: position.longitude,
          address: f.currentLocationLebanon,
        ),
      );

      Navigator.of(context).pop();
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(f.couldNotGetLocation)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final flow = PassengerFlowStrings(
      context.watch<SettingsProvider>().language,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: Colors.grey.shade800,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade900,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: flow.locationSearchHint,
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _results = [];
                            _error = null;
                          });
                        },
                      ),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
          if (widget.showUseCurrentLocation)
            ListTile(
              leading: const Icon(
                Icons.my_location,
                color: AppTheme.primaryTeal,
              ),
              title: Text(
                flow.useMyCurrentLocation,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryTeal,
                ),
              ),
              onTap: _useCurrentLocation,
            ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          if (_error != null && !_loading)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          Expanded(
            child: !_loading && _results.isEmpty
                ? Center(
                    child: Text(
                      _searchController.text.trim().length < 2
                          ? flow.locationSearchHint
                          : flow.noLocationsFound,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final loc = _results[index];

                      return ListTile(
                        leading: const Icon(
                          Icons.place,
                          color: AppTheme.primaryTeal,
                          size: 24,
                        ),
                        title: Text(
                          loc.address,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade900,
                          ),
                        ),
                        onTap: () {
                          widget.onLocationSelected(loc);
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
