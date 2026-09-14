import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../theme/marketplace_palette.dart';
import '../../theme/marketplace_typography.dart';
import '../../theme/marketplace_icons.dart';
import '../../theme/marketplace_radius.dart';
import '../../../core/localization/locale_keys.dart';

/// Floating tab bar.
///
/// Sits over the content as a rounded pill rather than a docked bar, so the
/// hero artwork and product rails run to the bottom edge of the screen. The
/// host [Scaffold] must set `extendBody: true` for that to work.
class MarketplaceBottomNav extends StatelessWidget {
  const MarketplaceBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.cartCount = 0,
  });

  final int currentIndex;
  final Function(int) onTap;
  final int cartCount;

  List<String> get _labels => [
        LocaleKeys.navHome.tr,
        LocaleKeys.navCategory.tr,
        LocaleKeys.navSeller.tr,
        LocaleKeys.navCart.tr,
        LocaleKeys.navAccount.tr,
      ];

  static const _outlinedIcons = [
    MarketplaceIcons.homeOutlined,
    MarketplaceIcons.categoryOutlined,
    MarketplaceIcons.sellerOutlined,
    MarketplaceIcons.cartOutlined,
    MarketplaceIcons.accountOutlined,
  ];

  static const _filledIcons = [
    MarketplaceIcons.homeFilled,
    MarketplaceIcons.categoryFilled,
    MarketplaceIcons.sellerFilled,
    MarketplaceIcons.cartFilled,
    MarketplaceIcons.accountFilled,
  ];

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: Container(
          height: 62,
          decoration: BoxDecoration(
            color: palette.navSurface,
            borderRadius: BorderRadius.circular(MarketplaceRadius.full),
            border: Border.all(color: palette.hairline),
            boxShadow: [
              BoxShadow(
                color: Color.alphaBlend(
                  palette.textPrimary.withValues(alpha: 0.10),
                  Colors.transparent,
                ),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: List.generate(5, (i) => _buildTab(context, i)),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(BuildContext context, int index) {
    final palette = context.palette;
    final isActive = currentIndex == index;
    final color = isActive ? palette.brand : palette.textMuted;
    final isCartTab = index == 3;

    return Expanded(
      child: Semantics(
        label: _labels[index],
        selected: isActive,
        button: true,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap(index);
          },
          behavior: HitTestBehavior.opaque,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    isActive ? _filledIcons[index] : _outlinedIcons[index],
                    color: color,
                    size: 21,
                  ),
                  if (isCartTab && cartCount > 0)
                    PositionedDirectional(
                      top: -4,
                      end: -6,
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 15,
                          minHeight: 15,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: palette.brand,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          cartCount > 99 ? '99+' : '$cartCount',
                          textDirection: TextDirection.ltr,
                          style: MarketplaceTypography.navLabelSmall.copyWith(
                            color: palette.onBrand,
                            fontSize: 9,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                _labels[index],
                style: MarketplaceTypography.navLabelSmall.copyWith(
                  color: isActive ? palette.brand : palette.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
