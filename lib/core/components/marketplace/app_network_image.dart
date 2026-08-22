import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../theme/marketplace_colors.dart';

/// Network image with shimmer placeholder and error fallback.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius,
    this.fit = BoxFit.contain,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final double? borderRadius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    // CachedNetworkImage throws on an empty url instead of routing to
    // errorWidget, so absent images are handled up front.
    if (imageUrl.trim().isEmpty) {
      return _fallback();
    }

    final child = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, __) => Shimmer.fromColors(
        baseColor: const Color(0xFFE0E0E0),
        highlightColor: const Color(0xFFF5F5F5),
        child: Container(
          width: width,
          height: height,
          color: MarketplaceColors.deleteBackground,
        ),
      ),
      errorWidget: (_, __, ___) => _fallback(),
    );

    if (borderRadius != null && borderRadius! > 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius!),
        child: child,
      );
    }
    return child;
  }

  Widget _fallback() => Container(
        width: width,
        height: height,
        color: MarketplaceColors.deleteBackground,
        child: const Icon(
          Icons.image_not_supported_outlined,
          color: MarketplaceColors.iconInactive,
        ),
      );
}
