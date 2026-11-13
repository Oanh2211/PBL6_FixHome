class TechnicianAvailabilityModel {
  final bool isAvailable;

  const TechnicianAvailabilityModel({required this.isAvailable});

  Map<String, dynamic> toJson() {
    return {'is_available': isAvailable};
  }
}
