import 'package:flutter/material.dart';
import '../../theme/marketplace_colors.dart';
import '../../theme/marketplace_typography.dart';
import '../../theme/marketplace_spacing.dart';
import '../../theme/marketplace_icons.dart';

/// Menu list item widget with icon, label, and optional divider.
class MenuListItem extends StatelessWidget {
  const MenuListItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.showDivider = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: MarketplaceSpacing.md,
              vertical: MarketplaceSpacing.md,
            ),
            child: Row(
              children: [
                // Icon
                Icon(
                  icon,
                  size: 24,
                  color: MarketplaceColors.textBody,
                ),
                const SizedBox(width: MarketplaceSpacing.menuItemGap),
                // Label
                Text(
                  label,
                  style: MarketplaceTypography.body,
                ),
                const Spacer(),
                // Forward arrow
                Icon(
                  MarketplaceIcons.forwardArrow,
                  size: 24,
                  color: MarketplaceColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            color: MarketplaceColors.stroke,
            height: 1,
            indent: MarketplaceSpacing.md,
            endIndent: MarketplaceSpacing.md,
          ),
      ],
    );
  }
}
