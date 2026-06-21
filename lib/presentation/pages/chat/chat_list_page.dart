import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/chat_summary.dart';
import '../../../core/models/user_credentials.dart';
import '../../../core/theme/app_theme.dart';
import '../../bloc/chat/chat_bloc.dart';
import '../../widgets/chat_avatar.dart';
import 'chat_detail_page.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key, required this.credentials});

  final UserCredentials credentials;

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

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
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) =>
                ChatDetailPage(credentials: widget.credentials, chat: chat),
          ),
        )
        .then((_) {
          if (mounted) {
            context.read<ChatBloc>().add(const ChatClosed());
          }
        });
  }

  Future<void> _showCreateGroupDialog() async {
    final name = await _showTextActionDialog(
      title: 'Створити групу',
      labelText: 'Назва групи',
      actionText: 'Створити',
    );
    if (name == null || !mounted) return;

    context.read<ChatBloc>().add(
      ChatGroupCreated(credentials: widget.credentials, name: name),
    );
  }

  Future<void> _showFindChatDialog() async {
    final chatId = await _showTextActionDialog(
      title: 'Знайти чат',
      labelText: 'ID чату',
      actionText: 'Додати',
    );
    if (chatId == null || !mounted) return;

    context.read<ChatBloc>().add(
      ChatJoinedById(credentials: widget.credentials, chatId: chatId),
    );
  }

  Future<String?> _showTextActionDialog({
    required String title,
    required String labelText,
    required String actionText,
  }) {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(labelText: labelText),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submitDialogValue(context, controller),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Скасувати'),
            ),
            FilledButton(
              onPressed: () => _submitDialogValue(context, controller),
              child: Text(actionText),
            ),
          ],
        );
      },
    ).whenComplete(controller.dispose);
  }

  void _submitDialogValue(
    BuildContext context,
    TextEditingController controller,
  ) {
    final value = controller.text.trim();
    if (value.isEmpty) return;
    Navigator.of(context).pop(value);
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

    return BlocListener<ChatBloc, ChatState>(
      listenWhen: (previous, current) =>
          previous.actionStatus != current.actionStatus,
      listener: (context, state) {
        if (state.actionStatus == ChatActionStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.actionMessage ?? 'Готово')),
          );
        }

        if (state.actionStatus == ChatActionStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Не вдалося виконати дію'),
            ),
          );
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
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
              tooltip: 'Оновити',
            ),
            IconButton(
              onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
              icon: const Icon(Icons.add_comment_outlined),
              tooltip: 'Дії з чатами',
            ),
          ],
        ),
        endDrawer: _ChatActionsDrawer(
          onCreateGroup: _showCreateGroupDialog,
          onFindChat: _showFindChatDialog,
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
              separatorBuilder: (_, _) => const Divider(height: 1, indent: 72),
              itemBuilder: (context, index) {
                final chat = chats[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
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
      ),
    );
  }
}

class _ChatActionsDrawer extends StatelessWidget {
  const _ChatActionsDrawer({
    required this.onCreateGroup,
    required this.onFindChat,
  });

  final VoidCallback onCreateGroup;
  final VoidCallback onFindChat;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            final isLoading = state.actionStatus == ChatActionStatus.loading;

            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                const ListTile(title: Text('Дії')),
                ListTile(
                  enabled: !isLoading,
                  leading: const Icon(Icons.group_add_outlined),
                  title: const Text('Створити групу'),
                  onTap: () {
                    Navigator.of(context).pop();
                    onCreateGroup();
                  },
                ),
                ListTile(
                  enabled: !isLoading,
                  leading: const Icon(Icons.search_rounded),
                  title: const Text('Знайти чат'),
                  onTap: () {
                    Navigator.of(context).pop();
                    onFindChat();
                  },
                ),
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: LinearProgressIndicator(),
                  ),
              ],
            );
          },
        ),
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
