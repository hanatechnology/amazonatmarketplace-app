import 'package:flutter/material.dart';

abstract class MarketplaceShadows {
  MarketplaceShadows._();

  static const BoxShadow activeTabIcon = BoxShadow(
    color: Color(0x3D000000), blurRadius: 4.0, offset: Offset.zero,
  );

  static const BoxShadow cardElevation = BoxShadow(
    color: Color(0x14000000), blurRadius: 8.0, offset: Offset(0, 2),
  );

  static const BoxShadow bottomNav = BoxShadow(
    color: Color(0x0A000000), blurRadius: 12.0, offset: Offset(0, -2),
  );
}
