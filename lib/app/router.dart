import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/signup_screen.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/cue/presentation/create_cue_screen.dart';
import '../features/cue/presentation/edit_cue_screen.dart';
import '../features/cue/domain/cue_model.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/admin/presentation/admin_user_list_screen.dart';
import '../features/admin/presentation/locked_area_list_screen.dart';
import '../features/admin/presentation/create_locked_area_screen.dart';

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
          final path = state.uri.path;
          final isLoggingIn = path == '/login' || path == '/signup';
          
          // GUEST ACCESS LOGIC
          if (user == null) {
            // Allow public routes
            if (path == '/' || path == '/splash' || isLoggingIn) {
               return null;
            }
            // Block protected routes
            if (path.startsWith('/create-cue') || path.startsWith('/edit-cue') || path.startsWith('/admin')) {
               return '/login';
            }
            // Allow any other route? Default to safe map view (home)
            return null; 
          }

          // LOGGED IN LOGIC
          // If logged in and trying to go to login/signup, redirect to home
          if (isLoggingIn) return '/';
          
          return null;
        },
        error: (_, __) => '/login', // Fallback on auth error
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
      GoRoute(
        path: '/edit-cue',
        builder: (context, state) {
          final cue = state.extra as CueModel;
          return EditCueScreen(cue: cue);
        },
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminUserListScreen(),
        routes: [
           GoRoute(
            path: 'locked-areas',
            builder: (context, state) => const LockedAreaListScreen(),
          ),
          GoRoute(
            path: 'create-locked-area',
            builder: (context, state) => const CreateLockedAreaScreen(),
          ),
        ],
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
