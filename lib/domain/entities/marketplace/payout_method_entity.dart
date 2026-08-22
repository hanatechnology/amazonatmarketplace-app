import 'package:equatable/equatable.dart';

/// Input control types a payout method can declare.
enum PayoutFieldType {
  text,
  number,
  phone,
  select,
  textarea;

  static PayoutFieldType fromWire(String? value) => switch (value) {
        'NUMBER' => PayoutFieldType.number,
        'PHONE' => PayoutFieldType.phone,
        'SELECT' => PayoutFieldType.select,
        'TEXTAREA' => PayoutFieldType.textarea,
        _ => PayoutFieldType.text,
      };
}

class PayoutFieldOptionEntity extends Equatable {
  const PayoutFieldOptionEntity({required this.value, required this.label});

  final String value;
  final String label;

  @override
  List<Object?> get props => [value, label];
}

/// One field the customer must fill in for a payout method. The backend owns
/// the label, the control type, and the validation rule.
class PayoutMethodFieldEntity extends Equatable {
  const PayoutMethodFieldEntity({
    required this.id,
    required this.fieldKey,
    required this.label,
    required this.fieldType,
    required this.isRequired,
    required this.sortOrder,
    this.placeholder,
    this.validationRegex,
    this.validationMessage,
    this.options = const [],
  });

  final String id;
  final String fieldKey;
  final String label;
  final PayoutFieldType fieldType;
  final bool isRequired;
  final int sortOrder;
  final String? placeholder;
  final String? validationRegex;
  final String? validationMessage;
  final List<PayoutFieldOptionEntity> options;

  @override
  List<Object?> get props => [
        id,
        fieldKey,
        label,
        fieldType,
        isRequired,
        sortOrder,
        placeholder,
        validationRegex,
        validationMessage,
        options,
      ];
}

/// One entry from `GET /dropdowns/payout-methods`.
class PayoutMethodEntity extends Equatable {
  const PayoutMethodEntity({
    required this.id,
    required this.name,
    required this.fields,
    required this.sortOrder,
    this.iconUrl,
  });

  final String id;
  final String name;
  final List<PayoutMethodFieldEntity> fields;
  final int sortOrder;
  final String? iconUrl;

  @override
  List<Object?> get props => [id, name, fields, sortOrder, iconUrl];
}
