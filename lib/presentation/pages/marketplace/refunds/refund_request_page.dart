import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/components/marketplace/app_network_image.dart';
import '../../../../core/components/marketplace/refunds/refund_reason_sheet.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/marketplace_palette.dart';
import '../../../../core/theme/marketplace_radius.dart';
import '../../../../core/theme/marketplace_typography.dart';
import '../../../../core/theme/status_tone.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../domain/entities/marketplace/order_entity.dart';
import '../../../../domain/entities/marketplace/payout_method_entity.dart';
import '../../../../domain/entities/marketplace/refund_entity.dart';
import '../../../controllers/marketplace/refund_request_controller.dart';
import '../../../../core/components/layout/keyboard_aware_bottom_bar.dart';
import '../../../../core/components/marketplace/sticky_back_bar.dart';

/// Request a refund on a delivered order.
///
/// Split into two steps, unlike the web's single modal: the payout fields come
/// from the backend and can be long, and neither half fits one phone screen.
///
/// The free-text explanation is required — `CreateRefundDto` marks `reason`
/// required even though the web labels it optional — while the reason picker
/// (`reason_id`) is the optional one. There is no attachment field on the DTO
/// and the only upload endpoint in the spec is for avatars, so no photo
/// evidence is offered anywhere here.
class RefundRequestPage extends GetView<RefundRequestController> {
  const RefundRequestPage({super.key});

  static const double gutter = 20;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.background,
      body: StickyBackBar(
        onBack: () => controller.step.value == 1
            ? controller.backToStep1()
            : Get.back(),
        child: SafeArea(
        bottom: false,
        child: Obx(
          () => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(gutter, 0, gutter, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _NavRow(),
                const SizedBox(height: 6),
                Text(
                  LocaleKeys.requestRefund.tr,
                  style: MarketplaceTypography.heroDisplay.copyWith(
                    fontSize: 28,
                    color: palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                const _StepRail(),
                const SizedBox(height: 20),
                if (controller.step.value == 0)
                  const _StepOne()
                else
                  const _StepTwo(),
              ],
            ),
          ),
        ),
      )),
      bottomNavigationBar: const KeyboardAwareBottomBar(child: _BottomBar()),
    );
  }
}

class _NavRow extends GetView<RefundRequestController> {
  const _NavRow();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 46, child: BackButtonSlot());
  }
}

/// Two dots and the current step's name. The row mirrors on its own, so in
/// Arabic step one sits on the right.
class _StepRail extends GetView<RefundRequestController> {
  const _StepRail();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Obx(() {
      final step = controller.step.value;

      return Row(
        children: [
          for (var i = 0; i < 2; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: i == step ? 22 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: i <= step ? palette.brand : palette.hairline,
                borderRadius: BorderRadius.circular(MarketplaceRadius.full),
              ),
            ),
          ],
          const SizedBox(width: 11),
          Text(
            step == 0
                ? LocaleKeys.refundStep1.tr
                : LocaleKeys.refundStep2.tr,
            style: MarketplaceTypography.rowMeta.copyWith(
              fontSize: 11,
              color: palette.textSecondary,
            ),
          ),
        ],
      );
    });
  }
}

// ── Step one ────────────────────────────────────────────────────────────────

class _StepOne extends GetView<RefundRequestController> {
  const _StepOne();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _TypeToggle(),
        const SizedBox(height: 18),
        Obx(
          () => controller.refundType.value == RefundType.partial
              ? const _ItemPicker()
              : const SizedBox.shrink(),
        ),
        const _ReasonRow(),
        const SizedBox(height: 18),
        const _FreeText(),
      ],
    );
  }
}

class _TypeToggle extends GetView<RefundRequestController> {
  const _TypeToggle();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final type = controller.refundType.value;

