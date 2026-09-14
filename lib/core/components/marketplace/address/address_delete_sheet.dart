import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../domain/entities/marketplace/address_entity.dart';
import '../../../localization/locale_keys.dart';
import '../../../theme/marketplace_palette.dart';
import '../../../theme/marketplace_radius.dart';
import '../../../theme/marketplace_typography.dart';
import '../../../theme/status_tone.dart';

/// Destructive confirm, as a sheet rather than an `AlertDialog`.
///
/// It names the address being removed: a generic "are you sure" on a list of
/// several addresses does not tell the customer which one they are about to
/// lose.
class AddressDeleteSheet extends StatelessWidget {
  const AddressDeleteSheet({super.key, required this.address});

  final AddressEntity address;

  static Future<bool?> show(AddressEntity address) {
    return Get.bottomSheet<bool>(
      AddressDeleteSheet(address: address),
      isScrollControlled: true,
      backgroundColor: const Color(0x00000000),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = palette.isDark;
    final summary = [
      address.label,
      address.addressLine1,
    ].where((part) => part.trim().isNotEmpty).join(' · ');

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: palette.textMuted.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(MarketplaceRadius.full),
              ),
            ),
            const SizedBox(height: 22),
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: StatusTone.danger.background(isDark),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                size: 28,
                color: StatusTone.danger.foreground(isDark),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              LocaleKeys.deleteAddress.tr,
              textAlign: TextAlign.center,
              style: MarketplaceTypography.heroDisplay.copyWith(
                fontSize: 23,
                color: palette.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              LocaleKeys.deleteAddressConfirm.tr,
              textAlign: TextAlign.center,
              style: MarketplaceTypography.rowMeta.copyWith(
                fontSize: 12,
                height: 1.7,
                color: palette.textSecondary,
              ),
            ),
            if (summary.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: palette.surfaceSunken,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  summary,
                  textAlign: TextAlign.center,
                  style: MarketplaceTypography.rowTitle.copyWith(
                    fontSize: 12,
                    color: palette.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: OutlinedButton(
                      onPressed: () => Get.back(result: false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: palette.textSecondary,
                        side: BorderSide(color: palette.hairline),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(MarketplaceRadius.full),
                        ),
                      ),
                      child: Text(
                        LocaleKeys.cancel.tr,
                        style: MarketplaceTypography.buttonLabel.copyWith(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: palette.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            StatusTone.danger.foreground(isDark),
                        foregroundColor: palette.surface,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(MarketplaceRadius.full),
                        ),
                      ),
                      child: Text(
                        LocaleKeys.delete.tr,
                        style: MarketplaceTypography.buttonLabel.copyWith(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: palette.surface,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
