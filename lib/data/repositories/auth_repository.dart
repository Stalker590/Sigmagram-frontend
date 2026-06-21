import '../../core/models/user_credentials.dart';
import '../../domain/repositories/i_repositories.dart';
import '../datasources/api_client.dart';

class AuthRepository implements IAuthRepository {
  AuthRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<String?> login(UserCredentials credentials) {
    return _apiClient.login(credentials);
  }
}