      return Row(
        children: [
          Expanded(
            child: _TypeCard(
              title: LocaleKeys.refundTypeFull.tr,
              hint: LocaleKeys.refundTypeFullHint.tr,
              isSelected: type == RefundType.full,
              onTap: () => controller.changeType(RefundType.full),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _TypeCard(
              title: LocaleKeys.refundTypePartial.tr,
              hint: LocaleKeys.refundTypePartialHint.tr,
              isSelected: type == RefundType.partial,
              onTap: () => controller.changeType(RefundType.partial),
            ),
          ),
        ],
      );
    });
  }
}

class _TypeCard extends StatelessWidget {
  const _TypeCard({
    required this.title,
    required this.hint,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String hint;
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
          color: isSelected ? palette.surfaceSunken : palette.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? palette.brand : palette.hairline,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: MarketplaceTypography.rowTitle.copyWith(
                fontWeight: FontWeight.w700,
                color: palette.textPrimary,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              hint,
              style: MarketplaceTypography.rowMeta.copyWith(
                height: 1.5,
                color: palette.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemPicker extends GetView<RefundRequestController> {
  const _ItemPicker();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Obx(() {
      final error = controller.itemsError.value?.tr;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(text: LocaleKeys.refundWhichItems.tr, isRequired: true),
          for (final item in controller.order.items) ...[
            _ItemRow(item: item),
            const SizedBox(height: 9),
          ],
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                error,
                style: MarketplaceTypography.rowMeta.copyWith(
                  fontSize: 11,
                  color: StatusTone.danger.foreground(palette.isDark),
                ),
              ),
            ),
          const SizedBox(height: 9),
        ],
      );
    });
  }
}

class _ItemRow extends GetView<RefundRequestController> {
  const _ItemRow({required this.item});

  final OrderItemEntity item;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Obx(() {
      final selection = controller.itemSelections[item.id];
      final isSelected = selection?.selected ?? false;
      final quantity = selection?.quantity ?? item.quantity;

      return GestureDetector(
        onTap: () => controller.toggleItem(item.id, !isSelected),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? palette.brand : palette.hairline,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              _Checkbox(isChecked: isSelected),
              const SizedBox(width: 11),
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: palette.surfaceSunken,
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.hardEdge,
                child: AppNetworkImage(
                  imageUrl: item.imageUrl ?? '',
                  width: 46,
                  height: 46,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.name,
                      style: MarketplaceTypography.rowTitle.copyWith(
                        fontSize: 12,
                        color: palette.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      PriceFormatter.formatWithUnit(item.unitPrice),
                      textDirection: TextDirection.ltr,
                      style: MarketplaceTypography.rowMeta.copyWith(
                        color: palette.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected && item.quantity > 1) ...[
                const SizedBox(width: 8),
                _QuantityStepper(
                  value: quantity,
                  max: item.quantity,
                  onChanged: (next) =>
                      controller.changeItemQuantity(item.id, next),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }
}

class _Checkbox extends StatelessWidget {
  const _Checkbox({required this.isChecked});

  final bool isChecked;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isChecked ? palette.brand : const Color(0x00000000),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: isChecked ? palette.brand : palette.hairline,
          width: 1.6,
        ),
      ),
      child: isChecked
          ? Icon(Icons.check_rounded, size: 13, color: palette.onBrand)
          : null,
    );
  }
}

/// Capped at the ordered quantity — the API rejects more than was bought.
class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.value,
    required this.max,
    required this.onChanged,
  });

  final int value;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: palette.surfaceSunken,
        borderRadius: BorderRadius.circular(MarketplaceRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: Icons.remove_rounded,
            onTap: value > 1 ? () => onChanged(value - 1) : null,
            color: value > 1 ? palette.textSecondary : palette.textMuted,
          ),
          SizedBox(
            width: 22,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
              style: MarketplaceTypography.rowTitle.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: palette.textPrimary,
              ),
            ),
          ),
          _StepButton(
            icon: Icons.add_rounded,
            onTap: value < max ? () => onChanged(value + 1) : null,
            color: value < max ? palette.textSecondary : palette.textMuted,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 22,
        height: 32,
        child: Icon(icon, size: 15, color: color),
      ),
    );
  }
}

