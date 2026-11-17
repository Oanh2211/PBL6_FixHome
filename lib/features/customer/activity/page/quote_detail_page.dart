import 'package:easy_localization/easy_localization.dart';
import 'package:fixhome/common/constants/app_color.dart';
import 'package:fixhome/features/customer/activity/api/activity_api_service.dart';
import 'package:fixhome/features/customer/activity/model/quote_model.dart';
import 'package:fixhome/features/customer/activity/model/repair_order_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/quote_detail_cubit.dart';
import '../cubit/quote_detail_state.dart';

class QuoteDetailPage extends StatelessWidget {
  final RepairOrderModel order;
  final int quoteId;

  const QuoteDetailPage({
    super.key,
    required this.order,
    required this.quoteId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          QuoteDetailCubit(ActivityApiService())
            ..fetchQuoteDetail(orderId: order.id, quoteId: quoteId),
      child: _QuoteDetailView(order: order, quoteId: quoteId),
    );
  }
}

class _QuoteDetailView extends StatelessWidget {
  final RepairOrderModel order;
  final int quoteId;

  const _QuoteDetailView({required this.order, required this.quoteId});

  String _formatCurrency(num amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount)}đ';
  }

  String _formatPriceRange(num minAmount, num maxAmount) {
    if (minAmount == maxAmount) {
      return _formatCurrency(minAmount);
    }
    return '${_formatCurrency(minAmount)} - ${_formatCurrency(maxAmount)}';
  }

  String _formatWarrantyRange(QuoteModel quote) {
    final startDate = (order.completedAt ?? quote.respondedAt ?? DateTime.now())
        .toLocal();
    final endDate = startDate.add(Duration(days: quote.warrantyDurationDays));
    final dateFormat = DateFormat('dd/MM/yyyy');
    return '${dateFormat.format(startDate)} → ${dateFormat.format(endDate)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'customer.activity.quote_detail.title'.tr(),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: BlocBuilder<QuoteDetailCubit, QuoteDetailState>(
        builder: (context, state) {
          if (state is QuoteDetailLoading || state is QuoteDetailInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is QuoteDetailError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.error),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<QuoteDetailCubit>().fetchQuoteDetail(
                            orderId: order.id,
                            quoteId: quoteId,
                          ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('common.retry'.tr()),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is QuoteDetailLoaded) {
            final quote = state.quote;

            // Tính ưu đãi hiển thị (ưu tiên discountMin/Max nếu có, fallback về discountAmount)
            final hasMinMaxDiscount =
                quote.discountMinAmount > 0 || quote.discountMaxAmount > 0;
            final discountText = hasMinMaxDiscount
                ? _formatPriceRange(
                    quote.discountMinAmount,
                    quote.discountMaxAmount,
                  )
                : _formatCurrency(quote.discountAmount);
            final showDiscount = quote.discountAmount > 0 || hasMinMaxDiscount;

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => context
                  .read<QuoteDetailCubit>()
                  .fetchQuoteDetail(orderId: order.id, quoteId: quoteId),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Card Thời hạn Bảo hành
                    if (quote.warrantyDurationDays > 0) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'customer.activity.quote_detail.warranty_period'
                                  .tr(),
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.event_available_outlined,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'customer.activity.quote_detail.warranty_valid_label'
                                              .tr(
                                                args: [
                                                  '${quote.warrantyDurationDays}',
                                                ],
                                              ),
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          _formatWarrantyRange(quote),
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 2. Card Thiết bị, Hạng mục chi tiết & Cơ cấu thanh toán minh bạch
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Box Thiết bị & Hiện tượng
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceMuted,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight.withValues(
                                      alpha: 0.15,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.home_repair_service_outlined,
                                    color: AppColors.primary,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        order.deviceTypeName ??
                                            order.categoryName ??
                                            '',
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${'customer.activity.tracking.symptom_prefix'.tr()}: ${order.issueDescription}',
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Danh sách các hạng mục báo giá (items) nếu API trả về
                          if (quote.items.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text(
                              'customer.activity.quote_detail.itemized_list'
                                  .tr(),
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...quote.items.map((item) {
                              final totalMin =
                                  item.minUnitPrice * item.quantity;
                              final totalMax =
                                  item.maxUnitPrice * item.quantity;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.itemName,
                                            style: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'x${item.quantity} • ${_formatPriceRange(item.minUnitPrice, item.maxUnitPrice)}',
                                            style: const TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _formatPriceRange(totalMin, totalMax),
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],

                          // Ghi chú của KTV nếu có
                          if (quote.note != null &&
                              quote.note!.trim().isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceMuted,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${'customer.activity.quote_detail.tech_note'.tr()}: ${quote.note}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 16),

                          // Cơ cấu thanh toán minh bạch
                          Text(
                            'customer.activity.quote_detail.payment_breakdown'
                                .tr(),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'customer.activity.tracking.total_cost'.tr(),
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                _formatPriceRange(
                                  quote.estimatedMinAmount,
                                  quote.estimatedMaxAmount,
                                ),
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          if (showDiscount) ...[
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    quote.voucher != null
                                        ? '${'customer.activity.tracking.customer_discount'.tr()} (${quote.voucher!.code})'
                                        : 'customer.activity.tracking.customer_discount'
                                              .tr(),
                                    style: const TextStyle(
                                      color: Color(0xFFD97706),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '-$discountText',
                                  style: const TextStyle(
                                    color: Color(0xFFD97706),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(color: AppColors.border, height: 1),
                          ),
                          Text(
                            'customer.activity.tracking.total_quote'.tr(),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatPriceRange(
                              quote.payableMinAmount,
                              quote.payableMaxAmount,
                            ),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
