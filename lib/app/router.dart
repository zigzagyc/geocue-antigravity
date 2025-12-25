import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/signup_screen.dart';
import '../features/cue/presentation/create_cue_screen.dart';
import '../features/home/presentation/home_screen.dart';

part 'router.g.dart';

@riverpod
GoRouter router(Ref ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final authState = ref.watch(authStateChangesProvider);
      return authState.when(
        data: (user) {
          final isLoggingIn = state.uri.path == '/login' || state.uri.path == '/signup';
          if (user == null && !isLoggingIn) return '/login';
          if (user != null && isLoggingIn) return '/';
          return null;
        },
        error: (_, __) => null,
        loading: () => null,
      );
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/create-cue',
        builder: (context, state) => const CreateCueScreen(),
      ),
    ],
  );
}
