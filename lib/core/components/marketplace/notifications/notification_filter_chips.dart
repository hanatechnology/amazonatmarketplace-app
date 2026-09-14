import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marketplace/core/localization/locale_keys.dart';
import 'package:marketplace/core/theme/marketplace_palette.dart';
import 'package:marketplace/core/theme/marketplace_radius.dart';
import 'package:marketplace/core/theme/marketplace_typography.dart';
import 'package:marketplace/presentation/controllers/marketplace/notifications_controller.dart';

class NotificationFilterChipsDto {
  const NotificationFilterChipsDto({
    required this.current,
    required this.onChanged,
    this.unreadCount = 0,
  });

  final NotificationReadFilter current;
  final ValueChanged<NotificationReadFilter> onChanged;

  /// Shown as a badge on the "unread" chip. Hidden at zero.
  final int unreadCount;
}

/// Read-state filter. These map to the `is_read` query param, so the list the
/// user sees is the list the server filtered — not a client-side slice of the
/// pages already fetched.
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
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: _labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final entry = _labels.entries.elementAt(index);
          return _FilterChip(
            label: entry.value.tr,
            isSelected: dto.current == entry.key,
            badge: entry.key == NotificationReadFilter.unread
                ? dto.unreadCount
                : 0,
            onTap: () => dto.onChanged(entry.key),
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badge = 0,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 32,
        padding: const EdgeInsetsDirectional.only(start: 14, end: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? palette.brand : Colors.transparent,
          borderRadius: BorderRadius.circular(MarketplaceRadius.full),
          border: Border.all(
            color: isSelected ? palette.brand : palette.hairline,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: MarketplaceTypography.pillLabel.copyWith(
                color: isSelected ? palette.onBrand : palette.textSecondary,
              ),
            ),
            if (badge > 0) ...[
              const SizedBox(width: 6),
              Container(
                constraints: const BoxConstraints(minWidth: 18),
                height: 18,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? palette.onBrand : palette.brand,
                  borderRadius: BorderRadius.circular(MarketplaceRadius.full),
                ),
                child: Text(
                  badge > 99 ? '99+' : '$badge',
                  textDirection: TextDirection.ltr,
                  style: MarketplaceTypography.rowMeta.copyWith(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                    color: isSelected ? palette.brand : palette.onBrand,
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
