class BookingModel {
  final int id;
  final String? bookingCode;
  final String? status;
  final String? address;
  final String? issueDescription;
  final DateTime? createdAt;

  const BookingModel({
    required this.id,
    this.bookingCode,
    this.status,
    this.address,
    this.issueDescription,
    this.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: (json['id'] as num).toInt(),
      bookingCode: json['booking_code'],
      status: json['status'],
      address: json['address'],
      issueDescription: json['issue_description'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }
}
