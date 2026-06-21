import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/user_credentials.dart';
import '../../../data/datasources/api_client.dart';
import '../../../data/datasources/credentials_storage.dart';
import '../../../domain/repositories/i_repositories.dart';

part 'session_state.dart';

class SessionCubit extends Cubit<SessionState> {
  SessionCubit({
    required CredentialsStorage storage,
    required ApiClient apiClient,
    required IAuthRepository authRepository,
  })  : _storage = storage,
        _apiClient = apiClient,
        _authRepository = authRepository,
        super(const SessionState.initial());

  final CredentialsStorage _storage;
  final ApiClient _apiClient;
  final IAuthRepository _authRepository;

  Future<void> initialize() async {
    emit(state.copyWith(status: SessionStatus.loading));
    try {
      final baseUrl = await _storage.loadBaseUrl();
      _apiClient.baseUrl = baseUrl;
      final credentials = await _storage.loadCredentials();

      if (!credentials.isComplete) {
        emit(
          state.copyWith(
            status: SessionStatus.unauthenticated,
            credentials: credentials,
            baseUrl: baseUrl,
          ),
        );
        return;
      }

      await _authenticate(credentials, baseUrl);
    } catch (error) {
      emit(
        state.copyWith(
          status: SessionStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> saveProfile({
    required String name,
    required String password,
  }) async {
    emit(state.copyWith(status: SessionStatus.loading, errorMessage: null));
    try {
      final credentials = UserCredentials(name: name.trim(), password: password);
      await _authenticate(credentials, state.baseUrl);
    } catch (error) {
      emit(
        state.copyWith(
          status: SessionStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> updateBaseUrl(String baseUrl) async {
    final normalized = baseUrl.trim().replaceAll(RegExp(r'/+$'), '');
    await _storage.saveBaseUrl(normalized);
    _apiClient.baseUrl = normalized;
    emit(state.copyWith(baseUrl: normalized));

    if (state.credentials.isComplete) {
      await saveProfile(
        name: state.credentials.name,
        password: state.credentials.password,
      );
    }
  }

  Future<void> _authenticate(
    UserCredentials credentials,
    String baseUrl,
  ) async {
    final userId = await _authRepository.login(credentials);
    final updated = credentials.copyWith(userId: userId);
    await _storage.saveCredentials(updated);

    emit(
      state.copyWith(
        status: SessionStatus.authenticated,
        credentials: updated,
        baseUrl: baseUrl,
        errorMessage: null,
      ),
    );
  }
}
