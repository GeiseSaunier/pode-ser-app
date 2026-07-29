import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'providers/auth_provider.dart';
import 'screens/landing_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_shell.dart';

void main() {
  runApp(const PodeSerApp());
}

class PodeSerApp extends StatelessWidget {
  const PodeSerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'Pode ser?',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const _RootGate(),
        routes: {
          '/login': (_) => const LoginScreen(),
          '/signup': (_) => const SignupScreen(),
          '/home': (_) => const HomeShell(),
        },
      ),
    );
  }
}

/// Decide a tela inicial com base no status de autenticação:
/// enquanto carrega o token salvo, mostra um loading; se autenticado, pula
/// direto pro app; senão, mostra a tela de entrada.
class _RootGate extends StatelessWidget {
  const _RootGate();

  @override
  Widget build(BuildContext context) {
    final status = context.watch<AuthProvider>().status;

    switch (status) {
      case AuthStatus.loading:
        return const Scaffold(
          backgroundColor: AppColors.ink,
          body: Center(child: CircularProgressIndicator(color: AppColors.gold)),
        );
      case AuthStatus.authenticated:
        return const HomeShell();
      case AuthStatus.unauthenticated:
        return const LandingScreen();
    }
  }
}
