part of 'chat_bloc.dart';

enum ChatListStatus { initial, loading, success, failure }

enum ChatMessagesStatus { initial, loading, success, failure }

enum ChatActionStatus { initial, loading, success, failure }

class ChatState extends Equatable {
  const ChatState({
    required this.listStatus,
    required this.messagesStatus,
    required this.actionStatus,
    required this.chats,
    required this.messages,
    this.activeChat,
    this.currentUserId,
    this.errorMessage,
    this.actionMessage,
  });

  const ChatState.initial()
    : this(
        listStatus: ChatListStatus.initial,
        messagesStatus: ChatMessagesStatus.initial,
        actionStatus: ChatActionStatus.initial,
        chats: const [],
        messages: const [],
      );

  final ChatListStatus listStatus;
  final ChatMessagesStatus messagesStatus;
  final ChatActionStatus actionStatus;
  final List<ChatSummary> chats;
  final List<Messenge> messages;
  final ChatSummary? activeChat;
  final String? currentUserId;
  final String? errorMessage;
  final String? actionMessage;

  ChatState copyWith({
    ChatListStatus? listStatus,
    ChatMessagesStatus? messagesStatus,
    ChatActionStatus? actionStatus,
    List<ChatSummary>? chats,
    List<Messenge>? messages,
    ChatSummary? activeChat,
    bool clearActiveChat = false,
    String? currentUserId,
    String? errorMessage,
    String? actionMessage,
  }) {
    return ChatState(
      listStatus: listStatus ?? this.listStatus,
      messagesStatus: messagesStatus ?? this.messagesStatus,
      actionStatus: actionStatus ?? this.actionStatus,
      chats: chats ?? this.chats,
      messages: messages ?? this.messages,
      activeChat: clearActiveChat ? null : activeChat ?? this.activeChat,
      currentUserId: currentUserId ?? this.currentUserId,
      errorMessage: errorMessage,
      actionMessage: actionMessage,
    );
  }

  @override
  List<Object?> get props => [
    listStatus,
    messagesStatus,
    actionStatus,
    chats,
    messages,
    activeChat,
    currentUserId,
    errorMessage,
    actionMessage,
  ];
}
