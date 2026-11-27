import 'package:flutter_bloc/flutter_bloc.dart';

import '../api/technician_chat_api_service.dart';
import '../model/technician_chat_message_model.dart';

class TechnicianChatState {
  final List<TechnicianChatMessageModel> messages;
  final int? currentAccountId;
  final bool isLoading;
  final bool isLoadingOlder;
  final bool isSending;
  final bool hasMore;
  final String? errorMessage;

  const TechnicianChatState({
    this.messages = const [],
    this.currentAccountId,
    this.isLoading = true,
    this.isLoadingOlder = false,
    this.isSending = false,
    this.hasMore = true,
    this.errorMessage,
  });

  TechnicianChatState copyWith({
    List<TechnicianChatMessageModel>? messages,
    int? currentAccountId,
    bool? isLoading,
    bool? isLoadingOlder,
    bool? isSending,
    bool? hasMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TechnicianChatState(
      messages: messages ?? this.messages,
      currentAccountId: currentAccountId ?? this.currentAccountId,
      isLoading: isLoading ?? this.isLoading,
      isLoadingOlder: isLoadingOlder ?? this.isLoadingOlder,
      isSending: isSending ?? this.isSending,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class TechnicianChatCubit extends Cubit<TechnicianChatState> {
  final int orderId;
  final TechnicianChatApiService _api;
  bool _isRefreshing = false;

  TechnicianChatCubit({
    required this.orderId,
    TechnicianChatApiService? api,
  }) : _api = api ?? TechnicianChatApiService(),
       super(const TechnicianChatState());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final accountIdFuture = _api.getCurrentAccountId();
      final messagesFuture = _api.getMessages(orderId);
      final accountId = await accountIdFuture;
      final page = await messagesFuture;
      emit(
        state.copyWith(
          currentAccountId: accountId,
          messages: page.messages,
          hasMore: page.hasMore,
          isLoading: false,
          clearError: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'technician.chat.load_error',
        ),
      );
    }
  }

  Future<void> refreshLatest() async {
    if (_isRefreshing || isClosed) return;
    _isRefreshing = true;
    try {
      final page = await _api.getMessages(orderId);
      if (isClosed) return;
      emit(
        state.copyWith(
          messages: _mergeMessages(state.messages, page.messages),
          hasMore: page.hasMore,
          clearError: true,
        ),
      );
    } catch (_) {
      if (!isClosed) {
        emit(state.copyWith(errorMessage: 'technician.chat.refresh_error'));
      }
    } finally {
      _isRefreshing = false;
    }
  }

  Future<bool> loadOlder() async {
    if (state.isLoadingOlder || !state.hasMore || state.messages.isEmpty) {
      return false;
    }
    emit(state.copyWith(isLoadingOlder: true, clearError: true));
    try {
      final page = await _api.getMessages(
        orderId,
        beforeId: state.messages.first.id,
      );
      emit(
        state.copyWith(
          messages: _mergeMessages(state.messages, page.messages),
          hasMore: page.hasMore,
          isLoadingOlder: false,
          clearError: true,
        ),
      );
      return page.messages.isNotEmpty;
    } catch (_) {
      emit(
        state.copyWith(
          isLoadingOlder: false,
          errorMessage: 'technician.chat.load_older_error',
        ),
      );
      return false;
    }
  }

  Future<bool> sendMessage(String text) async {
    final content = text.trim();
    if (content.isEmpty || state.isSending) return false;

    emit(state.copyWith(isSending: true, clearError: true));
    try {
      final message = await _api.sendMessage(
        orderId: orderId,
        content: content,
        clientMessageId: DateTime.now().microsecondsSinceEpoch.toString(),
      );
      emit(
        state.copyWith(
          messages: _mergeMessages(state.messages, [message]),
          isSending: false,
          clearError: true,
        ),
      );
      return true;
    } catch (_) {
      emit(
        state.copyWith(
          isSending: false,
          errorMessage: 'technician.chat.send_error',
        ),
      );
      return false;
    }
  }

  List<TechnicianChatMessageModel> _mergeMessages(
    List<TechnicianChatMessageModel> current,
    List<TechnicianChatMessageModel> incoming,
  ) {
    final messagesById = <int, TechnicianChatMessageModel>{
      for (final message in current) message.id: message,
    };
    for (final message in incoming) {
      messagesById[message.id] = message;
    }
    final messages = messagesById.values.toList()
      ..sort(compareTechnicianChatMessages);
    return messages;
  }
}
