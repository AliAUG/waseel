/// Completed or canceled job for driver history
enum JobStatus { completed, canceled }

enum JobType { ride, delivery }

class DriverJob {
  const DriverJob({
    required this.id,
    required this.dateTime,
    required this.amount,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.status,
    this.rating,
    required this.type,
  });

  final String id;
  final DateTime dateTime;
  final int amount;
  final String pickupAddress;
  final String dropoffAddress;
  final JobStatus status;
  final double? rating;
  final JobType type;
}
