import 'package:flutter/material.dart';

class Responsive {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 768 && width < 1024;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }

  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1440;
  }

  static int getGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1440) return 5;
    if (width >= 1280) return 4;
    if (width >= 768) return 3;
    return 2;
  }

  static double getHorizontalPadding(BuildContext context) {
    if (isDesktop(context)) return 64;
    if (isTablet(context)) return 32;
    return 16;
  }

  static double getDevicePixelRatio(BuildContext context) {
    final ratio = MediaQuery.of(context).devicePixelRatio;
    if (isDesktop(context)) return ratio > 1.5 ? 1.5 : ratio;
    if (isTablet(context)) return ratio > 1.25 ? 1.25 : ratio;
    return ratio > 1.0 ? 1.0 : ratio;
  }

  static bool prefersReducedMotion(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.disableAnimations ||
        mediaQuery.accessibleNavigation ||
        mediaQuery.invertColors;
  }

  static double scaleFontSize(BuildContext context, double baseSize) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1440) return baseSize * 1.15;
    if (width >= 1024) return baseSize * 1.08;
    if (width >= 768) return baseSize * 1.03;
    return baseSize;
  }

  static double scalePadding(BuildContext context, double basePadding) {
    if (isDesktop(context)) return basePadding * 1.5;
    if (isTablet(context)) return basePadding * 1.2;
    return basePadding;
  }

  static double getMaxContentWidth(BuildContext context) {
    if (isLargeDesktop(context)) return 1440;
    if (isDesktop(context)) return 1280;
    return double.infinity;
  }

  static double getProductCardAspectRatio(BuildContext context) {
    if (isDesktop(context)) return 0.78;
    if (isTablet(context)) return 0.72;
    return 0.62;
  }

  static EdgeInsets getContentPadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 64, vertical: 32);
    }
    if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 24);
    }
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
  }
}
