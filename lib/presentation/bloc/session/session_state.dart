part of 'session_cubit.dart';

enum SessionStatus { initial, loading, authenticated, unauthenticated, failure }

class SessionState extends Equatable {
  const SessionState({
    required this.status,
    required this.credentials,
    required this.baseUrl,
    this.errorMessage,
  });

  const SessionState.initial()
      : this(
          status: SessionStatus.initial,
          credentials: const UserCredentials(name: '', password: ''),
          baseUrl: '',
        );

  final SessionStatus status;
  final UserCredentials credentials;
  final String baseUrl;
  final String? errorMessage;

  SessionState copyWith({
    SessionStatus? status,
    UserCredentials? credentials,
    String? baseUrl,
    String? errorMessage,
  }) {
    return SessionState(
      status: status ?? this.status,
      credentials: credentials ?? this.credentials,
      baseUrl: baseUrl ?? this.baseUrl,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, credentials, baseUrl, errorMessage];
}
