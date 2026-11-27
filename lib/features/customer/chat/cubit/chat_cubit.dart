import 'package:flutter_bloc/flutter_bloc.dart';

import '../api/chat_api_service.dart';
import '../model/chat_message_model.dart';

class ChatState {
  final List<ChatMessageModel> messages;
  final int? currentAccountId;
  final bool isLoading;
  final bool isLoadingOlder;
  final bool isSending;
  final bool hasMore;
  final String? errorMessage;

  const ChatState({
    this.messages = const [],
    this.currentAccountId,
    this.isLoading = true,
    this.isLoadingOlder = false,
    this.isSending = false,
    this.hasMore = true,
    this.errorMessage,
  });

  ChatState copyWith({
    List<ChatMessageModel>? messages,
    int? currentAccountId,
    bool? isLoading,
    bool? isLoadingOlder,
    bool? isSending,
    bool? hasMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ChatState(
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

class ChatCubit extends Cubit<ChatState> {
  final int orderId;
  final ChatApiService _api;

  ChatCubit({required this.orderId, ChatApiService? api})
    : _api = api ?? ChatApiService(),
      super(const ChatState());

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
          errorMessage: 'customer.chat.load_error',
        ),
      );
    }
  }

  Future<void> refreshLatest() async {
    try {
      final page = await _api.getMessages(orderId);
      emit(
        state.copyWith(
          messages: _mergeMessages(state.messages, page.messages),
          hasMore: page.hasMore,
          clearError: true,
        ),
      );
    } catch (_) {
      emit(state.copyWith(errorMessage: 'customer.chat.refresh_error'));
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
          errorMessage: 'customer.chat.load_older_error',
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
          errorMessage: 'customer.chat.send_error',
        ),
      );
      return false;
    }
  }

  List<ChatMessageModel> _mergeMessages(
    List<ChatMessageModel> current,
    List<ChatMessageModel> incoming,
  ) {
    final messagesById = <int, ChatMessageModel>{
      for (final message in current) message.id: message,
    };
    for (final message in incoming) {
      messagesById[message.id] = message;
    }
    final messages = messagesById.values.toList()
      ..sort(compareChatMessages);
    return messages;
  }
}
