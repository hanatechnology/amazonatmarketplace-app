import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/components/marketplace/app_network_image.dart';
import '../../../../core/components/marketplace/marketplace_app_bar.dart';
import '../../../../core/components/marketplace/orders/order_status_badge.dart';
import '../../../../core/components/marketplace/refunds/refund_tracker.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/marketplace_colors.dart';
import '../../../../core/theme/marketplace_radius.dart';
import '../../../../core/theme/marketplace_spacing.dart';
import '../../../../core/theme/marketplace_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../domain/entities/marketplace/address_entity.dart';
import '../../../../domain/entities/marketplace/order_entity.dart';
import '../../../controllers/marketplace/order_details_controller.dart';

class OrderDetailsPage extends GetView<OrderDetailsController> {
  const OrderDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MarketplaceColors.surface,
      appBar: MarketplaceAppBar(title: LocaleKeys.orderDetails.tr),
      body: Obx(() {
        final state = controller.stateFor<OrderEntity>(kOrderDetails);
        return state.value.when(
          onInitial: () => const _DetailsLoading(),
          onLoading: () => const _DetailsLoading(),
          onSuccess: (order, _) => _DetailsBody(order: order),
          onError: (message, _) => _DetailsError(message: message),
        );
      }),
    );
  }
}

class _DetailsLoading extends StatelessWidget {
  const _DetailsLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: MarketplaceColors.primary),
    );
  }
}

class _DetailsBody extends GetView<OrderDetailsController> {
  const _DetailsBody({required this.order});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.refreshOrderDetails,
      color: MarketplaceColors.primary,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: MarketplaceSpacing.screenPaddingH,
          vertical: MarketplaceSpacing.md,
        ),
        children: [
          _Header(order: order),
          const SizedBox(height: MarketplaceSpacing.md),
          _ItemsCard(items: order.items),
          if (order.refunds.isNotEmpty) ...[
            const SizedBox(height: MarketplaceSpacing.md),
            RefundTracker(refunds: order.refunds),
          ],
          const SizedBox(height: MarketplaceSpacing.md),
          _TotalsCard(order: order),
          if (order.shippingAddress != null) ...[
            const SizedBox(height: MarketplaceSpacing.md),
            _AddressCard(address: order.shippingAddress!),
          ],
          const SizedBox(height: MarketplaceSpacing.xl),
        ],
      ),
    );
  }
}

class _Header extends GetView<OrderDetailsController> {
  const _Header({required this.order});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${LocaleKeys.orderNumber.tr}${order.orderNumber}',
                style: MarketplaceTypography.sectionHeading,
              ),
            ),
            OrderStatusBadge(status: order.status),
          ],
        ),
        const SizedBox(height: MarketplaceSpacing.xxs),
        Text(
          LocaleKeys.orderPlacedOn.trParams({
            'date': DateFormatter.dateWithTime(order.createdAt),
          }),
          style: MarketplaceTypography.micro.copyWith(
            color: MarketplaceColors.textMuted,
          ),
        ),
        if (order.cancellationReason != null &&
            order.cancellationReason!.isNotEmpty) ...[
          const SizedBox(height: MarketplaceSpacing.sm),
          Text(
            '${LocaleKeys.cancellationReason.tr}: ${order.cancellationReason}',
            style: MarketplaceTypography.micro.copyWith(
              color: MarketplaceColors.errorContent,
            ),
          ),
        ],
        if (order.canRequestRefund) ...[
          const SizedBox(height: MarketplaceSpacing.md),
          OutlinedButton(
            onPressed: () => Get.toNamed(
              Routes.MARKETPLACE_REFUND_REQUEST,
              arguments: order,
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(
                double.infinity,
                MarketplaceSpacing.buttonHeight,
              ),
              side: const BorderSide(color: MarketplaceColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(MarketplaceRadius.button),
              ),
            ),
            child: Text(
              LocaleKeys.requestRefund.tr,
              style: MarketplaceTypography.buttonLabel.copyWith(
                color: MarketplaceColors.primary,
              ),
            ),
          ),
        ],
        if (order.canCancel) ...[
          const SizedBox(height: MarketplaceSpacing.md),
          Obx(() => OutlinedButton(
                onPressed: controller.isCancelling
                    ? null
                    : () => _confirmCancel(context),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(
                    double.infinity,
                    MarketplaceSpacing.buttonHeight,
                  ),
                  side: const BorderSide(
                    color: MarketplaceColors.errorContent,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(MarketplaceRadius.button),
                  ),
                ),
                child: controller.isCancelling
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: MarketplaceColors.errorContent,
                        ),
                      )
                    : Text(
                        LocaleKeys.cancelOrder.tr,
                        style: MarketplaceTypography.buttonLabel.copyWith(
                          color: MarketplaceColors.errorContent,
                        ),
                      ),
              )),
        ],
      ],
    );
  }

  /// Bottom sheet rather than the web's `confirm()` — it also collects the
  /// optional reason the cancel endpoint accepts.
  void _confirmCancel(BuildContext context) {
    final reasonController = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(
          left: MarketplaceSpacing.md,
          right: MarketplaceSpacing.md,
          top: MarketplaceSpacing.lg,
          bottom: MediaQuery.of(context).viewInsets.bottom +
              MarketplaceSpacing.lg,
        ),
        decoration: const BoxDecoration(
          color: MarketplaceColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(MarketplaceRadius.screen),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              LocaleKeys.cancelOrderConfirm.tr,
              style: MarketplaceTypography.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: MarketplaceSpacing.md),
            TextField(
              controller: reasonController,
              maxLength: 500,
              maxLines: 3,
              decoration: InputDecoration(
                counterText: '',
                hintText: LocaleKeys.cancelOrderReasonHint.tr,
                hintStyle: MarketplaceTypography.inputPlaceholder,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(MarketplaceRadius.sm),
                ),
              ),
            ),
            const SizedBox(height: MarketplaceSpacing.md),
            ElevatedButton(
              onPressed: () {
                Get.back();
                controller.cancelOrder(reason: reasonController.text.trim());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: MarketplaceColors.errorContent,
                minimumSize: const Size(
                  double.infinity,
                  MarketplaceSpacing.buttonHeight,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(MarketplaceRadius.button),
                ),
              ),
              child: Text(
                LocaleKeys.cancelOrder.tr,
                style: MarketplaceTypography.buttonLabel.copyWith(
                  color: MarketplaceColors.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}

class _ItemsCard extends StatelessWidget {
  const _ItemsCard({required this.items});

  final List<OrderItemEntity> items;

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: LocaleKeys.orderItems.tr,
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0)
              const Divider(
                height: MarketplaceSpacing.md,
                color: MarketplaceColors.strokeLight,
              ),
            _ItemRow(item: items[i]),
          ],
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});

  final OrderItemEntity item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(MarketplaceRadius.cardImage),
          child: SizedBox(
            width: 56,
            height: 56,
            child: item.imageUrl == null
                ? Container(
                    color: MarketplaceColors.deleteBackground,
                    child: const Icon(
                      Icons.image_outlined,
                      color: MarketplaceColors.textMuted,
                    ),
                  )
                : AppNetworkImage(imageUrl: item.imageUrl!, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(width: MarketplaceSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: MarketplaceTypography.cardTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: MarketplaceSpacing.xxs),
              Text(
                '${LocaleKeys.quantity.tr}: ${item.quantity} × '
                '${PriceFormatter.format(item.unitPrice)}',
                style: MarketplaceTypography.micro.copyWith(
                  color: MarketplaceColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: MarketplaceSpacing.sm),
        Text(
          PriceFormatter.format(item.lineTotal),
          style: MarketplaceTypography.cardPrice,
        ),
      ],
    );
  }
}

