import 'package:flutter/material.dart';

import '../../../theme/marketplace_palette.dart';
import '../../../theme/marketplace_typography.dart';

/// Surface card used by the order detail sections, with a tracked uppercase
/// caption instead of a heading — the section titles are labels, not headlines,
/// and the serif is reserved for the order number and the total.
class OrderSectionCard extends StatelessWidget {
  const OrderSectionCard({
    super.key,
    required this.child,
    this.title,
    this.padding = const EdgeInsets.fromLTRB(14, 12, 14, 12),
  });

  final String? title;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: palette.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Text(
              title!.toUpperCase(),
              style: MarketplaceTypography.labelCaps.copyWith(
                color: palette.textMuted,
                letterSpacing: 1.6,
              ),
            ),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }
}
