import 'package:fixhome/features/customer/activity/model/repair_order_model.dart';

abstract class ActivityState {}

class ActivityInitial extends ActivityState {}

class ActivityLoading extends ActivityState {}

class ActivityLoaded extends ActivityState {
  final List<RepairOrderModel> activeOrders;
  final List<RepairOrderModel> completedOrders;
  final int selectedTabIndex; // 0: Đang tiến hành, 1: Lịch sử đã xong

  ActivityLoaded({
    required this.activeOrders,
    required this.completedOrders,
    this.selectedTabIndex = 0,
  });

  ActivityLoaded copyWith({
    List<RepairOrderModel>? activeOrders,
    List<RepairOrderModel>? completedOrders,
    int? selectedTabIndex,
  }) {
    return ActivityLoaded(
      activeOrders: activeOrders ?? this.activeOrders,
      completedOrders: completedOrders ?? this.completedOrders,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
    );
  }
}

class ActivityError extends ActivityState {
  final String message;
  ActivityError(this.message);
}
