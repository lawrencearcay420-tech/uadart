import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  final String image;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? iconColor;

  const ProductImage({
    super.key,
    required this.image,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(image);
    final isNetworkImage =
        uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    final placeholder = Container(
      width: width,
      height: height,
      color: backgroundColor ?? Colors.grey.shade100,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: iconColor ?? Colors.grey,
      ),
    );

    if (image.trim().isEmpty) return placeholder;

    return isNetworkImage
        ? Image.network(
            image,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (_, _, _) => placeholder,
          )
        : Image.asset(
            image,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (_, _, _) => placeholder,
          );
  }
}
