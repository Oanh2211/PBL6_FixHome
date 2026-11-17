import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:fixhome/features/technician/activity/api/technician_activity_api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/technician_order_model.dart';

abstract class TechnicianOrderDetailState {}

class OrderDetailInitial extends TechnicianOrderDetailState {}

class OrderDetailLoading extends TechnicianOrderDetailState {}

class OrderDetailLoaded extends TechnicianOrderDetailState {
  final TechnicianOrderModel order;
  final bool isUpdating;
  final String? actionSuccessMessage;
  final String? actionErrorMessage;

  // State cục bộ quản lý luồng Chốt giá -> Nghiệm thu -> Hoàn thành
  final bool isQuoteSubmitted;
  final bool isCompletedLocally;
  final double savedFinalAmount;
  final String savedWorkPerformed;
  final int savedWarrantyDays;

  OrderDetailLoaded({
    required this.order,
    this.isUpdating = false,
    this.actionSuccessMessage,
    this.actionErrorMessage,
    this.isQuoteSubmitted = false,
    this.isCompletedLocally = false,
    this.savedFinalAmount = 0,
    this.savedWorkPerformed = '',
    this.savedWarrantyDays = 30,
  });

  OrderDetailLoaded copyWith({
    TechnicianOrderModel? order,
    bool? isUpdating,
    String? actionSuccessMessage,
    String? actionErrorMessage,
    bool? isQuoteSubmitted,
    bool? isCompletedLocally,
    double? savedFinalAmount,
    String? savedWorkPerformed,
    int? savedWarrantyDays,
  }) {
    return OrderDetailLoaded(
      order: order ?? this.order,
      isUpdating: isUpdating ?? this.isUpdating,
      actionSuccessMessage: actionSuccessMessage,
      actionErrorMessage: actionErrorMessage,
      isQuoteSubmitted: isQuoteSubmitted ?? this.isQuoteSubmitted,
      isCompletedLocally: isCompletedLocally ?? this.isCompletedLocally,
      savedFinalAmount: savedFinalAmount ?? this.savedFinalAmount,
      savedWorkPerformed: savedWorkPerformed ?? this.savedWorkPerformed,
      savedWarrantyDays: savedWarrantyDays ?? this.savedWarrantyDays,
    );
  }
}

class OrderDetailError extends TechnicianOrderDetailState {
  final String message;
  OrderDetailError(this.message);
}

class TechnicianOrderDetailCubit extends Cubit<TechnicianOrderDetailState> {
  final TechnicianActivityApi _api;

  TechnicianOrderDetailCubit(this._api) : super(OrderDetailInitial());

  String _quoteCacheKey(int orderId) => 'tech_final_quote_$orderId';

  Future<void> _saveQuoteCache({
    required int orderId,
    required double finalAmount,
    required String workPerformed,
    required int warrantyDays,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _quoteCacheKey(orderId),
      jsonEncode({
        'isQuoteSubmitted': true,
        'finalAmount': finalAmount,
        'workPerformed': workPerformed,
        'warrantyDays': warrantyDays,
      }),
    );
  }

