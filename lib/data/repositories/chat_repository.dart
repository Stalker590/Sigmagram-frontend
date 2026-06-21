import '../../core/models/chat_summary.dart';
import '../../core/models/user_credentials.dart';
import '../../domain/Entities/Messenge.dart';
import '../../domain/repositories/i_repositories.dart';
import '../datasources/api_client.dart';

class ChatRepository implements IChatRepository {
  ChatRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<ChatSummary>> getChats(UserCredentials credentials) {
    return _apiClient.getChats(credentials);
  }

  @override
  Future<ChatSummary> createGroup(UserCredentials credentials, String name) {
    return _apiClient.createGroup(credentials, name);
  }

  @override
  Future<ChatSummary> joinChatById(UserCredentials credentials, String chatId) {
    return _apiClient.joinChatById(credentials, chatId);
  }

  @override
  Future<({List<Messenge> messages, String userId})> getMessages(
    UserCredentials credentials,
    String chatId,
  ) {
    return _apiClient.getMessages(credentials, chatId);
  }

  @override
  Future<void> sendMessage(
    UserCredentials credentials,
    String chatId,
    String content,
  ) {
    return _apiClient.sendMessage(credentials, chatId, content);
  }
}
