import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waseel/features/auth/providers/auth_provider.dart';
import 'package:waseel/features/passenger/data/trip_api_service.dart';
import 'package:waseel/features/passenger/models/driver_info.dart';
import 'package:waseel/features/passenger/models/package_size.dart';
import 'package:waseel/features/passenger/providers/ride_provider.dart';
import 'package:waseel/features/passenger/providers/settings_provider.dart';
import 'package:waseel/features/passenger/screens/delivery_found_screen.dart';
import 'package:waseel/features/passenger/strings/passenger_flow_strings.dart';

class SearchingForDeliveryScreen extends StatefulWidget {
  const SearchingForDeliveryScreen({super.key});

  @override
  State<SearchingForDeliveryScreen> createState() =>
      _SearchingForDeliveryScreenState();
}

class _SearchingForDeliveryScreenState extends State<SearchingForDeliveryScreen> {
  final _api = TripApiService();
  bool _requestDone = false;
  bool _requestOk = false;
  String? _requestError;
  /// True until the first [ _submitDeliveryRequest ] pass finishes.
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _submitDeliveryRequest());
  }

  Future<void> _submitDeliveryRequest() async {
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    final ride = context.read<RideProvider>();
    final token = auth.token;

    final pickup = ride.deliveryPickupAddress?.trim() ?? '';
    final dropoff = ride.deliveryDropoffAddress?.trim() ?? '';
    if (pickup.isEmpty || dropoff.isEmpty) {
      if (!mounted) return;
      final msg = PassengerFlowStrings(
        context.read<SettingsProvider>().language,
      ).deliveryAddressesRequired;
      setState(() {
        _loading = false;
        _requestDone = true;
        _requestOk = false;
        _requestError = msg;
      });
      return;
    }

    final useApi = token != null &&
        token.isNotEmpty &&
        token != 'local-session';

    if (!useApi) {
      setState(() {
        _loading = false;
        _requestDone = true;
        _requestOk = false;
        _requestError = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _requestError = null;
    });

    final km = ride.deliveryDistanceKm;
    final size = ride.selectedPackageSize;
    final baseMin = 20 + size.index * 5 + (km * 2).round();
    final etaMin = baseMin;
    final etaMax = baseMin + 10;
    final fee = calculateDeliveryFee(size, km);

    try {
      final id = await _api.createDelivery(
        token: token,
        pickupAddress: pickup,
        dropoffAddress: dropoff,
        packageSizeLabel: size.label,
        weightLimit: size.weight,
        deliveryFee: fee,
        etaMinMinutes: etaMin,
        etaMaxMinutes: etaMax,
        specialInstructions: ride.deliverySpecialInstructions,
      );
      if (!mounted) return;
      ride.setActiveDeliveryId(id);
      setState(() {
        _loading = false;
        _requestDone = true;
        _requestOk = true;
        _requestError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _requestDone = true;
        _requestOk = false;
        _requestError = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final flow = PassengerFlowStrings(context.watch<SettingsProvider>().language);
    final auth = context.watch<AuthProvider>();
    final token = auth.token;
    final demoOnly = token == null ||
        token.isEmpty ||
        token == 'local-session';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, size: 24),
          color: Colors.grey.shade800,
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          flow.searchingDeliveryAppBar,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade900,
          ),
        ),
      ),
      body: Column(
        children: [
          const _MapPlaceholder(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_loading) ...[
                    const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      flow.sendingDeliveryRequest,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ] else if (_requestDone && _requestError != null) ...[
                    Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
                    const SizedBox(height: 16),
                    Text(
                      _requestError!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () {
                        setState(() {
                          _requestDone = false;
                          _requestError = null;
                        });
                        _submitDeliveryRequest();
                      },
                      child: Text(flow.retry),
                    ),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          flow.findingDriver,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      flow.usuallyUnderMinute,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (_requestOk) ...[
                      const SizedBox(height: 12),
                      Text(
                        flow.deliveryRequestSavedNote,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.teal.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    if (demoOnly && !_requestOk && _requestDone) ...[
                      const SizedBox(height: 12),
                      Text(
                        flow.signInToSaveDeliveryOnServer,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          final ride = context.read<RideProvider>();
                          ride.assignDriver(
                            DriverInfo(
                              name: 'Driver',
                              rating: 4.9,
                              vehicle: '—',
                              location: 'Lebanon',
                            ),
                            eta: ride.driverEta,
                          );
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const DeliveryFoundScreen(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.grey.shade400),
                          foregroundColor: Colors.grey.shade700,
                        ),
                        child: Text(flow.simulateDriverFound),
                      ),
                    ),
                  ],
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
  const _MapPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      color: Colors.grey.shade200,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🚗', style: TextStyle(fontSize: 48)),
            const SizedBox(width: 40),
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'B',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
