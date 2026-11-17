import 'package:fixhome/features/customer/activity/model/quote_model.dart';

class RepairOrderModel {
  final int id;
  final String orderCode;
  final int customerId;
  final int? technicianId;
  final int categoryId;
  final int deviceTypeId;
  final String status;
  final String issueDescription;
  final String? requestedTimeType;
  final DateTime? scheduledAt;
  final String? wardCode;
  final String address;
  final double? latitude;
  final double? longitude;
  final String? contactName;
  final String? contactPhone;
  final String? customerNote;
  final num? finalAmount;
  final DateTime? travellingStartedAt;
  final DateTime? arrivedAt;
  final DateTime? repairStartedAt;
  final DateTime? completedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Dữ liệu được enrich (map từ các API phụ)
  final String? categoryName;
  final String? deviceTypeName;
  final String? deviceIconUrl;
  final QuoteModel? matchedQuote;

  RepairOrderModel({
    required this.id,
    required this.orderCode,
    required this.customerId,
    this.technicianId,
    required this.categoryId,
    required this.deviceTypeId,
    required this.status,
    required this.issueDescription,
    this.requestedTimeType,
    this.scheduledAt,
    this.wardCode,
    required this.address,
    this.latitude,
    this.longitude,
    this.contactName,
    this.contactPhone,
    this.customerNote,
    this.finalAmount,
    this.travellingStartedAt,
    this.arrivedAt,
    this.repairStartedAt,
    this.completedAt,
    this.createdAt,
    this.updatedAt,
    this.categoryName,
    this.deviceTypeName,
    this.deviceIconUrl,
    this.matchedQuote,
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
      requestedTimeType: json['requested_time_type'],
      scheduledAt: json['scheduled_at'] != null
          ? DateTime.tryParse(json['scheduled_at'])
          : null,
      wardCode: json['ward_code'],
      address: json['address'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      contactName: json['contact_name'],
      contactPhone: json['contact_phone'],
      customerNote: json['customer_note'],
      finalAmount: json['final_amount'],
      travellingStartedAt: json['travelling_started_at'] != null
          ? DateTime.tryParse(json['travelling_started_at'])
          : null,
      arrivedAt: json['arrived_at'] != null
          ? DateTime.tryParse(json['arrived_at'])
          : null,
      repairStartedAt: json['repair_started_at'] != null
          ? DateTime.tryParse(json['repair_started_at'])
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  RepairOrderModel copyWith({
    String? categoryName,
    String? deviceTypeName,
    String? deviceIconUrl,
    QuoteModel? matchedQuote,
  }) {
    return RepairOrderModel(
      id: id,
      orderCode: orderCode,
      customerId: customerId,
      technicianId: technicianId,
      categoryId: categoryId,
      deviceTypeId: deviceTypeId,
      status: status,
      issueDescription: issueDescription,
      requestedTimeType: requestedTimeType,
      scheduledAt: scheduledAt,
      wardCode: wardCode,
      address: address,
      latitude: latitude,
      longitude: longitude,
      contactName: contactName,
      contactPhone: contactPhone,
      customerNote: customerNote,
      finalAmount: finalAmount,
      travellingStartedAt: travellingStartedAt,
      arrivedAt: arrivedAt,
      repairStartedAt: repairStartedAt,
      completedAt: completedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      categoryName: categoryName ?? this.categoryName,
      deviceTypeName: deviceTypeName ?? this.deviceTypeName,
      deviceIconUrl: deviceIconUrl ?? this.deviceIconUrl,
      matchedQuote: matchedQuote ?? this.matchedQuote,
    );
  }
}
