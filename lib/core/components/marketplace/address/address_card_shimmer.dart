import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../theme/marketplace_palette.dart';

/// Placeholder in the shape of a real address card, so the list does not jump
/// when `GET /addresses` lands.
class AddressCardShimmer extends StatelessWidget {
  const AddressCardShimmer({super.key});

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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: palette.hairline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            bar(64, 18),
            const SizedBox(height: 12),
            bar(150, 12),
            const SizedBox(height: 8),
            bar(110, 10),
            const SizedBox(height: 10),
            bar(double.infinity, 10),
            const SizedBox(height: 6),
            bar(200, 10),
          ],
        ),
      ),
    );
  }
}