class _ReasonRow extends GetView<RefundRequestController> {
  const _ReasonRow();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Obx(() {
      final selectedId = controller.selectedReasonId.value;
      final reasons = controller.reasons;
      final selected = reasons.where((r) => r.id == selectedId).firstOrNull;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(text: LocaleKeys.refundReasonPick.tr),
          GestureDetector(
            onTap: reasons.isEmpty
                ? null
                : () async {
                    final picked = await RefundReasonSheet.show(
                      reasons: reasons,
                      selectedId: selectedId,
                    );
                    if (picked != null) controller.selectReason(picked.id);
                  },
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: palette.hairline),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selected?.label ?? LocaleKeys.refundReasonPickHint.tr,
                      style: MarketplaceTypography.rowTitle.copyWith(
                        fontSize: 13,
                        color: selected == null
                            ? palette.textMuted
                            : palette.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 17,
                    color: palette.textMuted,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _FreeText extends GetView<RefundRequestController> {
  const _FreeText();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Obx(() {
      final error = controller.reasonError.value?.tr;
      final hasError = error != null;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(text: LocaleKeys.refundTellUs.tr, isRequired: true),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hasError
                    ? StatusTone.danger.foreground(palette.isDark)
                    : palette.hairline,
                width: hasError ? 1.5 : 1,
              ),
            ),
            child: TextField(
              controller: controller.reasonController,
              maxLines: 4,
              minLines: 3,
              cursorColor: palette.brand,
              style: MarketplaceTypography.rowMeta.copyWith(
                fontSize: 12.5,
                height: 1.6,
                color: palette.textPrimary,
              ),
              decoration: InputDecoration(
                isDense: true,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: LocaleKeys.refundTellUsHint.tr,
                hintStyle: MarketplaceTypography.rowMeta.copyWith(
                  fontSize: 12.5,
                  height: 1.6,
                  color: palette.textMuted,
                ),
              ),
            ),
          ),
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                error,
                style: MarketplaceTypography.rowMeta.copyWith(
                  fontSize: 11,
                  color: StatusTone.danger.foreground(palette.isDark),
                ),
              ),
            ),
        ],
      );
    });
  }
}

// ── Step two ────────────────────────────────────────────────────────────────

class _StepTwo extends GetView<RefundRequestController> {
  const _StepTwo();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Obx(() {
      final methods = controller.payoutMethods;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(
            text: LocaleKeys.refundPayoutMethod.tr,
            isRequired: true,
          ),
          if (methods.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: StatusTone.warning.background(palette.isDark),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                LocaleKeys.refundNoPayoutMethods.tr,
                style: MarketplaceTypography.rowMeta.copyWith(
                  fontSize: 11.5,
                  height: 1.6,
                  color: StatusTone.warning.foreground(palette.isDark),
                ),
              ),
            )
          else
            for (final method in methods) ...[
              _PayoutCard(method: method),
              const SizedBox(height: 9),
            ],
          if (controller.payoutMethodError.value != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                controller.payoutMethodError.value!.tr,
                style: MarketplaceTypography.rowMeta.copyWith(
                  fontSize: 11,
                  color: StatusTone.danger.foreground(palette.isDark),
                ),
              ),
            ),
          const SizedBox(height: 18),
          const _ReviewCard(),
        ],
      );
    });
  }
}

/// The selected card expands to hold its own fields — the field set belongs to
/// the method, so a separate "payout details" section would only orphan it.
class _PayoutCard extends GetView<RefundRequestController> {
  const _PayoutCard({required this.method});

