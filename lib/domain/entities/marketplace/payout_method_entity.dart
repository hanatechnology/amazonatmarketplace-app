import 'package:equatable/equatable.dart';
import 'package:marketplace/core/utils/localized_copy.dart';

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
  const PayoutFieldOptionEntity({
    required this.value,
    required this.labelAr,
    required this.labelEn,
  });

  final String value;
  final String labelAr;
  final String labelEn;

  String get label => localizedCopy(labelAr, labelEn) ?? value;

  @override
  List<Object?> get props => [value, labelAr, labelEn];
}

/// One field the customer must fill in for a payout method. The backend owns
/// the label, the control type, and the validation rule — in both languages,
/// so the form follows the app language without a refetch.
class PayoutMethodFieldEntity extends Equatable {
  const PayoutMethodFieldEntity({
    required this.id,
    required this.fieldKey,
    required this.labelAr,
    required this.labelEn,
    required this.fieldType,
    required this.isRequired,
    required this.sortOrder,
    this.placeholderAr,
    this.placeholderEn,
    this.validationRegex,
    this.validationMessageAr,
    this.validationMessageEn,
    this.options = const [],
  });

  final String id;
  final String fieldKey;
  final String labelAr;
  final String labelEn;
  final PayoutFieldType fieldType;
  final bool isRequired;
  final int sortOrder;
  final String? placeholderAr;
  final String? placeholderEn;
  final String? validationRegex;
  final String? validationMessageAr;
  final String? validationMessageEn;
  final List<PayoutFieldOptionEntity> options;

  String get label => localizedCopy(labelAr, labelEn) ?? fieldKey;

  String? get placeholder => localizedCopy(placeholderAr, placeholderEn);

  /// The backend's "why this value is wrong" copy for the active locale.
  /// Null when the backend shipped neither language — the caller then falls
  /// back to the app's own generic message.
  String? get validationMessage =>
      localizedCopy(validationMessageAr, validationMessageEn);

  @override
  List<Object?> get props => [
        id,
        fieldKey,
        labelAr,
        labelEn,
        fieldType,
        isRequired,
        sortOrder,
        placeholderAr,
        placeholderEn,
        validationRegex,
        validationMessageAr,
        validationMessageEn,
        options,
      ];
}

/// One entry from `GET /dropdowns/payout-methods`.
class PayoutMethodEntity extends Equatable {
  const PayoutMethodEntity({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.fields,
    required this.sortOrder,
    this.iconUrl,
  });

  final String id;
  final String nameAr;
  final String nameEn;
  final List<PayoutMethodFieldEntity> fields;
  final int sortOrder;
  final String? iconUrl;

  String get name => localizedCopy(nameAr, nameEn) ?? '';

  @override
  List<Object?> get props => [id, nameAr, nameEn, fields, sortOrder, iconUrl];
}
