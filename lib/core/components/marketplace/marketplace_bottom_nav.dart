import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../theme/marketplace_colors.dart';
import '../../theme/marketplace_typography.dart';
import '../../theme/marketplace_shadows.dart';
import '../../theme/marketplace_icons.dart';
import '../../theme/marketplace_radius.dart';
import '../../../core/localization/locale_keys.dart';

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
    return SafeArea(
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: MarketplaceColors.surface,
          borderRadius: MarketplaceRadius.bottomNavBR,
          boxShadow: const [MarketplaceShadows.bottomNav],
        ),
        child: Row(
          children: List.generate(5, (i) => _buildTab(i)),
        ),
      ),
    );
  }

  Widget _buildTab(int index) {
    final isActive = currentIndex == index;
    final color =
        isActive ? MarketplaceColors.primary : MarketplaceColors.iconInactive;
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
              // Icon with optional cart badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    isActive ? _filledIcons[index] : _outlinedIcons[index],
                    color: color,
                    size: 24,
                  ),
                  // Cart badge
                  if (isCartTab && cartCount > 0)
                    Positioned(
                      top: -4,
                      right: -6,
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          cartCount > 99 ? '99+' : '$cartCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                _labels[index],
                style: MarketplaceTypography.navLabel.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
