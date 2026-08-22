import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:marketplace/domain/entities/marketplace/payout_method_entity.dart';

bool _isArabic() => Get.locale?.languageCode == 'ar';

String _localized(String? ar, String? en) {
  final arabic = ar ?? '';
  final english = en ?? '';
  return _isArabic()
      ? (arabic.isNotEmpty ? arabic : english)
      : (english.isNotEmpty ? english : arabic);
}

class PayoutFieldOptionModel {
  const PayoutFieldOptionModel({
    required this.value,
    required this.labelAr,
    required this.labelEn,
  });

  final String value;
  final String labelAr;
  final String labelEn;

  factory PayoutFieldOptionModel.fromJson(Map<String, dynamic> json) {
    return PayoutFieldOptionModel(
      value: json['value']?.toString() ?? '',
      labelAr: json['label_ar'] as String? ?? '',
      labelEn: json['label_en'] as String? ?? '',
    );
  }

  PayoutFieldOptionEntity toEntity() => PayoutFieldOptionEntity(
        value: value,
        label: _localized(labelAr, labelEn),
      );
}

class PayoutMethodFieldModel {
  const PayoutMethodFieldModel({
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
  final String fieldType;
  final bool isRequired;
  final int sortOrder;
  final String? placeholderAr;
  final String? placeholderEn;
  final String? validationRegex;
  final String? validationMessageAr;
  final String? validationMessageEn;
  final List<PayoutFieldOptionModel> options;

  factory PayoutMethodFieldModel.fromJson(Map<String, dynamic> json) {
    return PayoutMethodFieldModel(
      id: json['id'].toString(),
      fieldKey: json['field_key'] as String? ?? '',
      labelAr: json['label_ar'] as String? ?? '',
      labelEn: json['label_en'] as String? ?? '',
      fieldType: json['field_type'] as String? ?? 'TEXT',
      isRequired: json['is_required'] as bool? ?? false,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      placeholderAr: json['placeholder_ar'] as String?,
      placeholderEn: json['placeholder_en'] as String?,
      validationRegex: json['validation_regex'] as String?,
      validationMessageAr: json['validation_message_ar'] as String?,
      validationMessageEn: json['validation_message_en'] as String?,
      options: (json['options'] as List<dynamic>? ?? const [])
          .map((item) =>
              PayoutFieldOptionModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  PayoutMethodFieldEntity toEntity() {
    final placeholder = _localized(placeholderAr, placeholderEn);
    final message = _localized(validationMessageAr, validationMessageEn);

    return PayoutMethodFieldEntity(
      id: id,
      fieldKey: fieldKey,
      label: _localized(labelAr, labelEn),
      fieldType: PayoutFieldType.fromWire(fieldType),
      isRequired: isRequired,
      sortOrder: sortOrder,
      placeholder: placeholder.isEmpty ? null : placeholder,
      validationRegex: validationRegex,
      validationMessage: message.isEmpty ? null : message,
      options: options.map((option) => option.toEntity()).toList(),
    );
  }
}

/// Wire model for `GET /dropdowns/payout-methods`.
class PayoutMethodModel {
  const PayoutMethodModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.sortOrder,
    this.iconUrl,
    this.fields = const [],
  });

  final String id;
  final String nameAr;
  final String nameEn;
  final int sortOrder;
  final String? iconUrl;
  final List<PayoutMethodFieldModel> fields;

  factory PayoutMethodModel.fromJson(Map<String, dynamic> json) {
    return PayoutMethodModel(
      id: json['id'].toString(),
      nameAr: json['name_ar'] as String? ?? '',
      nameEn: json['name_en'] as String? ?? '',
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      iconUrl: json['icon_url'] as String?,
      fields: (json['fields'] as List<dynamic>? ?? const [])
          .map((item) =>
              PayoutMethodFieldModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  PayoutMethodEntity toEntity() {
    // Sorted here rather than in the UI so every consumer sees the backend's
    // intended field order.
    final sorted = [...fields]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return PayoutMethodEntity(
      id: id,
      name: _localized(nameAr, nameEn),
      sortOrder: sortOrder,
      iconUrl: iconUrl,
      fields: sorted.map((field) => field.toEntity()).toList(),
    );
  }
}
