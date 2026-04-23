import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/marketplace_colors.dart';
import '../../theme/marketplace_typography.dart';
import '../../theme/marketplace_icons.dart';

/// Standard app bar for marketplace screens.
/// Implements [PreferredSizeWidget] for use directly in Scaffold.appBar.
class MarketplaceAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MarketplaceAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.actions,
    this.showBack = true,
  });

  final String title;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final bool showBack;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: MarketplaceColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: showBack
          ? Semantics(
              label: 'Go back',
              button: true,
              child: GestureDetector(
                onTap: onBack ?? () => Get.back(),
                child: const Icon(
                  MarketplaceIcons.backArrow,
                  size: 24,
                  color: MarketplaceColors.primary,
                ),
              ),
            )
          : null,
      title: Text(title, style: MarketplaceTypography.screenTitle),
      actions: actions,
    );
  }
}
