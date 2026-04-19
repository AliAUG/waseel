/// Driver's vehicle information
class DriverVehicle {
  const DriverVehicle({
    required this.makeModel,
    required this.year,
    required this.color,
    required this.plateNumber,
  });

  final String makeModel;
  final int year;
  final String color;
  final String plateNumber;
}
