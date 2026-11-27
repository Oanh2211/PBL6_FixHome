import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:fixhome/common/constants/app_color.dart';
import 'package:fixhome/features/customer/chat/cubit/chat_cubit.dart';
import 'package:fixhome/features/customer/chat/model/chat_message_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatPage extends StatelessWidget {
  final int orderId;
  final String orderCode;
  final String contactName;

  const ChatPage({
    super.key,
    required this.orderId,
    required this.orderCode,
    required this.contactName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatCubit(orderId: orderId)..load(),
      child: _ChatView(orderCode: orderCode, contactName: contactName),
    );
  }
}

class _ChatView extends StatefulWidget {
  final String orderCode;
  final String contactName;

  const _ChatView({required this.orderCode, required this.contactName});

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _refreshTimer;
  bool _didInitialScroll = false;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => context.read<ChatCubit>().refreshLatest(),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadOlder() async {
    if (!_scrollController.hasClients) return;
    final previousMaxExtent = _scrollController.position.maxScrollExtent;
    final loaded = await context.read<ChatCubit>().loadOlder();
    if (!loaded || !mounted || !_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final addedExtent =
          _scrollController.position.maxScrollExtent - previousMaxExtent;
      _scrollController.jumpTo(_scrollController.position.pixels + addedExtent);
    });
  }

  Future<void> _sendMessage() async {
    final cubit = context.read<ChatCubit>();
    final sent = await cubit.sendMessage(_messageController.text);
    if (!mounted || !sent) return;
    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.contactName,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '${'customer.chat.order'.tr()} ${widget.orderCode}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatCubit, ChatState>(
              listenWhen: (previous, current) =>
                  previous.messages.length != current.messages.length &&
                  !current.isLoadingOlder,
              listener: (context, state) {
                if (!_scrollController.hasClients) return;
                final isNearBottom =
                    _scrollController.position.maxScrollExtent -
                        _scrollController.position.pixels <
                    120;
                if (isNearBottom) _scrollToBottom();
              },
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (state.messages.isEmpty && state.errorMessage != null) {
                  return _LoadError(
                    message: state.errorMessage!.tr(),
                    onRetry: () => context.read<ChatCubit>().load(),
                  );
                }

                if (!_didInitialScroll) {
                  _didInitialScroll = true;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) {
                      _scrollController.jumpTo(
                        _scrollController.position.maxScrollExtent,
                      );
                    }
                  });
                }

                return Column(
                  children: [
                    if (state.errorMessage != null)
                      Material(
                        color: AppColors.error.withValues(alpha: 0.08),
                        child: InkWell(
                          onTap: () =>
                              context.read<ChatCubit>().refreshLatest(),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: AppColors.error,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    state.errorMessage!.tr(),
                                    style: const TextStyle(
                                      color: AppColors.error,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Text(
                                  'common.retry'.tr(),
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    Expanded(
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if (notification.metrics.pixels < 60 &&
                              !state.isLoadingOlder &&
                              state.hasMore) {
                            _loadOlder();
                          }
                          return false;
                        },
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                          itemCount:
                              state.messages.length +
                              (state.isLoadingOlder ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (state.isLoadingOlder && index == 0) {
                              return const Padding(
                                padding: EdgeInsets.all(12),
                                child: Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              );
                            }
                            final messageIndex = state.isLoadingOlder
                                ? index - 1
                                : index;
                            final message = state.messages[messageIndex];
                            return _MessageBubble(
                              message: message,
                              isMine:
                                  message.senderAccountId ==
                                  state.currentAccountId,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          _MessageComposer(
            controller: _messageController,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _LoadError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.chat_bubble_outline, color: AppColors.textHint),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: Text('common.retry'.tr())),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool isMine;

  const _MessageBubble({required this.message, required this.isMine});

  @override
  Widget build(BuildContext context) {
    final sentAt = message.sentAt?.toLocal();
    final time = sentAt == null
        ? ''
        : DateFormat('HH:mm', context.locale.languageCode).format(sentAt);

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * 0.78,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isMine ? AppColors.primaryDark : AppColors.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isMine ? 16 : 4),
                    bottomRight: Radius.circular(isMine ? 4 : 16),
                  ),
                  border: isMine ? null : Border.all(color: AppColors.border),
                ),
                child: Text(
                  message.content,
                  style: TextStyle(
                    color: isMine ? Colors.white : AppColors.textPrimary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            ),
            if (time.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                child: Text(
                  time,
                  style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 10,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MessageComposer extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _MessageComposer({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        return SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    minLines: 1,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => onSend(),
                    decoration: InputDecoration(
                      hintText: 'customer.chat.message_hint'.tr(),
                      filled: true,
                      fillColor: AppColors.surfaceMuted,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 11,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 44,
                  height: 44,
                  child: IconButton.filled(
                    onPressed: state.isSending ? null : onSend,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.primaryLight,
                    ),
                    icon: state.isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send_rounded, size: 19),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
