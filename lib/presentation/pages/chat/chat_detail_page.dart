import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/chat_summary.dart';
import '../../../core/models/user_credentials.dart';
import '../../../core/theme/app_theme.dart';
import '../../bloc/chat/chat_bloc.dart';
import '../../widgets/chat_input_bar.dart';
import '../../widgets/message_bubble.dart';

class ChatDetailPage extends StatefulWidget {
  const ChatDetailPage({
    super.key,
    required this.credentials,
    required this.chat,
  });

  final UserCredentials credentials;
  final ChatSummary chat;

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
      appBar: AppBar(
        title: Text(widget.chat.name),
        leading: BackButton(
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocConsumer<ChatBloc, ChatState>(
        listenWhen: (previous, current) =>
            previous.messages.length != current.messages.length,
        listener: (_, __) => _scrollToBottom(),
        builder: (context, state) {
          final messages = state.messages;
          final userId = state.currentUserId ?? widget.credentials.userId ?? '';

          return Column(
            children: [
              if (state.errorMessage != null)
                MaterialBanner(
                  content: Text(state.errorMessage!),
                  backgroundColor: AppColors.accent.withValues(alpha: 0.35),
                  actions: [
                    TextButton(
                      onPressed: () {
                        context.read<ChatBloc>().add(
                              ChatMessagesRefreshed(
                                credentials: widget.credentials,
                              ),
                            );
                      },
                      child: const Text('Оновити'),
                    ),
                  ],
                ),
              Expanded(
                child: Container(
                  color: AppColors.chatBackground,
                  child: state.messagesStatus == ChatMessagesStatus.loading &&
                          messages.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : messages.isEmpty
                          ? const Center(
                              child: Text(
                                'Поки немає повідомлень.\nНапишіть першим!',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                final message = messages[index];
                                return MessageBubble(
                                  text: message.text,
                                  time: message.timeOfCreating,
                                  isMine: message.senderId == userId,
                                );
                              },
                            ),
                ),
              ),
              ChatInputBar(
                enabled: state.messagesStatus != ChatMessagesStatus.loading,
                onSend: (content) {
                  context.read<ChatBloc>().add(
                        ChatMessageSent(
                          credentials: widget.credentials,
                          content: content,
                        ),
                      );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
