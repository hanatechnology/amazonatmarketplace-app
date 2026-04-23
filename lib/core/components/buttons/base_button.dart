import 'package:flutter/material.dart';

enum ButtonType { primary, secondary, outlined, text }
enum ButtonSize { small, medium, large }

/// Multi-variant button with loading state support.
class BaseButton extends StatelessWidget {
  const BaseButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.icon,
    this.fullWidth = true,
    this.borderRadius,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final bool isLoading;
  final IconData? icon;
  final bool fullWidth;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? foregroundColor;

  double get _height => switch (size) {
        ButtonSize.small => 34,
        ButtonSize.medium => 48,
        ButtonSize.large => 56,
      };

  double get _fontSize => switch (size) {
        ButtonSize.small => 13,
        ButtonSize.medium => 16,
        ButtonSize.large => 18,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final content = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: type == ButtonType.primary ? cs.onPrimary : cs.primary,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: _fontSize + 4),
                const SizedBox(width: 8),
              ],
              Text(label, style: TextStyle(fontSize: _fontSize)),
            ],
          );

    final rad = borderRadius ?? 20.0;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(rad),
    );
    final minSize = Size(fullWidth ? double.infinity : 0, _height);

    switch (type) {
      case ButtonType.primary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? cs.primary,
            foregroundColor: foregroundColor ?? cs.onPrimary,
            minimumSize: minSize,
            shape: shape,
            elevation: 0,
          ),
          child: content,
        );
      case ButtonType.secondary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? cs.secondary,
            foregroundColor: foregroundColor ?? cs.onSecondary,
            minimumSize: minSize,
            shape: shape,
            elevation: 0,
          ),
          child: content,
        );
      case ButtonType.outlined:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: foregroundColor ?? cs.primary,
            side: BorderSide(color: cs.outline),
            minimumSize: minSize,
            shape: shape,
          ),
          child: content,
        );
      case ButtonType.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: foregroundColor ?? cs.primary,
            minimumSize: minSize,
            shape: shape,
          ),
          child: content,
        );
    }
  }
}
