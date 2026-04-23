import 'package:flutter/material.dart';
import '../../theme/marketplace_colors.dart';
import '../../theme/marketplace_typography.dart';
import '../../theme/marketplace_spacing.dart';
import '../../theme/marketplace_radius.dart';
import '../../theme/marketplace_icons.dart';

/// Quantity stepper widget with increment/decrement buttons.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.variant = QuantityStepperVariant.bordered,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final QuantityStepperVariant variant;

  void _increment() => onChanged(value + 1);
  void _decrement() {
    if (value > 1) {
      onChanged(value - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Minus button
        _buildButton(
          icon: MarketplaceIcons.minus,
          onTap: _decrement,
        ),
        // Value
        SizedBox(
          width: 32,
          child: Center(
            child: Text(
              value.toString(),
              style: MarketplaceTypography.quantityNumber,
            ),
          ),
        ),
        // Plus button
        _buildButton(
          icon: MarketplaceIcons.plus,
          onTap: _increment,
        ),
      ],
    );

    if (variant == QuantityStepperVariant.bordered) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: MarketplaceColors.stroke),
          borderRadius: BorderRadius.circular(MarketplaceRadius.stepper),
        ),
        child: content,
      );
    }

    // Compact variant (no border)
    return content;
  }

  Widget _buildButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(MarketplaceSpacing.sm),
        child: Icon(
          icon,
          size: 16,
          color: MarketplaceColors.textBody,
        ),
      ),
    );
  }
}

enum QuantityStepperVariant { bordered, compact }
