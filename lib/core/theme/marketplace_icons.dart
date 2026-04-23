import 'package:flutter/material.dart';

/// Icon mappings from Figma Iconify → Flutter Material Icons.
/// For icons without a Material equivalent, export SVG from Figma
/// and place in assets/icons/.
abstract class MarketplaceIcons {
  MarketplaceIcons._();

  // Navigation
  static const IconData backArrow = Icons.arrow_back_ios_new_rounded;
  static const IconData forwardArrow = Icons.arrow_forward_ios_rounded;

  // Bottom Tab — inactive (outlined) / active (filled)
  static const IconData homeOutlined = Icons.home_outlined;
  static const IconData homeFilled = Icons.home_rounded;
  static const IconData categoryOutlined = Icons.grid_view_outlined;
  static const IconData categoryFilled = Icons.grid_view_rounded;
  static const IconData sellerOutlined = Icons.storefront_outlined;
  static const IconData sellerFilled = Icons.storefront_rounded;
  static const IconData cartOutlined = Icons.shopping_cart_outlined;
  static const IconData cartFilled = Icons.shopping_cart_rounded;
  static const IconData accountOutlined = Icons.person_outline_rounded;
  static const IconData accountFilled = Icons.person_rounded;

  // Actions
  static const IconData search = Icons.search_rounded;
  static const IconData filter = Icons.tune_rounded;
  static const IconData edit = Icons.edit_outlined;
  static const IconData delete = Icons.delete_outline_rounded;
  static const IconData copy = Icons.content_copy_rounded;
  static const IconData selectAll = Icons.select_all_rounded;
  static const IconData minus = Icons.remove_rounded;
  static const IconData plus = Icons.add_rounded;

  // Info
  static const IconData star = Icons.star_rounded;
  static const IconData starOutline = Icons.star_outline_rounded;
  static const IconData verified = Icons.verified_rounded;
  static const IconData location = Icons.location_on_outlined;
  static const IconData language = Icons.language_rounded;
  static const IconData helpCenter = Icons.help_outline_rounded;
  static const IconData logout = Icons.logout_rounded;

  // Profile menu
  static const IconData myOrder = Icons.shopping_bag_outlined;
  static const IconData follow = Icons.person_add_outlined;
  static const IconData payment = Icons.payment_rounded;

  // Star sizes per context
  static const double starSizeCard = 16.0;
  static const double starSizeDetail = 24.0;
  static const double starSizeReview = 16.0;
}
