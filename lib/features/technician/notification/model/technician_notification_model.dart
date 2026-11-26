enum TechnicianNotificationCategory {
  all,
  orders,
  incomeWallet,
  system,
}

class TechnicianNotificationModel {
  final int id;
  final int accountId;
  final String type;
  final String title;
  final String body;
  final String referenceType;
  final int? referenceId;
  final bool isRead;
  final DateTime? createdAt;
  final DateTime? readAt;

  const TechnicianNotificationModel({
    required this.id,
    required this.accountId,
    required this.type,
    required this.title,
    required this.body,
    required this.referenceType,
    this.referenceId,
    required this.isRead,
    this.createdAt,
    this.readAt,
  });

  factory TechnicianNotificationModel.fromJson(Map<String, dynamic> json) {
    return TechnicianNotificationModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      accountId: (json['account_id'] as num?)?.toInt() ?? 0,
      type: (json['type'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      referenceType: (json['reference_type'] ?? '').toString(),
      referenceId: (json['reference_id'] as num?)?.toInt(),
      isRead: json['is_read'] == true,
      createdAt: _parseDate(json['created_at']),
      readAt: _parseDate(json['read_at']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    final raw = value.toString();
    if (raw.isEmpty) return null;
    return DateTime.tryParse(raw)?.toLocal();
  }

  TechnicianNotificationModel copyWith({
    int? id,
    int? accountId,
    String? type,
    String? title,
    String? body,
    String? referenceType,
    int? referenceId,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return TechnicianNotificationModel(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      referenceType: referenceType ?? this.referenceType,
      referenceId: referenceId ?? this.referenceId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }

  /// Phân loại thông báo vào tab dựa vào `reference_type`
  TechnicianNotificationCategory get category {
    final ref = referenceType.trim().toUpperCase();
    if (ref.isEmpty) {
      return TechnicianNotificationCategory.system;
    }

    const walletKeywords = [
      'WALLET',
      'INCOME',
      'PAYMENT',
      'PAYOUT',
      'TRANSACTION',
      'EARNING',
      'WITHDRAW',
      'COMMISSION',
      'SETTLEMENT',
    ];
    for (final keyword in walletKeywords) {
      if (ref.contains(keyword)) {
        return TechnicianNotificationCategory.incomeWallet;
      }
    }

    const orderKeywords = [
      'ORDER',
      'REPAIR',
      'BOOKING',
      'QUOTE',
      'JOB',
      'WARRANTY',
      'REVIEW',
      'RATING',
      'CHAT',
      'MESSAGE',
      'SERVICE',
    ];
    for (final keyword in orderKeywords) {
      if (ref.contains(keyword)) {
        return TechnicianNotificationCategory.orders;
      }
    }

    return TechnicianNotificationCategory.system;
  }

  bool get isOrderReference {
    final ref = referenceType.trim().toUpperCase();
    return ref.contains('ORDER') ||
        ref.contains('BOOKING') ||
        ref.contains('REPAIR') ||
        ref.contains('JOB') ||
        ref.contains('QUOTE');
  }

  bool get isProfileVerification {
    final ref = referenceType.trim().toUpperCase();
    final t = type.trim().toUpperCase();
    return ref.contains('PROFILE') ||
        ref.contains('VERIF') ||
        ref.contains('DOCUMENT') ||
        ref.contains('KYC') ||
        ref.contains('CERTIFICATE') ||
        t.contains('PROFILE') ||
        t.contains('VERIF');
  }

  bool get isReviewNotification {
    final ref = referenceType.trim().toUpperCase();
    final t = type.trim().toUpperCase();
    return ref.contains('REVIEW') ||
        ref.contains('RATING') ||
        t.contains('REVIEW') ||
        t.contains('RATING');
  }
}

class TechnicianNotificationPageResponse {
  final List<TechnicianNotificationModel> content;
  final int page;
  final int pageSize;
  final int totalElements;
  final int totalPages;
  final bool isFirst;
  final bool isLast;

  const TechnicianNotificationPageResponse({
    required this.content,
    required this.page,
    required this.pageSize,
    required this.totalElements,
    required this.totalPages,
    required this.isFirst,
    required this.isLast,
  });

  factory TechnicianNotificationPageResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawList = json['content'] as List<dynamic>? ?? [];
    return TechnicianNotificationPageResponse(
      content: rawList
          .whereType<Map<String, dynamic>>()
          .map(TechnicianNotificationModel.fromJson)
          .toList(),
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['page_size'] as num?)?.toInt() ?? 20,
      totalElements: (json['total_elements'] as num?)?.toInt() ?? 0,
      totalPages: (json['total_pages'] as num?)?.toInt() ?? 1,
      isFirst: json['is_first'] == true,
      isLast: json['is_last'] != false,
    );
  }
}
