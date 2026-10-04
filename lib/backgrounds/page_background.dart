import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clothingapp/backgrounds/liquid_ether_background.dart';
import 'package:clothingapp/providers/account_settings_provider.dart';

class PageBackground extends StatelessWidget {
  final Widget? child;
  final double intensity;
  final bool showLiquidEther;
  final bool showOverlay;
  final Color? overlayColor;

  const PageBackground({
    super.key,
    this.child,
    this.intensity = 1.0,
    this.showLiquidEther = true,
    this.showOverlay = false,
    this.overlayColor,
  });

  @override
  Widget build(BuildContext context) {
    final reducedMotion =
        context.watch<AccountSettingsProvider?>()?.reducedMotion ?? false;
    return Stack(
      children: [
        if (showLiquidEther && !reducedMotion)
          Positioned.fill(
            child: LiquidEtherBackground(
              autoSpeed: 0.25,
              autoIntensity: 0.15 * intensity,
              opacity: 0.5 + 0.3 * intensity,
              interactive: true,
            ),
          ),
        if (showOverlay)
          Positioned.fill(
            child: Container(
              color: overlayColor ??
                  Theme.of(context).scaffoldBackgroundColor.withValues(
                        alpha: 0.9,
                      ),
            ),
          ),
        if (child != null)
          Positioned.fill(
            child: child!,
          ),
      ],
    );
  }
}
