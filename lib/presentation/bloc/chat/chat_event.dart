part of 'chat_bloc.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class ChatListRequested extends ChatEvent {
  const ChatListRequested({required this.credentials});

  final UserCredentials credentials;

  @override
  List<Object?> get props => [credentials];
}

class ChatGroupCreated extends ChatEvent {
  const ChatGroupCreated({required this.credentials, required this.name});

  final UserCredentials credentials;
  final String name;

  @override
  List<Object?> get props => [credentials, name];
}

class ChatJoinedById extends ChatEvent {
  const ChatJoinedById({required this.credentials, required this.chatId});

  final UserCredentials credentials;
  final String chatId;

  @override
  List<Object?> get props => [credentials, chatId];
}

class ChatOpened extends ChatEvent {
  const ChatOpened({required this.credentials, required this.chat});

  final UserCredentials credentials;
  final ChatSummary chat;

  @override
  List<Object?> get props => [credentials, chat];
}

class ChatClosed extends ChatEvent {
  const ChatClosed();
}

class ChatMessagesRefreshed extends ChatEvent {
  const ChatMessagesRefreshed({required this.credentials});

  final UserCredentials credentials;

  @override
  List<Object?> get props => [credentials];
}

class ChatMessageSent extends ChatEvent {
  const ChatMessageSent({required this.credentials, required this.content});

  final UserCredentials credentials;
  final String content;

  @override
  List<Object?> get props => [credentials, content];
}

class ChatPollingTick extends ChatEvent {
  const ChatPollingTick({required this.credentials});

  final UserCredentials credentials;

  @override
  List<Object?> get props => [credentials];
}
