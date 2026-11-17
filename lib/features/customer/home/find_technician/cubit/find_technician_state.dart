import 'package:equatable/equatable.dart';
import 'package:fixhome/features/customer/home/find_technician/model/quote_models.dart';
import 'package:fixhome/features/customer/home/find_technician/model/repair_order_model.dart';

enum FindTechStatus { initial, loading, loaded, submitting, error }

class FindTechnicianState extends Equatable {
  final FindTechStatus status;
  final RepairOrderModel? order;
  final List<TechnicianQuoteModel> quotes;
  final TechnicianQuoteModel? selectedQuoteDetail;
  final List<ApplicableVoucherModel> vouchers;
  final bool isOrderDetailExpanded;
  final bool isLoadingDetail;
  final bool isLoadingVouchers;
  final bool isCancelled;
  final SelectQuoteResponse? selectedResult;
  final String? errorMessage;

  const FindTechnicianState({
    this.status = FindTechStatus.initial,
    this.order,
    this.quotes = const [],
    this.selectedQuoteDetail,
    this.vouchers = const [],
    this.isOrderDetailExpanded = false,
    this.isLoadingDetail = false,
    this.isLoadingVouchers = false,
    this.isCancelled = false,
    this.selectedResult,
    this.errorMessage,
  });

  FindTechnicianState copyWith({
    FindTechStatus? status,
    RepairOrderModel? order,
    List<TechnicianQuoteModel>? quotes,
    TechnicianQuoteModel? selectedQuoteDetail,
    List<ApplicableVoucherModel>? vouchers,
    bool? isOrderDetailExpanded,
    bool? isLoadingDetail,
    bool? isLoadingVouchers,
    bool? isCancelled,
    SelectQuoteResponse? selectedResult,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FindTechnicianState(
      status: status ?? this.status,
      order: order ?? this.order,
      quotes: quotes ?? this.quotes,
      selectedQuoteDetail: selectedQuoteDetail ?? this.selectedQuoteDetail,
      vouchers: vouchers ?? this.vouchers,
      isOrderDetailExpanded:
          isOrderDetailExpanded ?? this.isOrderDetailExpanded,
      isLoadingDetail: isLoadingDetail ?? this.isLoadingDetail,
      isLoadingVouchers: isLoadingVouchers ?? this.isLoadingVouchers,
      isCancelled: isCancelled ?? this.isCancelled,
      selectedResult: selectedResult ?? this.selectedResult,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    order,
    quotes,
    selectedQuoteDetail,
    vouchers,
    isOrderDetailExpanded,
    isLoadingDetail,
    isLoadingVouchers,
    isCancelled,
    selectedResult,
    errorMessage,
  ];
}
