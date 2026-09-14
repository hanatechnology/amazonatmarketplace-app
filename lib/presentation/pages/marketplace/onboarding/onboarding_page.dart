import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/marketplace_palette.dart';
import '../../../../core/theme/marketplace_radius.dart';
import '../../../../core/theme/marketplace_typography.dart';
import '../../../../data/services/storage_service.dart';
import '../splash/marketplace_splash_page.dart';

/// Three slides, shown once ever.
///
/// Each one states something the app can actually do — nothing here promises a
/// feature the contract does not back.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  int _index = 0;

  static const _slides = <(IconData, String, String)>[
    (
      Icons.handyman_outlined,
      LocaleKeys.onboard1Title,
      LocaleKeys.onboard1Body,
    ),
    (
      Icons.account_balance_wallet_outlined,
      LocaleKeys.onboard2Title,
      LocaleKeys.onboard2Body,
    ),
    (
      Icons.local_shipping_outlined,
      LocaleKeys.onboard3Title,
      LocaleKeys.onboard3Body,
    ),
  ];

  bool get _isLast => _index == _slides.length - 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _finish() {
    StorageService.instance
        .write(MarketplaceSplashPage.onboardingSeenKey, true);
    Get.offAllNamed(Routes.MARKETPLACE_JOIN);
  }

  void _next() {
    if (_isLast) {
      _finish();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 44,
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(end: 20),
                  child: _isLast
                      ? const SizedBox.shrink()
                      : GestureDetector(
                          onTap: _finish,
                          behavior: HitTestBehavior.opaque,
                          child: Text(
                            LocaleKeys.skip.tr,
                            style: MarketplaceTypography.pillLabel.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: palette.textMuted,
                            ),
                          ),
                        ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) => setState(() => _index = index),
                itemBuilder: (_, index) {
                  final slide = _slides[index];
                  return _Slide(
                    icon: slide.$1,
                    title: slide.$2.tr,
                    body: slide.$3.tr,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Dots(count: _slides.length, activeIndex: _index),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: palette.brand,
                        foregroundColor: palette.onBrand,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(MarketplaceRadius.full),
                        ),
                      ),
                      child: Text(
                        _isLast
                            ? LocaleKeys.startShopping.tr
                            : LocaleKeys.next.tr,
                        style: MarketplaceTypography.buttonLabel.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: palette.onBrand,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    child: _isLast
                        ? TextButton(
                            onPressed: _finish,
                            child: Text(
                              LocaleKeys.alreadyHaveAccount.tr,
                              style: MarketplaceTypography.buttonLabel
                                  .copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: palette.textSecondary,
                              ),
                            ),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  const _Slide({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 108,
            height: 108,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: palette.surfaceSunken,
              borderRadius: BorderRadius.circular(34),
            ),
            child: Icon(icon, size: 44, color: palette.brand),
          ),
          const SizedBox(height: 30),
          Text(
            title,
            textAlign: TextAlign.center,
            style: MarketplaceTypography.heroDisplay.copyWith(
              fontSize: 28,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            body,
            textAlign: TextAlign.center,
            style: MarketplaceTypography.rowMeta.copyWith(
              fontSize: 12.5,
              height: 1.75,
              color: palette.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Dots follow the text direction for free: in Arabic step one sits rightmost,
/// because the row itself is laid out right-to-left.
class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.activeIndex});

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == activeIndex;
        return Padding(
          padding: const EdgeInsetsDirectional.only(end: 6),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isActive ? 20 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive ? palette.brand : palette.hairline,
              borderRadius: BorderRadius.circular(MarketplaceRadius.full),
            ),
          ),
        );
      }),
    );
  }
}
