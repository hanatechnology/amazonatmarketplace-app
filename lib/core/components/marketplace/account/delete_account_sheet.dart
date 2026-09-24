import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../localization/locale_keys.dart';
import '../../../theme/marketplace_palette.dart';
import '../../../theme/marketplace_radius.dart';
import '../../../theme/marketplace_spacing.dart';
import '../../../theme/marketplace_typography.dart';
import '../../../theme/status_tone.dart';

/// Confirmation for erasing the account.
///
/// Deliberately heavier than a yes/no: the request cannot be undone from the
/// app — it deactivates the account on the spot, which locks the customer out
/// of the only screen that could reverse it — so what happens, what survives,
/// and how long the grace period runs are all stated before the button is
/// reachable. Returns true only when the destructive action was chosen.
Future<bool> showDeleteAccountSheet(BuildContext context) async {
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    // An accidental swipe must not be able to answer this.
    isDismissible: true,
    builder: (sheetContext) => const _DeleteAccountSheet(),
  );

  return confirmed ?? false;
}

class _DeleteAccountSheet extends StatefulWidget {
  const _DeleteAccountSheet();

  @override
  State<_DeleteAccountSheet> createState() => _DeleteAccountSheetState();
}

class _DeleteAccountSheetState extends State<_DeleteAccountSheet> {
  /// The customer has to arm the button. A destructive, irreversible action
  /// sitting one tap away under a chevron row is how it gets hit by mistake.
  bool _acknowledged = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = palette.isDark;
    final danger = StatusTone.danger.foreground(isDark);

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            MarketplaceSpacing.lg,
            MarketplaceSpacing.md,
            MarketplaceSpacing.lg,
            MarketplaceSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: palette.hairline,
                    borderRadius: BorderRadius.circular(MarketplaceRadius.full),
                  ),
                ),
              ),
              const SizedBox(height: MarketplaceSpacing.md),
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: StatusTone.danger.background(isDark),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: danger,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      LocaleKeys.deleteAccount.tr,
                      style: MarketplaceTypography.sectionDisplay.copyWith(
                        color: palette.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: MarketplaceSpacing.sm),
              Text(
                LocaleKeys.deleteAccountBody.tr,
                style: MarketplaceTypography.body.copyWith(
                  color: palette.textSecondary,
                ),
              ),
              const SizedBox(height: MarketplaceSpacing.md),
              _Point(text: LocaleKeys.deleteAccountPointAccess.tr),
              _Point(text: LocaleKeys.deleteAccountPointGrace.tr),
              _Point(text: LocaleKeys.deleteAccountPointOrders.tr),
              const SizedBox(height: MarketplaceSpacing.md),
              _Acknowledge(
                value: _acknowledged,
                onChanged: (value) => setState(() => _acknowledged = value),
              ),
              const SizedBox(height: MarketplaceSpacing.md),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _acknowledged
                      ? () => Navigator.of(context).pop(true)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: danger,
                    foregroundColor: palette.onBrand,
                    disabledBackgroundColor: palette.surfaceSunken,
                    disabledForegroundColor: palette.textMuted,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(MarketplaceRadius.full),
                    ),
                  ),
                  child: Text(
                    LocaleKeys.deleteAccountConfirm.tr,
                    style: MarketplaceTypography.buttonLabel.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _acknowledged
                          ? palette.onBrand
                          : palette.textMuted,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    LocaleKeys.cancel.tr,
                    style: MarketplaceTypography.buttonLabel.copyWith(
                      fontSize: 13,
                      color: palette.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One consequence of deleting, as a bulleted line.
class _Point extends StatelessWidget {
  const _Point({required this.text});

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
            padding: const EdgeInsetsDirectional.only(top: 6, end: 9),
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: palette.textMuted,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: MarketplaceTypography.rowMeta.copyWith(
                fontSize: 11.5,
                color: palette.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Acknowledge extends StatelessWidget {
  const _Acknowledge({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final danger = StatusTone.danger.foreground(palette.isDark);

    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: value ? danger : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: value ? danger : palette.hairline,
                width: 1.4,
              ),
            ),
            child: value
                ? Icon(Icons.check_rounded, size: 13, color: palette.onBrand)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              LocaleKeys.deleteAccountAcknowledge.tr,
              style: MarketplaceTypography.rowMeta.copyWith(
                fontSize: 11.5,
                color: palette.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
