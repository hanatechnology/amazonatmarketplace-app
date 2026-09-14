import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../localization/locale_keys.dart';
import '../../../theme/marketplace_palette.dart';
import '../../../theme/marketplace_radius.dart';
import '../../../theme/marketplace_typography.dart';

class CheckoutAddressDto {
  const CheckoutAddressDto({
    required this.id,
    required this.label,
    required this.street,
    required this.city,
    this.phone,
    this.isDefault = false,
  });

  final String id;
  final String label;
  final String street;
  final String city;

  /// Shown after the street line, always Latin-digit and left-to-right.
  final String? phone;

  final bool isDefault;
}

/// One saved address, selectable. Selection is carried by the radio and a
/// 1.5px brand border rather than a fill — a filled card at this size reads as
/// a banner, not a choice.
class CheckoutAddressCard extends StatelessWidget {
  const CheckoutAddressCard({
    super.key,
    required this.address,
    required this.isSelected,
    required this.onTap,
  });

  final CheckoutAddressDto address;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? palette.brand : palette.hairline,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Radio(isSelected: isSelected),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    address.label,
                    style: MarketplaceTypography.rowTitle.copyWith(
                      color: palette.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  _Detail(address: address),
                ],
              ),
            ),
            if (address.isDefault) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: palette.surfaceSunken,
                  borderRadius: BorderRadius.circular(MarketplaceRadius.full),
                ),
                child: Text(
                  LocaleKeys.defaultBadge.tr,
                  style: MarketplaceTypography.labelCaps.copyWith(
                    fontSize: 9,
                    color: palette.textSecondary,
                    letterSpacing: MarketplaceTypography.isArabic ? 0 : 0.4,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Street, city and phone on one wrapped line. The phone keeps its own LTR run
/// so `+218 91 …` cannot be reordered inside an Arabic sentence.
class _Detail extends StatelessWidget {
  const _Detail({required this.address});

  final CheckoutAddressDto address;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final style = MarketplaceTypography.rowMeta.copyWith(
      fontSize: 10.5,
      height: 1.6,
      color: palette.textSecondary,
    );

    final location = [address.street, address.city]
        .where((part) => part.trim().isNotEmpty)
        .join('، ');
    final phone = address.phone?.trim() ?? '';

    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: location),
          if (phone.isNotEmpty)
            // U+2066 LRI … U+2069 PDI — a bidi isolate around the number, so
            // `+218 91 …` cannot be reordered by the Arabic text around it.
            TextSpan(text: ' · \u{2066}$phone\u{2069}'),
        ],
      ),
      textDirection: Directionality.of(context),
    );
  }
}

class _Radio extends StatelessWidget {
  const _Radio({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      width: 19,
      height: 19,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? palette.brand : palette.hairline,
          width: 1.6,
        ),
      ),
      child: isSelected
          ? Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: palette.brand,
                shape: BoxShape.circle,
              ),
            )
          : null,
    );
  }
}
