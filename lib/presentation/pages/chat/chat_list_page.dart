import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/chat_summary.dart';
import '../../../core/models/user_credentials.dart';
import '../../../core/theme/app_theme.dart';
import '../../bloc/chat/chat_bloc.dart';
import '../../widgets/chat_avatar.dart';
import 'chat_detail_page.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({
    super.key,
    required this.credentials,
  });

  final UserCredentials credentials;

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(
          ChatListRequested(credentials: widget.credentials),
        );
  }

  void _openChat(ChatSummary chat) {
    context.read<ChatBloc>().add(
          ChatOpened(credentials: widget.credentials, chat: chat),
        );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatDetailPage(
          credentials: widget.credentials,
          chat: chat,
        ),
      ),
    ).then((_) {
      if (mounted) {
        context.read<ChatBloc>().add(const ChatClosed());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.credentials.isComplete) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sigmagram')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Спочатку заповніть ім\'я та пароль у вкладці «Профіль».',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sigmagram'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<ChatBloc>().add(
                    ChatListRequested(credentials: widget.credentials),
                  );
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state.listStatus == ChatListStatus.loading &&
              state.chats.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.listStatus == ChatListStatus.failure &&
              state.chats.isEmpty) {
            return _ErrorView(
              message: state.errorMessage ?? 'Не вдалося завантажити чати',
              onRetry: () => context.read<ChatBloc>().add(
                    ChatListRequested(credentials: widget.credentials),
                  ),
            );
          }

          final chats = state.chats;
          if (chats.isEmpty) {
            return const Center(
              child: Text(
                'Немає доступних чатів',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          return ListView.separated(
            itemCount: chats.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
            itemBuilder: (context, index) {
              final chat = chats[index];
              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: ChatAvatar(label: chat.name),
                title: Text(
                  chat.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  chat.type == 'global' ? 'Загальний чат' : 'Підписка',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                onTap: () => _openChat(chat),
              );
            },
          );
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Повторити')),
          ],
        ),
      ),
    );
  }
}
