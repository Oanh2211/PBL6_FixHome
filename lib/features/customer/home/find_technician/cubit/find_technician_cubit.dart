import 'dart:async';
import 'package:dio/dio.dart';
import 'package:fixhome/features/customer/home/find_technician/api/find_technician_api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'find_technician_state.dart';

class FindTechnicianCubit extends Cubit<FindTechnicianState> {
  final FindTechnicianApi _api;
  final int orderId;
  Timer? _pollingTimer;

  FindTechnicianCubit({required this.orderId, FindTechnicianApi? api})
    : _api = api ?? FindTechnicianApi(),
      super(const FindTechnicianState());

  Future<void> init() async {
    emit(state.copyWith(status: FindTechStatus.loading, clearError: true));
    try {
      final results = await Future.wait([
        _api.getOrderDetail(orderId),
        _api.getOrderQuotes(orderId),
      ]);
      final order = results[0] as dynamic;
      final quotesPage = results[1] as dynamic;

      emit(
        state.copyWith(
          status: FindTechStatus.loaded,
          order: order,
          quotes: quotesPage.content,
        ),
      );

      _startPollingQuotes();
    } catch (e) {
      emit(
        state.copyWith(
          status: FindTechStatus.error,
          errorMessage: _parseError(e),
        ),
      );
    }
  }

  void _startPollingQuotes() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (state.isCancelled || state.selectedResult != null) {
        _pollingTimer?.cancel();
        return;
      }
      await refreshQuotes();
    });
  }

  Future<void> refreshQuotes() async {
    try {
      final quotesPage = await _api.getOrderQuotes(orderId);
      emit(state.copyWith(quotes: quotesPage.content));
    } catch (_) {}
  }

  void toggleOrderDetail() {
    emit(state.copyWith(isOrderDetailExpanded: !state.isOrderDetailExpanded));
  }

  Future<void> loadQuoteDetail(int quoteId) async {
    emit(state.copyWith(isLoadingDetail: true, clearError: true));
    try {
      final detail = await _api.getQuoteDetail(orderId, quoteId);
      emit(state.copyWith(isLoadingDetail: false, selectedQuoteDetail: detail));
    } catch (e) {
      emit(
        state.copyWith(isLoadingDetail: false, errorMessage: _parseError(e)),
      );
    }
  }

  Future<void> loadApplicableVouchers(int quoteId) async {
    emit(state.copyWith(isLoadingVouchers: true, clearError: true));
    try {
      final vouchers = await _api.getApplicableVouchers(orderId, quoteId);
      emit(state.copyWith(isLoadingVouchers: false, vouchers: vouchers));
    } catch (e) {
      emit(
        state.copyWith(isLoadingVouchers: false, errorMessage: _parseError(e)),
      );
    }
  }

  Future<bool> applyVoucher(int quoteId, String? voucherCode) async {
    emit(state.copyWith(status: FindTechStatus.submitting, clearError: true));
    try {
      final updatedQuote = await _api.updateQuoteVoucher(
        orderId,
        quoteId,
        voucherCode: voucherCode,
      );
      final updatedList = state.quotes
          .map((q) => q.quoteId == quoteId ? updatedQuote : q)
          .toList();

      emit(
        state.copyWith(
          status: FindTechStatus.loaded,
          selectedQuoteDetail: updatedQuote,
          quotes: updatedList,
        ),
      );
      return true;
    } catch (e) {
      emit(
        state.copyWith(
          status: FindTechStatus.loaded,
          errorMessage: _parseError(e),
        ),
      );
      return false;
    }
  }

  Future<bool> selectTechnician(int quoteId) async {
    emit(state.copyWith(status: FindTechStatus.submitting, clearError: true));
    try {
      final res = await _api.selectQuote(orderId, quoteId);
      _pollingTimer?.cancel();
      emit(state.copyWith(status: FindTechStatus.loaded, selectedResult: res));
      return true;
    } catch (e) {
      emit(
        state.copyWith(
          status: FindTechStatus.loaded,
          errorMessage: _parseError(e),
        ),
      );
      return false;
    }
  }

  Future<bool> cancelOrder(String reason) async {
    emit(state.copyWith(status: FindTechStatus.submitting, clearError: true));
    try {
      final cancelledOrder = await _api.cancelOrder(orderId, reason: reason);
      _pollingTimer?.cancel();
      emit(
        state.copyWith(
          status: FindTechStatus.loaded,
          order: cancelledOrder,
          isCancelled: true,
        ),
      );
      return true;
    } catch (e) {
      emit(
        state.copyWith(
          status: FindTechStatus.loaded,
          errorMessage: _parseError(e),
        ),
      );
      return false;
    }
  }

  String _parseError(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
      return e.message ?? 'Đã có lỗi kết nối xảy ra';
    }
    return e.toString();
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }
}
