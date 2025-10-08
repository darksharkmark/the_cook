import 'package:flutter/material.dart';

/// Widget that tries to load a PNG asset, and falls back to JPG if PNG is missing.
class CardImageWidget extends StatelessWidget {
  final String id;
  final double? width;
  final double? height;
  final double borderRadius;

  const CardImageWidget({
    super.key,
    required this.id,
    this.width,
    this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final folder = id.split('-').first;
    final pngPath = 'assets/cards/$folder/$id.png';
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.asset(
        pngPath,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
