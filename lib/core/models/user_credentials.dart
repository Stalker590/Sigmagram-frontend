class UserCredentials {
  const UserCredentials({
    required this.name,
    required this.password,
    this.userId,
  });

  final String name;
  final String password;
  final String? userId;

  bool get isComplete => name.isNotEmpty && password.isNotEmpty;

  UserCredentials copyWith({
    String? name,
    String? password,
    String? userId,
  }) {
    return UserCredentials(
      name: name ?? this.name,
      password: password ?? this.password,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toAuthBody([Map<String, dynamic>? extra]) {
    return {
      'name': name,
      'password': password,
      ...?extra,
    };
  }
}
