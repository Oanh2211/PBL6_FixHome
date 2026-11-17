class TechnicianQuoteListResponse {
  final List<TechnicianQuoteModel> content;
  final int page;
  final int pageSize;
  final int totalElements;
  final int totalPages;
  final bool first;
  final bool last;

  TechnicianQuoteListResponse({
    required this.content,
    required this.page,
    required this.pageSize,
    required this.totalElements,
    required this.totalPages,
    required this.first,
    required this.last,
  });

  factory TechnicianQuoteListResponse.fromJson(Map<String, dynamic> json) {
    final list = json['content'] as List? ?? [];

    return TechnicianQuoteListResponse(
      content: list
          .whereType<Map<String, dynamic>>()
          .map(TechnicianQuoteModel.fromJson)
          .where((quote) => quote.status.trim().toUpperCase() != 'EXPIRED')
          .toList(),
      page: _int(json['page'], 1),
      pageSize: _int(json['page_size'], 20),
      totalElements: _int(json['total_elements']),
      totalPages: _int(json['total_pages']),
      first: json['first'] == true,
      last: json['last'] == true,
    );
  }
}

class TechnicianQuoteModel {
  final int quoteId;
  final int orderId;
  final String orderCode;
  final String status;
  final String requestedTimeType;
  final DateTime? scheduledAt;
  final int categoryId;
  final int deviceTypeId;
  final String wardCode;
  final String address;
  final double latitude;
  final double longitude;
  final double distanceKm;
  final int inviteRound;
  final String issueDescription;
  final DateTime? invitedAt;
  final DateTime? expiresAt;
  final String categoryName;
  final String categoryIconUrl;
  final String deviceName;
  final List<int> mediaIds;

  TechnicianQuoteModel({
    required this.quoteId,
    required this.orderId,
    required this.orderCode,
    required this.status,
    required this.requestedTimeType,
    this.scheduledAt,
    required this.categoryId,
    required this.deviceTypeId,
    required this.wardCode,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
    required this.inviteRound,
    required this.issueDescription,
    this.invitedAt,
    this.expiresAt,
    this.categoryName = '',
    this.categoryIconUrl = '',
    this.deviceName = '',
    this.mediaIds = const [],
  });

  TechnicianQuoteModel copyWithCatalog({
    String? categoryName,
    String? categoryIconUrl,
    String? deviceName,
  }) {
    return TechnicianQuoteModel(
      quoteId: quoteId,
      orderId: orderId,
      orderCode: orderCode,
      status: status,
      requestedTimeType: requestedTimeType,
      scheduledAt: scheduledAt,
      categoryId: categoryId,
      deviceTypeId: deviceTypeId,
      wardCode: wardCode,
      address: address,
      latitude: latitude,
      longitude: longitude,
      distanceKm: distanceKm,
      inviteRound: inviteRound,
      issueDescription: issueDescription,
      invitedAt: invitedAt,
      expiresAt: expiresAt,
      categoryName: categoryName ?? this.categoryName,
      categoryIconUrl: categoryIconUrl ?? this.categoryIconUrl,
      deviceName: deviceName ?? this.deviceName,
      mediaIds: mediaIds,
    );
  }

  factory TechnicianQuoteModel.fromJson(Map<String, dynamic> json) {
    return TechnicianQuoteModel(
      quoteId: _int(json['quote_id']),
      orderId: _int(json['order_id']),
      orderCode: _str(json['order_code']),
      status: _str(json['status']),
      requestedTimeType: _str(json['requested_time_type']),
      scheduledAt: _date(json['scheduled_at']),
      categoryId: _int(json['category_id']),
      deviceTypeId: _int(json['device_type_id']),
      wardCode: _str(json['ward_code']),
      address: _str(json['address']),
      latitude: _double(json['latitude']),
      longitude: _double(json['longitude']),
      distanceKm: _double(json['distance_km']),
      inviteRound: _int(json['invite_round']),
      issueDescription: _str(json['issue_description']),
      invitedAt: _date(json['invited_at']),
      expiresAt: _date(json['expires_at']),
      mediaIds: (json['media_ids'] as List? ?? []).map((e) => _int(e)).toList(),
    );
  }
}

class TechnicianIssueMediaModel {
  final int mediaId;
  final String mediaType;
  final String fileUrl;
  final String mimeType;
  final int fileSizeBytes;
  final double durationSeconds;
  final DateTime? createdAt;

  TechnicianIssueMediaModel({
    required this.mediaId,
    required this.mediaType,
    required this.fileUrl,
    required this.mimeType,
    required this.fileSizeBytes,
    required this.durationSeconds,
    this.createdAt,
  });

