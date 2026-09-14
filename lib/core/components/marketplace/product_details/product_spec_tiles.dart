import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../localization/locale_keys.dart';
import '../../../theme/marketplace_palette.dart';
import '../../../theme/marketplace_typography.dart';
import '../../../utils/date_formatter.dart';

/// Weight · SKU · Added — the three product facts the payload actually carries.
///
/// A tile is omitted when its field is absent rather than shown empty, and the
/// row disappears entirely when none of the three arrived.
class ProductSpecTiles extends StatelessWidget {
  const ProductSpecTiles({
    super.key,
    this.weight,
    this.sku,
    this.createdAt,
  });

  final String? weight;
  final String? sku;
  final DateTime? createdAt;

  @override
  Widget build(BuildContext context) {
    final specs = <_Spec>[
      if (weight != null && weight!.trim().isNotEmpty)
        _Spec(
          icon: Icons.scale_outlined,
          label: LocaleKeys.weightLabel.tr,
          value: weight!.trim(),
          isLatin: true,
        ),
      if (sku != null && sku!.trim().isNotEmpty)
        _Spec(
          icon: Icons.tag_rounded,
          label: LocaleKeys.skuLabel.tr,
          value: sku!.trim(),
          isLatin: true,
        ),
      if (createdAt != null)
        _Spec(
          icon: Icons.calendar_today_outlined,
          label: LocaleKeys.addedLabel.tr,
          value: DateFormatter.mediumDate(createdAt!),
        ),
    ];

    if (specs.isEmpty) return const SizedBox.shrink();

    // The tiles are stretched so a two-line value does not leave its neighbour
    // short. `stretch` alone cannot do that here: the row sits in a scroll view,
    // so its own height constraint is unbounded and stretching would hand every
    // child an infinite height. IntrinsicHeight measures the tallest tile first
    // and gives the row a real height to stretch into.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < specs.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(child: _SpecTile(spec: specs[i])),
          ],
        ],
      ),
    );
  }
}

class _Spec {
  const _Spec({
    required this.icon,
    required this.label,
    required this.value,
    this.isLatin = false,
  });

  final IconData icon;
  final String label;
  final String value;

  /// SKUs and weights stay Latin-digit and left-to-right inside Arabic copy.
  final bool isLatin;
}

class _SpecTile extends StatelessWidget {
  const _SpecTile({required this.spec});

  final _Spec spec;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(spec.icon, size: 10, color: palette.textMuted),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  spec.label.toUpperCase(),
                  style: MarketplaceTypography.labelCaps.copyWith(
                    fontSize: 8.5,
                    color: palette.textMuted,
                    letterSpacing: MarketplaceTypography.isArabic ? 0 : 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            spec.value,
            textDirection: spec.isLatin ? TextDirection.ltr : null,
            style: MarketplaceTypography.rowTitle.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: palette.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
