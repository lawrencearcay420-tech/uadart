import 'package:flutter/material.dart';
import 'package:clothingapp/core/constants/app_colors.dart';

class LoginBackground extends StatelessWidget {
  final Widget child;

  const LoginBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [
            AppColors.nearBlack,
            AppColors.darkGrey,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.warmGrey.withValues(alpha: 0.3),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.mediumGrey.withValues(alpha: 0.3),
              ),
            ),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}
