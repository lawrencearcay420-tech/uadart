import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:clothingapp/providers/auth_provider.dart';

Future<bool> requireSignIn(BuildContext context) async {
  if (context.read<AuthProvider>().isAuthenticated) return true;

  final router = GoRouter.of(context);
  final returnTo = GoRouterState.of(context).uri.toString();
  final signIn = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Sign in to continue'),
      content: const Text(
        'Please sign in or create an account before adding items to your bag.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Not now'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Sign in'),
        ),
      ],
    ),
  );

  if (signIn != true || !context.mounted) return false;

  router.go(
    Uri(
      path: '/login',
      queryParameters: {'redirect': returnTo},
    ).toString(),
  );
  return false;
}
