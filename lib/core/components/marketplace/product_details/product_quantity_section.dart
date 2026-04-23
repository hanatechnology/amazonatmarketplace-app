import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/marketplace_typography.dart';
import '../../../theme/marketplace_spacing.dart';
import '../quantity_stepper.dart';
import '../../../localization/locale_keys.dart';
import 'dtos/product_quantity_dto.dart';

/// Row that shows the "Quantity" label and a [QuantityStepper].
///
/// Pure [StatelessWidget] — reactive rebuilding is handled by the caller
/// wrapping this widget in an [Obx] with the latest [ProductQuantityDto].
class ProductQuantitySection extends StatelessWidget {
  const ProductQuantitySection({super.key, required this.dto});

  final ProductQuantityDto dto;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          LocaleKeys.quantity.tr,
          style: MarketplaceTypography.sectionSubheading,
        ),
        QuantityStepper(
          value: dto.value,
          onChanged: dto.onChanged,
          variant: QuantityStepperVariant.bordered,
        ),
      ],
    );
  }
}
