import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../localization/locale_keys.dart';
import '../../../theme/marketplace_palette.dart';
import '../../../theme/marketplace_typography.dart';

/// Serif section title with a tracked uppercase action on the trailing side.
class HomeSectionHeader extends StatelessWidget {
  const HomeSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;

  /// Defaults to "See All". Ignored when [onAction] is null.
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            title,
            style: MarketplaceTypography.sectionDisplay.copyWith(
              color: palette.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (onAction != null)
          GestureDetector(
            onTap: onAction,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: 12),
              child: Text(
                (actionLabel ?? LocaleKeys.seeAll.tr).toUpperCase(),
                style: MarketplaceTypography.linkCaps.copyWith(
                  color: palette.brand,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
