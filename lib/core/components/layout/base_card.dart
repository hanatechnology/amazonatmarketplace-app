import 'package:flutter/material.dart';

/// Base card with consistent border and shadow styling.
class BaseCard extends StatelessWidget {
  const BaseCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.elevation = 0,
    this.onTap,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final double elevation;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final card = Card(
      margin: margin ?? EdgeInsets.zero,
      elevation: elevation,
      color: color ?? theme.cardTheme.color,
      shape: theme.cardTheme.shape,
      child: padding != null ? Padding(padding: padding!, child: child) : child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius ?? 15),
        child: card,
      );
    }
    return card;
  }
}
