import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import '../../localization/locale_keys.dart';
import '../../theme/marketplace_palette.dart';

/// Pins the back control to the top of a scrolling page.
///
/// Every screen in the app used to draw its own back button as the first row
/// inside its scroll view, which meant leaving a long screen — a product, a
/// checkout, an address form — required scrolling all the way back up first.
/// This lifts just that one control out of the scroll and pins it, so going
/// back costs one tap from anywhere on the page.
///
/// Only the back button is pinned. Each page keeps its own header row, actions
/// and title scrolling as before; the row simply reserves the button's place
/// with a [BackButtonSlot] so nothing shifts when the page is at the top.
/// How the pinned chip is painted.
enum StickyBackTone {
  /// Card surface with a hairline — the app's normal control, on normal ground.
  surface,

  /// Dark translucent with a light chevron, for pages whose top is a photo:
  /// the seller banner and the product hero. A white circle on a bright
  /// photograph disappears; this one holds against anything.
  glass,
}

class StickyBackBar extends StatefulWidget {
  const StickyBackBar({
    super.key,
    required this.child,
    this.onBack,
    this.startInset = 20,
    this.topOffset = 4,
    this.tone = StickyBackTone.surface,
  });

  /// The page body. Normally the scroll view the button now floats over.
  final Widget child;

  /// Defaults to popping the route.
  final VoidCallback? onBack;

  /// Distance from the start edge, matching the page's own gutter.
  final double startInset;

  /// Extra distance below the status bar, matching the page's header padding.
  final double topOffset;

  final StickyBackTone tone;

  /// Height of the button, and so of the gap a page's header must reserve.
  static const double slot = 38;

  /// Scroll distance over which the backdrop reaches full strength.
  static const double _scrimRamp = 48;

  @override
  State<StickyBackBar> createState() => _StickyBackBarState();
}

class _StickyBackBarState extends State<StickyBackBar> {
  double _scrim = 0;

  bool _onScroll(ScrollNotification notification) {
    // Only the page's own vertical scroll tints the bar. A category rail or a
    // nested horizontal list is not the page moving under the button, and
    // letting either drive the scrim makes it flicker on sideways swipes.
    if (notification.depth != 0) return false;
    if (notification.metrics.axis != Axis.vertical) return false;

    final next = (notification.metrics.pixels / StickyBackBar._scrimRamp)
        .clamp(0.0, 1.0);
    _setScrim(next);
    return false;
  }

  /// A scroll notification can be dispatched *during* layout — a controller
  /// with an initial offset, `Scrollable.ensureVisible`, or the keyboard
  /// resizing the viewport all do it. Calling `setState` in that phase throws
  /// "Build scheduled during frame", so there the update waits for the frame
  /// to end. One frame of latency on a fading backdrop is invisible.
  void _setScrim(double next) {
    if ((next - _scrim).abs() < 0.01) return;

    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _scrim = next);
      });
      return;
    }
    setState(() => _scrim = next);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final topPadding = MediaQuery.paddingOf(context).top;

    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: _onScroll,
          child: widget.child,
        ),

        // Transparent while the page is at the top; a soft wash of the page
        // ground fades in as content passes beneath, so the chevron stays
        // readable over a product photo. Never a hard edge — the gradient
        // dissolves into the content instead of drawing a bar.
        if (widget.tone == StickyBackTone.surface)
          IgnorePointer(
            child: AnimatedOpacity(
              opacity: _scrim,
              duration: const Duration(milliseconds: 160),
              child: Container(
                height: topPadding + widget.topOffset + StickyBackBar.slot + 14,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      palette.background,
                      palette.background.withValues(alpha: 0.92),
                      palette.background.withValues(alpha: 0),
                    ],
                    stops: const [0, 0.55, 1],
                  ),
                ),
              ),
            ),
          ),

        PositionedDirectional(
          top: topPadding + widget.topOffset,
          start: widget.startInset,
          child: _BackChip(
            onTap: widget.onBack ?? Get.back,
            tone: widget.tone,
          ),
        ),
      ],
    );
  }
}

/// The button itself — the same 38px circle every screen already used, so
/// pinning it changed where it lives, not what it looks like.
class _BackChip extends StatelessWidget {
  const _BackChip({required this.onTap, required this.tone});

  final VoidCallback onTap;
  final StickyBackTone tone;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isGlass = tone == StickyBackTone.glass;

    // Fixed, not palette-driven: these sit on photography, which has no theme.
    const glassFill = Color(0x730E1310);
    const glassInk = Color(0xFFECF1E3);

    return Semantics(
      button: true,
      label: LocaleKeys.back.tr,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: StickyBackBar.slot,
          height: StickyBackBar.slot,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isGlass ? glassFill : palette.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color:
                  isGlass ? glassInk.withValues(alpha: 0.30) : palette.hairline,
            ),
          ),
          // A back chevron points, so it mirrors. Material flips this one
          // itself under RTL — adding a manual ternary double-flips it and
          // sends the arrow the wrong way in Arabic.
          child: Icon(
            Icons.chevron_left_rounded,
            size: 22,
            color: isGlass ? glassInk : palette.textPrimary,
          ),
        ),
      ),
    );
  }
}

/// The hole the pinned button sits over.
///
/// A page's header row keeps its original shape — the actions stay where they
/// were — but the leading control is now drawn by [StickyBackBar] on top of
/// this gap rather than by the row itself.
class BackButtonSlot extends StatelessWidget {
  const BackButtonSlot({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox(
        width: StickyBackBar.slot,
        height: StickyBackBar.slot,
      );
}
