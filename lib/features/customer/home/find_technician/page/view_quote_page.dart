import 'package:easy_localization/easy_localization.dart';
import 'package:fixhome/features/customer/home/find_technician/model/quote_models.dart';
import 'package:fixhome/features/customer/home/find_technician/model/repair_order_model.dart';
import 'package:fixhome/features/customer/home/find_technician/page/quote_detail_page.dart';
import 'package:fixhome/features/customer/main/page/customer_main_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fixhome/common/constants/app_color.dart';
import '../cubit/find_technician_cubit.dart';
import '../cubit/find_technician_state.dart';

class ViewQuotePage extends StatelessWidget {
  final int orderId;

  const ViewQuotePage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FindTechnicianCubit(orderId: orderId)..init(),
      child: const _ViewQuoteBody(),
    );
  }
}

class _ViewQuoteBody extends StatelessWidget {
  const _ViewQuoteBody();

  String _formatCurrency(num amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount).replaceAll(',', '.')}đ';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FindTechnicianCubit, FindTechnicianState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          final error = state.errorMessage!;
          final message = error.startsWith('customer.find_technician.')
              ? error.tr()
              : error;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: AppColors.error),
          );
        }

        // HỦY ĐƠN THÀNH CÔNG
        if (state.isCancelled) {
          _goToHomePage(context);
          return;
        }

        // CHỌN THỢ THÀNH CÔNG
        if (state.selectedResult != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'customer.find_technician.select_tech_success'.tr(
                  args: [state.selectedResult!.orderCode],
                ),
              ),
              backgroundColor: AppColors.success,
            ),
          );

          _goToHomePage(context);
          return;
        }
      },
      builder: (context, state) {
        final cubit = context.read<FindTechnicianCubit>();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,

            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const MainCustomerPage(initialIndex: 1),
                  ),
                  (route) => route.isFirst,
                );
              },
            ),

            title: Text(
              'customer.find_technician.title'.tr(),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            centerTitle: false,
          ),
          body: state.status == FindTechStatus.loading && state.order == null
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: cubit.refreshQuotes,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTopOrderChips(context, state),
                        const SizedBox(height: 12),

                        if (state.isOrderDetailExpanded &&
                            state.order != null) ...[
                          _buildExpandedOrderDetailCard(state.order!),
                          const SizedBox(height: 20),
                        ] else ...[
                          if (state.quotes.isEmpty) ...[
                            _buildBroadcastingBanner(state.quotes.length),
                            const SizedBox(height: 12),
                          ],

                          if (state.order != null) ...[
                            _buildCompactIssueCard(state.order!),
                            const SizedBox(height: 20),
                          ],

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'customer.find_technician.competitive_quotes'
                                    .tr(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (state.quotes.isNotEmpty)
                                ElevatedButton(
                                  onPressed: cubit.refreshQuotes,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    'customer.find_technician.add_tech_option'
                                        .tr(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          if (state.quotes.isEmpty)
                            const SizedBox(height: 120)
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: state.quotes.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final quote = state.quotes[index];
                                return _buildTechnicianQuoteCard(
                                  context,
                                  quote,
                                );
                              },
                            ),
                        ],

                        const SizedBox(height: 28),

                        if (state.selectedResult == null)
                          _buildCancelSection(context, state),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  void _goToHomePage(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainCustomerPage()),
      (route) => false,
    );
  }

  Widget _buildTopOrderChips(BuildContext context, FindTechnicianState state) {
    final code = state.order?.orderCode ?? '...';
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '#$code',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: () => context.read<FindTechnicianCubit>().toggleOrderDetail(),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: state.isOrderDetailExpanded
                  ? AppColors.primary
                  : AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text(
                  'customer.find_technician.order_detail'.tr(),
                  style: TextStyle(
                    color: state.isOrderDetailExpanded
                        ? Colors.white
                        : AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  state.isOrderDetailExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.chevron_right,
                  size: 16,
                  color: state.isOrderDetailExpanded
                      ? Colors.white
                      : AppColors.primary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBroadcastingBanner(int quoteCount) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.radar, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'customer.find_technician.broadcasting_signal'.tr(),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'customer.find_technician.radius_and_quotes'.tr(
                    args: ['5.0', '$quoteCount'],
                  ),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactIssueCard(RepairOrderModel order) {
    return Container(
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
            'customer.find_technician.reported_issue'.tr(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.build_circle_outlined,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.issueDescription,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            order.address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedOrderDetailCard(RepairOrderModel order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_long,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'customer.find_technician.order_detail'.tr(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: AppColors.border),
          _buildDetailRow(
            icon: Icons.warning_amber_rounded,
            label: 'customer.find_technician.issue_description'.tr(),
            value: order.issueDescription,
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            icon: Icons.access_time_filled,
            label: 'customer.find_technician.scheduled_time'.tr(),
            value: order.scheduledAt != null
                ? DateFormat('HH:mm - dd/MM/yyyy').format(order.scheduledAt!)
                : 'customer.find_technician.right_now'.tr(),
            valueColor: AppColors.primary,
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            icon: Icons.location_on,
            label: 'customer.find_technician.repair_address'.tr(),
            value: order.address,
            subValue: order.customerNote,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    String? subValue,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: valueColor ?? AppColors.textPrimary,
                ),
              ),
              if (subValue != null && subValue.isNotEmpty) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    subValue,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  int _calculateDiscountPercent(TechnicianQuoteModel quote) {
    final avgEstimated =
        (quote.estimatedMinAmount + quote.estimatedMaxAmount) / 2;
    if (avgEstimated <= 0) return 0;

    final effectiveDiscount = quote.discountAmount > 0
        ? quote.discountAmount
        : (quote.discountMinAmount + quote.discountMaxAmount) / 2;

    if (effectiveDiscount <= 0) return 0;
    return ((effectiveDiscount / avgEstimated) * 100).round();
  }

  Widget _buildTechnicianQuoteCard(
    BuildContext context,
    TechnicianQuoteModel quote,
  ) {
    final cubit = context.read<FindTechnicianCubit>();
    final hasDiscount = quote.discountAmount > 0 || quote.discountMinAmount > 0;
    final discountPercent = _calculateDiscountPercent(quote);
    final saveText = quote.discountAmount > 0
        ? _formatCurrency(quote.discountAmount)
        : _formatCurrency(quote.discountMinAmount);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Khoảng cách
          Row(
            children: [
              const Icon(
                Icons.near_me,
                size: 13,
                color: AppColors.primaryLight,
              ),
              const SizedBox(width: 4),
              Text(
                'customer.find_technician.distance_km'.tr(
                  args: [quote.distanceKm.toStringAsFixed(1)],
                ),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 2. Thông tin thợ & Số lượng đơn thành công
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.surfaceMuted,
                backgroundImage:
                    (quote.technician.avatarUrl != null &&
                        quote.technician.avatarUrl!.isNotEmpty)
                    ? NetworkImage(quote.technician.avatarUrl!)
                    : null,
                child:
                    (quote.technician.avatarUrl == null ||
                        quote.technician.avatarUrl!.isEmpty)
                    ? const Icon(Icons.person, color: AppColors.primary)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quote.technician.fullName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 3),
                        Text(
                          quote.technician.averageRating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          ' • ${'customer.find_technician.completed_orders'.tr(args: ['${quote.technician.completedOrderCount}'])}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 3. Khoảng giá & Badge tính % discount
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'customer.find_technician.proposed_price_range'.tr(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (hasDiscount)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEDD5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          discountPercent > 0
                              ? '${'customer.find_technician.save_percent'.tr(args: ['$discountPercent'])} ($saveText)'
                              : 'customer.find_technician.save_amount'.tr(
                                  args: [saveText],
                                ),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFEA580C),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                if (hasDiscount)
                  Text(
                    '${_formatCurrency(quote.estimatedMinAmount)} - ${_formatCurrency(quote.estimatedMaxAmount)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textHint,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                const SizedBox(height: 2),
                Text(
                  '${_formatCurrency(quote.payableMinAmount)} - ${_formatCurrency(quote.payableMaxAmount)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Các nút hành động
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: cubit,
                          child: QuoteDetailPage(quote: quote),
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    backgroundColor: AppColors.surfaceMuted,
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'customer.find_technician.view_quote_detail'.tr(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => cubit.selectTechnician(quote.quoteId),
                  icon: const Icon(Icons.check_circle_outline, size: 16),
                  label: Text(
                    'customer.find_technician.select_this_tech'.tr(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 4. Số lượng đánh giá của thợ
          Center(
            child: InkWell(
              onTap: () {},
              child: Text(
                'customer.find_technician.view_profile_and_reviews'.tr(
                  args: ['${quote.technician.completedOrderCount}'],
                ),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelSection(BuildContext context, FindTechnicianState state) {
    return Column(
      children: [
        TextButton.icon(
          onPressed: state.status == FindTechStatus.submitting
              ? null
              : () => _showCancelDialog(context),
          icon: const Icon(
            Icons.cancel_outlined,
            color: AppColors.error,
            size: 18,
          ),
          label: Text(
            'customer.find_technician.cancel_request'.tr(),
            style: const TextStyle(
              color: AppColors.error,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'customer.find_technician.cancel_free_note'.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  void _showCancelDialog(BuildContext context) {
    final reasonController = TextEditingController();
    final cubit = context.read<FindTechnicianCubit>();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'customer.find_technician.confirm_cancel_title'.tr(),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          content: TextField(
            controller: reasonController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'customer.find_technician.cancel_reason_hint'.tr(),
              hintStyle: const TextStyle(
                color: AppColors.textHint,
                fontSize: 13,
              ),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: Text(
                'customer.find_technician.keep_order'.tr(),
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final reason = reasonController.text.trim().isEmpty
                    ? 'customer.find_technician.default_cancel_reason'.tr()
                    : reasonController.text.trim();
                Navigator.of(dialogCtx).pop();
                cubit.cancelOrder(reason);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: Text('customer.find_technician.confirm_cancel'.tr()),
            ),
          ],
        );
      },
    );
  }
}
