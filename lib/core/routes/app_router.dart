// lib/core/routes/app_router.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:linkup/core/routes/routers.dart';
import 'package:linkup/feature/auth/presentation/cubit/auth_cubit.dart';
import 'package:linkup/feature/auth/presentation/views/login_page.dart';
import 'package:linkup/feature/auth/presentation/views/sign_up_page.dart';
import 'package:linkup/feature/chat/presentation/cubit/chat_cubit/chat_cubit.dart';
import 'package:linkup/feature/chat/presentation/view/all_chats_view.dart';
import 'package:linkup/feature/chat/presentation/view/all_users_page.dart';
import 'package:linkup/feature/chat/presentation/view/conversation_view.dart';
import 'package:linkup/feature/navigation_bar.dart';
import 'package:linkup/feature/splash/splash_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

abstract class AppRouter {
  static final router = GoRouter(
    navigatorKey: navigatorKey,
    routes: [
      GoRoute(
        path: Routers.splash,
        builder: (context, state) => BlocProvider(
          create: (context) => AuthCubit(),
          child: const SplashPage(),
        ),
      ),
      GoRoute(
        path: Routers.navigationBottom,
        builder: (context, state) => const NavigationBarButton(),
      ),
      GoRoute(
        path: Routers.login,
        builder: (context, state) => BlocProvider(
          create: (context) => AuthCubit(),
          child: const LoginPage(),
        ),
      ),
      GoRoute(
        path: Routers.signUp,
        builder: (context, state) => BlocProvider(
          create: (context) => AuthCubit(),
          child: const SignUpPage(),
        ),
      ),
      GoRoute(
        path: Routers.allUsers,
        builder: (context, state) => BlocProvider(
          create: (context) => ChatCubit(),
          child: const AllUsersPage(),
        ),
      ),
      GoRoute(
        path: Routers.allChats,
        builder: (context, state) => BlocProvider(
          create: (context) => ChatCubit(),
          child: const AllChatsPage(),
        ),
      ),
      GoRoute(
        path: '${Routers.conversation}/:chatId',
        builder: (context, state) {
          final chatId = state.pathParameters['chatId']!;
          final otherUserName =
              state.extra as String? ?? 'Unknown User'; // تعيين قيمة افتراضية

          return MultiBlocProvider(
            providers: [
              BlocProvider.value(
                  value: context.read<AuthCubit>()), // إعادة استخدام AuthCubit
              BlocProvider(
                  create: (context) => ChatCubit()..loadMessages(chatId)),
            ],
            child: ConversationPage(
              chatId: chatId,
              otherUserName: otherUserName,
            ),
          );
        },
      ),
    ],
  );
}
