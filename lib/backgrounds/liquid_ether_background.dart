import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:clothingapp/core/constants/app_colors.dart';
import 'package:clothingapp/core/utils/responsive.dart';

class LiquidEtherBackground extends StatefulWidget {
  final double speed;
  final double autoSpeed;
  final double autoIntensity;
  final double mouseForce;
  final double mouseRadius;
  final List<Color> colors;
  final double opacity;
  final double quality;
  final bool interactive;

  const LiquidEtherBackground({
    super.key,
    this.speed = 1.0,
    this.autoSpeed = 0.25,
    this.autoIntensity = 0.15,
    this.mouseForce = 1.0,
    this.mouseRadius = 1.0,
    this.colors = const [],
    this.opacity = 0.8,
    this.quality = 1.0,
    this.interactive = true,
  });

  @override
  State<LiquidEtherBackground> createState() => _LiquidEtherBackgroundState();
}

class _LiquidEtherBackgroundState extends State<LiquidEtherBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double _currentTime = 0.0;
  Offset _mousePosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this)
      ..repeat(min: 0, max: 1, period: const Duration(milliseconds: 16));
    _controller.addListener(_onTick);
  }

  void _onTick() {
    _currentTime += widget.autoSpeed * 0.016;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTick);
    _controller.dispose();
    super.dispose();
  }

  List<Color> get _activeColors {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return widget.colors.isNotEmpty
        ? widget.colors
        : (isDark ? AppColors.darkModeColors : AppColors.lightModeColors);
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion = Responsive.prefersReducedMotion(context);

    if (reducedMotion) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _activeColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      );
    }

    final screenSize = MediaQuery.of(context).size;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onHover: widget.interactive
          ? (event) {
              setState(() {
                _mousePosition = Offset(
                  event.position.dx / screenSize.width,
                  event.position.dy / screenSize.height,
                );
              });
            }
          : null,
      child: CustomPaint(
        painter: _LiquidEtherPainter(
          time: _currentTime,
          mousePosition: _mousePosition,
          speed: widget.speed * 0.5,
          autoSpeed: widget.autoSpeed,
          autoIntensity: widget.autoIntensity,
          mouseForce: widget.mouseForce,
          mouseRadius: widget.mouseRadius,
          colors: _activeColors,
          opacity: widget.opacity,
          quality: widget.quality,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _LiquidEtherPainter extends CustomPainter {
  final double time;
  final Offset mousePosition;
  final double speed;
  final double autoSpeed;
  final double autoIntensity;
  final double mouseForce;
  final double mouseRadius;
  final List<Color> colors;
  final double opacity;
  final double quality;

  _LiquidEtherPainter({
    required this.time,
    required this.mousePosition,
    required this.speed,
    required this.autoSpeed,
    required this.autoIntensity,
    required this.mouseForce,
    required this.mouseRadius,
    required this.colors,
    required this.opacity,
    required this.quality,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    for (int i = 0; i < 4; i++) {
      final color = colors[i % colors.length];
      final t = time + i * 0.5;
      final cx = size.width * 0.5 +
          math.sin(t * 0.3 + i) * size.width * 0.2 * autoIntensity +
          mousePosition.dx * size.width * 0.3 * mouseForce;
      final cy = size.height * 0.5 +
          math.cos(t * 0.2 + i) * size.height * 0.2 * autoIntensity +
          mousePosition.dy * size.height * 0.3 * mouseForce;
      final radius =
          (size.shortestSide * 0.25 + i * 20) * (1.0 + autoIntensity * 0.5);

      paint.shader = RadialGradient(
        center: Alignment.center,
        colors: [
          color.withValues(alpha: opacity * 0.4),
          color.withValues(alpha: 0),
        ],
        stops: const [0.0, 1.0],
      ).createShader(rect);

      canvas.drawCircle(Offset(cx, cy), radius, paint);
    }

    final overlayPaint = Paint()..blendMode = BlendMode.plus;
    final overlayRect = rect;

    final overlayShader = LinearGradient(
      colors: colors
          .asMap()
          .entries
          .map((e) =>
              e.value.withValues(alpha: 0.02 + e.key * 0.01 * autoIntensity))
          .toList(),
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      tileMode: TileMode.clamp,
    ).createShader(overlayRect);

    overlayPaint.shader = overlayShader;
    canvas.drawRect(overlayRect, overlayPaint);
  }

  @override
  bool shouldRepaint(covariant _LiquidEtherPainter old) {
    return time != old.time ||
        mousePosition != old.mousePosition ||
        speed != old.speed;
  }
}
