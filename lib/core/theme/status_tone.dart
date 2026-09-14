import 'package:flutter/material.dart';

import 'marketplace_palette.dart';
import 'marketplace_radius.dart';
import 'marketplace_typography.dart';

/// Semantic colour pair for a status pill, in both themes.
///
/// These live outside [MarketplacePalette] because they are washes, not
/// surfaces: pale tints on paper, translucent tints on ink. Order, refund and
/// payout badges all read from here so one status never means two colours.
@immutable
class StatusTone {
  const StatusTone._({
    required this.lightBackground,
    required this.lightForeground,
    required this.darkBackground,
    required this.darkForeground,
  });

  final Color lightBackground;
  final Color lightForeground;
  final Color darkBackground;
  final Color darkForeground;

  Color background(bool isDark) => isDark ? darkBackground : lightBackground;

  Color foreground(bool isDark) => isDark ? darkForeground : lightForeground;

  /// Waiting on someone — pending, under review.
  static const warning = StatusTone._(
    lightBackground: Color(0xFFFFF4E5),
    lightForeground: Color(0xFF9A6400),
    darkBackground: Color(0x3D9A6400),
    darkForeground: Color(0xFFE8B767),
  );

  /// In motion — paid, processing, shipped, awaiting payout.
  static const info = StatusTone._(
    lightBackground: Color(0xFFE8F1FF),
    lightForeground: Color(0xFF2F72C9),
    darkBackground: Color(0x334897FF),
    darkForeground: Color(0xFF8FBEFF),
  );

  /// Landed well — delivered, refunded, completed.
  static const success = StatusTone._(
    lightBackground: Color(0xFFE6F7E8),
    lightForeground: Color(0xFF1F7A2E),
    darkBackground: Color(0x381F7A2E),
    darkForeground: Color(0xFF8FD79C),
  );

  /// Ended badly — cancelled, rejected, declined.
  static const danger = StatusTone._(
    lightBackground: Color(0xFFFDE8E8),
    lightForeground: Color(0xFFB4271C),
    darkBackground: Color(0x33D92D20),
    darkForeground: Color(0xFFF19C93),
  );

  /// Unknown to the client — a status the API added since this build.
  static const neutral = StatusTone._(
    lightBackground: Color(0xFFEAEAEA),
    lightForeground: Color(0xFF767676),
    darkBackground: Color(0x1FECF1E3),
    darkForeground: Color(0xA6ECF1E3),
  );
}

/// Tracked-caps pill used for every lifecycle status in the app.
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, required this.tone});

  final String label;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    final isDark = context.palette.isDark;

    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tone.background(isDark),
        borderRadius: BorderRadius.circular(MarketplaceRadius.full),
      ),
      child: Text(
        label.toUpperCase(),
        style: MarketplaceTypography.labelCaps.copyWith(
          color: tone.foreground(isDark),
          letterSpacing: 1.1,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
