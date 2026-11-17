import 'package:fixhome/features/customer/activity/api/activity_api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'quote_detail_state.dart';

class QuoteDetailCubit extends Cubit<QuoteDetailState> {
  final ActivityApiService _apiService;

  QuoteDetailCubit(this._apiService) : super(QuoteDetailInitial());

  Future<void> fetchQuoteDetail({
    required int orderId,
    required int quoteId,
  }) async {
    emit(QuoteDetailLoading());
    try {
      final quote = await _apiService.getQuoteDetail(orderId, quoteId);
      emit(QuoteDetailLoaded(quote));
    } catch (e) {
      emit(QuoteDetailError(e.toString()));
    }
  }
}
