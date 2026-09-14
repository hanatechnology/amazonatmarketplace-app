import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/components/marketplace/app_network_image.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/marketplace_spacing.dart';
import '../../../../core/theme/marketplace_typography.dart';

/// Arguments for [ProductGalleryPage].
class ProductGalleryArgs {
  const ProductGalleryArgs({required this.images, this.initialIndex = 0});

  final List<String> images;
  final int initialIndex;
}

/// Fullscreen product photos: swipe between them, pinch to zoom, drag down to
/// dismiss.
///
/// Deliberately its own screen rather than a dialog — it takes the whole
/// viewport, and a route means the system back gesture closes it like every
/// other screen in the app.
///
/// The ground is always dark and the chrome always light, in both themes and
/// both languages: this screen shows photography, and a photo reads against a
/// dark surround regardless of what the rest of the app is doing.
class ProductGalleryPage extends StatefulWidget {
  const ProductGalleryPage({super.key});

  @override
  State<ProductGalleryPage> createState() => _ProductGalleryPageState();
}

class _ProductGalleryPageState extends State<ProductGalleryPage>
    with SingleTickerProviderStateMixin {
  static const Color _ground = Color(0xFF0B0F0D);
  static const Color _onGround = Color(0xFFF2F5F3);

  /// Below this the pinch is treated as "not zoomed", so a swipe still pages
  /// and a drag still dismisses.
  static const double _zoomedThreshold = 1.02;

  late final ProductGalleryArgs _args;
  late final PageController _pageController;
  late final TransformationController _zoomController;

  /// One controller drives the double-tap zoom so it animates rather than snaps.
  late final AnimationController _zoomAnimation;
  Animation<Matrix4>? _zoomTween;

  late int _index;
  bool _isZoomed = false;

  /// Vertical drag distance while dismissing, in logical pixels.
  double _dragOffset = 0;

  @override
  void initState() {
    super.initState();
    final raw = Get.arguments;
    _args = raw is ProductGalleryArgs
        ? raw
        : const ProductGalleryArgs(images: []);
    _index = _args.initialIndex.clamp(
      0,
      _args.images.isEmpty ? 0 : _args.images.length - 1,
    );
    _pageController = PageController(initialPage: _index);
    _zoomController = TransformationController()..addListener(_onZoomChanged);
    _zoomAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..addListener(() {
        final value = _zoomTween?.value;
        if (value != null) _zoomController.value = value;
      });
  }

  @override
  void dispose() {
    _zoomController.removeListener(_onZoomChanged);
    _zoomController.dispose();
    _zoomAnimation.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onZoomChanged() {
    final zoomed =
        _zoomController.value.getMaxScaleOnAxis() > _zoomedThreshold;
    if (zoomed != _isZoomed) setState(() => _isZoomed = zoomed);
  }

  void _resetZoom() {
    _zoomTween = Matrix4Tween(
      begin: _zoomController.value,
      end: Matrix4.identity(),
    ).animate(
      CurvedAnimation(parent: _zoomAnimation, curve: Curves.easeOutCubic),
    );
    _zoomAnimation.forward(from: 0);
  }

  void _handleDoubleTap(TapDownDetails details) {
    if (_isZoomed) {
      _resetZoom();
      return;
    }
    // Zoom about the point that was tapped, so the detail under the finger is
    // the detail that fills the screen.
    const scale = 2.5;
    final position = details.localPosition;
    _zoomTween = Matrix4Tween(
      begin: _zoomController.value,
      end: Matrix4.identity()
        ..translateByDouble(
          -position.dx * (scale - 1),
          -position.dy * (scale - 1),
          0,
          1,
        )
        ..scaleByDouble(scale, scale, scale, 1),
    ).animate(
      CurvedAnimation(parent: _zoomAnimation, curve: Curves.easeOutCubic),
    );
    _zoomAnimation.forward(from: 0);
  }

  void _onPageChanged(int next) {
    // Leaving a photo zoomed means the next one opens mid-zoom for no reason.
    if (_isZoomed) _zoomController.value = Matrix4.identity();
    setState(() => _index = next);
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_isZoomed) return; // panning the photo, not dismissing
    setState(() => _dragOffset += details.delta.dy);
  }

  void _onDragEnd(DragEndDetails details) {
    if (_isZoomed) return;
    final velocity = details.velocity.pixelsPerSecond.dy;
    if (_dragOffset.abs() > 120 || velocity.abs() > 700) {
      Get.back();
      return;
    }
    setState(() => _dragOffset = 0);
  }

  @override
  Widget build(BuildContext context) {
    final images = _args.images;

    // How far the drag has gone, as a fraction, used to fade the ground out.
    final progress =
        (_dragOffset.abs() / (MediaQuery.sizeOf(context).height * 0.5))
            .clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: _ground.withValues(alpha: 1 - (progress * 0.4)),
      body: Stack(
        children: [
          if (images.isEmpty)
            Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                size: 40,
                color: _onGround.withValues(alpha: 0.5),
              ),
            )
          else
            GestureDetector(
              onVerticalDragUpdate: _onDragUpdate,
              onVerticalDragEnd: _onDragEnd,
              onDoubleTapDown: _handleDoubleTap,
              onDoubleTap: () {},
              child: Transform.translate(
                offset: Offset(0, _dragOffset),
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: images.length,
                  // A zoomed photo pans instead of paging; otherwise every drag
                  // sideways would leave the picture the customer zoomed into.
                  physics: _isZoomed
                      ? const NeverScrollableScrollPhysics()
                      : const PageScrollPhysics(),
                  onPageChanged: _onPageChanged,
                  itemBuilder: (_, i) => InteractiveViewer(
                    transformationController:
                        i == _index ? _zoomController : null,
                    minScale: 1,
                    maxScale: 4,
                    child: Center(
                      child: AppNetworkImage(
                        imageUrl: images[i],
                        width: double.infinity,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // ── Chrome ──────────────────────────────────────
          PositionedDirectional(
            top: MediaQuery.paddingOf(context).top + MarketplaceSpacing.sm,
            start: MarketplaceSpacing.md,
            child: _GlassCircle(
              icon: Icons.close_rounded,
              onTap: Get.back,
              semanticLabel: LocaleKeys.close.tr,
            ),
          ),
          if (images.length > 1)
            PositionedDirectional(
              bottom: MediaQuery.paddingOf(context).bottom +
                  MarketplaceSpacing.lg,
              start: 0,
              end: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: MarketplaceSpacing.md - 4,
                    vertical: MarketplaceSpacing.xs + 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  // A counter is a figure: Latin digits, left to right, in
                  // Arabic as much as in English.
                  child: Text(
                    '${_index + 1} / ${images.length}',
                    textDirection: TextDirection.ltr,
                    style: MarketplaceTypography.rowMeta.copyWith(
                      color: _onGround,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GlassCircle extends StatelessWidget {
  const _GlassCircle({
    required this.icon,
    required this.onTap,
    required this.semanticLabel,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withValues(alpha: 0.45),
          ),
          child: Icon(
            icon,
            size: 20,
            color: _ProductGalleryPageState._onGround,
          ),
        ),
      ),
    );
  }
}
