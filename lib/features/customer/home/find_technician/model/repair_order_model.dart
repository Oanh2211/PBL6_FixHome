class RepairOrderModel {
  final int id;
  final String orderCode;
  final int customerId;
  final int? technicianId;
  final int categoryId;
  final int deviceTypeId;
  final String status;
  final String issueDescription;
  final String requestedTimeType;
  final DateTime? scheduledAt;
  final String wardCode;
  final String address;
  final double latitude;
  final double longitude;
  final String contactName;
  final String contactPhone;
  final String? customerNote;
  final num? finalAmount;
  final DateTime? createdAt;

  RepairOrderModel({
    required this.id,
    required this.orderCode,
    required this.customerId,
    this.technicianId,
    required this.categoryId,
    required this.deviceTypeId,
    required this.status,
    required this.issueDescription,
    required this.requestedTimeType,
    this.scheduledAt,
    required this.wardCode,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.contactName,
    required this.contactPhone,
    this.customerNote,
    this.finalAmount,
    this.createdAt,
  });

  factory RepairOrderModel.fromJson(Map<String, dynamic> json) {
    return RepairOrderModel(
      id: json['id'] ?? 0,
      orderCode: json['order_code'] ?? '',
      customerId: json['customer_id'] ?? 0,
      technicianId: json['technician_id'],
      categoryId: json['category_id'] ?? 0,
      deviceTypeId: json['device_type_id'] ?? 0,
      status: json['status'] ?? '',
      issueDescription: json['issue_description'] ?? '',
      requestedTimeType: json['requested_time_type'] ?? '',
      scheduledAt: json['scheduled_at'] != null
          ? DateTime.tryParse(json['scheduled_at'])
          : null,
      wardCode: json['ward_code'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      contactName: json['contact_name'] ?? '',
      contactPhone: json['contact_phone'] ?? '',
      customerNote: json['customer_note'],
      finalAmount: json['final_amount'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }
}
