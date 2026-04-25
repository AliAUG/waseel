/// Represents a past trip (ride or delivery) for history
enum TripType {
  ride,
  delivery,
}

class TripHistory {
  const TripHistory({
    required this.id,
    required this.tripType,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.pickupDateTime,
    required this.dropoffDateTime,
    required this.totalFare,
    required this.driverName,
    required this.driverRating,
    required this.vehicle,
    required this.driverLocation,
    required this.baseFare,
    required this.distanceKm,
    required this.distanceFare,
    required this.timeMinutes,
    required this.timeFare,
    required this.paymentMethod,
    this.packageSizeLabel,
    this.status,
    this.estimatedArrivalMinutes,
  });

  final String id;
  final TripType tripType;
  final String pickupAddress;
  final String dropoffAddress;
  final DateTime pickupDateTime;
  final DateTime dropoffDateTime;
  final int totalFare;
  final String driverName;
  final double driverRating;
  final String vehicle;
  final String driverLocation;
  final int baseFare;
  final double distanceKm;
  final int distanceFare;
  final int timeMinutes;
  final int timeFare;
  final String paymentMethod;
  /// Set for delivery rows from `packageDetails.size`.
  final String? packageSizeLabel;

  /// From `GET /trips/...` — e.g. `searching_driver`, `driver_assigned`.
  final String? status;

  /// Server ETA in minutes when set.
  final int? estimatedArrivalMinutes;

  /// True when [driver] was populated on the server (not placeholder `—`).
  bool get hasAssignedDriver =>
      driverName.isNotEmpty && driverName != '—';

