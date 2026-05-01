import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waseel/core/theme.dart';
import 'package:waseel/features/auth/providers/auth_provider.dart';
import 'package:waseel/features/passenger/data/trip_api_service.dart';
import 'package:waseel/features/passenger/models/package_size.dart';
import 'package:waseel/features/passenger/models/trip_history.dart';
import 'package:waseel/features/passenger/providers/settings_provider.dart';
import 'package:waseel/features/passenger/strings/passenger_flow_strings.dart';

class TripDetailsScreen extends StatefulWidget {
  const TripDetailsScreen({super.key, required this.trip});

  /// Summary from list; screen refreshes from `GET /trips/:id/details` when possible.
  final TripHistory trip;

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  final _api = TripApiService();
  late TripHistory _trip;
  bool _loadingDetails = false;

  @override
  void initState() {
    super.initState();
    _trip = widget.trip;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDetails());
  }

  Future<void> _loadDetails() async {
    final id = widget.trip.id;
    if (id.isEmpty) return;

    final auth = context.read<AuthProvider>();
    final token = auth.token;
    if (token == null ||
        token.isEmpty ||
        token == 'local-session') {
      return;
    }

    setState(() => _loadingDetails = true);
    try {
      final TripHistory? fresh;
      if (widget.trip.tripType == TripType.delivery) {
        fresh = await _api.getHistoryDeliveryDetails(token, id);
      } else {
        fresh = await _api.getTripDetails(token, id);
      }
      if (!mounted) return;
      final updated = fresh;
      if (updated != null) {
        setState(() => _trip = updated);
      }
    } finally {
      if (mounted) setState(() => _loadingDetails = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final trip = _trip;
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
          trip.tripType == TripType.delivery
              ? flow.deliveryDetailsTitle
              : flow.tripDetailsTitle,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        actions: [
          if (!_loadingDetails)
            IconButton(
              icon: const Icon(Icons.refresh),
              color: Theme.of(context).colorScheme.onSurface,
              onPressed: _loadDetails,
            ),
        ],
      ),
      body: Column(
        children: [
          if (_loadingDetails)
            const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MapPlaceholder(),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LocationRow(
                          isPickup: true,
                          caption: flow.pickupCaption,
                          address: trip.pickupAddress,
                          dateTime: flow.formatDateTimeDetailLine(trip.pickupDateTime),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 11),
                          child: Container(
                            width: 2,
                            height: 24,
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                        _LocationRow(
                          isPickup: false,
                          caption: flow.dropoffCaption,
                          address: trip.dropoffAddress,
                          dateTime: flow.formatDateTimeDetailLine(trip.dropoffDateTime),
                        ),
                        if (trip.tripType == TripType.delivery &&
                            trip.packageSizeLabel != null) ...[
                          const SizedBox(height: 24),
                          _SectionTitle(flow.sectionPackage),
                          const SizedBox(height: 8),
                          Text(
                            trip.packageSizeLabel!,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        _SectionTitle(
                          trip.tripType == TripType.delivery
                              ? flow.sectionDriverCourier
                              : flow.sectionDriver,
                        ),
                        const SizedBox(height: 12),
                        _DriverCard(
                          name: trip.driverName,
                          rating: trip.driverRating,
                          vehicle: trip.vehicle,
                          location: trip.driverLocation,
                        ),
                        const SizedBox(height: 24),
                        if (trip.tripType == TripType.delivery) ...[
                          _SectionTitle(flow.deliveryFeeSection),
                          const SizedBox(height: 12),
                          if (trip.distanceKm > 0)
                            _FareRow(
                              label: flow.distanceKmLabel(trip.distanceKm),
                              value: '—',
                            ),
                          if (trip.distanceKm > 0) const SizedBox(height: 8),
                          _FareRow(
                            label: flow.fareTotalLabel,
                            value: formatLebanesePounds(trip.totalFare),
                            isTotal: true,
                          ),
                        ] else ...[
                          _SectionTitle(flow.fareBreakdownSection),
                          const SizedBox(height: 12),
                          _FareRow(
                            label: flow.baseFareLabel,
                            value: formatLebanesePounds(trip.baseFare),
                          ),
                          const SizedBox(height: 8),
                          _FareRow(
                            label: flow.distanceKmLabel(trip.distanceKm),
                            value: formatLebanesePounds(trip.distanceFare),
                          ),
                          const SizedBox(height: 8),
                          _FareRow(
                            label: flow.timeMinLabel(trip.timeMinutes),
                            value: formatLebanesePounds(trip.timeFare),
                          ),
                          const SizedBox(height: 12),
                          _FareRow(
                            label: flow.fareTotalLabel,
                            value: formatLebanesePounds(trip.totalFare),
                            isTotal: true,
                          ),
                        ],
                        const SizedBox(height: 24),
                        _SectionTitle(flow.paymentMethodSection),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.account_balance_wallet_outlined,
                                size: 24, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            const SizedBox(width: 12),
                            Text(
                              trip.paymentMethod,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.download,
                                size: 20, color: AppTheme.primaryTeal),
                            label: Text(
                              flow.downloadReceipt,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryTeal,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: AppTheme.primaryTeal),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = scheme.brightness == Brightness.dark;
    return Container(
      height: 180,
      color: isDark ? scheme.surfaceContainerLow : scheme.surfaceContainerHigh,
      child: Stack(
        children: [
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on, size: 40, color: AppTheme.primaryTeal),
                const SizedBox(width: 40),
                Icon(Icons.location_on, size: 40, color: Colors.red.shade400),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationRow extends StatelessWidget {
  const _LocationRow({
    required this.isPickup,
    required this.caption,
    required this.address,
    required this.dateTime,
  });

  final bool isPickup;
  final String caption;
  final String address;
  final String dateTime;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isPickup)
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          )
        else
          Icon(Icons.location_on, size: 22, color: Colors.red.shade400),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                caption,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                address,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                dateTime,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

class _DriverCard extends StatelessWidget {
  const _DriverCard({
    required this.name,
    required this.rating,
    required this.vehicle,
    required this.location,
  });

  final String name;
  final double rating;
  final String vehicle;
  final String location;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = scheme.brightness == Brightness.dark;
    final cardBg =
        isDark ? scheme.surfaceContainerLow : scheme.surfaceContainerHigh;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: scheme.primaryContainer,
            child: const Text('👤', style: TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                if (rating > 0) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text('⭐', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(
                        rating.toString(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  '$vehicle • $location',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FareRow extends StatelessWidget {
  const _FareRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  final String label;
  final String value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: FontWeight.bold,
            color: isTotal ? AppTheme.primaryTeal : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
