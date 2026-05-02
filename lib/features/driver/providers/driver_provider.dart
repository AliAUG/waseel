import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:waseel/core/network/api_exception.dart';
import 'package:waseel/features/driver/data/driver_api_service.dart';
import 'package:waseel/features/driver/models/driver_job.dart';
import 'package:waseel/features/driver/models/driver_vehicle.dart';
import 'package:waseel/features/driver/models/ride_request.dart';
import 'package:waseel/features/driver/utils/driver_trip_merge.dart';

class DriverProvider extends ChangeNotifier {
  DriverProvider({DriverApiService? driverApi})
      : _api = driverApi ?? DriverApiService();

  final DriverApiService _api;

  bool _isOnline = false;
  RideRequest? _incomingRequest;
  RideRequest? _activeRide;
  Timer? _requestTimer;

  bool _useDemoData = true;

  int _earningsToday = 162750;
  int _earningsYesterday = 145000;
  int _tripsToday = 12;
  double _onlineTimeHours = 5.2;
  List<int> _weeklyEarnings = [140000, 120000, 150000, 125000, 162750, 145000, 135250];
  int _totalEarnings = 1868250;
  int _weeklyRides = 28;
  int _weeklyDeliveries = 14;
  int _weeklyDaysLeft = 8;
  int _totalJobs = 342;
  double _avgRating = 4.9;
  int _acceptedJobs = 325;
  String _memberSince = '6mo';
  DriverVehicle _vehicle = const DriverVehicle(
    makeModel: 'Toyota Camry',
    year: 2022,
    color: 'White',
    plateNumber: 'Lebanon A-12345',
  );
  List<DriverJob> _jobs = [];

  String? _lastSyncError;

  bool get isOnline => _isOnline;
  RideRequest? get incomingRequest => _incomingRequest;
  RideRequest? get activeRide => _activeRide;
  int get earningsToday => _earningsToday;
  int get earningsYesterday => _earningsYesterday;
  int get todayVsYesterdayPercent => _earningsYesterday > 0
      ? ((_earningsToday - _earningsYesterday) / _earningsYesterday * 100).round()
      : 0;
  int get tripsToday => _tripsToday;
  int get weeklyRides => _weeklyRides;
  int get weeklyDeliveries => _weeklyDeliveries;
  int get weeklyJobs => _weeklyRides + _weeklyDeliveries;
  int get weeklyDaysLeft => _weeklyDaysLeft;
  double get onlineTimeHours => _onlineTimeHours;
  List<int> get weeklyEarnings => List.unmodifiable(_weeklyEarnings);
  int get weeklyTotal => _weeklyEarnings.fold(0, (a, b) => a + b);
  int get totalEarnings => _totalEarnings;
  int get totalJobs => _totalJobs;
  double get avgRating => _avgRating;
  int get acceptedJobs => _acceptedJobs;
  int get acceptancePercent =>
      _totalJobs > 0 ? ((_acceptedJobs / _totalJobs) * 100).round() : 0;
  String get memberSince => _memberSince;
  DriverVehicle get vehicle => _vehicle;

  /// Short line for header, e.g. `Toyota Camry • A-12345`.
  String get vehicleLabel => '${vehicle.makeModel} • ${vehicle.plateNumber}';

  List<DriverJob> get jobs => List.unmodifiable(_jobs);

  /// Last driver API error (e.g. network); null when OK or demo mode.
  String? get lastSyncError => _lastSyncError;

  bool _isRealDriverSession(String? token, String? role) {
    return token != null &&
        token.isNotEmpty &&
        token != 'local-session' &&
        role == 'Driver';
  }

  bool _hasRealToken(String? token) =>
      token != null && token.isNotEmpty && token != 'local-session';

