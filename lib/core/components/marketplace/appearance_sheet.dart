import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/services/theme_service.dart';
import '../../localization/locale_keys.dart';
import '../../theme/marketplace_palette.dart';
import '../../theme/marketplace_radius.dart';
import '../../theme/marketplace_spacing.dart';
import '../../theme/marketplace_typography.dart';

/// Light / dark / follow-device picker.
///
/// A bottom sheet rather than a dialog — native pattern, and it keeps the
/// screen behind visible so the theme change can be seen as it is chosen.
Future<void> showAppearanceSheet(BuildContext context) {
  final service = Get.find<ThemeService>();

  // Every colour is read from `sheetContext` inside the builder, and the sheet
  // paints its own ground rather than taking `backgroundColor`. A palette read
  // out here — or a route argument — is captured once when the sheet opens, so
  // the sheet the customer is changing the appearance *from* would keep the old
  // one, which is exactly the screen where that shows.
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      final palette = sheetContext.palette;

      return Container(
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              MarketplaceSpacing.lg,
              MarketplaceSpacing.md,
              MarketplaceSpacing.lg,
              MarketplaceSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: palette.hairline,
                      borderRadius:
                          BorderRadius.circular(MarketplaceRadius.full),
                    ),
                  ),
                ),
                const SizedBox(height: MarketplaceSpacing.md),
                Text(
                  LocaleKeys.appearance.tr,
                  style: MarketplaceTypography.sectionDisplay.copyWith(
                    color: palette.textPrimary,
                  ),
                ),
                const SizedBox(height: MarketplaceSpacing.sm),
                Obx(() => Column(
                      children: [
                        _AppearanceOption(
                          label: LocaleKeys.themeLight.tr,
                          icon: Icons.light_mode_outlined,
                          isSelected: service.mode.value == ThemeMode.light,
                          onTap: () => service.setMode(ThemeMode.light),
                        ),
                        _AppearanceOption(
                          label: LocaleKeys.themeDark.tr,
                          icon: Icons.dark_mode_outlined,
                          isSelected: service.mode.value == ThemeMode.dark,
                          onTap: () => service.setMode(ThemeMode.dark),
                        ),
                        _AppearanceOption(
                          label: LocaleKeys.themeSystem.tr,
                          icon: Icons.phone_iphone_rounded,
                          isSelected: service.mode.value == ThemeMode.system,
                          onTap: () => service.setMode(ThemeMode.system),
                        ),
                      ],
                    )),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _AppearanceOption extends StatelessWidget {
  const _AppearanceOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(top: MarketplaceSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: MarketplaceSpacing.md,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: isSelected ? palette.surfaceSunken : Colors.transparent,
          borderRadius: BorderRadius.circular(MarketplaceRadius.xl),
          border: Border.all(
            color: isSelected ? palette.brand : palette.hairline,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: palette.textSecondary),
            const SizedBox(width: MarketplaceSpacing.md),
            Expanded(
              child: Text(
                label,
                style: MarketplaceTypography.body.copyWith(
                  color: palette.textPrimary,
                  fontSize: 15,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_rounded, size: 20, color: palette.brand),
          ],
        ),
      ),
    );
  }
}