  Future<Map<String, dynamic>?> _readQuoteCache(int orderId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_quoteCacheKey(orderId));
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> _clearQuoteCache(int orderId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_quoteCacheKey(orderId));
  }

  Future<void> fetchDetail(int orderId) async {
    emit(OrderDetailLoading());
    try {
      final order = await _api.getOrderDetail(orderId);
      final cachedQuote = await _readQuoteCache(orderId);

      final isDone =
          order.status == 'COMPLETED' || order.status == 'PENDING_ACCEPTANCE';

      if (isDone) {
        await _clearQuoteCache(orderId);
      }

      final hasSubmittedQuote =
          !isDone &&
          (order.isQuoteSubmitted ||
              (cachedQuote?['isQuoteSubmitted'] == true));

      final resolvedFinalAmount =
          order.finalAmount ??
          (cachedQuote?['finalAmount'] as num?)?.toDouble() ??
          0;

      final resolvedWork =
          (cachedQuote?['workPerformed'] as String?) ??
          (order.workPerformed.isNotEmpty
              ? order.workPerformed
              : order.issueDescription);

      final resolvedWarranty =
          (cachedQuote?['warrantyDays'] as num?)?.toInt() ??
          order.warrantyDurationDays;

      emit(
        OrderDetailLoaded(
          order: order.copyWith(
            finalAmount: resolvedFinalAmount > 0 ? resolvedFinalAmount : null,
            isQuoteSubmitted: hasSubmittedQuote,
          ),
          isQuoteSubmitted: hasSubmittedQuote || isDone,
          isCompletedLocally: isDone,
          savedFinalAmount: resolvedFinalAmount,
          savedWorkPerformed: resolvedWork,
          savedWarrantyDays: resolvedWarranty,
        ),
      );
    } catch (e) {
      emit(OrderDetailError(e.toString()));
    }
  }

  /// Chuyển trạng thái các bước đầu: TECHNICIAN_SELECTED -> TRAVELLING -> ARRIVED -> REPAIRING
  Future<void> progressNextStatus() async {
    final currentState = state;
    if (currentState is! OrderDetailLoaded) return;
    final order = currentState.order;

    emit(currentState.copyWith(isUpdating: true));
    try {
      TechnicianOrderModel updated;
      switch (order.status) {
        case 'TECHNICIAN_SELECTED':
          updated = await _api.startTravelling(order.id);
          break;
        case 'TRAVELLING':
          updated = await _api.arriveAtLocation(order.id);
          break;
        case 'ARRIVED':
          updated = await _api.startRepair(order.id);
          break;
        default:
          updated = order;
      }

      updated = updated.copyWith(
        categoryName: order.categoryName,
        deviceName: order.deviceName,
        deviceIconUrl: order.deviceIconUrl,
        issueMedia: updated.issueMedia.isEmpty
            ? order.issueMedia
            : updated.issueMedia,
      );

      emit(
        currentState.copyWith(
          order: updated,
          isUpdating: false,
          actionSuccessMessage: 'technician.activity.detail.status_updated',
        ),
      );
    } catch (e) {
      emit(
        currentState.copyWith(
          isUpdating: false,
          actionErrorMessage: e.toString(),
        ),
      );
    }
  }

  /// Bước 4 -> 5: Gửi chốt giá (PUT /quote) & lưu lại giá tổng cuối cùng, cập nhật thẳng UI sang bước Nghiệm thu
  Future<bool> submitFinalQuote(FinalQuoteRequestModel request) async {
    final currentState = state;
    if (currentState is! OrderDetailLoaded) return false;
    final order = currentState.order;

    emit(currentState.copyWith(isUpdating: true));
    try {
      await _api.submitFinalQuote(order.id, request);

      final summaryWork = request.items
          .map((e) => '${e.itemName} (x${e.quantity})')
          .join(', ');
      final resolvedWork = summaryWork.isNotEmpty ? summaryWork : request.note;

      // Lưu bền vững vào SharedPreferences để thoát ra quay lại vẫn giữ trạng thái đã chốt giá
      await _saveQuoteCache(
        orderId: order.id,
        finalAmount: request.estimatedMaxAmount,
        workPerformed: resolvedWork,
        warrantyDays: request.warrantyDurationDays,
      );

      emit(
        currentState.copyWith(
          order: order.copyWith(
            finalAmount: request.estimatedMaxAmount,
            isQuoteSubmitted: true,
            workPerformed: resolvedWork,
            warrantyDurationDays: request.warrantyDurationDays,
          ),
          isUpdating: false,
          isQuoteSubmitted: true,
          savedFinalAmount: request.estimatedMaxAmount,
          savedWorkPerformed: resolvedWork,
          savedWarrantyDays: request.warrantyDurationDays,
          actionSuccessMessage:
              'technician.activity.final_quote.submit_success',
        ),
      );
      return true;
    } catch (e) {
      emit(
        currentState.copyWith(
          isUpdating: false,
          actionErrorMessage: e.toString(),
        ),
      );
      return false;
    }
  }

  /// Bước 5 -> 6: Upload ảnh nghiệm thu lấy media_ids -> Gọi POST /complete kèm savedFinalAmount -> Cập nhật UI Hoàn thành
  Future<bool> submitAcceptanceAndComplete({
    required String workPerformed,
    required String completionNote,
    required List<File> evidenceFiles,
  }) async {
    final currentState = state;
    if (currentState is! OrderDetailLoaded) return false;
    final order = currentState.order;

    emit(currentState.copyWith(isUpdating: true));
    try {
      final updated = await _api.completeOrder(
        order.id,
        finalAmount: currentState.savedFinalAmount,
        workPerformed: workPerformed,
        completionNote: completionNote,
        warrantyDurationDays: currentState.savedWarrantyDays,
        evidenceFiles: evidenceFiles,
      );

      await _clearQuoteCache(order.id);

      emit(
        currentState.copyWith(
          order: updated.copyWith(
            status: 'COMPLETED',
            categoryName: order.categoryName,
            deviceName: order.deviceName,
            deviceIconUrl: order.deviceIconUrl,
            finalAmount: currentState.savedFinalAmount,
            isQuoteSubmitted: true,
            issueMedia: updated.issueMedia.isEmpty
                ? order.issueMedia
                : updated.issueMedia,
          ),
          isUpdating: false,
          isCompletedLocally: true,
          actionSuccessMessage: 'technician.activity.detail.status_updated',
        ),
      );
      return true;
    } catch (e) {
      emit(
        currentState.copyWith(
          isUpdating: false,
          actionErrorMessage: e.toString(),
        ),
      );
      return false;
    }
  }
}