class _TotalsCard extends StatelessWidget {
  const _TotalsCard({required this.order});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: LocaleKeys.orderSummary.tr,
      child: Column(
        children: [
          _Row(
            label: LocaleKeys.subtotal.tr,
            value: PriceFormatter.format(order.subtotal),
          ),
          _Row(
            label: LocaleKeys.shippingFee.tr,
            value: PriceFormatter.format(order.shippingFee),
          ),
          if (order.vendorName.isNotEmpty)
            _Row(label: LocaleKeys.vendor.tr, value: order.vendorName),
          _Row(
            label: LocaleKeys.paymentMethod.tr,
            value: _paymentLabel(order.paymentMethod),
          ),
          const Divider(color: MarketplaceColors.strokeLight),
          _Row(
            label: LocaleKeys.totalAmount.tr,
            value: PriceFormatter.format(order.totalAmount),
            emphasized: true,
          ),
        ],
      ),
    );
  }

  /// The API's payment methods are brand names (EDFALI, STRIPE), so they are
  /// shown as-is rather than translated — only the delivery option reads as a
  /// phrase and gets a localized label.
  static String _paymentLabel(PaymentMethod method) => switch (method) {
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
    final region = [address.state, address.country]
        .where((part) => part.isNotEmpty)
        .join(', ');

    final lines = <String>[
      address.addressLine1,
      address.addressLine2 ?? '',
      region,
      address.phone,
    ].where((line) => line.isNotEmpty).toList();

    return _Card(
      title: LocaleKeys.shippingAddress.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(address.fullName, style: MarketplaceTypography.cardTitle),
          const SizedBox(height: MarketplaceSpacing.xxs),
          for (final line in lines)
            Text(line, style: MarketplaceTypography.descriptionBody),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(MarketplaceSpacing.md),
      decoration: BoxDecoration(
        color: MarketplaceColors.surface,
        borderRadius: BorderRadius.circular(MarketplaceRadius.card),
        border: Border.all(color: MarketplaceColors.strokeLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: MarketplaceTypography.cardTitle),
          const SizedBox(height: MarketplaceSpacing.sm),
          child,
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: MarketplaceSpacing.xxs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: MarketplaceTypography.descriptionBody,
            ),
          ),
          Text(
            value,
            style: emphasized
                ? MarketplaceTypography.cardPrice
                    .copyWith(color: MarketplaceColors.primary)
                : MarketplaceTypography.bodyBold,
            textAlign: TextAlign.end,
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: MarketplaceSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: MarketplaceTypography.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: MarketplaceSpacing.sm),
            TextButton(
              onPressed: controller.refreshOrderDetails,
              child: Text(
                LocaleKeys.retry.tr,
                style: MarketplaceTypography.buttonLabel.copyWith(
                  color: MarketplaceColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
