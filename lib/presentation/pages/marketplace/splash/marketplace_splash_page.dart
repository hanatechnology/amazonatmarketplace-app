import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/marketplace_palette.dart';
import '../../../../core/theme/marketplace_radius.dart';
import '../../../../core/theme/marketplace_typography.dart';
import '../../../../data/services/push_notification_service.dart';
import '../../../../data/services/session_service.dart';
import '../../../../data/services/storage_service.dart';

/// A router with a face, not a screen the customer acts on.
///
/// A stored JWT is good for seven days, so it goes straight to Home. A customer
/// who chose to browse without an account goes there too — that choice is
/// persisted, so it is asked once, not every launch. Otherwise first launch gets
/// onboarding once, ever, and every launch after that lands on Welcome. The rail
/// is determinate because the wait is a token read, not a network call — a
/// spinner would imply otherwise.
///
/// The mark carries the screen: the knight is drawn in fine circuit traces, and
/// [_CircuitFieldPainter] continues those traces out past it. No photography —
/// a photo under this mark turns its trace detail to mud.
class MarketplaceSplashPage extends StatefulWidget {
  const MarketplaceSplashPage({super.key});

  /// Set the first time onboarding is dismissed; never shown again after.
  static const String onboardingSeenKey = 'onboarding_seen';

  @override
  State<MarketplaceSplashPage> createState() => _MarketplaceSplashPageState();
}

class _MarketplaceSplashPageState extends State<MarketplaceSplashPage> {
  @override
  void initState() {
    super.initState();
    _routeOnStartup();
  }

  Future<void> _routeOnStartup() async {
    final results = await Future.wait([
      StorageService.instance.getToken(),
      Future<void>.delayed(const Duration(milliseconds: 1600)),
    ]);
    final token = results.first as String?;

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      Get.find<DioClient>().updateToken(token);
      SessionService.to.markSignedIn();
      // Restored session: re-send the token, which may have rotated while the
      // app was closed, and route any notification the app was launched from.
      PushNotificationService.instance.registerForCurrentUser();
      Get.offAllNamed(Routes.MARKETPLACE_MAIN);
      PushNotificationService.instance.handleLaunchMessage();
      return;
    }

    // No token, but the welcome screen was already answered with "browse as a
    // guest" — the catalogue is open, so there is nothing to ask again.
    if (SessionService.to.isGuest) {
      Get.offAllNamed(Routes.MARKETPLACE_MAIN);
      return;
    }

    final seenOnboarding = StorageService.instance
            .read<bool>(MarketplaceSplashPage.onboardingSeenKey) ??
        false;
    Get.offAllNamed(
      seenOnboarding ? Routes.MARKETPLACE_JOIN : Routes.MARKETPLACE_ONBOARDING,
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    // The whole composition is drawn against the 390pt board it was designed
    // on, then scaled — the trace field and the mark must keep their ratio to
    // each other, not to the device.
    final scale = (MediaQuery.sizeOf(context).width / _SplashMetrics.boardWidth)
        .clamp(0.82, 1.18);

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Deliberately unpadded: the traces are meant to run off both
                  // edges of the screen.
                  _BrandMark(palette: palette, scale: scale),
                  // The wordmark tucks up into the field's lower margin; the
                  // traces below the mark are cleared for exactly this.
                  Transform.translate(
                    offset: Offset(0, -_SplashMetrics.wordmarkLift * scale),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            LocaleKeys.appName.tr,
                            textAlign: TextAlign.center,
                            style: MarketplaceTypography.heroDisplay.copyWith(
                              fontSize: 52,
                              color: palette.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 252),
                            child: Text(
                              LocaleKeys.splashTagline.tr,
                              textAlign: TextAlign.center,
                              style: MarketplaceTypography.rowMeta.copyWith(
                                fontSize: 12,
                                height: 1.75,
                                color: palette.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            width: 34,
                            height: 1.5,
                            decoration: BoxDecoration(
                              color: palette.brand.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            PositionedDirectional(
              start: 40,
              end: 40,
              bottom: 34,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _StartupRail(color: palette.brand, track: palette.hairline),
                  const SizedBox(height: 14),
                  Text(
                    LocaleKeys.madeInLibya.tr.toUpperCase(),
                    style: MarketplaceTypography.labelCaps.copyWith(
                      color: palette.textMuted,
                      letterSpacing: MarketplaceTypography.isArabic ? 0 : 1.5,
                    ),
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

/// Measurements of the 390pt design board, kept in one place so the painter and
/// the layout cannot drift apart.
abstract class _SplashMetrics {
  static const double boardWidth = 390;

  /// The square the trace field is drawn in, centred on the mark.
  static const double fieldSize = 390;

  /// Height of the mark itself (the asset is trimmed to the artwork).
  static const double markHeight = 119;

  /// Radius of the soft halo the mark sits on.
  static const double haloSize = 300;

  /// How far the wordmark rises into the field's lower margin.
  static const double wordmarkLift = 34;
}

/// The mark, its halo, and the circuit field that runs off both edges.
class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.palette, required this.scale});

  final MarketplacePalette palette;
  final double scale;

  /// Dark mode brightens the mark rather than recolouring it: the literal olive
  /// is too dim on the ink ground, and swapping it for flat lime would erase the
  /// circuit detail drawn inside the figure. Saturation eases off slightly so
  /// the brightened green does not read as neon.
  static const List<double> _darkMatrix = <double>[
    1.51795, 0.09269, 0.00936, 0, 0, //
    0.02755, 1.58309, 0.00936, 0, 0, //
    0.02755, 0.09269, 1.49976, 0, 0, //
    0, 0, 0, 1, 0, //
  ];

  @override
  Widget build(BuildContext context) {
    final traceColor = palette.isDark
        ? palette.accent.withValues(alpha: 0.24)
        : palette.brandDeep.withValues(alpha: 0.30);
    final nodeColor = palette.isDark
        ? palette.accent.withValues(alpha: 0.50)
        : palette.brandDeep.withValues(alpha: 0.55);
    final haloColor = palette.isDark
        ? palette.accent.withValues(alpha: 0.15)
        : palette.brandDeep.withValues(alpha: 0.10);

    final logo = Image.asset(
      'assets/images/amazonat_logo.png',
      height: _SplashMetrics.markHeight * scale,
      fit: BoxFit.contain,
      semanticLabel: LocaleKeys.appName.tr,
    );

    return SizedBox(
      width: _SplashMetrics.fieldSize * scale,
      height: _SplashMetrics.fieldSize * scale,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Symmetric about the vertical axis, so it needs no RTL mirror.
          CustomPaint(
            size: Size.square(_SplashMetrics.fieldSize * scale),
            painter: _CircuitFieldPainter(
              trace: traceColor,
              node: nodeColor,
              scale: scale,
            ),
          ),
          Container(
            width: _SplashMetrics.haloSize * scale,
            height: _SplashMetrics.haloSize * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [haloColor, haloColor.withValues(alpha: 0)],
                stops: const [0, 0.68],
              ),
            ),
          ),
          if (palette.isDark)
            ColorFiltered(
              colorFilter: const ColorFilter.matrix(_darkMatrix),
              child: logo,
            )
          else
            logo,
        ],
      ),
    );
  }
}

/// The mark's own PCB lines, continued out into the screen: two dotted rings and
/// four elbowed traces that bleed off the left and right edges, each closing on
/// a node. Everything below the mark is left clear so nothing crosses the
/// wordmark.
class _CircuitFieldPainter extends CustomPainter {
  const _CircuitFieldPainter({
    required this.trace,
    required this.node,
    required this.scale,
  });

