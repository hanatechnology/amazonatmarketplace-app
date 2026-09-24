import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/routes/app_router.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/components/marketplace/sticky_back_bar.dart';
import '../../../../core/content/help_center_content.dart';
import '../../../../core/legal/legal_content.dart';
import '../../../../core/localization/locale_controller.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/marketplace_palette.dart';
import '../../../../core/theme/marketplace_radius.dart';
import '../../../../core/theme/marketplace_typography.dart';

/// Answers to the questions the app actually raises, then a way to reach a
/// human, then the policies.
///
/// Grouped and collapsed by default: the list is long enough that an open
/// accordion would bury the contact card, which is what someone who did not
/// find their answer is looking for.
class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  static const double _gutter = 20;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.background,
      body: StickyBackBar(
        child: SafeArea(
          bottom: false,
          child: Obx(() {
            // Rebuild on a language switch — the copy below is resolved per
            // locale rather than through translation keys.
            Get.find<LocaleController>().currentLocale.value;

            return ListView(
              padding: const EdgeInsets.fromLTRB(_gutter, 0, _gutter, 40),
              children: [
                const _NavRow(),
                const SizedBox(height: 6),
                Text(
                  LocaleKeys.helpCenter.tr,
                  style: MarketplaceTypography.heroDisplay.copyWith(
                    fontSize: 28,
                    color: palette.textPrimary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  LocaleKeys.helpCenterSubtitle.tr,
                  style: MarketplaceTypography.rowMeta.copyWith(
                    fontSize: 11,
                    color: palette.textSecondary,
                  ),
                ),
                const SizedBox(height: 18),
                for (final section in helpSections()) _Section(section: section),
                const SizedBox(height: 10),
                const _ContactCard(),
                const SizedBox(height: 18),
                _LegalRow(
                  icon: Icons.shield_outlined,
                  label: LocaleKeys.privacyPolicy.tr,
                  kind: LegalDocumentKind.privacyPolicy,
                ),
                _LegalRow(
                  icon: Icons.description_outlined,
                  label: LocaleKeys.termsOfService.tr,
                  kind: LegalDocumentKind.termsOfService,
                ),
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

  final HelpSection section;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 2, right: 2),
            child: Text(
              section.title.toUpperCase(),
              style: MarketplaceTypography.labelCaps.copyWith(
                color: palette.textMuted,
                letterSpacing: MarketplaceTypography.isArabic ? 0 : 1.3,
              ),
            ),
          ),
          for (final topic in section.topics) _TopicTile(topic: topic),
        ],
      ),
    );
  }
}

/// One question, expanding in place to its answer.
class _TopicTile extends StatefulWidget {
  const _TopicTile({required this.topic});

  final HelpTopic topic;

  @override
  State<_TopicTile> createState() => _TopicTileState();
}

class _TopicTileState extends State<_TopicTile> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return GestureDetector(
      onTap: () => setState(() => _isOpen = !_isOpen),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isOpen ? palette.brand : palette.hairline,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    widget.topic.question,
                    style: MarketplaceTypography.rowTitle.copyWith(
                      fontSize: 12.5,
                      color: palette.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                AnimatedRotation(
                  turns: _isOpen ? 0.5 : 0,
                  duration: const Duration(milliseconds: 160),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: _isOpen ? palette.brand : palette.textMuted,
                  ),
                ),
              ],
            ),
            if (_isOpen) ...[
              const SizedBox(height: 8),
              Text(
                widget.topic.answer,
                style: MarketplaceTypography.body.copyWith(
                  color: palette.textSecondary,
                  height: 1.75,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The way out of the FAQ when none of it fits.
class _ContactCard extends StatelessWidget {
  const _ContactCard();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surfaceSunken,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.stillNeedHelp.tr,
            style: MarketplaceTypography.rowTitle.copyWith(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: palette.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            LocaleKeys.stillNeedHelpBody.tr,
            style: MarketplaceTypography.rowMeta.copyWith(
              fontSize: 11.5,
              color: palette.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: _writeToSupport,
              icon: const Icon(Icons.mail_outline_rounded, size: 16),
              label: Text(
                LocaleKeys.emailSupport.tr,
                style: MarketplaceTypography.buttonLabel.copyWith(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: palette.onBrand,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: palette.brand,
                foregroundColor: palette.onBrand,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(MarketplaceRadius.full),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: _callSupport,
              icon: const Icon(Icons.phone_outlined, size: 16),
              label: Text(
                LocaleKeys.callSupport.tr,
                style: MarketplaceTypography.buttonLabel.copyWith(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: palette.textPrimary,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: palette.textPrimary,
                side: BorderSide(color: palette.hairline),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(MarketplaceRadius.full),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Both details in plain text under the buttons: a device with no mail
          // or dialler app still leaves the customer something to copy.
          Center(
            child: Column(
              children: [
                Text(
                  helpSupportEmail,
                  // Latin contact details inside Arabic keep their own
                  // direction — the bidi algorithm otherwise reorders them.
                  textDirection: TextDirection.ltr,
                  style: MarketplaceTypography.rowMeta.copyWith(
                    fontSize: 11,
                    color: palette.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  helpSupportPhone,
                  textDirection: TextDirection.ltr,
                  style: MarketplaceTypography.rowMeta.copyWith(
                    fontSize: 11,
                    color: palette.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Opens the device mail composer. Silent if no mail app is configured —
  /// the address is printed under the button either way, so the customer can
  /// still copy it.
  Future<void> _writeToSupport() async {
    final uri = Uri(
      scheme: 'mailto',
      path: helpSupportEmail,
      queryParameters: <String, String>{
        'subject': LocaleKeys.supportEmailSubject.tr,
      },
    );

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  /// Opens the dialler with the support line pre-filled. Silent if the device
  /// cannot place calls — the number is printed below the button either way.
  Future<void> _callSupport() async {
    await launchUrl(
      Uri(scheme: 'tel', path: helpSupportPhone),
      mode: LaunchMode.externalApplication,
    );
  }
}

class _LegalRow extends StatelessWidget {
  const _LegalRow({
    required this.icon,
    required this.label,
    required this.kind,
  });

  final IconData icon;
  final String label;
  final LegalDocumentKind kind;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return GestureDetector(
      onTap: () => AppRouter.toNamed<void>(
        Routes.MARKETPLACE_LEGAL,
        arguments: kind,
      ),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: palette.hairline),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: palette.surfaceSunken,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, size: 16, color: palette.textSecondary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: MarketplaceTypography.rowTitle.copyWith(
                  fontSize: 12.5,
                  color: palette.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 17,
              color: palette.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
