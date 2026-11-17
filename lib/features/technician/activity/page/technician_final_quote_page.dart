import 'package:easy_localization/easy_localization.dart';
import 'package:fixhome/common/constants/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/technician_order_detail_cubit.dart';
import '../model/technician_order_model.dart';

class _PartItemUI {
  final String name;
  final double price;
  _PartItemUI({required this.name, required this.price});
}

class TechnicianFinalQuotePage extends StatefulWidget {
  final TechnicianOrderModel order;

  const TechnicianFinalQuotePage({super.key, required this.order});

  @override
  State<TechnicianFinalQuotePage> createState() =>
      _TechnicianFinalQuotePageState();
}

class _TechnicianFinalQuotePageState extends State<TechnicianFinalQuotePage> {
  final TextEditingController _laborDescController = TextEditingController();
  final TextEditingController _laborPriceController = TextEditingController();
  final TextEditingController _warrantyDaysController = TextEditingController(
    text: '30',
  );

  final List<_PartItemUI> _parts = [];
  final _currencyFormat = NumberFormat('#,###', 'vi_VN');

  double get _laborAmount =>
      double.tryParse(_laborPriceController.text.replaceAll(',', '').trim()) ??
      0;

  double get _partsTotal => _parts.fold(0, (sum, item) => sum + item.price);

  double get _grandTotal => _laborAmount + _partsTotal;

  int get _warrantyDays =>
      int.tryParse(_warrantyDaysController.text.trim()) ?? 30;

  @override
  void dispose() {
    _laborDescController.dispose();
    _laborPriceController.dispose();
    _warrantyDaysController.dispose();
    super.dispose();
  }

  void _showAddPartDialog() {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'technician.activity.final_quote.add_part_modal_title'.tr(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '• ${'technician.activity.final_quote.part_name_label'.tr()}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                hintText: 'technician.activity.final_quote.part_name_hint'.tr(),
                filled: true,
                fillColor: AppColors.surfaceMuted,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              '• ${'technician.activity.final_quote.part_price_label'.tr()}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'technician.activity.final_quote.part_price_hint'
                    .tr(),
                suffixText: 'đ',
                filled: true,
                fillColor: AppColors.surfaceMuted,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                final price =
                    double.tryParse(
                      priceCtrl.text.replaceAll(',', '').trim(),
                    ) ??
                    0;
                if (name.isNotEmpty && price > 0) {
                  setState(() {
                    _parts.add(_PartItemUI(name: name, price: price));
                  });
                  Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'technician.activity.final_quote.add_btn'.tr(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onSubmitFinalQuote() async {
    final laborDesc = _laborDescController.text.trim();
    if (laborDesc.isEmpty || _laborAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'technician.activity.final_quote.validation_empty_labor'.tr(),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Build items chuẩn theo request body của PUT /technician/repair-orders/{orderId}/quote
    final items = <FinalQuoteItemModel>[
      FinalQuoteItemModel(
        quantity: 1,
        itemName: laborDesc,
        itemType: 'LABOR',
        minUnitPrice: _laborAmount,
        maxUnitPrice: _laborAmount,
      ),
      ..._parts.map(
        (p) => FinalQuoteItemModel(
          quantity: 1,
          itemName: p.name,
          itemType: 'PART',
          minUnitPrice: p.price,
          maxUnitPrice: p.price,
        ),
      ),
    ];

    final request = FinalQuoteRequestModel(
      note: laborDesc,
      items: items,
      estimatedMinAmount: _grandTotal,
      estimatedMaxAmount: _grandTotal,
      warrantyDurationDays: _warrantyDays,
    );

    final success = await context
        .read<TechnicianOrderDetailCubit>()
        .submitFinalQuote(request);
    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final endWarranty = now.add(Duration(days: _warrantyDays));
    final dateRangeStr =
        '${DateFormat('dd/MM/yyyy').format(now)} → ${DateFormat('dd/MM/yyyy').format(endWarranty)}';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'technician.activity.final_quote.title'.tr(),
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Card 1: Tiền công & Linh kiện
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ${'technician.activity.final_quote.labor_section'.tr()}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _laborDescController,
                    decoration: InputDecoration(
                      hintText:
                          'technician.activity.final_quote.labor_desc_hint'
                              .tr(),
                      filled: true,
                      fillColor: AppColors.surfaceMuted,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _laborPriceController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText:
                          'technician.activity.final_quote.labor_price_hint'
                              .tr(),
                      suffixText: 'đ',
                      filled: true,
                      fillColor: AppColors.surfaceMuted,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    '• ${'technician.activity.final_quote.parts_section'.tr()}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Danh sách linh kiện đã thêm
                  ...List.generate(_parts.length, (index) {
                    final part = _parts[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              part.name,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Text(
                            '${_currencyFormat.format(part.price)} đ',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => setState(() => _parts.removeAt(index)),
                            child: const Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  // Nút thêm linh kiện
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _showAddPartDialog,
                      icon: const Icon(
                        Icons.add_circle_outline,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      label: Text(
                        'technician.activity.final_quote.add_part_btn'.tr(),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.06,
                        ),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Card 2: Thiết lập Thời hạn Bảo hành
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'technician.activity.final_quote.warranty_section'.tr(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'technician.activity.final_quote.warranty_select_label'
                        .tr(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _warrantyDaysController,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                          decoration: InputDecoration(
                            suffixIcon: const Icon(
                              Icons.edit,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            filled: true,
                            fillColor: AppColors.primary.withValues(
                              alpha: 0.08,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'technician.activity.final_quote.warranty_unit_day'
                              .tr(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.event_available,
                          size: 18,
                          color: AppColors.primaryDark,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'technician.activity.final_quote.warranty_effective'
                                  .tr(),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              dateRangeStr,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Card 3: Cơ cấu thanh toán minh bạch
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'technician.activity.final_quote.payment_summary'.tr(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'technician.activity.final_quote.labor_cost_label'.tr(),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${_currencyFormat.format(_laborAmount)} đ',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'technician.activity.final_quote.parts_cost_label'.tr(
                          args: ['${_parts.length}'],
                        ),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${_currencyFormat.format(_partsTotal)} đ',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Text(
                    'technician.activity.final_quote.total_quote_label'.tr(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_currencyFormat.format(_grandTotal)}đ',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 14),
                  BlocBuilder<
                    TechnicianOrderDetailCubit,
                    TechnicianOrderDetailState
                  >(
                    builder: (context, state) {
                      final isSubmitting =
                          state is OrderDetailLoaded && state.isUpdating;
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: isSubmitting ? null : _onSubmitFinalQuote,
                          icon: isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 18,
                                ),
                          label: Text(
                            'technician.activity.final_quote.submit_btn'.tr(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryDark,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