  final PayoutMethodEntity method;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Obx(() {
      final isSelected = controller.selectedPayoutMethodId.value == method.id;
      final fields = [...method.fields]
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      return GestureDetector(
        onTap: () => controller.selectPayoutMethod(method.id),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: isSelected ? palette.surfaceSunken : palette.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? palette.brand : palette.hairline,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? palette.surface
                          : palette.surfaceSunken,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 16,
                      color: isSelected
                          ? palette.brand
                          : palette.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      method.name,
                      style: MarketplaceTypography.rowTitle.copyWith(
                        color: palette.textPrimary,
                      ),
                    ),
                  ),
                  _Radio(isSelected: isSelected),
                ],
              ),
              if (isSelected && fields.isNotEmpty) ...[
                const SizedBox(height: 12),
                for (final field in fields) ...[
                  _PayoutField(field: field),
                  const SizedBox(height: 10),
                ],
              ],
            ],
          ),
        ),
      );
    });
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

/// The backend owns the label, the control type and the validation rule, so
/// this renders whatever it is handed rather than hardcoding IBAN or wallet.
class _PayoutField extends GetView<RefundRequestController> {
  const _PayoutField({required this.field});

  final PayoutMethodFieldEntity field;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Obx(() {
      final error = controller.payoutFieldErrorText(field);
      final hasError = error != null;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                field.label.toUpperCase(),
                style: MarketplaceTypography.labelCaps.copyWith(
                  fontSize: 9,
                  color: palette.textMuted,
                  letterSpacing: MarketplaceTypography.isArabic ? 0 : 1,
                ),
              ),
              if (field.isRequired)
                Text(
                  ' *',
                  style: MarketplaceTypography.labelCaps.copyWith(
                    fontSize: 9,
                    color: StatusTone.danger.foreground(palette.isDark),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          if (field.fieldType == PayoutFieldType.select)
            _SelectField(field: field, hasError: hasError)
          else
            _TextPayoutField(field: field, hasError: hasError),
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                error,
                style: MarketplaceTypography.rowMeta.copyWith(
                  color: StatusTone.danger.foreground(palette.isDark),
                ),
              ),
            ),
        ],
      );
    });
  }
}

class _TextPayoutField extends GetView<RefundRequestController> {
  const _TextPayoutField({required this.field, required this.hasError});

  final PayoutMethodFieldEntity field;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isNumeric = field.fieldType == PayoutFieldType.number ||
        field.fieldType == PayoutFieldType.phone;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasError
              ? StatusTone.danger.foreground(palette.isDark)
              : palette.hairline,
          width: hasError ? 1.5 : 1,
        ),
      ),
      child: TextField(
        controller: controller.payoutControllers[field.fieldKey],
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        // Account numbers and IBANs are Latin runs; mirroring them corrupts
        // the value the customer is checking against their bank app.
        textDirection: isNumeric ? TextDirection.ltr : null,
        maxLines: field.fieldType == PayoutFieldType.textarea ? 3 : 1,
        cursorColor: palette.brand,
        onChanged: (value) =>
            controller.setPayoutValue(field.fieldKey, value),
        style: MarketplaceTypography.rowTitle.copyWith(
          fontSize: 13,
          color: palette.textPrimary,
        ),
        decoration: InputDecoration(
          isDense: true,
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          hintText: field.placeholder,
          hintStyle: MarketplaceTypography.rowTitle.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: palette.textMuted,
          ),
        ),
      ),
    );
  }
}

class _SelectField extends GetView<RefundRequestController> {
  const _SelectField({required this.field, required this.hasError});

  final PayoutMethodFieldEntity field;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Obx(() {
      final value = controller.payoutValues[field.fieldKey];

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 13),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasError
                ? StatusTone.danger.foreground(palette.isDark)
                : palette.hairline,
            width: hasError ? 1.5 : 1,
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            hint: Text(
              field.placeholder ?? '',
              style: MarketplaceTypography.rowTitle.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: palette.textMuted,
              ),
            ),
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: palette.textMuted,
            ),
            dropdownColor: palette.surface,
            style: MarketplaceTypography.rowTitle.copyWith(
              fontSize: 13,
              color: palette.textPrimary,
            ),
            items: field.options
                .map(
                  (option) => DropdownMenuItem(
                    value: option.value,
                    child: Text(option.label),
                  ),
                )
                .toList(),
            onChanged: (next) {
              if (next != null) {
                controller.setPayoutValue(field.fieldKey, next);
              }
            },
          ),
        ),
      );
    });
  }
}

