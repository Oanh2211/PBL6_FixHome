class TechnicianSubmitQuoteItemModel {
  final int quantity;
  final String itemName;
  final String itemType;
  final int minUnitPrice;
  final int maxUnitPrice;

  const TechnicianSubmitQuoteItemModel({
    required this.quantity,
    required this.itemName,
    required this.itemType,
    required this.minUnitPrice,
    required this.maxUnitPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'quantity': quantity,
      'item_name': itemName,
      'item_type': itemType,
      'min_unit_price': minUnitPrice,
      'max_unit_price': maxUnitPrice,
    };
  }
}

class TechnicianSubmitQuoteRequestModel {
  final String note;
  final List<TechnicianSubmitQuoteItemModel> items;
  final int estimatedMinAmount;
  final int estimatedMaxAmount;
  final int warrantyDurationDays;

  const TechnicianSubmitQuoteRequestModel({
    required this.note,
    required this.items,
    required this.estimatedMinAmount,
    required this.estimatedMaxAmount,
    required this.warrantyDurationDays,
  });

  Map<String, dynamic> toJson() {
    return {
      'note': note,
      'items': items.map((item) => item.toJson()).toList(),
      'estimated_min_amount': estimatedMinAmount,
      'estimated_max_amount': estimatedMaxAmount,
      'warranty_duration_days': warrantyDurationDays,
    };
  }
}
