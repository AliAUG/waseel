import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waseel/features/passenger/providers/ride_provider.dart';
import 'package:waseel/features/passenger/providers/settings_provider.dart';
import 'package:waseel/features/passenger/screens/comment_for_driver_screen.dart';
import 'package:waseel/features/passenger/strings/passenger_flow_strings.dart';

class RatingScreen extends StatefulWidget {
  const RatingScreen({
    super.key,
    required this.driverName,
    this.forPackagePickup = false,
    this.tripId,
    this.deliveryId,
  });

  final String driverName;
  final bool forPackagePickup;

  /// Mongo trip id from [RideProvider.activeTripId] after `POST /trips`.
  final String? tripId;

  /// Mongo delivery id from [RideProvider.activeDeliveryId] after `POST /deliveries`.
  final String? deliveryId;

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _rating = 0;

  @override
  Widget build(BuildContext context) {
    final flow = PassengerFlowStrings(context.watch<SettingsProvider>().language);
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
          widget.forPackagePickup
              ? flow.ratingTitleRateTrip
              : flow.ratingTitleRating,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade900,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 32),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '🤷‍♂️',
                  style: TextStyle(fontSize: 48),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              flow.ratingHowWasTrip,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.forPackagePickup
                  ? flow.ratingSubtitleDelivery(widget.driverName)
                  : flow.ratingSubtitleRide(widget.driverName),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              flow.ratingTapStars,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => GestureDetector(
                  onTap: () => setState(() => _rating = index + 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      index < _rating ? '⭐' : '☆',
                      style: TextStyle(
                        fontSize: 40,
                        color: index < _rating
                            ? Colors.amber
                            : Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (_rating > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  flow.ratingStarsOfFive(_rating),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _rating > 0
                    ? () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => CommentForDriverScreen(
                              driverName: widget.driverName,
                              rating: _rating,
                              forPackagePickup: widget.forPackagePickup,
                              tripId: widget.tripId,
                              deliveryId: widget.deliveryId,
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(flow.ratingSubmit),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  context.read<RideProvider>().clearRide();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.grey.shade400),
                  foregroundColor: Colors.grey.shade700,
                ),
                child: Text(flow.ratingSkip),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