  final Color trace;
  final Color node;
  final double scale;

  /// Elbowed traces, in board coordinates. Each list is one polyline.
  static const List<List<Offset>> _traces = <List<Offset>>[
    [Offset(0, 118), Offset(46, 118), Offset(74, 90), Offset(112, 90)],
    [Offset(390, 118), Offset(344, 118), Offset(316, 90), Offset(278, 90)],
    [Offset(0, 272), Offset(46, 272), Offset(74, 300), Offset(112, 300)],
    [Offset(390, 272), Offset(344, 272), Offset(316, 300), Offset(278, 300)],
    [Offset(0, 196), Offset(30, 196)],
    [Offset(390, 196), Offset(360, 196)],
    [Offset(195, 0), Offset(195, 30)],
    [Offset(96, 344), Offset(124, 316)],
    [Offset(294, 344), Offset(266, 316)],
  ];

  static const List<Offset> _majorNodes = <Offset>[
    Offset(112, 90),
    Offset(278, 90),
    Offset(112, 300),
    Offset(278, 300),
  ];

  static const List<Offset> _minorNodes = <Offset>[
    Offset(195, 30),
    Offset(30, 196),
    Offset(360, 196),
    Offset(124, 316),
    Offset(266, 316),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(scale);

    final strokePaint = Paint()
      ..color = trace
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final polyline in _traces) {
      final path = Path()..moveTo(polyline.first.dx, polyline.first.dy);
      for (final point in polyline.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, strokePaint);
    }

    // Dotted rings — Flutter has no dash support, so the dashes are drawn as
    // points stepped around the circumference.
    const center = Offset(195, 195);
    _drawDottedRing(canvas, center, 150, 9, 0.55, trace);
    _drawDottedRing(
        canvas,
        center,
        182,
        14,
        0.5,
        trace.withValues(
          alpha: trace.a * 0.65,
        ));

    final nodePaint = Paint()..color = node;
    for (final point in _majorNodes) {
      canvas.drawCircle(point, 3.2, nodePaint);
    }
    for (final point in _minorNodes) {
      canvas.drawCircle(point, 2.6, nodePaint);
    }

    canvas.restore();
  }

  void _drawDottedRing(
    Canvas canvas,
    Offset center,
    double radius,
    double spacing,
    double dotRadius,
    Color color,
  ) {
    final paint = Paint()..color = color;
    final count = (2 * math.pi * radius / spacing).round();
    final step = 2 * math.pi / count;
    for (var i = 0; i < count; i++) {
      final angle = i * step;
      canvas.drawCircle(
        center + Offset(math.cos(angle) * radius, math.sin(angle) * radius),
        dotRadius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_CircuitFieldPainter oldDelegate) =>
      oldDelegate.trace != trace ||
      oldDelegate.node != node ||
      oldDelegate.scale != scale;
}

/// Determinate on purpose: this bar tracks a local read that always finishes.
class _StartupRail extends StatefulWidget {
  const _StartupRail({required this.color, required this.track});

  final Color color;
  final Color track;

  @override
  State<_StartupRail> createState() => _StartupRailState();
}

class _StartupRailState extends State<_StartupRail>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..forward();

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 3,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (_, __) => ClipRRect(
          borderRadius: BorderRadius.circular(MarketplaceRadius.full),
          child: LinearProgressIndicator(
            value: _animation.value,
            minHeight: 3,
            backgroundColor: widget.track,
            valueColor: AlwaysStoppedAnimation<Color>(widget.color),
          ),
        ),
      ),
    );
  }
}
