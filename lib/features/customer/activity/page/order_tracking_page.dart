import 'package:easy_localization/easy_localization.dart';
import 'package:fixhome/common/constants/app_color.dart';
import 'package:fixhome/features/customer/activity/api/activity_api_service.dart';
import 'package:fixhome/features/customer/activity/page/quote_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/order_tracking_cubit.dart';
import '../cubit/order_tracking_state.dart';

class OrderTrackingPage extends StatelessWidget {
  final int orderId;

  const OrderTrackingPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          OrderTrackingCubit(ActivityApiService())..fetchOrderDetail(orderId),
      child: _OrderTrackingView(orderId: orderId),
    );
  }
}

class _OrderTrackingView extends StatelessWidget {
  final int orderId;

  const _OrderTrackingView({required this.orderId});

  int _getCurrentStepIndex(String status) {
    switch (status.toUpperCase()) {
      case 'TECHNICIAN_SELECTED':
        return 1;
      case 'TRAVELLING':
        return 2;
      case 'ARRIVED':
      case 'REPAIRING':
        return 3;
      case 'PENDING_ACCEPTANCE':
        // Đã xong bước 4 (KTV chốt giá) -> chuyển sang bước 5 (bước cuối chờ KH xác nhận)
        return 5;
      case 'COMPLETED':
        // Đã hoàn tất cả 5 bước
        return 6;
      default:
        return 1;
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrderTrackingCubit, OrderTrackingState>(
      listener: (context, state) {
        if (state is OrderTrackingLoaded) {
          if (state.actionError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.actionError!),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state.isConfirmSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'customer.activity.tracking.confirm_success'.tr(),
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      },
      builder: (context, state) {
        final isPendingAcceptance =
            state is OrderTrackingLoaded &&
            state.order.status.toUpperCase() == 'PENDING_ACCEPTANCE';

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
              'customer.activity.tracking.title'.tr(),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          bottomNavigationBar: isPendingAcceptance
              ? SafeArea(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border(top: BorderSide(color: AppColors.border)),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: state.isConfirming
                            ? null
                            : () => context
                                  .read<OrderTrackingCubit>()
                                  .confirmCompletion(orderId),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: state.isConfirming
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'customer.activity.tracking.confirm_completion'
                                    .tr(),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ),
                )
              : null,
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, OrderTrackingState state) {
    if (state is OrderTrackingLoading || state is OrderTrackingInitial) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state is OrderTrackingError) {
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
                onPressed: () => context
                    .read<OrderTrackingCubit>()
                    .fetchOrderDetail(orderId),
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

    if (state is OrderTrackingLoaded) {
      final order = state.order;
      final quote = order.matchedQuote;
      final tech = quote?.technician;
      final currentStep = _getCurrentStepIndex(order.status);

      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () =>
            context.read<OrderTrackingCubit>().fetchOrderDetail(orderId),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Card Thông tin KTV
              if (tech != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: AppColors.surfaceMuted,
                            backgroundImage:
                                (tech.avatarUrl != null &&
                                    tech.avatarUrl!.startsWith('http'))
                                ? NetworkImage(tech.avatarUrl!)
                                : null,
                            child:
                                (tech.avatarUrl == null ||
                                    !tech.avatarUrl!.startsWith('http'))
                                ? const Icon(
                                    Icons.person,
                                    color: AppColors.primary,
                                    size: 28,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tech.fullName,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      color: Color(0xFFF59E0B),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${tech.averageRating.toStringAsFixed(1)} (${tech.completedOrderCount})',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: const Icon(Icons.phone_outlined, size: 18),
                              label: Text(
                                'customer.activity.tracking.call'.tr(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryLight
                                    .withValues(alpha: 0.12),
                                foregroundColor: AppColors.primary,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: const Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 18,
                              ),
                              label: Text(
                                'customer.activity.tracking.message'.tr(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // 2. Card Theo dõi KTV trên đường
              Container(
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
                      'customer.activity.tracking.track_tech_on_way'.tr(),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 140,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.map_rounded,
                            size: 56,
                            color: AppColors.primaryLight.withValues(
                              alpha: 0.35,
                            ),
                          ),
                          Positioned(
                            top: 24,
                            left: 24,
                            right: 24,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.textPrimary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  order.address,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                          if (quote != null)
                            Positioned(
                              bottom: 20,
                              left: 24,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEA580C),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${quote.distanceKm.toStringAsFixed(1)} km',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 3. Card Tiến trình phục vụ (5 bước)
              Container(
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
                      'customer.activity.tracking.service_progress'.tr(),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStepItem(
                      stepNumber: 1,
                      currentStep: currentStep,
                      title: 'customer.activity.tracking.step_1_title'.tr(),
                      subtitle: 'customer.activity.tracking.step_1_sub'.tr(
                        args: [order.orderCode],
                      ),
                      isLast: false,
                    ),
                    _buildStepItem(
                      stepNumber: 2,
                      currentStep: currentStep,
                      title: 'customer.activity.tracking.step_2_title'.tr(),
                      subtitle: 'customer.activity.tracking.step_2_sub'.tr(
                        args: [order.address],
                      ),
                      isLast: false,
                    ),
                    _buildStepItem(
                      stepNumber: 3,
                      currentStep: currentStep,
                      title: 'customer.activity.tracking.step_3_title'.tr(),
                      subtitle: 'customer.activity.tracking.step_3_sub'.tr(),
                      isLast: false,
                    ),
                    _buildStepItem(
                      stepNumber: 4,
                      currentStep: currentStep,
                      title: 'customer.activity.tracking.step_4_title'.tr(),
                      subtitle: 'customer.activity.tracking.step_4_sub'.tr(),
                      isLast: false,
                    ),
                    _buildStepItem(
                      stepNumber: 5,
                      currentStep: currentStep,
                      title: 'customer.activity.tracking.step_5_title'.tr(),
                      subtitle: 'customer.activity.tracking.step_5_sub'.tr(),
                      isLast: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 4. Card Thiết bị & Chi tiết giá
              GestureDetector(
                onTap: quote != null
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QuoteDetailPage(
                              order: order,
                              quoteId: quote.quoteId,
                            ),
                          ),
                        );
                      }
                    : null,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                    '${'customer.activity.tracking.symptom_prefix'.tr()} : ${order.issueDescription}',
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
                      if (quote != null) ...[
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'customer.activity.tracking.estimated_price_detail'
                                  .tr(),
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                          ],
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
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        if (quote.discountAmount > 0) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'customer.activity.tracking.customer_discount'
                                    .tr(),
                                style: const TextStyle(
                                  color: Color(0xFFD97706),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '-${_formatCurrency(quote.discountAmount)}',
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildStepItem({
    required int stepNumber,
    required int currentStep,
    required String title,
    required String subtitle,
    required bool isLast,
  }) {
    final isCompleted = stepNumber < currentStep;
    final isActive = stepNumber == currentStep;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: (isCompleted || isActive)
                      ? AppColors.primary
                      : AppColors.surfaceMuted,
                  shape: BoxShape.circle,
                  border: isActive
                      ? Border.all(color: const Color(0xFFFDBA74), width: 2.5)
                      : null,
                ),
                alignment: Alignment.center,
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 14)
                    : Text(
                        '$stepNumber',
                        style: TextStyle(
                          color: isActive
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isCompleted ? AppColors.primary : AppColors.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Container(
                padding: isActive ? const EdgeInsets.all(12) : EdgeInsets.zero,
                decoration: isActive
                    ? BoxDecoration(
                        color: AppColors.primaryLight.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      )
                    : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isActive
                            ? AppColors.primary
                            : (isCompleted
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary),
                        fontWeight: (isActive || isCompleted)
                            ? FontWeight.w700
                            : FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
