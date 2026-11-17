class TechnicianSummaryModel {
  final int technicianId;
  final int accountId;
  final String fullName;
  final String? avatarUrl;
  final String? experienceLevel;
  final int completedOrderCount;
  final double averageRating;

  TechnicianSummaryModel({
    required this.technicianId,
    required this.accountId,
    required this.fullName,
    this.avatarUrl,
    this.experienceLevel,
    required this.completedOrderCount,
    required this.averageRating,
  });

  factory TechnicianSummaryModel.fromJson(Map<String, dynamic> json) {
    return TechnicianSummaryModel(
      technicianId: json['technician_id'] ?? 0,
      accountId: json['account_id'] ?? 0,
      fullName: json['full_name'] ?? '',
      avatarUrl: json['avatar_url'],
      experienceLevel: json['experience_level'],
      completedOrderCount: json['completed_order_count'] ?? 0,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class QuoteVoucherModel {
  final int id;
  final String code;
  final String name;
  final String discountType;
  final num discountValue;
  final num? maxDiscountAmount;
  final num? minimumOrderAmount;

  QuoteVoucherModel({
    required this.id,
    required this.code,
    required this.name,
    required this.discountType,
    required this.discountValue,
    this.maxDiscountAmount,
    this.minimumOrderAmount,
  });

  factory QuoteVoucherModel.fromJson(Map<String, dynamic> json) {
    return QuoteVoucherModel(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      discountType: json['discount_type'] ?? '',
      discountValue: json['discount_value'] ?? 0,
      maxDiscountAmount: json['max_discount_amount'],
      minimumOrderAmount: json['minimum_order_amount'],
    );
  }
}

class QuoteItemModel {
  final int id;
  final String itemType;
  final String itemName;
  final int quantity;
  final num minUnitPrice;
  final num maxUnitPrice;

  QuoteItemModel({
    required this.id,
    required this.itemType,
    required this.itemName,
    required this.quantity,
    required this.minUnitPrice,
    required this.maxUnitPrice,
  });

  factory QuoteItemModel.fromJson(Map<String, dynamic> json) {
    return QuoteItemModel(
      id: json['id'] ?? 0,
      itemType: json['item_type'] ?? '',
      itemName: json['item_name'] ?? '',
      quantity: json['quantity'] ?? 1,
      minUnitPrice: json['min_unit_price'] ?? 0,
      maxUnitPrice: json['max_unit_price'] ?? 0,
    );
  }
}

class QuoteModel {
  final int quoteId;
  final int orderId;
  final int technicianId;
  final TechnicianSummaryModel? technician;
  final String status;
  final double distanceKm;
  final double matchingScore;
  final num estimatedMinAmount;
  final num estimatedMaxAmount;
  final num discountAmount;
  final num discountMinAmount;
  final num discountMaxAmount;
  final num payableMinAmount;
  final num payableMaxAmount;
  final int warrantyDurationDays;
  final String? note;
  final DateTime? invitedAt;
  final DateTime? respondedAt;
  final DateTime? expiresAt;
  final QuoteVoucherModel? voucher;
  final List<QuoteItemModel> items;

  QuoteModel({
    required this.quoteId,
    required this.orderId,
    required this.technicianId,
    this.technician,
    required this.status,
    required this.distanceKm,
    required this.matchingScore,
    required this.estimatedMinAmount,
    required this.estimatedMaxAmount,
    required this.discountAmount,
    required this.discountMinAmount,
    required this.discountMaxAmount,
    required this.payableMinAmount,
    required this.payableMaxAmount,
    required this.warrantyDurationDays,
    this.note,
    this.invitedAt,
    this.respondedAt,
    this.expiresAt,
    this.voucher,
    this.items = const [],
  });

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      quoteId: json['quote_id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      technicianId: json['technician_id'] ?? 0,
      technician: json['technician'] != null
          ? TechnicianSummaryModel.fromJson(json['technician'])
          : null,
      status: json['status'] ?? '',
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
      matchingScore: (json['matching_score'] as num?)?.toDouble() ?? 0.0,
      estimatedMinAmount: json['estimated_min_amount'] ?? 0,
      estimatedMaxAmount: json['estimated_max_amount'] ?? 0,
      discountAmount: json['discount_amount'] ?? 0,
      discountMinAmount: json['discount_min_amount'] ?? 0,
      discountMaxAmount: json['discount_max_amount'] ?? 0,
      payableMinAmount: json['payable_min_amount'] ?? 0,
      payableMaxAmount: json['payable_max_amount'] ?? 0,
      warrantyDurationDays: json['warranty_duration_days'] ?? 0,
      note: json['note'],
      invitedAt: json['invited_at'] != null
          ? DateTime.tryParse(json['invited_at'])
          : null,
      respondedAt: json['responded_at'] != null
          ? DateTime.tryParse(json['responded_at'])
          : null,
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'])
          : null,
      voucher: json['voucher'] != null
          ? QuoteVoucherModel.fromJson(json['voucher'])
          : null,
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => QuoteItemModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}
