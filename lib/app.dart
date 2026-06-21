import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'data/datasources/api_client.dart';
import 'data/datasources/credentials_storage.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/chat_repository.dart';
import 'presentation/bloc/chat/chat_bloc.dart';
import 'presentation/bloc/session/session_cubit.dart';
import 'presentation/pages/home_page.dart';

class SigmagramApp extends StatelessWidget {
  const SigmagramApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient();
    final storage = CredentialsStorage();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => SessionCubit(
            storage: storage,
            apiClient: apiClient,
            authRepository: AuthRepository(apiClient),
          )..initialize(),
        ),
        BlocProvider(
          create: (_) => ChatBloc(
            chatRepository: ChatRepository(apiClient),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Sigmagram',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const HomePage(),
      ),
    );
  }
}
