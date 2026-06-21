import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../../core/models/chat_summary.dart';
import '../../core/models/user_credentials.dart';
import '../../domain/Entities/Messenge.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  String baseUrl = ApiConstants.defaultBaseUrl;

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException(
        'Невірна відповідь сервера (${response.statusCode})',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode >= 400) {
      throw ApiException(
        decoded['error']?.toString() ?? 'Помилка сервера',
        statusCode: response.statusCode,
      );
    }

    return decoded;
  }

  Future<String?> login(UserCredentials credentials) async {
    final data = await post('/login', credentials.toAuthBody());
    final user = data['user'] as Map<String, dynamic>?;
    return user?['id'] as String?;
  }

  Future<List<ChatSummary>> getChats(UserCredentials credentials) async {
    final data = await post('/get_chats', credentials.toAuthBody());
    final chats = data['chats'] as List<dynamic>? ?? [];
    return chats
        .map((e) => ChatSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<({List<Messenge> messages, String userId})> getMessages(
    UserCredentials credentials,
    String chatId,
  ) async {
    final data = await post(
      '/get_messages',
      credentials.toAuthBody({'chatId': chatId}),
    );
    final rawMessages = data['messages'] as List<dynamic>? ?? [];
    final messages = rawMessages
        .map((e) => Messenge.fromJson(e as Map<String, dynamic>))
        .toList();
    final userId = data['userId'] as String? ?? credentials.userId ?? '';
    return (messages: messages, userId: userId);
  }

  Future<void> sendMessage(
    UserCredentials credentials,
    String chatId,
    String content,
  ) async {
    await post(
      '/send_message',
      credentials.toAuthBody({
        'chatId': chatId,
        'content': content,
      }),
    );
  }
}
