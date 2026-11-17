class TechnicianSummaryModel {
  final int technicianId;
  final int accountId;
  final String fullName;
  final String? avatarUrl;
  final String experienceLevel;
  final int completedOrderCount;
  final double averageRating;

  TechnicianSummaryModel({
    required this.technicianId,
    required this.accountId,
    required this.fullName,
    this.avatarUrl,
    required this.experienceLevel,
    required this.completedOrderCount,
    required this.averageRating,
  });

  factory TechnicianSummaryModel.fromJson(Map<String, dynamic> json) {
    return TechnicianSummaryModel(
      technicianId: json['technician_id'] ?? 0,
      accountId: json['account_id'] ?? 0,
      fullName: json['full_name'] ?? '',
      avatarUrl: json['avatar_url'],
      experienceLevel: json['experience_level'] ?? '',
      completedOrderCount: json['completed_order_count'] ?? 0,
      averageRating: (json['average_rating'] ?? 0).toDouble(),
    );
  }
}

class VoucherInfoModel {
  final int id;
  final String code;
  final String name;
  final String discountType;
  final num discountValue;
  final num maxDiscountAmount;
  final num minimumOrderAmount;

  VoucherInfoModel({
    required this.id,
    required this.code,
    required this.name,
    required this.discountType,
    required this.discountValue,
    required this.maxDiscountAmount,
    required this.minimumOrderAmount,
  });

  factory VoucherInfoModel.fromJson(Map<String, dynamic> json) {
    return VoucherInfoModel(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      discountType: json['discount_type'] ?? '',
      discountValue: json['discount_value'] ?? 0,
      maxDiscountAmount: json['max_discount_amount'] ?? 0,
      minimumOrderAmount: json['minimum_order_amount'] ?? 0,
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

class TechnicianQuoteModel {
  final int quoteId;
  final int orderId;
  final int technicianId;
  final TechnicianSummaryModel technician;
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
  final VoucherInfoModel? voucher;
  final List<QuoteItemModel> items;

  TechnicianQuoteModel({
    required this.quoteId,
    required this.orderId,
    required this.technicianId,
    required this.technician,
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
    required this.items,
  });

  factory TechnicianQuoteModel.fromJson(Map<String, dynamic> json) {
    return TechnicianQuoteModel(
      quoteId: json['quote_id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      technicianId: json['technician_id'] ?? 0,
      technician: TechnicianSummaryModel.fromJson(json['technician'] ?? {}),
      status: json['status'] ?? '',
      distanceKm: (json['distance_km'] ?? 0).toDouble(),
      matchingScore: (json['matching_score'] ?? 0).toDouble(),
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
          ? VoucherInfoModel.fromJson(json['voucher'])
          : null,
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => QuoteItemModel.fromJson(e))
          .toList(),
    );
  }
}

class QuotePageResponse {
  final List<TechnicianQuoteModel> content;
  final int page;
  final int pageSize;
  final int totalElements;
  final int totalPages;
  final bool first;
  final bool last;

  QuotePageResponse({
    required this.content,
    required this.page,
    required this.pageSize,
    required this.totalElements,
    required this.totalPages,
    required this.first,
    required this.last,
  });

  factory QuotePageResponse.fromJson(Map<String, dynamic> json) {
    return QuotePageResponse(
      content: (json['content'] as List<dynamic>? ?? [])
          .map((e) => TechnicianQuoteModel.fromJson(e))
          .toList(),
      page: json['page'] ?? 1,
      pageSize: json['page_size'] ?? 20,
      totalElements: json['total_elements'] ?? 0,
      totalPages: json['total_pages'] ?? 1,
      first: json['first'] ?? true,
      last: json['last'] ?? true,
    );
  }
}

class ApplicableVoucherModel {
  final VoucherInfoModel voucher;
  final bool eligible;
  final String? ineligibleReason;
  final bool selected;
  final bool bestChoice;
  final num discountMinAmount;
  final num discountMaxAmount;
  final num payableMinAmount;
  final num payableMaxAmount;

  ApplicableVoucherModel({
    required this.voucher,
    required this.eligible,
    this.ineligibleReason,
    required this.selected,
    required this.bestChoice,
    required this.discountMinAmount,
    required this.discountMaxAmount,
    required this.payableMinAmount,
    required this.payableMaxAmount,
  });

  factory ApplicableVoucherModel.fromJson(Map<String, dynamic> json) {
    return ApplicableVoucherModel(
      voucher: VoucherInfoModel.fromJson(json['voucher'] ?? {}),
      eligible: json['eligible'] ?? false,
      ineligibleReason: json['ineligible_reason'],
      selected: json['selected'] ?? false,
      bestChoice: json['best_choice'] ?? false,
      discountMinAmount: json['discount_min_amount'] ?? 0,
      discountMaxAmount: json['discount_max_amount'] ?? 0,
      payableMinAmount: json['payable_min_amount'] ?? 0,
      payableMaxAmount: json['payable_max_amount'] ?? 0,
    );
  }
}

class SelectQuoteResponse {
  final int orderId;
  final String orderCode;
  final String status;
  final String matchingStatus;
  final int selectedQuoteId;
  final int technicianId;
  final DateTime? quoteSelectedAt;

  SelectQuoteResponse({
    required this.orderId,
    required this.orderCode,
    required this.status,
    required this.matchingStatus,
    required this.selectedQuoteId,
    required this.technicianId,
    this.quoteSelectedAt,
  });

  factory SelectQuoteResponse.fromJson(Map<String, dynamic> json) {
    return SelectQuoteResponse(
      orderId: json['order_id'] ?? 0,
      orderCode: json['order_code'] ?? '',
      status: json['status'] ?? '',
      matchingStatus: json['matching_status'] ?? '',
      selectedQuoteId: json['selected_quote_id'] ?? 0,
      technicianId: json['technician_id'] ?? 0,
      quoteSelectedAt: json['quote_selected_at'] != null
          ? DateTime.tryParse(json['quote_selected_at'])
          : null,
    );
  }
}
