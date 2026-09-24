import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/components/marketplace/app_network_image.dart';
import '../../../../core/components/marketplace/orders/order_progress_rail.dart';
import '../../../../core/components/marketplace/orders/order_section_card.dart';
import '../../../../core/components/marketplace/orders/order_status_badge.dart';
import '../../../../core/components/marketplace/refunds/refund_strip.dart';
import '../../../../core/components/marketplace/refunds/refund_tracker.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/marketplace_palette.dart';
import '../../../../core/theme/marketplace_radius.dart';
import '../../../../core/theme/marketplace_spacing.dart';
import '../../../../core/theme/marketplace_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../domain/entities/marketplace/address_entity.dart';
import '../../../../domain/entities/marketplace/order_entity.dart';
import '../../../controllers/marketplace/order_details_controller.dart';
import 'package:marketplace/app/routes/app_router.dart';

/// One order in full: progress, items, store, money, address — and a single
/// sticky action chosen by the order's status.
class OrderDetailsPage extends GetView<OrderDetailsController> {
  const OrderDetailsPage({super.key});

  static const double _gutter = 20.0;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Same reason as the list: undo home's light-glyph override.
      value: palette.isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarBrightness: Brightness.light,
            ),
      child: Scaffold(
        backgroundColor: palette.background,
        body: SafeArea(
          bottom: false,
          child: Obx(() {
            final state = controller.stateFor<OrderEntity>(kOrderDetails);
            return state.value.when(
              onInitial: () => const _DetailsLoading(),
              onLoading: () => const _DetailsLoading(),
              onSuccess: (order, _) => _DetailsBody(order: order),
              onError: (message, _) => _DetailsError(message: message),
            );
          }),
        ),
      ),
    );
  }
}

class _DetailsLoading extends StatelessWidget {
  const _DetailsLoading();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(color: context.palette.brand),
    );
  }
}

class _DetailsBody extends GetView<OrderDetailsController> {
  const _DetailsBody({required this.order});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final action = _OrderAction.forOrder(order);

    return Column(
      children: [
        const _DetailsTopBar(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: controller.refreshOrderDetails,
            color: palette.brand,
            backgroundColor: palette.surface,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                OrderDetailsPage._gutter,
                4,
                OrderDetailsPage._gutter,
                action == null ? MarketplaceSpacing.xl : MarketplaceSpacing.md,
              ),
              children: [
                _Header(order: order),

                // The refund's state, directly under the order's status pill —
                // the one place it cannot be missed. Tapping it scrolls to the
                // tracker below.
                if (order.headlineRefund != null) ...[
                  const SizedBox(height: 11),
                  RefundStrip(
                    refund: order.headlineRefund!,
                    onTap: () => controller.scrollToRefundTracker(),
                  ),
                ],

                if (OrderProgressRail.stepFor(order.status) != null) ...[
                  const SizedBox(height: 10),
                  OrderSectionCard(
                    title: LocaleKeys.orderProgress.tr,
                    child: OrderProgressRail(status: order.status),
                  ),
                ],

                // Above the items, not below them. When a refund is running it
                // is what the customer opened this screen to see; the order's
                // contents are context for it, not the other way round.
                if (order.refunds.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  KeyedSubtree(
                    key: controller.refundTrackerKey,
                    child: RefundTracker(refunds: order.refunds),
                  ),
                ],

                // Delivered, nothing refunded, nothing in flight: explain the
                // process before the sticky button asks them to start it.
                if (order.canRequestRefund) ...[
                  const SizedBox(height: 10),
                  const RefundEligibleCard(),
                ],

                const SizedBox(height: 10),
                _ItemsCard(items: order.items),
                if (order.vendorName.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _StoreCard(order: order),
                ],
                const SizedBox(height: 10),
                _TotalsCard(order: order),
                if (order.shippingAddress != null) ...[
                  const SizedBox(height: 10),
                  _AddressCard(address: order.shippingAddress!),
                ],
                const SizedBox(height: MarketplaceSpacing.md),
              ],
            ),
          ),
        ),
        if (action != null) _ActionBar(order: order, action: action),
      ],
    );
  }
}

