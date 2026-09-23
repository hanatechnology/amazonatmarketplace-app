import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../data/services/session_service.dart';
import '../../../../domain/entities/marketplace/banner_entity.dart';
import '../../../../presentation/controllers/marketplace/notification_badge_controller.dart';
import '../../../localization/locale_keys.dart';
import '../../../theme/marketplace_palette.dart';
import '../../../theme/marketplace_typography.dart';
import '../banner_card.dart';
import 'package:marketplace/app/routes/app_router.dart';

/// Full-bleed hero at the top of Home: the banner carousel plus the app header
/// that sits on top of it.
///
/// The header lives inside the hero rather than above it so the artwork runs
/// under the status bar — the shape the redesign is built around. Everything
/// drawn here is light-on-photo in both themes; the scrim, not the palette,
/// guarantees the contrast.
class HomeHero extends StatelessWidget {
  const HomeHero({
    super.key,
    required this.banners,
    required this.pageController,
    required this.activeIndex,
    required this.onPageChanged,
    required this.onBannerTap,
    required this.onInteractionStart,
    required this.onInteractionEnd,
    this.height = 296,
  });

  final List<BannerEntity> banners;
  final PageController pageController;
  final int activeIndex;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<BannerEntity> onBannerTap;
  final VoidCallback onInteractionStart;
  final VoidCallback onInteractionEnd;
  final double height;

  static const Color _onArtwork = Color(0xFFECF1E3);

  /// How far the content sheet below rides up over the hero. Owned here rather
  /// than by the page, because the hero is what has to lay out around it.
  static const double sheetOverlap = 26;

  /// The page the carousel starts on.
  ///
  /// The hero pages forever in both directions: [PageView] is unbounded and the
  /// slide is picked by `(page - loopBase) % banners.length`, so page
  /// [loopBase] is always the first banner and a swipe left from it lands on
  /// the last one instead of hitting a wall. Far enough from zero that a
  /// customer cannot swipe out the other side of it.
  static const int loopBase = 100000;

  /// The banner shown on [page], for a carousel that wraps.
  static int _slideFor(int page, int count) {
    if (count <= 1) return 0;
    return ((page - loopBase) % count + count) % count;
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final topInset = MediaQuery.paddingOf(context).top;
    final totalHeight = height + topInset;

    return SizedBox(
      height: totalHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Artwork ─────────────────────────────────
          // Each slide is a [BannerCard]: artwork, scrim and the banner's own
          // CTA travel together, because all three belong to the banner rather
          // than to the carousel.
          if (banners.isEmpty)
            Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(color: palette.brandDeep),
                const BannerScrim(),
                PositionedDirectional(
                  start: 20,
                  end: 20,
                  bottom: BannerCard.copyBottom(sheetOverlap),
                  child: BannerCopy(title: LocaleKeys.homeHeroTitle.tr),
                ),
              ],
            )
          else
            GestureDetector(
              onPanDown: (_) => onInteractionStart(),
              onPanEnd: (_) => onInteractionEnd(),
              onPanCancel: onInteractionEnd,
              child: PageView.builder(
                controller: pageController,
                // Null count with a modulo lookup: the carousel wraps in both
                // directions instead of stopping dead on the last banner. A
                // single banner is not a carousel, so it stays a single page.
                itemCount: banners.length > 1 ? null : 1,
                onPageChanged: (page) =>
                    onPageChanged(_slideFor(page, banners.length)),
                itemBuilder: (_, index) {
                  final banner = banners[_slideFor(index, banners.length)];
                  return BannerCard(
                    banner: banner,
                    height: totalHeight,
                    sheetOverlap: sheetOverlap,
                    onTap: () => onBannerTap(banner),
                  );
                },
              ),
            ),

          // ── Header ──────────────────────────────────
          PositionedDirectional(
            top: topInset + 6,
            start: 20,
            end: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const _Wordmark(),
                // Notifications are bearer-only, and the web client hides the
                // bell for a logged-out visitor rather than showing an empty
                // one. Same here.
                Obx(() => SessionService.to.isSignedIn
                    ? const _HeroBell()
                    : const SizedBox.shrink()),
              ],
            ),
          ),

          // ── Slide counter ───────────────────────────
          // Stays in the chrome: it counts the carousel, not any one slide, so
          // it must not slide away with the artwork. Sits on the CTA's line.
          if (banners.length > 1)
            PositionedDirectional(
              end: 20,
              bottom: BannerCard.copyBottom(sheetOverlap),
              child: IgnorePointer(
                child: SizedBox(
                  height: kBannerCtaHeight,
                  child: Center(
                    child: Text.rich(
                      textDirection: TextDirection.ltr,
                      TextSpan(
                        text: _twoDigits(activeIndex + 1),
                        style: MarketplaceTypography.rowMeta.copyWith(
                          color: _onArtwork,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          letterSpacing: 1,
                        ),
                        children: [
                          TextSpan(
                            text: ' / ${_twoDigits(banners.length)}',
                            style: MarketplaceTypography.rowMeta.copyWith(
                              color: _onArtwork.withValues(alpha: 0.55),
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');
}

class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Text.rich(
      // A Latin wordmark keeps its own direction inside an Arabic UI.
      textDirection: TextDirection.ltr,
      TextSpan(
        text: 'amazon',
        style: MarketplaceTypography.wordmark.copyWith(
          color: HomeHero._onArtwork,
        ),
        children: [
          TextSpan(
            text: 'at',
            style: MarketplaceTypography.wordmarkEmphasis.copyWith(
              color: palette.accent,
            ),
          ),
        ],
      ),
    );
  }
}

/// Glass bell over the artwork, with the unread dot.
class _HeroBell extends StatelessWidget {
  const _HeroBell();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final controller = Get.isRegistered<NotificationBadgeController>()
        ? Get.find<NotificationBadgeController>()
        : null;

    return GestureDetector(
      onTap: () async {
        await AppRouter.toNamed(Routes.MARKETPLACE_NOTIFICATIONS);
        await controller?.loadUnreadCount();
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0x330E1310),
          border:
              Border.all(color: HomeHero._onArtwork.withValues(alpha: 0.22)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(
              Icons.notifications_none_rounded,
              size: 19,
              color: HomeHero._onArtwork,
            ),
            if (controller != null)
              // Align rather than Positioned: an Obx sits between this and the
              // Stack, and only a direct child may be positioned.
              Obx(() {
                if (controller.unreadCount <= 0) return const SizedBox.shrink();
                return Align(
                  alignment: AlignmentDirectional.topEnd,
                  child: Container(
                    margin: const EdgeInsetsDirectional.only(top: 8, end: 9),
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: palette.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
