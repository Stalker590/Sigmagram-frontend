import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/chat/chat_bloc.dart';
import '../bloc/session/session_cubit.dart';
import 'chat/chat_list_page.dart';
import 'profile/profile_page.dart';
import 'settings/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionState>(
      builder: (context, sessionState) {
        if (sessionState.status == SessionStatus.loading &&
            sessionState.credentials.name.isEmpty) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final credentials = sessionState.credentials;
        final pages = [
          ChatListPage(credentials: credentials),
          const SettingsPage(),
          const ProfilePage(),
        ];

        return Scaffold(
          body: IndexedStack(
            index: _index,
            children: pages,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (value) {
              setState(() => _index = value);
              if (value == 0 && credentials.isComplete) {
                context.read<ChatBloc>().add(
                      ChatListRequested(credentials: credentials),
                    );
              }
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.chat_bubble_outline),
                selectedIcon: Icon(Icons.chat_bubble),
                label: 'Чат',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: 'Налаштування',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Профіль',
              ),
            ],
          ),
        );
      },
    );
  }
}
