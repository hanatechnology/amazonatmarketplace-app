import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/components/marketplace/sticky_back_bar.dart';
import '../../../../core/legal/legal_content.dart';
import '../../../../core/localization/locale_controller.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/marketplace_palette.dart';
import '../../../../core/theme/marketplace_typography.dart';

/// Renders one policy — privacy or terms — from [legalDocument].
///
/// Which document is decided by the route argument, so both policies share this
/// screen rather than existing as two near-identical pages.
class LegalDocumentPage extends StatelessWidget {
  const LegalDocumentPage({super.key});

  static const double _gutter = 20;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final kind = Get.arguments is LegalDocumentKind
        ? Get.arguments as LegalDocumentKind
        : LegalDocumentKind.privacyPolicy;

    // Obx, so switching language from the account tab and coming back — or
    // switching it while this screen is open — swaps the text, not just the
    // direction of the layout around it.
    return Scaffold(
      backgroundColor: palette.background,
      body: StickyBackBar(
        child: SafeArea(
          bottom: false,
          child: Obx(() {
            // Read the locale observable so the rebuild is driven by it; the
            // document itself is resolved from `Get.locale` inside.
            Get.find<LocaleController>().currentLocale.value;
            final document = legalDocument(kind);

            return ListView(
              padding: const EdgeInsets.fromLTRB(_gutter, 0, _gutter, 48),
              children: [
                const _NavRow(),
                const SizedBox(height: 6),
                Text(
                  document.title,
                  style: MarketplaceTypography.heroDisplay.copyWith(
                    fontSize: 28,
                    color: palette.textPrimary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  LocaleKeys.lastUpdatedOn
                      .trParams({'date': document.lastUpdated}),
                  style: MarketplaceTypography.rowMeta.copyWith(
                    fontSize: 11,
                    color: palette.textMuted,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  document.intro,
                  style: MarketplaceTypography.body.copyWith(
                    color: palette.textSecondary,
                    height: 1.75,
                  ),
                ),
                const SizedBox(height: 8),
                for (final section in document.sections)
                  _Section(section: section),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: const BackButtonSlot(),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.section});

  final LegalSection section;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: MarketplaceTypography.rowTitle.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: palette.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          for (final paragraph in section.paragraphs)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                paragraph,
                style: MarketplaceTypography.body.copyWith(
                  color: palette.textSecondary,
                  height: 1.75,
                ),
              ),
            ),
          for (final bullet in section.bullets) _Bullet(text: bullet),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 8, end: 10),
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: palette.brand,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: MarketplaceTypography.body.copyWith(
                color: palette.textSecondary,
                height: 1.75,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