  /// Loads dashboard, wallet balance, trip history from backend when token + Driver role.
  Future<void> syncFromBackend(String? token, String? role) async {
    if (!_isRealDriverSession(token, role)) {
      _lastSyncError = null;
      _useDemoData = true;
      notifyListeners();
      return;
    }
    _lastSyncError = null;
    try {
      final dash = await _api.getDashboard(token!);
      _earningsToday = _toInt(dash['earningsToday']);
      _tripsToday = _toInt(dash['tripsToday']);
      final weekEarn = _toInt(dash['earningsThisWeek']);
      final tripsWeek = _toInt(dash['tripsThisWeek']);
      _weeklyRides = tripsWeek;
      _totalEarnings = _toInt(dash['balance']);
      final perDay = weekEarn > 0 ? (weekEarn / 7).round() : 0;
      _weeklyEarnings = List<int>.generate(7, (_) => perDay);

      _earningsYesterday = 0;
      _onlineTimeHours = 0;
      _weeklyDeliveries = 0;

      final vehicleMap = dash['vehicle'];
      if (vehicleMap is Map) {
        final v = Map<String, dynamic>.from(vehicleMap);
        _vehicle = DriverVehicle(
          makeModel: v['makeModel']?.toString() ?? _vehicle.makeModel,
          year: _toInt(v['year'], _vehicle.year),
          color: v['color']?.toString() ?? _vehicle.color,
          plateNumber: v['plateNumber']?.toString() ?? _vehicle.plateNumber,
        );
      }

      final hist = await _api.getTripHistory(token, page: 1, limit: 50);
      final rawTrips = hist['trips'];
      final total = _toInt(hist['total']);
      _totalJobs = total > 0 ? total : (rawTrips is List ? rawTrips.length : 0);
      _acceptedJobs = _totalJobs;

      if (rawTrips is List) {
        _jobs = rawTrips
            .whereType<Map>()
            .map((e) => _tripToJob(Map<String, dynamic>.from(e)))
            .toList();
        _jobs.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      } else {
        _jobs = [];
      }

      _useDemoData = false;
    } on ApiException catch (e) {
      _lastSyncError = e.message;
      _useDemoData = true;
    } catch (e) {
      _lastSyncError = e.toString();
      _useDemoData = true;
    }
    notifyListeners();
  }

  DriverJob _tripToJob(Map<String, dynamic> t) {
    final id = _mongoId(t['_id']);
    final statusStr = t['status']?.toString() ?? '';
    final pickup = t['pickupLocation'];
    final drop = t['dropoffLocation'];
    final pu = pickup is Map ? pickup['address']?.toString() ?? '' : '';
    final du = drop is Map ? drop['address']?.toString() ?? '' : '';
    final typeStr = t['type']?.toString() ?? 'ride';
    final completedAt = t['completedAt'];
    final createdAt = t['createdAt'];
    DateTime dt = DateTime.now();
    if (completedAt is String) {
      dt = DateTime.tryParse(completedAt) ?? dt;
    } else if (createdAt is String) {
      dt = DateTime.tryParse(createdAt) ?? dt;
    }
    final fare = _toDouble(t['actualFare'] ?? t['estimatedFare'], 0);
    final curRaw = t['currency']?.toString().trim();
    final currency = (curRaw != null && curRaw.isNotEmpty)
        ? curRaw.toUpperCase()
        : (fare > 0 && fare < 500 ? 'USD' : 'LBP');
    final jobStatus = statusStr == 'cancelled'
        ? JobStatus.canceled
        : JobStatus.completed;
    final jt = typeStr == 'delivery' ? JobType.delivery : JobType.ride;
    return DriverJob(
      id: id.isEmpty ? 'unknown' : id,
      dateTime: dt,
      amount: fare,
      currency: currency,
      pickupAddress: pu,
      dropoffAddress: du,
      status: jobStatus,
      rating: null,
      type: jt,
    );
  }

