part of 'chat_bloc.dart';

enum ChatListStatus { initial, loading, success, failure }

enum ChatMessagesStatus { initial, loading, success, failure }

class ChatState extends Equatable {
  const ChatState({
    required this.listStatus,
    required this.messagesStatus,
    required this.chats,
    required this.messages,
    this.activeChat,
    this.currentUserId,
    this.errorMessage,
  });

  const ChatState.initial()
      : this(
          listStatus: ChatListStatus.initial,
          messagesStatus: ChatMessagesStatus.initial,
          chats: const [],
          messages: const [],
        );

  final ChatListStatus listStatus;
  final ChatMessagesStatus messagesStatus;
  final List<ChatSummary> chats;
  final List<Messenge> messages;
  final ChatSummary? activeChat;
  final String? currentUserId;
  final String? errorMessage;

  ChatState copyWith({
    ChatListStatus? listStatus,
    ChatMessagesStatus? messagesStatus,
    List<ChatSummary>? chats,
    List<Messenge>? messages,
    ChatSummary? activeChat,
    bool clearActiveChat = false,
    String? currentUserId,
    String? errorMessage,
  }) {
    return ChatState(
      listStatus: listStatus ?? this.listStatus,
      messagesStatus: messagesStatus ?? this.messagesStatus,
      chats: chats ?? this.chats,
      messages: messages ?? this.messages,
      activeChat: clearActiveChat ? null : activeChat ?? this.activeChat,
      currentUserId: currentUserId ?? this.currentUserId,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        listStatus,
        messagesStatus,
        chats,
        messages,
        activeChat,
        currentUserId,
        errorMessage,
      ];
}
