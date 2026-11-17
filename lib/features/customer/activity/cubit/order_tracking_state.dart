import 'package:fixhome/features/customer/activity/model/repair_order_model.dart';

abstract class OrderTrackingState {}

class OrderTrackingInitial extends OrderTrackingState {}

class OrderTrackingLoading extends OrderTrackingState {}

class OrderTrackingLoaded extends OrderTrackingState {
  final RepairOrderModel order;
  final bool isConfirming;
  final String? actionError;
  final bool isConfirmSuccess;

  OrderTrackingLoaded(
    this.order, {
    this.isConfirming = false,
    this.actionError,
    this.isConfirmSuccess = false,
  });

  OrderTrackingLoaded copyWith({
    RepairOrderModel? order,
    bool? isConfirming,
    String? actionError,
    bool? isConfirmSuccess,
  }) {
    return OrderTrackingLoaded(
      order ?? this.order,
      isConfirming: isConfirming ?? this.isConfirming,
      actionError: actionError,
      isConfirmSuccess: isConfirmSuccess ?? this.isConfirmSuccess,
    );
  }
}

class OrderTrackingError extends OrderTrackingState {
  final String message;
  OrderTrackingError(this.message);
}
