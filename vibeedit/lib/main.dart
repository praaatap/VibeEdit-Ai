/// VibeEdit AI - Video Editor Application
/// Main entry point
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/theme.dart';
import 'core/constants/constants.dart';
import 'features/splash/splash_screen.dart';
import 'features/navigation/app_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: VibeEditApp()));
}

/// Root application widget
class VibeEditApp extends StatelessWidget {
  const VibeEditApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const _AppStartup(),
    );
  }
}

/// Handles splash → main app transition
class _AppStartup extends StatefulWidget {
  const _AppStartup();

  @override
  State<_AppStartup> createState() => _AppStartupState();
}

class _AppStartupState extends State<_AppStartup> {
  bool _showSplash = true;

  void _onSplashComplete() {
    setState(() => _showSplash = false);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: _showSplash
          ? SplashScreen(
              key: const ValueKey('splash'),
              onComplete: _onSplashComplete,
            )
          : const AppShell(key: ValueKey('app')),
    );
  }
}
