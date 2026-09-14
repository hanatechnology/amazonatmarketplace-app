import 'package:flutter/material.dart';

import '../../../theme/marketplace_palette.dart';
import '../../../theme/marketplace_typography.dart';
import '../../../theme/status_tone.dart';

/// Tracked caps kicker above each checkout step, with the step's validation
/// error underneath it.
///
/// Tracking is dropped in Arabic — letter-spacing only smears a joined script.
class CheckoutSectionLabel extends StatelessWidget {
  const CheckoutSectionLabel({
    super.key,
    required this.title,
    this.errorMessage,
  });

  final String title;

  /// Shown under the label when the step is missing at submit time.
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final hasError = errorMessage != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: MarketplaceTypography.labelCaps.copyWith(
            color: hasError
                ? StatusTone.danger.foreground(palette.isDark)
                : palette.textMuted,
            letterSpacing: MarketplaceTypography.isArabic ? 0 : 1.5,
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Text(
            errorMessage!,
            style: MarketplaceTypography.rowMeta.copyWith(
              fontSize: 10.5,
              color: StatusTone.danger.foreground(palette.isDark),
            ),
          ),
        ],
        const SizedBox(height: 9),
      ],
    );
  }
}
