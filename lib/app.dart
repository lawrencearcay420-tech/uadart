import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clothingapp/core/theme/app_theme.dart';
import 'package:clothingapp/navigation/app_router.dart';
import 'package:clothingapp/providers/auth_provider.dart';
import 'package:clothingapp/providers/theme_provider.dart';

class UnderAsawaApp extends StatelessWidget {
  const UnderAsawaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<AppThemeProvider>(context);

    return MaterialApp.router(
      title: 'Under Asawa',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      routerConfig: AppRouter(authProvider).router,
    );
  }
}

class UnderAsawaAppLegacy extends StatelessWidget {
  const UnderAsawaAppLegacy({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Under Asawa',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const Scaffold(),
    );
  }
}
