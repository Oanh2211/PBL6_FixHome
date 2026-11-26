import 'package:dio/dio.dart';
import 'package:fixhome/features/technician/notification/api/technician_notification_api_service.dart';
import 'package:fixhome/features/technician/notification/cubit/technician_notification_state.dart';
import 'package:fixhome/features/technician/notification/model/technician_notification_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TechnicianNotificationCubit extends Cubit<TechnicianNotificationState> {
  final TechnicianNotificationApiService _apiService;
  static const int _pageSize = 20;

  TechnicianNotificationCubit(this._apiService)
      : super(TechnicianNotificationInitial());

  Future<void> loadNotifications({bool showLoading = true}) async {
    final previousCategory = state is TechnicianNotificationLoaded
        ? (state as TechnicianNotificationLoaded).selectedCategory
        : TechnicianNotificationCategory.all;

    if (showLoading) {
      emit(TechnicianNotificationLoading());
    }

    try {
      final response = await _apiService.getNotifications(
        page: 1,
        pageSize: _pageSize,
      );

      emit(
        TechnicianNotificationLoaded(
          notifications: response.content,
          selectedCategory: previousCategory,
          currentPage: 1,
          hasMore: !response.isLast,
        ),
      );
    } on DioException catch (e) {
      emit(TechnicianNotificationError(_extractErrorMessage(e)));
    } catch (e) {
      emit(TechnicianNotificationError(e.toString()));
    }
  }

  Future<void> refresh() => loadNotifications(showLoading: false);

  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is! TechnicianNotificationLoaded ||
        !currentState.hasMore ||
        currentState.isLoadingMore) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));
    try {
      final nextPage = currentState.currentPage + 1;
      final response = await _apiService.getNotifications(
        page: nextPage,
        pageSize: _pageSize,
      );

      final existingIds = currentState.notifications.map((e) => e.id).toSet();
      final newItems = response.content
          .where((item) => !existingIds.contains(item.id))
          .toList();

      emit(
        currentState.copyWith(
          notifications: [...currentState.notifications, ...newItems],
          currentPage: nextPage,
          hasMore: !response.isLast,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      final latestState = state;
      if (latestState is TechnicianNotificationLoaded) {
        emit(latestState.copyWith(isLoadingMore: false));
      }
    }
  }

  void switchTab(TechnicianNotificationCategory category) {
    final currentState = state;
    if (currentState is TechnicianNotificationLoaded &&
        currentState.selectedCategory != category) {
      emit(currentState.copyWith(selectedCategory: category));
    }
  }

  Future<void> markAsRead(int notificationId) async {
    final currentState = state;
    if (currentState is! TechnicianNotificationLoaded) return;

    final targetIndex = currentState.notifications.indexWhere(
      (item) => item.id == notificationId,
    );
    if (targetIndex == -1 || currentState.notifications[targetIndex].isRead) {
      return;
    }

    final optimisticList = List<TechnicianNotificationModel>.from(
      currentState.notifications,
    );
    optimisticList[targetIndex] = optimisticList[targetIndex].copyWith(
      isRead: true,
      readAt: DateTime.now(),
    );
    emit(currentState.copyWith(notifications: optimisticList));

    try {
      final updated = await _apiService.markAsRead(notificationId);
      final latestState = state;
      if (latestState is TechnicianNotificationLoaded) {
        final updatedList = latestState.notifications.map((item) {
          if (item.id == notificationId) {
            return updated.title.isNotEmpty
                ? updated
                : item.copyWith(
                    isRead: true,
                    readAt: updated.readAt ?? DateTime.now(),
                  );
          }
          return item;
        }).toList();
        emit(latestState.copyWith(notifications: updatedList));
      }
    } catch (_) {
      final latestState = state;
      if (latestState is TechnicianNotificationLoaded) {
        final revertedList = latestState.notifications.map((item) {
          if (item.id == notificationId) {
            return item.copyWith(isRead: false, readAt: null);
          }
          return item;
        }).toList();
        emit(latestState.copyWith(notifications: revertedList));
      }
    }
  }

  Future<void> markAllAsRead() async {
    final currentState = state;
    if (currentState is! TechnicianNotificationLoaded ||
        currentState.totalUnreadCount == 0 ||
        currentState.isMarkingAllRead) {
      return;
    }

    emit(currentState.copyWith(isMarkingAllRead: true));
    try {
      await _apiService.markAllAsRead();
      final now = DateTime.now();
      final updatedList = currentState.notifications
          .map(
            (item) => item.isRead
                ? item
                : item.copyWith(isRead: true, readAt: now),
          )
          .toList();
      emit(
        currentState.copyWith(
          notifications: updatedList,
          isMarkingAllRead: false,
        ),
      );
    } catch (_) {
      final latestState = state;
      if (latestState is TechnicianNotificationLoaded) {
        emit(latestState.copyWith(isMarkingAllRead: false));
      }
    }
  }

  String _extractErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic> && data['message'] != null) {
      return data['message'].toString();
    }
    return e.message ?? 'Error loading notifications';
  }
}
