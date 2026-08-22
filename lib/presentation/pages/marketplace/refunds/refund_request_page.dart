import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/components/marketplace/marketplace_app_bar.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/marketplace_colors.dart';
import '../../../../core/theme/marketplace_radius.dart';
import '../../../../core/theme/marketplace_spacing.dart';
import '../../../../core/theme/marketplace_typography.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../domain/entities/marketplace/payout_method_entity.dart';
import '../../../../domain/entities/marketplace/refund_entity.dart';
import '../../../controllers/marketplace/refund_request_controller.dart';

/// Refund request form. A full page rather than the web's modal — the payout
/// fields are backend-driven and can be long.
class RefundRequestPage extends GetView<RefundRequestController> {
  const RefundRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MarketplaceColors.surface,
      appBar: MarketplaceAppBar(title: LocaleKeys.requestRefund.tr),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: MarketplaceSpacing.screenPaddingH,
          vertical: MarketplaceSpacing.md,
        ),
        children: const [
          _TypeSelector(),
          SizedBox(height: MarketplaceSpacing.md),
          _ItemSelector(),
          _ReasonPicker(),
          SizedBox(height: MarketplaceSpacing.md),
          _ExplanationField(),
          SizedBox(height: MarketplaceSpacing.md),
          _PayoutMethodPicker(),
          SizedBox(height: MarketplaceSpacing.md),
          _PayoutFields(),
          SizedBox(height: MarketplaceSpacing.lg),
          _SubmitButton(),
          SizedBox(height: MarketplaceSpacing.xl),
        ],
      ),
    );
  }
}

class _TypeSelector extends GetView<RefundRequestController> {
  const _TypeSelector();

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: LocaleKeys.refundType.tr,
      child: Obx(
        () => Row(
          children: [
            for (final type in RefundType.values)
              Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.only(
                    end: type == RefundType.full ? MarketplaceSpacing.sm : 0,
                  ),
                  child: _ChoiceChip(
                    label: type == RefundType.full
                        ? LocaleKeys.refundTypeFull.tr
                        : LocaleKeys.refundTypePartial.tr,
                    selected: controller.refundType.value == type,
                    onTap: () => controller.changeType(type),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ItemSelector extends GetView<RefundRequestController> {
  const _ItemSelector();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.refundType.value != RefundType.partial) {
        return const SizedBox.shrink();
      }

      return _Section(
        title: LocaleKeys.selectItems.tr,
        error: controller.itemsError.value,
        child: Column(
          children: [
            for (final item in controller.order.items)
              Builder(builder: (_) {
                final selection = controller.itemSelections[item.id];
                if (selection == null) return const SizedBox.shrink();

                return Row(
                  children: [
                    Checkbox(
                      value: selection.selected,
                      activeColor: MarketplaceColors.primary,
                      onChanged: (value) =>
                          controller.toggleItem(item.id, value ?? false),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: MarketplaceTypography.body,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            PriceFormatter.format(item.unitPrice),
                            style: MarketplaceTypography.micro.copyWith(
                              color: MarketplaceColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (selection.selected)
                      _QuantityStepper(
                        quantity: selection.quantity,
                        max: item.quantity,
                        onChanged: (next) =>
                            controller.changeItemQuantity(item.id, next),
                      ),
                  ],
                );
              }),
          ],
        ),
      );
    });
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.max,
    required this.onChanged,
  });

  final int quantity;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: quantity <= 1 ? null : () => onChanged(quantity - 1),
          icon: const Icon(Icons.remove_rounded, size: 18),
          color: MarketplaceColors.primary,
        ),
        Text('$quantity', style: MarketplaceTypography.bodyBold),
        IconButton(
          onPressed: quantity >= max ? null : () => onChanged(quantity + 1),
          icon: const Icon(Icons.add_rounded, size: 18),
          color: MarketplaceColors.primary,
        ),
      ],
    );
  }
}

class _ReasonPicker extends GetView<RefundRequestController> {
  const _ReasonPicker();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final state =
          controller.stateFor<List<RefundReasonEntity>>(kRefundReasons);
      final reasons = state.value.dataOrNull ?? const <RefundReasonEntity>[];
      if (reasons.isEmpty) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.only(top: MarketplaceSpacing.md),
        child: _Section(
          title: LocaleKeys.refundReason.tr,
          child: DropdownButtonFormField<String>(
            initialValue: controller.selectedReasonId.value,
            isExpanded: true,
            hint: Text(
              LocaleKeys.refundReasonHint.tr,
              style: MarketplaceTypography.inputPlaceholder,
            ),
            decoration: _fieldDecoration(),
            items: [
              for (final reason in reasons)
                DropdownMenuItem(
                  value: reason.id,
                  child: Text(
                    reason.label,
                    style: MarketplaceTypography.body,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: controller.selectReason,
          ),
        ),
      );
    });
  }
}

