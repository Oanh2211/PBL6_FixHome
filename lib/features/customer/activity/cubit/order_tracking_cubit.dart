import 'package:fixhome/features/customer/activity/api/activity_api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'order_tracking_state.dart';

class OrderTrackingCubit extends Cubit<OrderTrackingState> {
  final ActivityApiService _apiService;

  OrderTrackingCubit(this._apiService) : super(OrderTrackingInitial());

  Future<void> fetchOrderDetail(int orderId) async {
    emit(OrderTrackingLoading());
    try {
      final order = await _apiService.getOrderDetail(orderId);
      emit(OrderTrackingLoaded(order));
    } catch (e) {
      emit(OrderTrackingError(e.toString()));
    }
  }

  Future<void> confirmCompletion(int orderId) async {
    final currentState = state;
    if (currentState is! OrderTrackingLoaded || currentState.isConfirming) {
      return;
    }

    emit(currentState.copyWith(isConfirming: true, actionError: null));
    try {
      await _apiService.confirmOrderCompletion(orderId);
      final updatedOrder = await _apiService.getOrderDetail(orderId);
      emit(
        OrderTrackingLoaded(
          updatedOrder,
          isConfirming: false,
          isConfirmSuccess: true,
        ),
      );
    } catch (e) {
      emit(
        currentState.copyWith(isConfirming: false, actionError: e.toString()),
      );
    }
  }
}
