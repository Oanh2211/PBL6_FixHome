import 'package:easy_localization/easy_localization.dart';
import 'package:fixhome/features/customer/home/find_technician/model/quote_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fixhome/common/constants/app_color.dart';
import '../cubit/find_technician_cubit.dart';
import '../cubit/find_technician_state.dart';

class SelectVoucherPage extends StatefulWidget {
  final int quoteId;
  final String? currentVoucherCode;

  const SelectVoucherPage({
    super.key,
    required this.quoteId,
    this.currentVoucherCode,
  });

  @override
  State<SelectVoucherPage> createState() => _SelectVoucherPageState();
}

class _SelectVoucherPageState extends State<SelectVoucherPage> {
  final TextEditingController _codeController = TextEditingController();
  String? _selectedCode;

  @override
  void initState() {
    super.initState();
    _selectedCode = widget.currentVoucherCode;
    context.read<FindTechnicianCubit>().loadApplicableVouchers(widget.quoteId);
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
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
        final eligibleVouchers = state.vouchers
            .where((v) => v.eligible)
            .toList();
        final ineligibleVouchers = state.vouchers
            .where((v) => !v.eligible)
            .toList();

        TechnicianQuoteModel? currentQuote;
        if (state.selectedQuoteDetail?.quoteId == widget.quoteId) {
          currentQuote = state.selectedQuoteDetail;
        } else {
          for (final q in state.quotes) {
            if (q.quoteId == widget.quoteId) {
              currentQuote = q;
              break;
            }
          }
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            title: Text(
              'customer.find_technician.select_voucher_title'.tr(),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: state.isLoadingVouchers
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : Column(
                  children: [
                    Container(
                      color: AppColors.surface,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _codeController,
                              decoration: InputDecoration(
                                hintText:
                                    'customer.find_technician.enter_voucher_hint'
                                        .tr(),
                                hintStyle: const TextStyle(
                                  color: AppColors.textHint,
                                  fontSize: 13,
                                ),
                                prefixIcon: const Icon(
                                  Icons.confirmation_number_outlined,
                                  color: AppColors.textSecondary,
                                  size: 20,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                filled: true,
                                fillColor: AppColors.background,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: AppColors.border,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: AppColors.border,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () async {
                              final code = _codeController.text.trim();
                              if (code.isEmpty) return;
                              final ok = await cubit.applyVoucher(
                                widget.quoteId,
                                code,
                              );
                              if (ok && context.mounted) {
                                Navigator.of(context).pop();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 13,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'customer.find_technician.apply'.tr(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.account_balance_wallet_outlined,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'customer.find_technician.your_voucher_wallet'
                                      .tr(),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            ...eligibleVouchers.map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildVoucherCard(item, currentQuote),
                              ),
                            ),

                            if (ineligibleVouchers.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.lock_outline,
                                    size: 15,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'customer.find_technician.ineligible_vouchers'
                                        .tr(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ...ineligibleVouchers.map(
                                (item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildVoucherCard(item, currentQuote),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: state.status == FindTechStatus.submitting
                    ? null
                    : () async {
                        final ok = await cubit.applyVoucher(
                          widget.quoteId,
                          _selectedCode,
                        );
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
                child: Text(
                  'customer.find_technician.apply_now'.tr(),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  int _calculateVoucherPercent(
    ApplicableVoucherModel item,
    TechnicianQuoteModel? quote,
  ) {
    if (item.voucher.discountType == 'PERCENTAGE') {
      return item.voucher.discountValue.round();
    }
    if (quote == null) return 0;
    final avgEstimated =
        (quote.estimatedMinAmount + quote.estimatedMaxAmount) / 2;
    if (avgEstimated <= 0) return 0;

    final avgDiscount = (item.discountMinAmount + item.discountMaxAmount) / 2;
    final effectiveDiscount = avgDiscount > 0
        ? avgDiscount
        : item.voucher.discountValue;

    return ((effectiveDiscount / avgEstimated) * 100).round();
  }

  Widget _buildVoucherCard(
    ApplicableVoucherModel item,
    TechnicianQuoteModel? currentQuote,
  ) {
    final isSelected = _selectedCode == item.voucher.code;
    final isEligible = item.eligible;
    final percent = _calculateVoucherPercent(item, currentQuote);

    final titleText = item.voucher.discountType == 'PERCENTAGE'
        ? 'customer.find_technician.discount_percent'.tr(
            args: ['${item.voucher.discountValue.round()}'],
          )
        : percent > 0
        ? '${'customer.find_technician.discount_percent'.tr(args: ['$percent'])} (${_formatCurrency(item.voucher.discountValue)})'
        : 'customer.find_technician.discount_amount'.tr(
            args: [_formatCurrency(item.voucher.discountValue)],
          );

    return InkWell(
      onTap: !isEligible
          ? null
          : () {
              setState(() {
                if (_selectedCode == item.voucher.code) {
                  _selectedCode = null;
                } else {
                  _selectedCode = item.voucher.code;
                }
              });
            },
      borderRadius: BorderRadius.circular(14),
      child: Opacity(
        opacity: isEligible ? 1.0 : 0.6,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Radio<String>(
                value: item.voucher.code,
                groupValue: _selectedCode,
                activeColor: AppColors.primary,
                onChanged: !isEligible
                    ? null
                    : (val) {
                        setState(() => _selectedCode = val);
                      },
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            titleText,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (item.bestChoice)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEDD5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'customer.find_technician.best_choice'.tr(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFEA580C),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.voucher.name,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (!isEligible &&
                        item.ineligibleReason != null &&
                        item.ineligibleReason!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              size: 14,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                item.ineligibleReason!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
