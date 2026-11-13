import 'package:fixhome/features/technician/home/quote/api/technician_quote_api.dart';
import 'package:fixhome/features/technician/home/quote/cubit/technician_quote_cubit.dart';
import 'package:fixhome/features/technician/home/quote/cubit/technician_quote_state.dart';
import 'package:fixhome/features/technician/home/quote/page/technician_quote_detail_page.dart';
import 'package:fixhome/features/technician/home/quote/page/technician_quotes_page.dart';
import 'package:fixhome/features/technician/home/quote/page/widget/quote_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:fixhome/common/constants/app_color.dart';

class NewQuotesSection extends StatelessWidget {
  const NewQuotesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          TechnicianQuoteCubit(api: TechnicianQuoteApi())..getQuotes(),
      child: const _NewQuotesContent(),
    );
  }
}

class _NewQuotesContent extends StatelessWidget {
  const _NewQuotesContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TechnicianQuoteCubit, TechnicianQuoteState>(
      builder: (context, state) {
        // Đang tải dữ liệu
        if (state is TechnicianQuoteInitial ||
            state is TechnicianQuoteLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            ),
          );
        }

        // Tài khoản chưa được duyệt hoặc đang bị khóa
        if (state is TechnicianQuoteAccountNotApproved) {
          return _buildAccountNotApproved();
        }

        // Lỗi API thông thường
        if (state is TechnicianQuoteError) {
          return _buildError(context, state.message);
        }

        // Đã tải dữ liệu
        if (state is TechnicianQuoteLoaded) {
          final quotes = state.quotes;

          // Không có yêu cầu
          if (quotes.isEmpty) {
            return _buildEmpty();
          }

          // Có yêu cầu
          return _buildQuoteList(context, quotes);
        }

        return const SizedBox.shrink();
      },
    );
  }

  // =====================================================
  // EMPTY STATE
  // =====================================================

  Widget _buildEmpty() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.assignment_outlined,
            size: 35,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 9),
          Text(
            'technician.quotes.empty'.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'technician.quotes.empty_description'.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // ERROR
  // =====================================================
  Widget _buildAccountNotApproved() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.lock_outline_rounded,
            color: Color(0xFFF59E0B),
            size: 35,
          ),

          const SizedBox(height: 10),

          Text(
            'technician.quotes.account_not_approved_title'.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'technician.quotes.account_not_approved_message'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 30),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11),
          ),
          TextButton(
            onPressed: () {
              context.read<TechnicianQuoteCubit>().getQuotes();
            },
            child: Text('common.retry'.tr()),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // QUOTE LIST
  // =====================================================

  Widget _buildQuoteList(BuildContext context, List quotes) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'technician.quotes.new_requests'.tr(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TechnicianQuotesPage(),
                    ),
                  );
                },
                child: Text(
                  'technician.quotes.view_all'.tr(),
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          ...quotes
              .take(3)
              .map(
                (quote) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: QuoteCard(
                    quote: quote,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              TechnicianQuoteDetailPage(quoteId: quote.quoteId),
                        ),
                      );
                    },
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
