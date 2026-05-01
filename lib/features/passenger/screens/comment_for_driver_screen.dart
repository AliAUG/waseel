import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waseel/core/network/api_exception.dart';
import 'package:waseel/core/theme.dart';
import 'package:waseel/features/auth/providers/auth_provider.dart';
import 'package:waseel/features/passenger/data/trip_api_service.dart';
import 'package:waseel/features/passenger/providers/ride_provider.dart';
import 'package:waseel/features/passenger/providers/settings_provider.dart';
import 'package:waseel/features/passenger/screens/passenger_shell.dart';
import 'package:waseel/features/passenger/strings/passenger_flow_strings.dart';

const _kFeedbackTagKeys = <String>[
  'friendly_driver',
  'clean_car',
  'safe_driving',
  'on_time',
  'good_music',
];

class CommentForDriverScreen extends StatefulWidget {
  const CommentForDriverScreen({
    super.key,
    required this.driverName,
    this.rating = 5,
    this.forPackagePickup = false,
    this.tripId,
    this.deliveryId,
  });

  final String driverName;
  final int rating;
  final bool forPackagePickup;

  /// When set (ride flow), submits to `POST /trips/:id/rate`.
  final String? tripId;

  /// When set (delivery flow), submits to `POST /deliveries/:id/rate`.
  final String? deliveryId;

  @override
  State<CommentForDriverScreen> createState() => _CommentForDriverScreenState();
}

class _CommentForDriverScreenState extends State<CommentForDriverScreen> {
  late int _rating;
  bool _submitting = false;
  final _api = TripApiService();
  final _feedbackController = TextEditingController();
  final Set<String> _selectedTagKeys = {};

  @override
  void initState() {
    super.initState();
    _rating = widget.rating;
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _goHome() {
    if (!mounted) return;
    context.read<RideProvider>().clearRide();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => const PassengerShell(),
      ),
      (route) => false,
    );
  }

  Future<void> _submit() async {
    final tripId = widget.tripId;
    final deliveryId = widget.deliveryId;

    if (widget.forPackagePickup) {
      if (deliveryId == null || deliveryId.isEmpty) {
        _goHome();
        return;
      }
      final auth = context.read<AuthProvider>();
      final token = auth.token;
      if (token == null ||
          token.isEmpty ||
          token == 'local-session') {
        _goHome();
        return;
      }
      setState(() => _submitting = true);
      try {
        await _api.rateDelivery(
          token: token,
          deliveryId: deliveryId,
          stars: _rating,
          comment: _feedbackController.text,
          feedbackTags: _selectedTagKeys.isEmpty
              ? null
              : _selectedTagKeys
                  .map(PassengerFlowStrings.feedbackTagApiValue)
                  .toList(),
        );
        if (!mounted) return;
        _goHome();
      } on ApiException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      } finally {
        if (mounted) setState(() => _submitting = false);
      }
      return;
    }

    if (tripId == null || tripId.isEmpty) {
      _goHome();
      return;
    }

    final auth = context.read<AuthProvider>();
    final token = auth.token;
    if (token == null ||
        token.isEmpty ||
        token == 'local-session') {
      _goHome();
      return;
    }

    setState(() => _submitting = true);
    try {
      await _api.rateTrip(
        token: token,
        tripId: tripId,
        stars: _rating,
        comment: _feedbackController.text,
        feedbackTags: _selectedTagKeys.isEmpty
            ? null
            : _selectedTagKeys
                .map(PassengerFlowStrings.feedbackTagApiValue)
                .toList(),
      );
      if (!mounted) return;
      _goHome();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
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
          widget.forPackagePickup
              ? flow.commentTitleDelivery
              : flow.commentTitleRide,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Center(
              child: Container(
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
            ),
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  Text(
                    widget.forPackagePickup
                        ? flow.commentHowWasDelivery
                        : flow.ratingHowWasTrip,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    flow.commentTapChangeRating(widget.driverName),
                    style: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (index) => GestureDetector(
                        onTap: () => setState(() => _rating = index + 1),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            index < _rating ? '⭐' : '☆',
                            style: TextStyle(
                              fontSize: 32,
                              color: index < _rating
                                  ? Colors.amber
                                  : Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              flow.commentAdditionalFeedback,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _feedbackController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: flow.commentFeedbackHint,
                hintStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              flow.commentWhatLiked,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _kFeedbackTagKeys.map((key) {
                final isSelected = _selectedTagKeys.contains(key);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedTagKeys.remove(key);
                      } else {
                        _selectedTagKeys.add(key);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryTeal.withValues(alpha: 0.15)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryTeal
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      flow.feedbackTagLabel(key),
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected
                            ? AppTheme.primaryTeal
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _submitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(flow.ratingSubmit),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _submitting
                    ? null
                    : _goHome,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.grey.shade400),
                  foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
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
