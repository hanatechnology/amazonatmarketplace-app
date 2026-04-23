import 'package:flutter/material.dart';
import '../../../theme/marketplace_colors.dart';
import '../../../theme/marketplace_typography.dart';
import '../../../theme/marketplace_spacing.dart';
import '../../../theme/marketplace_radius.dart';
import '../app_network_image.dart';

class CheckoutOrderItemDto {
  const CheckoutOrderItemDto({
    required this.imageUrl,
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });

  final String imageUrl;
  final String name;
  final int quantity;
  final double unitPrice;

  double get lineTotal => unitPrice * quantity;
}

/// Single item row inside the collapsible order summary.
class CheckoutOrderItemRow extends StatelessWidget {
  const CheckoutOrderItemRow({super.key, required this.data});

  final CheckoutOrderItemDto data;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppNetworkImage(
          imageUrl: data.imageUrl,
          width: 40,
          height: 40,
          borderRadius: MarketplaceRadius.cardImage,
        ),
        const SizedBox(width: MarketplaceSpacing.sm),
        Expanded(
          child: Text(
            data.name,
            style: MarketplaceTypography.cardTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: MarketplaceSpacing.sm),
        Text(
          '${data.quantity} × \$${data.unitPrice.toStringAsFixed(2)}',
          style: MarketplaceTypography.cardSubtitle.copyWith(
            color: MarketplaceColors.textBody,
          ),
        ),
      ],
    );
  }
}