/// Back control + the screen's own small title. The big type on this screen is
/// the order number, so the bar stays quiet.
class _DetailsTopBar extends StatelessWidget {
  const _DetailsTopBar();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        OrderDetailsPage._gutter,
        4,
        OrderDetailsPage._gutter,
        0,
      ),
      child: SizedBox(
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: GestureDetector(
                onTap: Get.back,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: palette.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: palette.hairline),
                  ),
                  child: Icon(
                    Icons.chevron_left_rounded,
                    size: 22,
                    color: palette.textPrimary,
                  ),
                ),
              ),
            ),
            Text(
              LocaleKeys.orderDetails.tr,
              style: MarketplaceTypography.sectionDisplay.copyWith(
                fontSize: 15,
                color: palette.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.order});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final reason = order.cancellationReason?.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        Text(
          '${LocaleKeys.orderNumber.tr}${order.orderNumber}',
          // Latin token — keep it whole rather than letting the hash flip.
          textDirection: TextDirection.ltr,
          style: MarketplaceTypography.heroDisplay.copyWith(
            fontSize: 27,
            color: palette.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            OrderStatusBadge(status: order.status),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                LocaleKeys.orderPlacedOn.trParams({
                  'date': DateFormatter.dateWithTime(order.createdAt),
                }),
                style: MarketplaceTypography.rowMeta.copyWith(
                  color: palette.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        // A cancellation reason belongs next to the status, not in a card at
        // the bottom of a long scroll where it would be missed.
        if (reason != null && reason.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: palette.surfaceSunken,
              borderRadius: BorderRadius.circular(MarketplaceRadius.md),
              border: Border.all(color: palette.hairline),
            ),
            child: Text(
              '${LocaleKeys.cancellationReason.tr}: $reason',
              style: MarketplaceTypography.rowMeta.copyWith(
                fontSize: 11.5,
                color: palette.textSecondary,
              ),
            ),
          ),
        ],
        const SizedBox(height: 4),
      ],
    );
  }
}

class _ItemsCard extends StatelessWidget {
  const _ItemsCard({required this.items});

  final List<OrderItemEntity> items;

  @override
  Widget build(BuildContext context) {
    return OrderSectionCard(
      title: LocaleKeys.itemsCountOne.trPluralParams(
        LocaleKeys.itemsCount,
        items.length,
        {'count': '${items.length}'},
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++)
            _ItemRow(item: items[i], showDivider: i > 0),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item, required this.showDivider});

