import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/models/chat_summary.dart';
import '../../../core/models/user_credentials.dart';
import '../../../domain/Entities/Messenge.dart';
import '../../../domain/repositories/i_repositories.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc({required IChatRepository chatRepository})
      : _chatRepository = chatRepository,
        super(const ChatState.initial()) {
    on<ChatListRequested>(_onChatListRequested);
    on<ChatOpened>(_onChatOpened);
    on<ChatClosed>(_onChatClosed);
    on<ChatMessagesRefreshed>(_onChatMessagesRefreshed);
    on<ChatMessageSent>(_onChatMessageSent);
    on<ChatPollingTick>(_onChatPollingTick);
  }

  final IChatRepository _chatRepository;
  Timer? _pollTimer;

  Future<void> _onChatListRequested(
    ChatListRequested event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(listStatus: ChatListStatus.loading, errorMessage: null));
    try {
      final chats = await _chatRepository.getChats(event.credentials);
      emit(
        state.copyWith(
          listStatus: ChatListStatus.success,
          chats: chats,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          listStatus: ChatListStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onChatOpened(ChatOpened event, Emitter<ChatState> emit) async {
    _stopPolling();
    emit(
      state.copyWith(
        activeChat: event.chat,
        messagesStatus: ChatMessagesStatus.loading,
        messages: const [],
        currentUserId: event.credentials.userId,
        errorMessage: null,
      ),
    );

    await _loadMessages(event.credentials, event.chat.id, emit);
    _startPolling(event.credentials, event.chat.id);
  }

  void _onChatClosed(ChatClosed event, Emitter<ChatState> emit) {
    _stopPolling();
    emit(
      state.copyWith(
        clearActiveChat: true,
        messages: const [],
        messagesStatus: ChatMessagesStatus.initial,
      ),
    );
  }

  Future<void> _onChatMessagesRefreshed(
    ChatMessagesRefreshed event,
    Emitter<ChatState> emit,
  ) async {
    final chat = state.activeChat;
    if (chat == null) return;
    await _loadMessages(event.credentials, chat.id, emit, silent: true);
  }

  Future<void> _onChatMessageSent(
    ChatMessageSent event,
    Emitter<ChatState> emit,
  ) async {
    final chat = state.activeChat;
    if (chat == null) return;

    try {
      await _chatRepository.sendMessage(
        event.credentials,
        chat.id,
        event.content,
      );
      await _loadMessages(event.credentials, chat.id, emit, silent: true);
    } catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }

  Future<void> _onChatPollingTick(
    ChatPollingTick event,
    Emitter<ChatState> emit,
  ) async {
    final chat = state.activeChat;
    if (chat == null) return;
    await _loadMessages(event.credentials, chat.id, emit, silent: true);
  }

  Future<void> _loadMessages(
    UserCredentials credentials,
    String chatId,
    Emitter<ChatState> emit, {
    bool silent = false,
  }) async {
    if (!silent) {
      emit(state.copyWith(messagesStatus: ChatMessagesStatus.loading));
    }

    try {
      final result = await _chatRepository.getMessages(credentials, chatId);
      emit(
        state.copyWith(
          messagesStatus: ChatMessagesStatus.success,
          messages: result.messages,
          currentUserId: result.userId,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          messagesStatus: silent
              ? state.messagesStatus
              : ChatMessagesStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void _startPolling(UserCredentials credentials, String chatId) {
    _pollTimer = Timer.periodic(
      const Duration(seconds: ApiConstants.pollIntervalSeconds),
      (_) => add(ChatPollingTick(credentials: credentials)),
    );
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  @override
  Future<void> close() {
    _stopPolling();
    return super.close();
  }
}
