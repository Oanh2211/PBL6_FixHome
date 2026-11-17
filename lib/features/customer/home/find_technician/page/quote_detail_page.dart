import 'package:easy_localization/easy_localization.dart';
import 'package:fixhome/features/customer/home/find_technician/model/quote_models.dart';
import 'package:fixhome/features/customer/home/find_technician/page/select_voucher_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fixhome/common/constants/app_color.dart';
import '../cubit/find_technician_cubit.dart';
import '../cubit/find_technician_state.dart';

class QuoteDetailPage extends StatefulWidget {
  final TechnicianQuoteModel quote;

  const QuoteDetailPage({super.key, required this.quote});

  @override
  State<QuoteDetailPage> createState() => _QuoteDetailPageState();
}

class _QuoteDetailPageState extends State<QuoteDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<FindTechnicianCubit>().loadQuoteDetail(widget.quote.quoteId);
  }

  String _formatCurrency(num amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount).replaceAll(',', '.')}đ';
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<FindTechnicianCubit>();

    return BlocBuilder<FindTechnicianCubit, FindTechnicianState>(
      builder: (context, state) {
        final detail =
            state.selectedQuoteDetail?.quoteId == widget.quote.quoteId
            ? state.selectedQuoteDetail!
            : widget.quote;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            title: Text(
              'customer.find_technician.quote_detail_title'.tr(),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: state.isLoadingDetail
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                              'customer.find_technician.payment_structure'.tr(),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 14),

                            if (detail.items.isNotEmpty) ...[
                              ...detail.items.map(
                                (item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${item.itemName} (x${item.quantity})',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${_formatCurrency(item.minUnitPrice)} - ${_formatCurrency(item.maxUnitPrice)}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Divider(
                                height: 20,
                                color: AppColors.border,
                              ),
                            ],

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'customer.find_technician.total_cost'.tr(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  '${_formatCurrency(detail.estimatedMinAmount)} - ${_formatCurrency(detail.estimatedMaxAmount)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            Container(
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
                                  const Icon(
                                    Icons.local_offer_outlined,
                                    size: 16,
                                    color: Color(0xFFEA580C),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: detail.voucher != null
                                        ? RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text:
                                                      '${detail.voucher!.code} ',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    color:
                                                        AppColors.textPrimary,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text:
                                                      '-${_formatCurrency(detail.discountAmount > 0 ? detail.discountAmount : detail.discountMinAmount)}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFFEA580C),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : Text(
                                            'customer.find_technician.select_code'
                                                .tr(),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => BlocProvider.value(
                                            value: cubit,
                                            child: SelectVoucherPage(
                                              quoteId: detail.quoteId,
                                              currentVoucherCode:
                                                  detail.voucher?.code,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      detail.voucher != null
                                          ? 'customer.find_technician.change_code'
                                                .tr()
                                          : 'customer.find_technician.select_code'
                                                .tr(),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 24, color: AppColors.border),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'customer.find_technician.final_total_cost'
                                      .tr(),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  '${_formatCurrency(detail.payableMinAmount)} - ${_formatCurrency(detail.payableMaxAmount)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (detail.warrantyDurationDays > 0 ||
                          (detail.note != null && detail.note!.isNotEmpty))
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'customer.find_technician.warranty_label'
                                        .tr(),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    'customer.find_technician.warranty_days'.tr(
                                      args: ['${detail.warrantyDurationDays}'],
                                    ),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.success,
                                    ),
                                  ),
                                ],
                              ),
                              if (detail.note != null &&
                                  detail.note!.isNotEmpty) ...[
                                const Divider(
                                  height: 20,
                                  color: AppColors.border,
                                ),
                                Text(
                                  'customer.find_technician.tech_note'.tr(),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  detail.note!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: state.status == FindTechStatus.submitting
                    ? null
                    : () async {
                        final ok = await cubit.selectTechnician(detail.quoteId);
                        if (ok && context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'customer.find_technician.select_this_tech'.tr(),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
