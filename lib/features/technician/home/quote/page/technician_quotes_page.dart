import 'package:fixhome/features/technician/home/quote/page/technician_quote_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:fixhome/common/constants/app_color.dart';

import '../api/technician_quote_api.dart';
import '../cubit/technician_quote_cubit.dart';
import '../cubit/technician_quote_state.dart';
import '../model/technician_quote_model.dart';
import 'widget/quote_card.dart';

class TechnicianQuotesPage extends StatelessWidget {
  const TechnicianQuotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          TechnicianQuoteCubit(api: TechnicianQuoteApi())..getQuotes(),
      child: const _TechnicianQuotesView(),
    );
  }
}

class _TechnicianQuotesView extends StatefulWidget {
  const _TechnicianQuotesView();

  @override
  State<_TechnicianQuotesView> createState() => _TechnicianQuotesViewState();
}

class _TechnicianQuotesViewState extends State<_TechnicianQuotesView> {
  int selectedFilter = 0;

  final ScrollController _scrollController = ScrollController();

  final List<String?> _filterValues = [null, 'NOW', 'SCHEDULED'];

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 150) {
      final state = context.read<TechnicianQuoteCubit>().state;

      if (state is TechnicianQuoteLoaded) {
        context.read<TechnicianQuoteCubit>().loadMore();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openDetail(TechnicianQuoteModel quote) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TechnicianQuoteDetailPage(quoteId: quote.quoteId),
      ),
    );

    if (!mounted) return;

    context.read<TechnicianQuoteCubit>().getQuotes(
      refresh: true,
      showLoading: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final filters = [
      'technician.quotes.filter.all'.tr(),
      'technician.quotes.filter.now'.tr(),
      'technician.quotes.filter.scheduled'.tr(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<TechnicianQuoteCubit, TechnicianQuoteState>(
          builder: (context, state) {
            if (state is TechnicianQuoteLoading ||
                state is TechnicianQuoteInitial) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (state is TechnicianQuoteAccountNotApproved) {
              return _buildAccountNotApproved();
            }

            if (state is TechnicianQuoteError) {
              return _buildError(state.message);
            }

            if (state is TechnicianQuoteLoaded) {
              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () => context.read<TechnicianQuoteCubit>().getQuotes(
                  refresh: true,
                ),
                child: ListView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(12),
                  children: [
                    // Tiêu đề
                    Row(
                      children: [
                        const Icon(
                          Icons.circle,
                          color: Color(0xFFFF641F),
                          size: 9,
                        ),
                        const SizedBox(width: 7),
                        Text(
                          'technician.quotes.new_requests'.tr(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'technician.quotes.total'.tr(
                            args: [state.totalElements.toString()],
                          ),
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Bộ lọc
                    Row(
                      children: List.generate(filters.length, (index) {
                        final selected = selectedFilter == index;

                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedFilter = index;
                              });

                              context.read<TechnicianQuoteCubit>().filterByTime(
                                _filterValues[index],
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.primary
                                    : const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(22),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                filters[index],
                                style: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 14),

                    if (state.quotes.isEmpty)
                      _buildEmpty()
                    else
                      ...state.quotes.map(
                        (quote) => Padding(
                          padding: const EdgeInsets.only(bottom: 11),
                          child: QuoteCard(
                            quote: quote,
                            onTap: () => _openDetail(quote),
                          ),
                        ),
                      ),

                    if (state.currentPage < state.totalPages)
                      const Padding(
                        padding: EdgeInsets.all(15),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildAccountNotApproved() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                size: 42,
                color: Color(0xFFD97706),
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'technician.quotes.account_not_approved_title'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'technician.quotes.account_not_approved_message'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.only(top: 75),
      child: Column(
        children: [
          const Icon(Icons.inbox_outlined, size: 65, color: AppColors.textHint),
          const SizedBox(height: 12),
          Text(
            'technician.quotes.empty'.tr(),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 45),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                context.read<TechnicianQuoteCubit>().getQuotes();
              },
              child: Text('common.retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
