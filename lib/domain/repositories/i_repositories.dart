import '../../core/models/chat_summary.dart';
import '../Entities/Messenge.dart';
import '../../core/models/user_credentials.dart';

abstract class IAuthRepository {
  Future<String?> login(UserCredentials credentials);
}

abstract class IChatRepository {
  Future<List<ChatSummary>> getChats(UserCredentials credentials);
  Future<ChatSummary> createGroup(UserCredentials credentials, String name);
  Future<ChatSummary> joinChatById(UserCredentials credentials, String chatId);
  Future<({List<Messenge> messages, String userId})> getMessages(
    UserCredentials credentials,
    String chatId,
  );
  Future<void> sendMessage(
    UserCredentials credentials,
    String chatId,
    String content,
  );
}
