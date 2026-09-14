import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../localization/locale_keys.dart';
import '../../../theme/status_tone.dart';
import '../../../../domain/entities/marketplace/order_entity.dart';

/// Pill showing an order's lifecycle status.
class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    return StatusPill(label: labelFor(status), tone: _toneFor(status));
  }

  static String labelFor(OrderStatus status) => switch (status) {
        OrderStatus.pending => LocaleKeys.statusPending.tr,
        OrderStatus.paid => LocaleKeys.statusPaid.tr,
        OrderStatus.cod => LocaleKeys.statusCod.tr,
        OrderStatus.processing => LocaleKeys.statusProcessing.tr,
        OrderStatus.shipped => LocaleKeys.statusShipped.tr,
        OrderStatus.readyForPickup => LocaleKeys.statusReadyForPickup.tr,
        OrderStatus.delivered => LocaleKeys.statusDelivered.tr,
        OrderStatus.cancelled => LocaleKeys.statusCancelled.tr,
        OrderStatus.refunded => LocaleKeys.statusRefunded.tr,
        OrderStatus.unknown => LocaleKeys.statusUnknown.tr,
      };

  static StatusTone _toneFor(OrderStatus status) => switch (status) {
        OrderStatus.pending => StatusTone.warning,
        OrderStatus.paid ||
        OrderStatus.cod ||
        OrderStatus.processing ||
        OrderStatus.shipped ||
        OrderStatus.readyForPickup =>
          StatusTone.info,
        OrderStatus.delivered => StatusTone.success,
        OrderStatus.cancelled || OrderStatus.refunded => StatusTone.danger,
        OrderStatus.unknown => StatusTone.neutral,
      };
}
