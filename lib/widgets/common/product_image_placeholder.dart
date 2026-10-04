import 'package:flutter/material.dart';

class ProductImagePlaceholder extends StatelessWidget {
  final double size;
  final Color? color;

  const ProductImagePlaceholder({
    super.key,
    this.size = 48,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: isDark ? Colors.grey[850] : Colors.grey[200],
      child: Icon(
        Icons.image,
        size: size,
        color: color ?? (isDark ? Colors.grey[700] : Colors.grey),
      ),
    );
  }
}

class NetworkImagePlaceholder extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;

  const NetworkImagePlaceholder({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    final placeholderWidget = placeholder ??
        Container(
          width: width,
          height: height,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[850]
              : Colors.grey[200],
          child: const Icon(Icons.image, size: 32, color: Colors.grey),
        );

    if (imageUrl.startsWith('http')) {
      return ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: Image.network(
          imageUrl,
          fit: fit,
          width: width,
          height: height,
errorBuilder: (_, _, _) => placeholderWidget,
        ),
      );
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Image.asset(
        imageUrl,
        fit: fit,
        width: width,
        height: height,
          errorBuilder: (_, _, _) => placeholderWidget,
      ),
    );
  }
}