class _ReviewCard extends GetView<RefundRequestController> {
  const _ReviewCard();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Obx(() {
      final type = controller.refundType.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(text: LocaleKeys.refundReview.tr),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: palette.hairline),
            ),
            child: Column(
              children: [
                _ReviewRow(
                  label: LocaleKeys.orderNumber.tr,
                  value: controller.order.orderNumber,
                  isLatin: true,
                ),
                _ReviewRow(
                  label: LocaleKeys.refundReasonPick.tr,
                  value: type == RefundType.full
                      ? LocaleKeys.refundTypeFull.tr
                      : LocaleKeys.refundItemsCount.trParams({
                          'count': '${controller.selectedItemCount}',
                          'total': '${controller.order.items.length}',
                        }),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: palette.hairline),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          LocaleKeys.refundEstimate.tr,
                          style: MarketplaceTypography.rowTitle.copyWith(
                            fontSize: 12.5,
                            color: palette.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        PriceFormatter.formatWithUnit(
                          controller.estimatedAmount,
                        ),
                        textDirection: TextDirection.ltr,
                        style: MarketplaceTypography.priceDisplay.copyWith(
                          fontSize: 21,
                          color: palette.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  LocaleKeys.refundEstimateNote.tr,
                  style: MarketplaceTypography.rowMeta.copyWith(
                    height: 1.6,
                    color: palette.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({
    required this.label,
    required this.value,
    this.isLatin = false,
  });

  final String label;
  final String value;
  final bool isLatin;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: MarketplaceTypography.rowMeta.copyWith(
                fontSize: 11.5,
                color: palette.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            value,
            textDirection: isLatin ? TextDirection.ltr : null,
            style: MarketplaceTypography.rowTitle.copyWith(
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

// ── Chrome ──────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text, this.isRequired = false});

  final String text;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Text(
            text.toUpperCase(),
            style: MarketplaceTypography.labelCaps.copyWith(
              color: palette.textMuted,
              letterSpacing: MarketplaceTypography.isArabic ? 0 : 1.2,
            ),
          ),
          if (isRequired)
            Text(
              ' *',
              style: MarketplaceTypography.labelCaps.copyWith(
                color: StatusTone.danger.foreground(palette.isDark),
              ),
            ),
        ],
      ),
    );
  }
}

class _BottomBar extends GetView<RefundRequestController> {
  const _BottomBar();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        RefundRequestPage.gutter,
        12,
        RefundRequestPage.gutter,
        0,
      ),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(top: BorderSide(color: palette.hairline)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Obx(() {
            final isStepTwo = controller.step.value == 1;
            final isBusy = controller.isSubmitting;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        LocaleKeys.refundEstimate.tr,
                        style: MarketplaceTypography.rowMeta.copyWith(
                          fontSize: 11,
                          color: palette.textSecondary,
                        ),
                      ),
                    ),
                    Text(
                      PriceFormatter.formatWithUnit(
                        controller.estimatedAmount,
                      ),
                      textDirection: TextDirection.ltr,
                      style: MarketplaceTypography.rowTitle.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: palette.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isBusy
                        ? null
                        : (isStepTwo
                            ? controller.submit
                            : controller.goToStep2),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: palette.brand,
                      foregroundColor: palette.onBrand,
                      disabledBackgroundColor: palette.surfaceSunken,
                      disabledForegroundColor: palette.textMuted,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(MarketplaceRadius.full),
                      ),
                    ),
                    child: isBusy
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: palette.onBrand,
                            ),
                          )
                        : Text(
                            isStepTwo
                                ? LocaleKeys.refundSubmit.tr
                                : LocaleKeys.refundContinue.tr,
                            style:
                                MarketplaceTypography.buttonLabel.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
