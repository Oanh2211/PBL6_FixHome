class BookingRequestModel {
  final String address;
  final double latitude;
  final double longitude;
  final int categoryId;
  final int deviceTypeId;
  final String issueDescription;
  final String requestedTimeType;
  final DateTime? scheduledAt;
  final String wardCode;
  final String contactName;
  final String contactPhone;
  final String customerNote;
  final String? voucherCode;
  final List<int> mediaIds;

  const BookingRequestModel({
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.categoryId,
    required this.deviceTypeId,
    required this.issueDescription,
    required this.requestedTimeType,
    this.scheduledAt,
    required this.wardCode,
    required this.contactName,
    required this.contactPhone,
    this.customerNote = '',
    this.voucherCode = null,
    this.mediaIds = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'category_id': categoryId,
      'device_type_id': deviceTypeId,
      'issue_description': issueDescription,
      'requested_time_type': requestedTimeType,
      'scheduled_at': requestedTimeType == 'SCHEDULED'
          ? scheduledAt?.toUtc().toIso8601String()
          : null,
      'ward_code': wardCode.trim().isEmpty ? 20200 : wardCode,
      'contact_name': contactName,
      'contact_phone': contactPhone,
      'customer_note': customerNote,
      'voucher_code': voucherCode,
      'media_ids': mediaIds,
    };
  }
}
