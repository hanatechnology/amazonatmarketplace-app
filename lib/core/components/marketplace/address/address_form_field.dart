import 'package:flutter/material.dart';
import 'package:marketplace/core/theme/marketplace_colors.dart';
import 'package:marketplace/core/theme/marketplace_radius.dart';
import 'package:marketplace/core/theme/marketplace_spacing.dart';
import 'package:marketplace/core/theme/marketplace_typography.dart';

class AddressFormField extends StatelessWidget {
  const AddressFormField({
    super.key,
    required this.label,
    required this.controller,
    required this.validator,
    this.hint,
    this.maxLines = 1,
    this.textInputAction,
  });

  final String label;
  final TextEditingController controller;
  final String? Function(String?) validator;
  final String? hint;
  final int maxLines;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: MarketplaceTypography.sectionSubheading),
        const SizedBox(height: MarketplaceSpacing.xs),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          textInputAction: textInputAction,
          validator: validator,
          style: MarketplaceTypography.body,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: MarketplaceTypography.inputPlaceholder,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: MarketplaceSpacing.md,
              vertical: 14,
            ),
            constraints: const BoxConstraints(minHeight: 48),
            filled: true,
            fillColor: MarketplaceColors.surface,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(MarketplaceRadius.sm),
              borderSide: const BorderSide(color: MarketplaceColors.stroke),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(MarketplaceRadius.sm),
              borderSide: const BorderSide(
                color: MarketplaceColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(MarketplaceRadius.sm),
              borderSide: const BorderSide(color: Color(0xFFD32F2F)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(MarketplaceRadius.sm),
              borderSide:
                  const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
            ),
            errorStyle: const TextStyle(
              color: Color(0xFFD32F2F),
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
