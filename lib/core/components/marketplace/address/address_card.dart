import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../domain/entities/marketplace/address_entity.dart';
import '../../../localization/locale_keys.dart';
import '../../../theme/marketplace_palette.dart';
import '../../../theme/marketplace_radius.dart';
import '../../../theme/marketplace_typography.dart';
import '../../../theme/status_tone.dart';

/// One saved address.
///
/// A saved address is not editable — the card offers "set as default" and
/// "delete" only. Correcting one means adding the right address and deleting
/// the wrong one, so a courier never reads a half-amended address.
///
/// "Set as default" lives here rather than inside the form: it is a
/// `PATCH /addresses/{id}` carrying one key, so making the customer open and
/// re-save the whole form for it — the web's only path — is unnecessary.
class AddressCard extends StatelessWidget {
  const AddressCard({
    super.key,
    required this.address,
    required this.cityName,
    required this.onDelete,
    required this.onSetDefault,
    this.onTap,
    this.isBusy = false,
  });

  final AddressEntity address;
  final String cityName;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  /// Set in pick mode, when the whole card selects an address.
  final VoidCallback? onTap;

  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = palette.isDark;
    final locality = [
      address.addressLine2 ?? '',
      cityName,
      address.state,
    ].where((part) => part.trim().isNotEmpty).join('، ');

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: isBusy ? 0.5 : 1,
        child: Container(
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: address.isDefault ? palette.brand : palette.hairline,
              width: address.isDefault ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 13, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (address.label.trim().isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: palette.surfaceSunken,
                              borderRadius: BorderRadius.circular(
                                MarketplaceRadius.full,
                              ),
                            ),
                            child: Text(
                              address.label,
                              style: MarketplaceTypography.labelCaps.copyWith(
                                fontSize: 9,
                                color: palette.textSecondary,
                                letterSpacing:
                                    MarketplaceTypography.isArabic ? 0 : 0.4,
                              ),
                            ),
                          ),
                        const Spacer(),
                        if (address.isDefault)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: StatusTone.success.background(isDark),
                              borderRadius: BorderRadius.circular(
                                MarketplaceRadius.full,
                              ),
                            ),
                            child: Text(
                              LocaleKeys.defaultBadge.tr.toUpperCase(),
                              style: MarketplaceTypography.labelCaps.copyWith(
                                fontSize: 9,
                                color:
                                    StatusTone.success.foreground(isDark),
                                letterSpacing:
                                    MarketplaceTypography.isArabic ? 0 : 0.8,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 9),
                    Text(
                      address.fullName,
                      style: MarketplaceTypography.rowTitle.copyWith(
                        fontWeight: FontWeight.w700,
                        color: palette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      address.phone,
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.left,
                      style: MarketplaceTypography.rowMeta.copyWith(
                        fontSize: 11,
                        color: palette.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      address.addressLine1,
                      style: MarketplaceTypography.rowMeta.copyWith(
                        fontSize: 11,
                        height: 1.6,
                        color: palette.textSecondary,
                      ),
                    ),
                    if (locality.isNotEmpty)
                      Text(
                        locality,
                        style: MarketplaceTypography.rowMeta.copyWith(
                          fontSize: 11,
                          height: 1.6,
                          color: palette.textSecondary,
                        ),
                      ),
                    if (address.location != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 12,
                            color: palette.textMuted,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              address.location!.address.isEmpty
                                  ? LocaleKeys.locationPinned.tr
                                  : address.location!.address,
                              style: MarketplaceTypography.rowMeta.copyWith(
                                color: palette.textMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: palette.hairline)),
                ),
                child: Row(
                  children: [
                    if (address.isDefault)
                      Text(
                        LocaleKeys.defaultAddress.tr,
                        style: MarketplaceTypography.pillLabel.copyWith(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: StatusTone.success.foreground(isDark),
                        ),
                      )
                    else
                      _Action(
                        label: LocaleKeys.setAsDefault.tr,
                        onTap: onSetDefault,
                        color: palette.brand,
                      ),
                    const Spacer(),
                    _Action(
                      label: LocaleKeys.delete.tr,
                      onTap: onDelete,
                      color: StatusTone.danger.foreground(isDark),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.label,
    required this.onTap,
    required this.color,
  });

  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Text(
        label,
        style: MarketplaceTypography.pillLabel.copyWith(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
