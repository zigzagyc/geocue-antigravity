import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/signup_screen.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/cue/presentation/create_cue_screen.dart';
import '../features/home/presentation/home_screen.dart';

part 'router.g.dart';

@riverpod
GoRouter router(Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  // Keep the auth state provider alive so ref.read gets the latest value
  ref.listen(authStateChangesProvider, (_, __) {});

  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(authRepository.authStateChanges),
    redirect: (context, state) {
      final authState = ref.read(authStateChangesProvider);
      print('Router redirect: path=${state.uri.path}, user=${authState.value}, isLoading=${authState.isLoading}');
      
      return authState.when(
        data: (user) {
          final isLoggingIn = state.uri.path == '/login' || state.uri.path == '/signup';
          if (user == null && !isLoggingIn) return '/login';
          if (user != null && isLoggingIn) return '/';
          return null;
        },
        error: (_, __) => '/login',
        loading: () => '/splash',
      );
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
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

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