  String get timeFormatted {
    final h = pickupDateTime.hour;
    final m = pickupDateTime.minute;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  /// One trip from `GET /trips` list item (Mongoose JSON).
  factory TripHistory.fromBackend(Map<String, dynamic> json) {
    final id = _parseMongoId(json['_id']) ?? '';
    final typeStr = json['type']?.toString() ?? 'ride';
    final tripType =
        typeStr == 'delivery' ? TripType.delivery : TripType.ride;

    final pickup = json['pickupLocation'];
    final drop = json['dropoffLocation'];
    final pickupAddress = pickup is Map
        ? (pickup['address']?.toString() ?? '')
        : '';
    final dropoffAddress =
        drop is Map ? (drop['address']?.toString() ?? '') : '';

    final created = _parseDate(json['createdAt']);
    final updated = json['updatedAt'] != null
        ? _parseDate(json['updatedAt'])
        : created;

    final fb = json['fareBreakdown'];
    var baseFare = 0;
    var distanceFare = 0;
    var timeFare = 0;
    var total = 0;
    var distanceKm = 0.0;
    var timeMinutes = 0;
    if (fb is Map) {
      baseFare = _toInt(fb['baseFare']);
      distanceFare = _toInt(fb['distanceCost']);
      timeFare = _toInt(fb['timeCost']);
      total = _toInt(fb['total']);
      distanceKm = _toDouble(fb['distanceKm']);
      timeMinutes = _toInt(fb['timeMinutes']);
    }
    if (total == 0) {
      total = _toInt(json['estimatedFare']);
    }

    final driverRaw = json['driver'];
    var driverName = '—';
    var driverRating = 0.0;
    var vehicle = '—';
    var driverLocation = 'Lebanon';
    if (driverRaw is Map) {
      final driver = Map<String, dynamic>.from(driverRaw);
      driverName = driver['fullName']?.toString() ?? '—';
      driverRating = _toDouble(driver['rating']);
      final v = driver['vehicle'];
      if (v is Map) {
        final vm = Map<String, dynamic>.from(v);
        final mm = vm['makeModel']?.toString() ?? '';
        final col = vm['color']?.toString() ?? '';
        vehicle = '$mm $col'.trim();
        if (vehicle.isEmpty) vehicle = '—';
        final reg = vm['region']?.toString();
        if (reg != null && reg.isNotEmpty) driverLocation = reg;
      }
      final dr = driver['region']?.toString();
      if (dr != null && dr.isNotEmpty) driverLocation = dr;
    }

    final rawPay = json['paymentMethod']?.toString() ?? 'cash';
    final paymentMethod = rawPay.isEmpty
        ? 'Cash'
        : rawPay.length == 1
            ? rawPay.toUpperCase()
            : '${rawPay[0].toUpperCase()}${rawPay.substring(1).toLowerCase()}';

    final etaRaw = json['estimatedArrivalMinutes'];
    final etaMin = _toInt(etaRaw);
    final eta = etaMin > 0 ? etaMin : null;

    return TripHistory(
      id: id,
      tripType: tripType,
      pickupAddress: pickupAddress.isEmpty ? '—' : pickupAddress,
      dropoffAddress: dropoffAddress.isEmpty ? '—' : dropoffAddress,
      pickupDateTime: created,
      dropoffDateTime: updated,
      totalFare: total,
      driverName: driverName,
      driverRating: driverRating,
      vehicle: vehicle,
      driverLocation: driverLocation,
      baseFare: baseFare,
      distanceKm: distanceKm,
      distanceFare: distanceFare,
      timeMinutes: timeMinutes,
      timeFare: timeFare,
      paymentMethod: paymentMethod,
      packageSizeLabel: null,
      status: json['status']?.toString(),
      estimatedArrivalMinutes: eta,
    );
  }

  /// Delivery document from `GET /history?type=deliveries`.
  factory TripHistory.fromDeliveryJson(Map<String, dynamic> json) {
    final id = _parseMongoId(json['_id']) ?? '';
    final pickup = json['pickupLocation'];
    final drop = json['dropoffLocation'];
    final pickupAddress = pickup is Map
        ? (pickup['address']?.toString() ?? '')
        : '';
    final dropoffAddress =
        drop is Map ? (drop['address']?.toString() ?? '') : '';
    final created = _parseDate(json['createdAt']);
    final end = json['tripEndTime'] != null
        ? _parseDate(json['tripEndTime'])
        : _parseDate(json['updatedAt']);
    final fee = _toInt(json['deliveryFee']);
    final dist = _toDouble(json['distance']);

    var driverName = '—';
    final driverRaw = json['driver'];
    if (driverRaw is Map) {
      driverName =
          Map<String, dynamic>.from(driverRaw)['fullName']?.toString() ?? '—';
    }

    String? pkg;
    final pd = json['packageDetails'];
    if (pd is Map) {
      pkg = Map<String, dynamic>.from(pd)['size']?.toString();
    }

    return TripHistory(
      id: id,
      tripType: TripType.delivery,
      pickupAddress: pickupAddress.isEmpty ? '—' : pickupAddress,
      dropoffAddress: dropoffAddress.isEmpty ? '—' : dropoffAddress,
      pickupDateTime: created,
      dropoffDateTime: end,
      totalFare: fee,
      driverName: driverName,
      driverRating: 0,
      vehicle: '—',
      driverLocation: 'Lebanon',
      baseFare: fee,
      distanceKm: dist,
      distanceFare: 0,
      timeMinutes: 0,
      timeFare: 0,
      paymentMethod: 'Delivery',
      packageSizeLabel: pkg,
      status: json['status']?.toString(),
      estimatedArrivalMinutes: null,
    );
  }

  static String? _parseMongoId(dynamic v) {
    if (v == null) return null;
    if (v is String) return v;
    if (v is Map && v[r'$oid'] != null) return v[r'$oid'].toString();
    return v.toString();
  }

  static DateTime _parseDate(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is String) {
      return DateTime.tryParse(v) ?? DateTime.now();
    }
    if (v is Map) {
      final d = v[r'$date'];
      if (d is String) return DateTime.tryParse(d) ?? DateTime.now();
      if (d is int) return DateTime.fromMillisecondsSinceEpoch(d);
    }
    return DateTime.now();
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.round();
    return int.tryParse(v.toString()) ?? 0;
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}