  void _initDemoJobs() {
    if (!_useDemoData || _jobs.isNotEmpty) return;
    final now = DateTime.now();
    _jobs.addAll([
      DriverJob(
        id: '1',
        dateTime: DateTime(now.year, now.month, now.day, 14, 30),
        amount: 42,
        currency: 'USD',
        pickupAddress: 'Tripoli City Center',
        dropoffAddress: 'Al Mina, Tripoli',
        status: JobStatus.completed,
        rating: 5.0,
        type: JobType.ride,
      ),
      DriverJob(
        id: '2',
        dateTime: DateTime(now.year, now.month, now.day, 13, 15),
        amount: 22.5,
        currency: 'USD',
        pickupAddress: 'Marina Walk, Jounieh',
        dropoffAddress: 'Jbeil Beach',
        status: JobStatus.completed,
        rating: 4.0,
        type: JobType.ride,
      ),
    ]);
    _jobs.sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  List<DriverJob> getJobsForFilter(JobFilter filter) {
    if (_useDemoData) _initDemoJobs();
    switch (filter) {
      case JobFilter.all:
        return List.from(_jobs);
      case JobFilter.rides:
        return _jobs.where((j) => j.type == JobType.ride).toList();
      case JobFilter.deliveries:
        return _jobs.where((j) => j.type == JobType.delivery).toList();
      case JobFilter.completed:
        return _jobs.where((j) => j.status == JobStatus.completed).toList();
    }
  }

  List<DriverJob> getTransactionsForFilter(EarningsFilter filter) {
    if (_useDemoData) _initDemoJobs();
    final paid = _jobs.where((j) => j.status == JobStatus.completed && j.amount > 0).toList();
    switch (filter) {
      case EarningsFilter.all:
        return paid;
      case EarningsFilter.rides:
        return paid.where((j) => j.type == JobType.ride).toList();
      case EarningsFilter.deliveries:
        return paid.where((j) => j.type == JobType.delivery).toList();
      case EarningsFilter.pending:
        return [];
    }
  }

  void toggleOnline() {
    _isOnline = !_isOnline;
    if (!_isOnline) {
      _requestTimer?.cancel();
      _incomingRequest = null;
    }
    notifyListeners();
  }

  void setOnline(bool value) {
    _isOnline = value;
    if (!value) {
      _requestTimer?.cancel();
      _incomingRequest = null;
    }
    notifyListeners();
  }

  /// Call after going online with a real driver session to show pending requests.
  Future<void> refreshIncomingRequests(String? token, String? role) async {
    if (!_isOnline) return;
    if (!_isRealDriverSession(token, role)) return;
    try {
      final list = await _api.getRideRequests(token!);
      if (list.isEmpty) {
        _incomingRequest = null;
      } else {
        _incomingRequest = _mapRideRequest(list.first);
        _startRequestTimer();
      }
      _lastSyncError = null;
    } on ApiException catch (e) {
      _lastSyncError = e.message;
    } catch (e) {
      _lastSyncError = e.toString();
    }
    notifyListeners();
  }

  RideRequest _mapRideRequest(Map<String, dynamic> m) {
    final id = _mongoId(m['_id']);
    final pickup = m['pickupLocation'];
    final drop = m['dropoffLocation'];
    final pu = pickup is Map ? pickup['address']?.toString() ?? '' : '';
    final du = drop is Map ? drop['address']?.toString() ?? '' : '';
    final passenger = m['passenger'];
    var name = 'Passenger';
    var rating = 4.8;
    var trips = 42;
    if (passenger is Map) {
      name = passenger['fullName']?.toString() ?? name;
      rating = _toDouble(passenger['rating'], rating);
      trips = _toInt(passenger['tripsCount'], trips);
    }
    final fare = _toDouble(m['estimatedFare'], 0);
    final fareCur = m['currency']?.toString().trim();
    final currency = (fareCur != null && fareCur.isNotEmpty)
        ? fareCur.toUpperCase()
        : (fare > 0 && fare < 500 ? 'USD' : 'LBP');
    var seconds = 20;
    final exp = m['expiresAt'];
    if (exp is String) {
      final t = DateTime.tryParse(exp);
      if (t != null) {
        seconds = t.difference(DateTime.now()).inSeconds.clamp(1, 120);
      }
    }
    return RideRequest(
      passengerName: name,
      passengerRating: rating,
      passengerTrips: trips,
      pickupAddress: pu,
      dropoffAddress: du,
      estimatedFare: fare,
      fareCurrency: currency,
      timeRemainingSeconds: seconds,
      apiRequestId: id.isEmpty ? null : id,
      tripId: _tripRefToId(m['trip']),
    );
  }

  void simulateIncomingRequest() {
    _incomingRequest = const RideRequest(
      passengerName: 'Passenger',
      passengerRating: 4.8,
      passengerTrips: 42,
      pickupAddress: 'Tripoli City Center, Lebanon',
      dropoffAddress: 'Al Mina, Tripoli',
      estimatedFare: 18,
      fareCurrency: 'USD',
      timeRemainingSeconds: 20,
    );
    _startRequestTimer();
    notifyListeners();
  }

  void _startRequestTimer() {
    _requestTimer?.cancel();
    var remaining = _incomingRequest?.timeRemainingSeconds ?? 20;
    _requestTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      remaining--;
      if (remaining <= 0) {
        _requestTimer?.cancel();
        _incomingRequest = null;
        notifyListeners();
      } else {
        final cur = _incomingRequest;
        if (cur == null) return;
        _incomingRequest = RideRequest(
          passengerName: cur.passengerName,
          passengerRating: cur.passengerRating,
          passengerTrips: cur.passengerTrips,
          pickupAddress: cur.pickupAddress,
          dropoffAddress: cur.dropoffAddress,
          estimatedFare: cur.estimatedFare,
          fareCurrency: cur.fareCurrency,
          timeRemainingSeconds: remaining,
          apiRequestId: cur.apiRequestId,
          tripId: cur.tripId,
        );
        notifyListeners();
      }
    });
  }

  Future<bool> acceptRequest(String? token) async {
    final req = _incomingRequest;
    if (req == null) return false;
    var tripId = req.tripId;
    if (req.apiRequestId != null && _hasRealToken(token)) {
      try {
        final resp = await _api.acceptRideRequest(token!, req.apiRequestId!);
        final data = resp['data'];
        if (data is Map) {
          final parsed = _mongoId(data['_id']);
          if (parsed.isNotEmpty) tripId = parsed;
        }
      } on ApiException {
        return false;
      } catch (_) {
        return false;
      }
    }
    _requestTimer?.cancel();
    _activeRide = req.copyWith(tripId: tripId ?? req.tripId);
    _incomingRequest = null;
    notifyListeners();
    return true;
  }

  /// Syncs trip status with backend (`driver_en_route`, `driver_arrived`, `en_route`, `completed`).
  /// No-op success when [tripId] is null (local / simulate flow).
  Future<bool> updateTripStatus(
    String? token,
    String? tripId,
    String status,
  ) async {
    if (!_hasRealToken(token) || tripId == null || tripId.isEmpty) {
      return true;
    }
    try {
      await _api.updateTripStatus(token!, tripId, status);
      return true;
    } on ApiException {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Fetches `GET /driver/trips/:id` and merges into [ride] for active-trip UI.
  /// Returns [ride] unchanged when no [RideRequest.tripId], demo token, or on failure.
  Future<RideRequest> mergeRideWithServerTrip(
    RideRequest ride,
    String? token,
  ) async {
    final tid = ride.tripId;
    if (tid == null || tid.isEmpty || !_hasRealToken(token)) {
      return ride;
    }
    try {
      final map = await _api.getTrip(token!, tid);
      if (map.isEmpty) return ride;
      return DriverTripMerge.mergeTripMapIntoRide(ride, map);
    } catch (_) {
      return ride;
    }
  }

  Future<void> declineRequest(String? token) async {
    final req = _incomingRequest;
    if (req?.apiRequestId != null && _hasRealToken(token)) {
      try {
        await _api.declineRideRequest(token!, req!.apiRequestId!);
      } catch (_) {}
    }
    _requestTimer?.cancel();
    _incomingRequest = null;
    notifyListeners();
  }

  void clearActiveRide() {
    _activeRide = null;
    notifyListeners();
  }

  /// Clears active trip state and restores demo dashboard after [AuthProvider.logout].
  void resetForLogout() {
    _requestTimer?.cancel();
    _requestTimer = null;
    _incomingRequest = null;
    _activeRide = null;
    _isOnline = false;
    _useDemoData = true;
    _lastSyncError = null;
    _jobs.clear();
    _earningsToday = 162750;
    _earningsYesterday = 145000;
    _tripsToday = 12;
    _onlineTimeHours = 5.2;
    _weeklyEarnings = [140000, 120000, 150000, 125000, 162750, 145000, 135250];
    _totalEarnings = 1868250;
    _weeklyRides = 28;
    _weeklyDeliveries = 14;
    _weeklyDaysLeft = 8;
    _totalJobs = 342;
    _avgRating = 4.9;
    _acceptedJobs = 325;
    _memberSince = '6mo';
    _vehicle = const DriverVehicle(
      makeModel: 'Toyota Camry',
      year: 2022,
      color: 'White',
      plateNumber: 'Lebanon A-12345',
    );
    notifyListeners();
  }

  Future<bool> requestPayout(String? token, int amount) async {
    if (amount <= 0 || amount > _totalEarnings) return false;
    if (!_hasRealToken(token)) {
      _totalEarnings -= amount;
      notifyListeners();
      return true;
    }
    try {
      final resp = await _api.requestPayout(token!, amount);
      final data = resp['data'];
      if (data is Map) {
        final nb = data['newBalance'];
        if (nb != null) {
          _totalEarnings = _toInt(nb);
        }
      }
      await syncFromBackend(token, 'Driver');
      return true;
    } on ApiException {
      return false;
    } catch (_) {
      return false;
    }
  }

  static int _toInt(dynamic v, [int fallback = 0]) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is double) return v.round();
    return int.tryParse(v.toString()) ?? fallback;
  }

  static double _toDouble(dynamic v, double fallback) {
    if (v == null) return fallback;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? fallback;
  }

  static String _mongoId(dynamic v) {
    if (v == null) return '';
    if (v is String) return v;
    if (v is Map && v[r'$oid'] != null) return v[r'$oid'].toString();
    return v.toString();
  }

  static String? _tripRefToId(dynamic v) {
    if (v == null) return null;
    if (v is String && v.isNotEmpty) return v;
    if (v is Map) {
      final id = _mongoId(v['_id']);
      return id.isEmpty ? null : id;
    }
    return null;
  }
}

enum JobFilter { all, rides, deliveries, completed }

enum EarningsFilter { all, rides, deliveries, pending }
