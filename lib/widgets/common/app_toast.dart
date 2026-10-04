import 'package:flutter/material.dart';
import 'package:clothingapp/core/constants/app_colors.dart';

class AppToast {
  static OverlayEntry? _currentToast;

  static void show(
    BuildContext context,
    String message, {
    IconData? icon,
    Color? backgroundColor,
    bool isError = false,
    Duration duration = const Duration(seconds: 2),
  }) {
    _currentToast?.remove();

    final overlay = Overlay.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    _currentToast = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, (1 - value) * -10),
                  child: child!,
                ),
              );
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: isError
                    ? AppColors.error.withValues(alpha: 0.9)
                    : (backgroundColor ??
                        (isDark ? Colors.grey[800] : Colors.grey[100])),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    spreadRadius: 0,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      color: isError
                          ? Colors.white
                          : (isDark ? Colors.white : AppColors.black),
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Text(
                      message,
                      style: TextStyle(
                        color: isError
                            ? Colors.white
                            : (isDark ? Colors.white : AppColors.black),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_currentToast!);

    Future.delayed(duration, () {
      _currentToast?.remove();
      _currentToast = null;
    });
  }

  static void showSuccess(BuildContext context, String message) {
    show(context, message,
        icon: Icons.check_circle, isError: false);
  }

  static void showError(BuildContext context, String message) {
    show(context, message,
        icon: Icons.error, isError: true);
  }
}
