import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

import '../api/technician_quote_api.dart';
import '../model/technician_quote_model.dart';
import 'technician_quote_state.dart';

class TechnicianQuoteCubit extends Cubit<TechnicianQuoteState> {
  final TechnicianQuoteApi api;

  TechnicianQuoteCubit({required this.api}) : super(TechnicianQuoteInitial());

  String? _selectedStatus;
  String? _selectedTimeType;

  int _currentPage = 1;
  int _totalPages = 1;
  int _totalElements = 0;

  List<TechnicianQuoteModel> _quotes = [];

  String? get selectedStatus => _selectedStatus;
  String? get selectedTimeType => _selectedTimeType;

  bool _isTechnicianNotApproved(Object error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      final responseData = error.response?.data;

      if (statusCode == 403 &&
          responseData is Map &&
          responseData['code'] == 'TECHNICIAN_NOT_APPROVED') {
        return true;
      }
    }

    return false;
  }

  // GET LIST
  Future<void> getQuotes({
    bool refresh = false,
    bool showLoading = true,
  }) async {
    if (isClosed) return;

    if (refresh) {
      _currentPage = 1;
    }

    if (showLoading) {
      emit(TechnicianQuoteLoading());
    }

    try {
      final result = await api.getQuotes(
        status: _selectedStatus,
        requestedTimeType: _selectedTimeType,
        page: _currentPage,
        pageSize: 20,
      );

      if (isClosed) return;

      _quotes = result.content;
      _totalPages = result.totalPages;
      _totalElements = result.totalElements;

      emit(
        TechnicianQuoteLoaded(
          quotes: List.unmodifiable(_quotes),
          totalElements: _totalElements,
          currentPage: _currentPage,
          totalPages: _totalPages,
          selectedStatus: _selectedStatus,
          selectedTimeType: _selectedTimeType,
        ),
      );
    } catch (e) {
      if (isClosed) return;

      if (_isTechnicianNotApproved(e)) {
        _quotes = [];
        _totalElements = 0;
        _currentPage = 1;
        _totalPages = 1;

        emit(TechnicianQuoteAccountNotApproved());
        return;
      }

      emit(TechnicianQuoteError(_getErrorMessage(e)));
    }
  }

  // FILTER STATUS
  Future<void> filterByStatus(String? status) async {
    _selectedStatus = status;
    _currentPage = 1;

    await getQuotes();
  }

  // FILTER TIME
  Future<void> filterByTime(String? timeType) async {
    _selectedTimeType = timeType;
    _currentPage = 1;

    await getQuotes();
  }

  // LOAD NEXT PAGE
  Future<void> loadMore() async {
    if (isClosed || _currentPage >= _totalPages) return;

    try {
      final nextPage = _currentPage + 1;

      final result = await api.getQuotes(
        status: _selectedStatus,
        requestedTimeType: _selectedTimeType,
        page: nextPage,
        pageSize: 20,
      );

      if (isClosed) return;

      _currentPage = nextPage;
      _quotes.addAll(result.content);
      _totalPages = result.totalPages;
      _totalElements = result.totalElements;

      emit(
        TechnicianQuoteLoaded(
          quotes: List.unmodifiable(_quotes),
          totalElements: _totalElements,
          currentPage: _currentPage,
          totalPages: _totalPages,
          selectedStatus: _selectedStatus,
          selectedTimeType: _selectedTimeType,
        ),
      );
    } catch (e) {
      if (isClosed) return;

      if (_isTechnicianNotApproved(e)) {
        _quotes = [];
        emit(TechnicianQuoteAccountNotApproved());
        return;
      }

      emit(TechnicianQuoteError(_getErrorMessage(e)));
    }
  }

  // GET DETAIL
  Future<TechnicianQuoteDetailModel?> getQuoteDetail(int quoteId) async {
    if (isClosed) return null;

    emit(TechnicianQuoteDetailLoading());

    try {
      final result = await api.getQuoteDetail(quoteId);

      if (isClosed) return null;

      emit(TechnicianQuoteDetailLoaded(result));

      return result;
    } catch (e) {
      if (isClosed) return null;

      emit(TechnicianQuoteDetailError(e.toString()));
      return null;
    }
  }

  String _getErrorMessage(Object error) {
    if (error is DioException) {
      final data = error.response?.data;

      if (data is Map) {
        return data['message']?.toString() ??
            data['detail']?.toString() ??
            'Đã xảy ra lỗi khi kết nối máy chủ.';
      }

      if (error.type == DioExceptionType.connectionError) {
        return 'Không thể kết nối máy chủ. Vui lòng kiểm tra Internet.';
      }

      return error.message ?? 'Đã xảy ra lỗi không xác định.';
    }

    return error.toString();
  }
}
