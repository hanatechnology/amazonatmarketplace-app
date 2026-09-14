import 'package:flutter/material.dart';

/// Generic dropdown selector.
class BaseDropdown<T> extends StatelessWidget {
  const BaseDropdown({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    required this.labelBuilder,
    this.hint,
    this.label,
    this.validator,
  });

  final List<T> items;
  final T? value;
  final ValueChanged<T?> onChanged;
  final String Function(T item) labelBuilder;
  final String? hint;
  final String? label;
  final String? Function(T?)? validator;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(labelBuilder(item)),
            ),
          )
          .toList(),
    );
  }
}