class _ExplanationField extends GetView<RefundRequestController> {
  const _ExplanationField();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => _Section(
        title: LocaleKeys.refundExplanation.tr,
        error: controller.reasonError.value,
        child: TextField(
          controller: controller.reasonController,
          maxLines: 3,
          onChanged: (_) => controller.reasonError.value = null,
          decoration: _fieldDecoration(),
        ),
      ),
    );
  }
}

class _PayoutMethodPicker extends GetView<RefundRequestController> {
  const _PayoutMethodPicker();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final methods = controller.payoutMethods;

      return _Section(
        title: LocaleKeys.payoutMethod.tr,
        error: controller.payoutMethodError.value,
        // RadioGroup owns the selection; the tiles only declare their value.
        child: RadioGroup<String>(
          groupValue: controller.selectedPayoutMethodId.value,
          onChanged: (value) {
            if (value != null) controller.selectPayoutMethod(value);
          },
          child: Column(
            children: [
              for (final method in methods)
                RadioListTile<String>(
                  value: method.id,
                  activeColor: MarketplaceColors.primary,
                  contentPadding: EdgeInsets.zero,
                  title: Text(method.name, style: MarketplaceTypography.body),
                ),
            ],
          ),
        ),
      );
    });
  }
}

/// Renders whatever fields the selected payout method declares. The backend
/// owns the labels, control types, and validation, so nothing here is hardcoded.
class _PayoutFields extends GetView<RefundRequestController> {
  const _PayoutFields();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final method = controller.selectedPayoutMethod;
      if (method == null) return const SizedBox.shrink();

      return Column(
        children: [
          for (final field in method.fields)
            Padding(
              padding: const EdgeInsets.only(bottom: MarketplaceSpacing.md),
              child: _Section(
                title: field.isRequired ? '${field.label} *' : field.label,
                error: controller.payoutFieldErrors[field.fieldKey],
                child: field.fieldType == PayoutFieldType.select
                    ? DropdownButtonFormField<String>(
                        initialValue: controller.payoutValues[field.fieldKey],
                        isExpanded: true,
                        decoration: _fieldDecoration(hint: field.placeholder),
                        items: [
                          for (final option in field.options)
                            DropdownMenuItem(
                              value: option.value,
                              child: Text(
                                option.label,
                                style: MarketplaceTypography.body,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            controller.setPayoutValue(field.fieldKey, value);
                          }
                        },
                      )
                    : TextField(
                        controller: controller.payoutControllers[field.fieldKey],
                        keyboardType: switch (field.fieldType) {
                          PayoutFieldType.number => TextInputType.number,
                          PayoutFieldType.phone => TextInputType.phone,
                          PayoutFieldType.textarea => TextInputType.multiline,
                          _ => TextInputType.text,
                        },
                        maxLines:
                            field.fieldType == PayoutFieldType.textarea ? 3 : 1,
                        onChanged: (value) =>
                            controller.setPayoutValue(field.fieldKey, value),
                        decoration: _fieldDecoration(hint: field.placeholder),
                      ),
              ),
            ),
        ],
      );
    });
  }
}

class _SubmitButton extends GetView<RefundRequestController> {
  const _SubmitButton();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ElevatedButton(
        onPressed: controller.isSubmitting ? null : controller.submit,
        style: ElevatedButton.styleFrom(
          minimumSize:
              const Size(double.infinity, MarketplaceSpacing.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MarketplaceRadius.button),
          ),
        ),
        child: controller.isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: MarketplaceColors.onPrimary,
                ),
              )
            : Text(
                LocaleKeys.submitRefund.tr,
                style: MarketplaceTypography.buttonLabel,
              ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.error});

  final String title;
  final Widget child;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: MarketplaceTypography.cardTitle),
        const SizedBox(height: MarketplaceSpacing.xs),
        child,
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: MarketplaceSpacing.xxs),
            child: Text(
              error!,
              style: MarketplaceTypography.micro
                  .copyWith(color: MarketplaceColors.errorContent),
            ),
          ),
      ],
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(MarketplaceRadius.sm),
      child: Container(
        height: MarketplaceSpacing.buttonHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? MarketplaceColors.secondary
              : MarketplaceColors.surface,
          borderRadius: BorderRadius.circular(MarketplaceRadius.sm),
          border: Border.all(
            color: selected
                ? MarketplaceColors.primary
                : MarketplaceColors.strokeLight,
          ),
        ),
        child: Text(
          label,
          style: MarketplaceTypography.body.copyWith(
            color: selected
                ? MarketplaceColors.primary
                : MarketplaceColors.textBody,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

InputDecoration _fieldDecoration({String? hint}) => InputDecoration(
      hintText: hint,
      hintStyle: MarketplaceTypography.inputPlaceholder,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: MarketplaceSpacing.md,
        vertical: MarketplaceSpacing.sm,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(MarketplaceRadius.sm),
        borderSide: const BorderSide(color: MarketplaceColors.stroke),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(MarketplaceRadius.sm),
        borderSide: const BorderSide(color: MarketplaceColors.stroke),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(MarketplaceRadius.sm),
        borderSide: const BorderSide(
          color: MarketplaceColors.primary,
          width: 2,
        ),
      ),
    );
