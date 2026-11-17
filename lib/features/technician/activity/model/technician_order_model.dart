class IssueMediaModel {
  final int mediaId;
  final String mediaType;
  final String fileUrl;
  final String mimeType;

  IssueMediaModel({
    required this.mediaId,
    required this.mediaType,
    required this.fileUrl,
    required this.mimeType,
  });

  factory IssueMediaModel.fromJson(Map<String, dynamic> json) {
    return IssueMediaModel(
      mediaId: (json['media_id'] as num?)?.toInt() ?? 0,
      mediaType: json['media_type']?.toString() ?? 'IMAGE',
      fileUrl: json['file_url']?.toString() ?? '',
      mimeType: json['mime_type']?.toString() ?? '',
    );
  }
}

class TechnicianOrderModel {
  final int id;
  final String orderCode;
  final int customerId;
  final int technicianId;
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
  final String customerNote;
  final double? finalAmount;
  final DateTime? travellingStartedAt;
  final DateTime? arrivedAt;
  final DateTime? repairStartedAt;
  final DateTime? completedAt;
  final DateTime? createdAt;
  final List<IssueMediaModel> issueMedia;

  // Mapped names từ API Category & Device
  final String categoryName;
  final String deviceName;
  final String deviceIconUrl;

  final String workPerformed;
  final int warrantyDurationDays;
  final bool isQuoteSubmitted;

  TechnicianOrderModel({
    required this.id,
    required this.orderCode,
    required this.customerId,
    required this.technicianId,
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
    required this.customerNote,
    this.finalAmount,
    this.travellingStartedAt,
    this.arrivedAt,
    this.repairStartedAt,
    this.completedAt,
    this.createdAt,
    this.issueMedia = const [],
    this.categoryName = '',
    this.deviceName = '',
    this.deviceIconUrl = '',
    this.workPerformed = '',
    this.warrantyDurationDays = 30,
    this.isQuoteSubmitted = false,
  });

  factory TechnicianOrderModel.fromJson(
    Map<String, dynamic> json, {
    String categoryName = '',
    String deviceName = '',
    String deviceIconUrl = '',
  }) {
    final quoteMap = json['quote'] as Map<String, dynamic>?;
    final rawFinalAmount =
        (json['final_amount'] as num?)?.toDouble() ??
        (quoteMap?['payable_max_amount'] as num?)?.toDouble() ??
        (quoteMap?['estimated_max_amount'] as num?)?.toDouble();

    final hasQuoteInResponse =
        json['final_amount'] != null ||
        json['is_quote_submitted'] == true ||
        (quoteMap != null &&
            (quoteMap['estimated_max_amount'] != null ||
                quoteMap['status'] == 'FINAL_SUBMITTED'));

    return TechnicianOrderModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      orderCode: json['order_code']?.toString() ?? '',
      customerId: (json['customer_id'] as num?)?.toInt() ?? 0,
      technicianId: (json['technician_id'] as num?)?.toInt() ?? 0,
      categoryId: (json['category_id'] as num?)?.toInt() ?? 0,
      deviceTypeId: (json['device_type_id'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? 'TECHNICIAN_SELECTED',
      issueDescription: json['issue_description']?.toString() ?? '',
      requestedTimeType: json['requested_time_type']?.toString() ?? 'NOW',
      scheduledAt: json['scheduled_at'] != null
          ? DateTime.tryParse(json['scheduled_at'].toString())?.toLocal()
          : null,
      wardCode: json['ward_code']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      contactName: json['contact_name']?.toString() ?? '',
      contactPhone: json['contact_phone']?.toString() ?? '',
      customerNote: json['customer_note']?.toString() ?? '',
      finalAmount: rawFinalAmount,
      travellingStartedAt: json['travelling_started_at'] != null
          ? DateTime.tryParse(
              json['travelling_started_at'].toString(),
            )?.toLocal()
          : null,
      arrivedAt: json['arrived_at'] != null
          ? DateTime.tryParse(json['arrived_at'].toString())?.toLocal()
          : null,
      repairStartedAt: json['repair_started_at'] != null
          ? DateTime.tryParse(json['repair_started_at'].toString())?.toLocal()
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'].toString())?.toLocal()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())?.toLocal()
          : null,
      issueMedia:
          (json['issue_media'] as List<dynamic>?)
              ?.map((e) => IssueMediaModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      categoryName: categoryName,
      deviceName: deviceName,
      deviceIconUrl: deviceIconUrl,
      workPerformed:
          json['work_performed']?.toString() ??
          quoteMap?['note']?.toString() ??
          '',
      warrantyDurationDays:
          (json['warranty_duration_days'] as num?)?.toInt() ??
          (quoteMap?['warranty_duration_days'] as num?)?.toInt() ??
          30,
      isQuoteSubmitted: hasQuoteInResponse,
    );
  }

  TechnicianOrderModel copyWith({
    String? status,
    double? finalAmount,
    String? categoryName,
    String? deviceName,
    String? deviceIconUrl,
    List<IssueMediaModel>? issueMedia,
    String? workPerformed,
    int? warrantyDurationDays,
    bool? isQuoteSubmitted,
  }) {
    return TechnicianOrderModel(
      id: id,
      orderCode: orderCode,
      customerId: customerId,
      technicianId: technicianId,
      categoryId: categoryId,
      deviceTypeId: deviceTypeId,
      status: status ?? this.status,
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
      finalAmount: finalAmount ?? this.finalAmount,
      travellingStartedAt: travellingStartedAt,
      arrivedAt: arrivedAt,
      repairStartedAt: repairStartedAt,
      completedAt: completedAt,
      createdAt: createdAt,
      issueMedia: issueMedia ?? this.issueMedia,
      categoryName: categoryName ?? this.categoryName,
      deviceName: deviceName ?? this.deviceName,
      deviceIconUrl: deviceIconUrl ?? this.deviceIconUrl,
      workPerformed: workPerformed ?? this.workPerformed,
      warrantyDurationDays: warrantyDurationDays ?? this.warrantyDurationDays,
      isQuoteSubmitted: isQuoteSubmitted ?? this.isQuoteSubmitted,
    );
  }
}

/// Model Item gửi lên API PUT /technician/repair-orders/{orderId}/quote
class FinalQuoteItemModel {
  final int quantity;
  final String itemName;
  final String itemType; // "LABOR" hoặc "PART"
  final double minUnitPrice;
  final double maxUnitPrice;

  FinalQuoteItemModel({
    this.quantity = 1,
    required this.itemName,
    required this.itemType,
    required this.minUnitPrice,
    required this.maxUnitPrice,
  });

  Map<String, dynamic> toJson() => {
    'quantity': quantity,
    'item_name': itemName,
    'item_type': itemType,
    'min_unit_price': minUnitPrice,
    'max_unit_price': maxUnitPrice,
  };
}

class FinalQuoteRequestModel {
  final String note;
  final List<FinalQuoteItemModel> items;
  final double estimatedMinAmount;
  final double estimatedMaxAmount;
  final int warrantyDurationDays;

  FinalQuoteRequestModel({
    this.note = '',
    required this.items,
    required this.estimatedMinAmount,
    required this.estimatedMaxAmount,
    required this.warrantyDurationDays,
  });

  Map<String, dynamic> toJson() => {
    'note': note,
    'items': items.map((e) => e.toJson()).toList(),
    'estimated_min_amount': estimatedMinAmount,
    'estimated_max_amount': estimatedMaxAmount,
    'warranty_duration_days': warrantyDurationDays,
  };
}
