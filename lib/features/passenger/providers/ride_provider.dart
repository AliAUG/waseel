import 'package:flutter/material.dart';
import 'package:waseel/features/passenger/data/trip_api_service.dart';
import 'package:waseel/features/passenger/models/driver_info.dart';
import 'package:waseel/features/passenger/models/location_data.dart';
import 'package:waseel/features/passenger/models/package_size.dart';
import 'package:waseel/features/passenger/models/ride_type.dart';

class RideProvider extends ChangeNotifier {
  RideProvider({TripApiService? tripApi})
      : _tripApi = tripApi ?? TripApiService();

  final TripApiService _tripApi;

  /// Non-empty after a successful fetch with at least one row; otherwise UI uses [RideType.homeDisplayOrder].
  List<RideType> _homeRideTypes = [];
  bool _rideTypesLoading = false;
  String? _rideTypesError;

  LocationData? _pickupLocation;
  LocationData? _destination;
  RideType? _selectedRideType;
  PackageSize _selectedPackageSize = PackageSize.small;
  bool _isDelivery = false;

  // Delivery addresses (from Send Package form)
  String? _deliveryPickupAddress;
  String? _deliveryDropoffAddress;
  double _deliveryDistanceKm = 5.0;
  String? _deliverySpecialInstructions;

  /// Set when `POST /deliveries` succeeds until flow ends.
  String? _activeDeliveryId;
  String? get activeDeliveryId => _activeDeliveryId;

  // Assigned driver - set when driver is found (from API, not hardcoded)
  DriverInfo? _assignedDriver;
  String? _driverEta; // Dynamic: "3 min away", "5 min away", etc. based on destination

  // Driver position - for real-time tracking
  double? _driverLat;
  double? _driverLng;
  String? _driverAddress;

  LocationData? get pickupLocation => _pickupLocation;
  LocationData? get destination => _destination;
  RideType? get selectedRideType => _selectedRideType;
  PackageSize get selectedPackageSize => _selectedPackageSize;
  bool get isDelivery => _isDelivery;
  String? get deliveryPickupAddress => _deliveryPickupAddress;
  String? get deliveryDropoffAddress => _deliveryDropoffAddress;
  double get deliveryDistanceKm => _deliveryDistanceKm;
  String? get deliverySpecialInstructions => _deliverySpecialInstructions;
  DriverInfo? get assignedDriver => _assignedDriver;
  String get driverEta {
    if (_driverEta != null) return _driverEta!;
    // Dynamic ETA based on distance - ~2 min per km, min 2
    final min = (2 + (_deliveryDistanceKm * 1.5).round()).clamp(2, 45);
    return '$min min away';
  }
  double? get driverLat => _driverLat;
  double? get driverLng => _driverLng;
  String? get driverAddress => _driverAddress;

  /// Last trip id from `POST /trips` (Mongo), for later screens/APIs.
  String? _activeTripId;
  String? get activeTripId => _activeTripId;

  void setActiveTripId(String? id) {
    _activeTripId = id;
    notifyListeners();
  }

  List<RideType> get homeRideTypes =>
      _homeRideTypes.isNotEmpty ? _homeRideTypes : RideType.homeDisplayOrder;

  bool get rideTypesLoading => _rideTypesLoading;

  String? get rideTypesError => _rideTypesError;

  /// Loads ride types from the backend; on failure or empty response, falls back to local presets.
  Future<void> loadRideTypesFromBackend() async {
    _rideTypesLoading = true;
    _rideTypesError = null;
    notifyListeners();
    try {
      final list = await _tripApi.getRideTypes();
      if (list.isEmpty) {
        _homeRideTypes = [];
      } else {
        final byCategory = <RideCategory, RideType>{};
        for (final t in list) {
          byCategory.putIfAbsent(t.category, () => t);
        }
        _homeRideTypes = [
          for (final c in RideCategory.values)
            if (byCategory.containsKey(c)) byCategory[c]!,
        ];
      }
    } catch (e) {
      _homeRideTypes = [];
      _rideTypesError = e.toString();
    } finally {
      _rideTypesLoading = false;
      notifyListeners();
    }
  }

  void setPickupLocation(LocationData location) {
    _pickupLocation = location;
    notifyListeners();
  }

  void setDestination(LocationData location) {
    _destination = location;
    notifyListeners();
  }

  void setSelectedRideType(RideType? type) {
    _selectedRideType = type;
    notifyListeners();
  }

  void setSelectedPackageSize(PackageSize size) {
    _selectedPackageSize = size;
    notifyListeners();
  }

  void setIsDelivery(bool value) {
    _isDelivery = value;
    notifyListeners();
  }

  void updateDriverPosition(double lat, double lng, [String? address]) {
    _driverLat = lat;
    _driverLng = lng;
    _driverAddress = address;
    notifyListeners();
  }

  void clearDriverPosition() {
    _driverLat = null;
    _driverLng = null;
    _driverAddress = null;
    notifyListeners();
  }

  void setDeliveryAddresses(
    String pickup,
    String dropoff,
    double distanceKm, {
    String? specialInstructions,
  }) {
    _deliveryPickupAddress = pickup;
    _deliveryDropoffAddress = dropoff;
    _deliveryDistanceKm = distanceKm;
    final s = specialInstructions?.trim();
    _deliverySpecialInstructions = (s == null || s.isEmpty) ? null : s;
    notifyListeners();
  }

  void setActiveDeliveryId(String? id) {
    _activeDeliveryId = id;
    notifyListeners();
  }

  void assignDriver(DriverInfo driver, {String? eta}) {
    _assignedDriver = driver;
    _driverEta = eta ?? driverEta;
    notifyListeners();
  }

  void clearAssignedDriver() {
    _assignedDriver = null;
    _driverEta = null;
    notifyListeners();
  }

  void clearRide() {
    _activeTripId = null;
    _activeDeliveryId = null;
    _pickupLocation = null;
    _destination = null;
    _selectedRideType = null;
    _selectedPackageSize = PackageSize.small;
    _assignedDriver = null;
    _driverEta = null;
    _deliveryPickupAddress = null;
    _deliveryDropoffAddress = null;
    _deliverySpecialInstructions = null;
    notifyListeners();
  }
}
