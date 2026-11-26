import 'package:fixhome/features/technician/notification/model/technician_notification_model.dart';

abstract class TechnicianNotificationState {}

class TechnicianNotificationInitial extends TechnicianNotificationState {}

class TechnicianNotificationLoading extends TechnicianNotificationState {}

class TechnicianNotificationLoaded extends TechnicianNotificationState {
  final List<TechnicianNotificationModel> notifications;
  final TechnicianNotificationCategory selectedCategory;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isMarkingAllRead;

  TechnicianNotificationLoaded({
    required this.notifications,
    this.selectedCategory = TechnicianNotificationCategory.all,
    this.currentPage = 1,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.isMarkingAllRead = false,
  });

  List<TechnicianNotificationModel> get filteredNotifications {
    if (selectedCategory == TechnicianNotificationCategory.all) {
      return notifications;
    }
    return notifications
        .where((item) => item.category == selectedCategory)
        .toList();
  }

  int get totalUnreadCount =>
      notifications.where((item) => !item.isRead).length;

  int get ordersUnreadCount => notifications
      .where(
        (item) =>
            !item.isRead &&
            item.category == TechnicianNotificationCategory.orders,
      )
      .length;

  TechnicianNotificationLoaded copyWith({
    List<TechnicianNotificationModel>? notifications,
    TechnicianNotificationCategory? selectedCategory,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isMarkingAllRead,
  }) {
    return TechnicianNotificationLoaded(
      notifications: notifications ?? this.notifications,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isMarkingAllRead: isMarkingAllRead ?? this.isMarkingAllRead,
    );
  }
}

class TechnicianNotificationError extends TechnicianNotificationState {
  final String message;

  TechnicianNotificationError(this.message);
}
