class TechnicianLocationModel {
  final double latitude;
  final double longitude;
  final String locationSource;

  const TechnicianLocationModel({
    required this.latitude,
    required this.longitude,
    required this.locationSource,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'location_source': locationSource,
    };
  }
}
