import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waseel/features/passenger/providers/ride_provider.dart';
import 'package:waseel/features/passenger/providers/settings_provider.dart';
import 'package:waseel/features/passenger/strings/passenger_flow_strings.dart';
import 'package:waseel/features/passenger/screens/delivery_flow_widgets.dart';

class DeliveryFoundScreen extends StatelessWidget {
  const DeliveryFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final flow = PassengerFlowStrings(context.watch<SettingsProvider>().language);
    return Consumer<RideProvider>(
      builder: (context, rideProvider, _) {
        final driver = rideProvider.assignedDriver;
        if (driver == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
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
              flow.deliveryFoundAppBar,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade900,
              ),
            ),
          ),
          body: Column(
            children: [
              _MapPlaceholder(status: flow.driverOnTheWay),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: DeliveryInfoContent(
                    driverName: driver.name,
                    driverRating: driver.rating,
                    driverVehicle: driver.vehicle,
                    driverLocation: driver.location,
                    eta: rideProvider.driverEta,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      color: Colors.grey.shade200,
      child: Stack(
        children: [
          Center(
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
          Positioned(
            bottom: 12,
            left: 20,
            child: Row(
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
                  status,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
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
