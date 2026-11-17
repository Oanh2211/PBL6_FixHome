import 'package:fixhome/features/customer/activity/api/activity_api_service.dart';
import 'package:fixhome/features/customer/activity/model/repair_order_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'activity_state.dart';

class ActivityCubit extends Cubit<ActivityState> {
  final ActivityApiService _apiService;

  ActivityCubit(this._apiService) : super(ActivityInitial());

  Future<void> loadOrders() async {
    emit(ActivityLoading());
    try {
      // Đã lọc bỏ CANCELLED trong service
      final allValidOrders = await _apiService.getRepairOrders(
        page: 0,
        size: 50,
      );

      final activeOrders = <RepairOrderModel>[];
      final completedOrders = <RepairOrderModel>[];

      for (final order in allValidOrders) {
        if (order.status.toUpperCase() == 'COMPLETED') {
          completedOrders.add(order);
        } else {
          activeOrders.add(order);
        }
      }

      emit(
        ActivityLoaded(
          activeOrders: activeOrders,
          completedOrders: completedOrders,
          selectedTabIndex: 0,
        ),
      );
    } catch (e) {
      emit(ActivityError(e.toString()));
    }
  }

  void switchTab(int index) {
    final currentState = state;
    if (currentState is ActivityLoaded) {
      emit(currentState.copyWith(selectedTabIndex: index));
    }
  }
}
