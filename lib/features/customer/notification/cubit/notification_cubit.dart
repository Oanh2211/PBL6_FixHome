import 'package:dio/dio.dart';
import 'package:fixhome/features/customer/notification/api/notification_api_service.dart';
import 'package:fixhome/features/customer/notification/cubit/notification_state.dart';
import 'package:fixhome/features/customer/notification/model/notification_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationApiService _apiService;
  static const int _pageSize = 20;

  NotificationCubit(this._apiService) : super(NotificationInitial());

  Future<void> loadNotifications({bool showLoading = true}) async {
    final previousCategory = state is NotificationLoaded
        ? (state as NotificationLoaded).selectedCategory
        : NotificationCategory.all;

    if (showLoading) {
      emit(NotificationLoading());
    }

    try {
      final response = await _apiService.getNotifications(
        page: 1,
        pageSize: _pageSize,
      );

      emit(
        NotificationLoaded(
          notifications: response.content,
          selectedCategory: previousCategory,
          currentPage: 1,
          hasMore: !response.isLast,
        ),
      );
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      emit(NotificationError(message));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> refresh() => loadNotifications(showLoading: false);

  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is! NotificationLoaded ||
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
      if (latestState is NotificationLoaded) {
        emit(latestState.copyWith(isLoadingMore: false));
      }
    }
  }

  void switchTab(NotificationCategory category) {
    final currentState = state;
    if (currentState is NotificationLoaded &&
        currentState.selectedCategory != category) {
      emit(currentState.copyWith(selectedCategory: category));
    }
  }

  Future<void> markAsRead(int notificationId) async {
    final currentState = state;
    if (currentState is! NotificationLoaded) return;

    final targetIndex = currentState.notifications.indexWhere(
      (item) => item.id == notificationId,
    );
    if (targetIndex == -1 || currentState.notifications[targetIndex].isRead) {
      return;
    }

    // Optimistic update
    final optimisticList = List<NotificationModel>.from(
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
      if (latestState is NotificationLoaded) {
        final updatedList = latestState.notifications.map((item) {
          if (item.id == notificationId) {
            return updated.title.isNotEmpty
                ? updated
                : item.copyWith(isRead: true, readAt: updated.readAt ?? DateTime.now());
          }
          return item;
        }).toList();
        emit(latestState.copyWith(notifications: updatedList));
      }
    } catch (_) {
      // Revert on failure
      final latestState = state;
      if (latestState is NotificationLoaded) {
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
    if (currentState is! NotificationLoaded ||
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
      if (latestState is NotificationLoaded) {
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
