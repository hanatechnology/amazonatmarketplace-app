import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:marketplace/core/theme/marketplace_palette.dart';

/// Placeholder shaped like a real notification row — icon tile, title bar,
/// two body lines — so the list does not jump when the data lands.
class NotificationTileShimmer extends StatelessWidget {
  const NotificationTileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    Widget bar(double width, double height) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: palette.shimmerBase,
            borderRadius: BorderRadius.circular(6),
          ),
        );

    return Shimmer.fromColors(
      baseColor: palette.shimmerBase,
      highlightColor: palette.shimmerHighlight,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: palette.hairline),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: palette.shimmerBase,
                borderRadius: BorderRadius.circular(11),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  bar(double.infinity, 11),
                  const SizedBox(height: 8),
                  bar(double.infinity, 9),
                  const SizedBox(height: 6),
                  bar(160, 9),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
