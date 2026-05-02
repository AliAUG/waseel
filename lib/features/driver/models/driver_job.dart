/// Completed or canceled job for driver history
enum JobStatus { completed, canceled }

enum JobType { ride, delivery }

class DriverJob {
  const DriverJob({
    required this.id,
    required this.dateTime,
    required this.amount,
    this.currency = 'USD',
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.status,
    this.rating,
    required this.type,
  });

  final String id;
  final DateTime dateTime;
  final double amount;
  final String currency;
  final String pickupAddress;
  final String dropoffAddress;
  final JobStatus status;
  final double? rating;
  final JobType type;
}
