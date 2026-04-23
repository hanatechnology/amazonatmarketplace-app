import 'package:flutter/material.dart';

/// Generic loading indicator with optional message.
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.message, this.color});

  final String? message;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: color ?? cs.primary,
            strokeWidth: 2.5,
          ),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(
              message!,
              style: TextStyle(color: cs.onSurface.withAlpha(153)),
            ),
          ],
        ],
      ),
    );
  }
}