  final OrderItemEntity item;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: EdgeInsets.only(top: showDivider ? 10 : 0, bottom: 10),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(top: BorderSide(color: palette.hairline))
            : null,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 52,
              height: 52,
              color: palette.surfaceSunken,
              child: AppNetworkImage(
                imageUrl: item.imageUrl ?? '',
                width: 52,
                height: 52,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.name,
                  style: MarketplaceTypography.cardHeading.copyWith(
                    color: palette.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '${item.quantity} × ${PriceFormatter.formatWithUnit(item.unitPrice)}',
                  textDirection: TextDirection.ltr,
                  style: MarketplaceTypography.rowMeta.copyWith(
                    color: palette.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            PriceFormatter.amount(item.lineTotal),
            textDirection: TextDirection.ltr,
            style: MarketplaceTypography.priceDisplay.copyWith(
              fontSize: 16,
              color: palette.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// The selling store, with a way through to its page. The order payload
/// carries the vendor id and name only.
class _StoreCard extends StatelessWidget {
  const _StoreCard({required this.order});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return OrderSectionCard(
      child: GestureDetector(
        onTap: order.vendorId.isEmpty
            ? null
            : () => AppRouter.toNamed(
                  Routes.MARKETPLACE_SELLER,
                  arguments: order.vendorId,
                ),
        behavior: HitTestBehavior.opaque,
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
              clipBehavior: Clip.antiAlias,
              // The glyph is the fallback; the detail payload carries the
              // store's own logo and the customer recognises the shop by it.
              child: order.vendorLogoUrl.isEmpty
                  ? Icon(
                      Icons.storefront_outlined,
                      size: 18,
                      color: palette.textSecondary,
                    )
                  : AppNetworkImage(
                      imageUrl: order.vendorLogoUrl,
                      width: 34,
                      height: 34,
                      borderRadius: 11,
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    order.vendorName,
                    style: MarketplaceTypography.rowTitle.copyWith(
                      color: palette.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    LocaleKeys.soldShippedBy.tr,
                    style: MarketplaceTypography.rowMeta.copyWith(
                      color: palette.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (order.vendorId.isNotEmpty)
              Text(
                LocaleKeys.viewStore.tr.toUpperCase(),
                style: MarketplaceTypography.linkCaps.copyWith(
                  color: palette.brand,
                  letterSpacing: 0.6,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TotalsCard extends StatelessWidget {
  const _TotalsCard({required this.order});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return OrderSectionCard(
      title: LocaleKeys.orderSummary.tr,
      child: Column(
        children: [
          _Row(
            label: LocaleKeys.subtotal.tr,
            value: PriceFormatter.formatWithUnit(order.subtotal),
            isNumeric: true,
          ),
          _Row(
            label: LocaleKeys.shippingFee.tr,
            value: PriceFormatter.formatWithUnit(order.shippingFee),
            isNumeric: true,
          ),
          _Row(
            label: LocaleKeys.paymentMethod.tr,
            value: paymentLabel(order.paymentMethod),
          ),
          Container(
            margin: const EdgeInsets.only(top: 6),
            padding: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: palette.hairline)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    LocaleKeys.totalPaid.tr,
                    style: MarketplaceTypography.rowTitle.copyWith(
                      color: palette.textPrimary,
                    ),
                  ),
                ),
                Text.rich(
                  textDirection: TextDirection.ltr,
                  TextSpan(
                    text: PriceFormatter.amount(order.totalAmount),
                    style: MarketplaceTypography.priceDisplay.copyWith(
                      fontSize: 22,
                      color: palette.textPrimary,
                    ),
                    children: [
                      TextSpan(
                        text: ' ${PriceFormatter.unit()}',
                        style: MarketplaceTypography.priceUnit.copyWith(
                          color: palette.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// The API's payment methods are brand names (EDFALI, STRIPE), so they are
  /// shown as-is rather than translated — only the delivery option reads as a
  /// phrase and gets a localized label.
  static String paymentLabel(PaymentMethod method) => switch (method) {
        PaymentMethod.plutu => 'Plutu',
        PaymentMethod.sadad => 'Sadad',
        PaymentMethod.paypal => 'PayPal',
        PaymentMethod.stripe => 'Stripe',
        PaymentMethod.edfali => 'Edfali',
        PaymentMethod.payOnDelivery => LocaleKeys.statusCod.tr,
        PaymentMethod.unknown => LocaleKeys.statusUnknown.tr,
      };
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.address});

  final AddressEntity address;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final region = [address.state, address.country]
        .where((part) => part.isNotEmpty)
        .join(', ');

    final lines = <String>[
      address.addressLine1,
      address.addressLine2 ?? '',
      region,
      address.phone,
    ].where((line) => line.isNotEmpty).toList();

    return OrderSectionCard(
      title: LocaleKeys.shippingAddress.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 14,
                color: palette.textMuted,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  address.fullName.isNotEmpty
                      ? address.fullName
                      : address.label,
                  style: MarketplaceTypography.rowTitle.copyWith(
                    color: palette.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                line,
                style: MarketplaceTypography.rowMeta.copyWith(
                  fontSize: 11.5,
                  height: 1.45,
                  color: palette.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    this.isNumeric = false,
  });

  final String label;
  final String value;

  /// Money and other Latin-digit runs keep their own direction inside Arabic.
  final bool isNumeric;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: MarketplaceTypography.body.copyWith(
                fontSize: 12,
                color: palette.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            textDirection: isNumeric ? TextDirection.ltr : null,
            style: MarketplaceTypography.body.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: palette.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Which single action this order affords, if any. Mirrors what the API will
/// actually accept: cancel on pending, refund once delivered and not already
/// refunded or mid-request.
enum _OrderAction {
  cancel,
  requestRefund,
  viewStore;

  static _OrderAction? forOrder(OrderEntity order) {
    if (order.canCancel) return _OrderAction.cancel;
    if (order.canRequestRefund) return _OrderAction.requestRefund;
    if (order.status == OrderStatus.cancelled ||
        order.status == OrderStatus.refunded ||
        order.status == OrderStatus.unknown) {
      return null;
    }
    return order.vendorId.isEmpty ? null : _OrderAction.viewStore;
  }
}

class _ActionBar extends GetView<OrderDetailsController> {
  const _ActionBar({required this.order, required this.action});

  final OrderEntity order;
  final _OrderAction action;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isCancel = action == _OrderAction.cancel;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        OrderDetailsPage._gutter,
        14,
        OrderDetailsPage._gutter,
        0,
      ),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(top: BorderSide(color: palette.hairline)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Obx(() {
            // Read the observable before the && — short-circuiting it means an
            // Obx with no reactive read, which GetX reports as improper use.
            final isCancelling = controller.isCancelling;
            final busy = isCancel && isCancelling;

            return SizedBox(
              height: 46,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: busy ? null : () => _onPressed(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: palette.brand,
                  foregroundColor: palette.onBrand,
                  disabledBackgroundColor:
                      palette.brand.withValues(alpha: 0.55),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(MarketplaceRadius.full),
                  ),
                ),
                child: busy
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: palette.onBrand,
                        ),
                      )
                    : Text(
                        _label,
                        style: MarketplaceTypography.buttonLabel.copyWith(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: palette.onBrand,
                        ),
                      ),
              ),
            );
          }),
        ),
      ),
    );
  }

  String get _label => switch (action) {
        _OrderAction.cancel => LocaleKeys.cancelOrder.tr,
        _OrderAction.requestRefund => LocaleKeys.requestRefund.tr,
        _OrderAction.viewStore => LocaleKeys.viewStore.tr,
      };

  void _onPressed(BuildContext context) {
    switch (action) {
      case _OrderAction.cancel:
        _confirmCancel(context);
      case _OrderAction.requestRefund:
        AppRouter.toNamed(Routes.MARKETPLACE_REFUND_REQUEST, arguments: order);
      case _OrderAction.viewStore:
        AppRouter.toNamed(Routes.MARKETPLACE_SELLER, arguments: order.vendorId);
    }
  }

  /// Bottom sheet rather than the web's `confirm()` — it also collects the
  /// optional reason the cancel endpoint accepts.
  void _confirmCancel(BuildContext context) {
    Get.bottomSheet(
      _CancelOrderSheet(
        onConfirm: (reason) {
          Get.back();
          controller.cancelOrder(reason: reason);
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

/// The cancel confirmation, as a widget rather than a pre-built tree handed to
/// `Get.bottomSheet`.
///
/// A tree built at the call site freezes whatever it read from the calling
/// context: the palette stops following a theme change while the sheet is up,
/// and the keyboard inset never updates, so the reason field ends up behind the
/// keyboard. Reading both inside `build` fixes each.
class _CancelOrderSheet extends StatefulWidget {
  const _CancelOrderSheet({required this.onConfirm});

  final ValueChanged<String> onConfirm;

  @override
  State<_CancelOrderSheet> createState() => _CancelOrderSheetState();
}

class _CancelOrderSheetState extends State<_CancelOrderSheet> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: EdgeInsets.only(
        left: MarketplaceSpacing.lg,
        right: MarketplaceSpacing.lg,
        top: MarketplaceSpacing.lg,
        bottom: MediaQuery.viewInsetsOf(context).bottom + MarketplaceSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
          Text(
            LocaleKeys.cancelOrderConfirm.tr,
            style: MarketplaceTypography.body.copyWith(
              fontSize: 14,
              color: palette.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: MarketplaceSpacing.md),
          TextField(
            controller: _reason,
            maxLength: 500,
            maxLines: 3,
            style: MarketplaceTypography.body.copyWith(
              fontSize: 13,
              color: palette.textPrimary,
            ),
            decoration: InputDecoration(
              counterText: '',
              hintText: LocaleKeys.cancelOrderReasonHint.tr,
              hintStyle: MarketplaceTypography.inputPlaceholder.copyWith(
                color: palette.textMuted,
              ),
              filled: true,
              fillColor: palette.surfaceSunken,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(MarketplaceRadius.md),
                borderSide: BorderSide(color: palette.hairline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(MarketplaceRadius.md),
                borderSide: BorderSide(color: palette.hairline),
              ),
            ),
          ),
          const SizedBox(height: MarketplaceSpacing.md),
          SizedBox(
            height: 46,
            child: ElevatedButton(
              onPressed: () => widget.onConfirm(_reason.text.trim()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB4271C),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(MarketplaceRadius.full),
                ),
              ),
              child: Text(
                LocaleKeys.cancelOrder.tr,
                style: MarketplaceTypography.buttonLabel.copyWith(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsError extends GetView<OrderDetailsController> {
  const _DetailsError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: MarketplaceSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: MarketplaceTypography.body.copyWith(
                color: palette.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: MarketplaceSpacing.sm),
            TextButton(
              onPressed: controller.refreshOrderDetails,
              child: Text(
                LocaleKeys.retry.tr,
                style: MarketplaceTypography.body.copyWith(
                  color: palette.brand,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