  factory TechnicianIssueMediaModel.fromJson(Map<String, dynamic> json) {
    return TechnicianIssueMediaModel(
      mediaId: _int(json['media_id']),
      mediaType: _str(json['media_type']),
      fileUrl: _str(json['file_url']),
      mimeType: _str(json['mime_type']),
      fileSizeBytes: _int(json['file_size_bytes']),
      durationSeconds: _double(json['duration_seconds']),
      createdAt: _date(json['created_at']),
    );
  }
}

class TechnicianQuoteDetailModel extends TechnicianQuoteModel {
  final String customerNote;
  final String contactName;
  final double estimatedMinAmount;
  final double estimatedMaxAmount;
  final double discountAmount;
  final int warrantyDurationDays;
  final String note;
  final DateTime? respondedAt;
  final List<TechnicianQuoteItemModel> items;
  final List<TechnicianIssueMediaModel> issueMedia;

  TechnicianQuoteDetailModel({
    required super.quoteId,
    required super.orderId,
    required super.orderCode,
    required super.status,
    required super.requestedTimeType,
    super.scheduledAt,
    required super.categoryId,
    required super.deviceTypeId,
    required super.wardCode,
    required super.address,
    required super.latitude,
    required super.longitude,
    required super.distanceKm,
    required super.inviteRound,
    required super.issueDescription,
    super.invitedAt,
    super.expiresAt,
    super.categoryName,
    super.categoryIconUrl,
    super.deviceName,
    super.mediaIds,
    required this.customerNote,
    required this.contactName,
    required this.estimatedMinAmount,
    required this.estimatedMaxAmount,
    required this.discountAmount,
    required this.warrantyDurationDays,
    required this.note,
    this.respondedAt,
    required this.items,
    this.issueMedia = const [],
  });

  factory TechnicianQuoteDetailModel.fromJson(Map<String, dynamic> json) {
    final itemList = json['items'] as List? ?? [];
    final mediaList = json['media_ids'] as List? ?? [];
    final issueMediaList = json['issue_media'] as List? ?? [];

    return TechnicianQuoteDetailModel(
      quoteId: _int(json['quote_id']),
      orderId: _int(json['order_id']),
      orderCode: _str(json['order_code']),
      status: _str(json['status']),
      requestedTimeType: _str(json['requested_time_type']),
      scheduledAt: _date(json['scheduled_at']),
      categoryId: _int(json['category_id']),
      deviceTypeId: _int(json['device_type_id']),
      wardCode: _str(json['ward_code']),
      address: _str(json['address']),
      latitude: _double(json['latitude']),
      longitude: _double(json['longitude']),
      distanceKm: _double(json['distance_km']),
      inviteRound: _int(json['invite_round']),
      issueDescription: _str(json['issue_description']),
      invitedAt: _date(json['invited_at']),
      expiresAt: _date(json['expires_at']),
      customerNote: _str(json['customer_note']),
      contactName: _str(json['contact_name']),
      mediaIds: mediaList.map((e) => _int(e)).toList(),
      issueMedia: issueMediaList
          .whereType<Map<String, dynamic>>()
          .map(TechnicianIssueMediaModel.fromJson)
          .toList(),
      estimatedMinAmount: _double(json['estimated_min_amount']),
      estimatedMaxAmount: _double(json['estimated_max_amount']),
      discountAmount: _double(json['discount_amount']),
      warrantyDurationDays: _int(json['warranty_duration_days']),
      note: _str(json['note']),
      respondedAt: _date(json['responded_at']),
      items: itemList
          .whereType<Map<String, dynamic>>()
          .map(TechnicianQuoteItemModel.fromJson)
          .toList(),
    );
  }
}

class TechnicianQuoteItemModel {
  final int id;
  final String itemType;
  final String itemName;
  final int quantity;
  final double minUnitPrice;
  final double maxUnitPrice;

  TechnicianQuoteItemModel({
    required this.id,
    required this.itemType,
    required this.itemName,
    required this.quantity,
    required this.minUnitPrice,
    required this.maxUnitPrice,
  });

  factory TechnicianQuoteItemModel.fromJson(Map<String, dynamic> json) {
    return TechnicianQuoteItemModel(
      id: _int(json['id']),
      itemType: _str(json['item_type']),
      itemName: _str(json['item_name']),
      quantity: _int(json['quantity']),
      minUnitPrice: _double(json['min_unit_price']),
      maxUnitPrice: _double(json['max_unit_price']),
    );
  }
}

// Các hàm chuyển đổi dữ liệu an toàn.

String _str(dynamic value) => value?.toString() ?? '';

int _int(dynamic value, [int fallback = 0]) {
  if (value == null) return fallback;
  if (value is int) return value;
  return int.tryParse(value.toString()) ?? fallback;
}

double _double(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}

DateTime? _date(dynamic value) {
  if (value == null || value.toString().isEmpty) return null;
  return DateTime.tryParse(value.toString());
}
