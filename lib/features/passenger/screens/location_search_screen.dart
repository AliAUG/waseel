import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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
  List<LocationData> _filtered = LocationData.allLebanon;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterLocations);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterLocations);
    _searchController.dispose();
    super.dispose();
  }

  void _filterLocations() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() => _filtered = LocationData.allLebanon);
      return;
    }
    setState(() {
      _filtered = LocationData.allLebanon
          .where((l) => l.address.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final flow = PassengerFlowStrings(context.watch<SettingsProvider>().language);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: Theme.of(context).colorScheme.onSurface,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
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
                prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurfaceVariant),
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
              onChanged: (_) => _filterLocations(),
            ),
          ),
          if (widget.showUseCurrentLocation)
            ListTile(
              leading: Icon(Icons.my_location, color: AppTheme.primaryTeal),
              title: Text(
                flow.useMyCurrentLocation,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryTeal,
                ),
              ),
              onTap: () async {
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
                  widget.onLocationSelected(LocationData(
                    lat: position.latitude,
                    lng: position.longitude,
                    address: f.currentLocationLebanon,
                  ));
                  Navigator.of(context).pop();
                } catch (_) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(f.couldNotGetLocation)),
                  );
                }
              },
            ),
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Text(
                      flow.noLocationsFound,
                      style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) {
                      final loc = _filtered[index];
                      return ListTile(
                        leading: Icon(
                          Icons.place,
                          color: AppTheme.primaryTeal,
                          size: 24,
                        ),
                        title: Text(
                          loc.address,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface,
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
