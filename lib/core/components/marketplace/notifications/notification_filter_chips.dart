import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marketplace/core/localization/locale_keys.dart';
import 'package:marketplace/core/theme/marketplace_colors.dart';
import 'package:marketplace/core/theme/marketplace_radius.dart';
import 'package:marketplace/core/theme/marketplace_spacing.dart';
import 'package:marketplace/core/theme/marketplace_typography.dart';
import 'package:marketplace/presentation/controllers/marketplace/notifications_controller.dart';

class NotificationFilterChipsDto {
  const NotificationFilterChipsDto({
    required this.current,
    required this.onChanged,
  });

  final NotificationReadFilter current;
  final ValueChanged<NotificationReadFilter> onChanged;
}

class NotificationFilterChips extends StatelessWidget {
  const NotificationFilterChips({super.key, required this.dto});

  final NotificationFilterChipsDto dto;

  static const Map<NotificationReadFilter, String> _labels = {
    NotificationReadFilter.all: LocaleKeys.notificationsAll,
    NotificationReadFilter.unread: LocaleKeys.notificationsUnread,
    NotificationReadFilter.read: LocaleKeys.notificationsRead,
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: MarketplaceSpacing.screenPaddingH,
      ),
      child: Row(
        children: [
          for (final entry in _labels.entries) ...[
            _FilterChip(
              label: entry.value.tr,
              isSelected: dto.current == entry.key,
              onTap: () => dto.onChanged(entry.key),
            ),
            const SizedBox(width: MarketplaceSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(MarketplaceRadius.full),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: MarketplaceSpacing.md,
          vertical: MarketplaceSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? MarketplaceColors.primary
              : MarketplaceColors.surface,
          borderRadius: BorderRadius.circular(MarketplaceRadius.full),
          border: Border.all(
            color: isSelected
                ? MarketplaceColors.primary
                : MarketplaceColors.stroke,
          ),
        ),
        child: Text(
          label,
          style: MarketplaceTypography.smallButton.copyWith(
            color: isSelected
                ? MarketplaceColors.onPrimary
                : MarketplaceColors.textBody,
          ),
        ),
      ),
    );
  }
}
