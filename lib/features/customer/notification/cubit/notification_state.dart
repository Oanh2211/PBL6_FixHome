import 'package:fixhome/features/customer/notification/model/notification_model.dart';

abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationModel> notifications;
  final NotificationCategory selectedCategory;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isMarkingAllRead;

  NotificationLoaded({
    required this.notifications,
    this.selectedCategory = NotificationCategory.all,
    this.currentPage = 1,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.isMarkingAllRead = false,
  });

  List<NotificationModel> get filteredNotifications {
    if (selectedCategory == NotificationCategory.all) {
      return notifications;
    }
    return notifications
        .where((item) => item.category == selectedCategory)
        .toList();
  }

  int get totalUnreadCount =>
      notifications.where((item) => !item.isRead).length;

  NotificationLoaded copyWith({
    List<NotificationModel>? notifications,
    NotificationCategory? selectedCategory,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isMarkingAllRead,
  }) {
    return NotificationLoaded(
      notifications: notifications ?? this.notifications,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isMarkingAllRead: isMarkingAllRead ?? this.isMarkingAllRead,
    );
  }
}

class NotificationError extends NotificationState {
  final String message;

  NotificationError(this.message);
}
