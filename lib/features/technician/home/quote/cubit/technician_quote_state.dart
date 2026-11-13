import '../model/technician_quote_model.dart';

abstract class TechnicianQuoteState {}

class TechnicianQuoteInitial extends TechnicianQuoteState {}

// Danh sách yêu cầu

class TechnicianQuoteLoading extends TechnicianQuoteState {}

class TechnicianQuoteAccountNotApproved extends TechnicianQuoteState {}

class TechnicianQuoteLoaded extends TechnicianQuoteState {
  final List<TechnicianQuoteModel> quotes;
  final int totalElements;
  final int currentPage;
  final int totalPages;
  final String? selectedStatus;
  final String? selectedTimeType;

  TechnicianQuoteLoaded({
    required this.quotes,
    required this.totalElements,
    required this.currentPage,
    required this.totalPages,
    this.selectedStatus,
    this.selectedTimeType,
  });
}

class TechnicianQuoteError extends TechnicianQuoteState {
  final String message;

  TechnicianQuoteError(this.message);
}

// Chi tiết yêu cầu

class TechnicianQuoteDetailLoading extends TechnicianQuoteState {}

class TechnicianQuoteDetailLoaded extends TechnicianQuoteState {
  final TechnicianQuoteDetailModel detail;

  TechnicianQuoteDetailLoaded(this.detail);
}

class TechnicianQuoteDetailError extends TechnicianQuoteState {
  final String message;

  TechnicianQuoteDetailError(this.message);
}
