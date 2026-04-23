import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marketplace/data/models/marketplace/local_cart_item_model.dart';

/// Local cart repository — all reads/writes go to SharedPreferences.
/// The server is never touched here; checkout is handled separately.
class LocalCartRepository {
  static const _key = 'local_cart';
  final SharedPreferences _prefs;

  LocalCartRepository(this._prefs);

  // ── Read ──────────────────────────────────────────────────

  /// Return all items sorted newest-first.
  List<LocalCartItemModel> getItems() {
    final raw = _prefs.getString(_key);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => LocalCartItemModel.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.addedAt.compareTo(a.addedAt));
  }

  // ── Write ─────────────────────────────────────────────────

  Future<void> _save(List<LocalCartItemModel> items) async {
    await _prefs.setString(
      _key,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }

  /// Add a new item or increment quantity if [productId] already exists.
  Future<void> addOrUpdate(LocalCartItemModel item) async {
    final items = getItems();
    final idx = items.indexWhere((e) => e.productId == item.productId);
    if (idx >= 0) {
      final existing = items[idx];
      final newQty = (existing.quantity + item.quantity).clamp(1, 99);
      items[idx] = existing.copyWith(quantity: newQty);
    } else {
      items.insert(0, item);
    }
    await _save(items);
  }

  Future<void> remove(String productId) async {
    final items = getItems()..removeWhere((e) => e.productId == productId);
    await _save(items);
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    final items = getItems();
    final idx = items.indexWhere((e) => e.productId == productId);
    if (idx < 0) return;
    items[idx] = items[idx].copyWith(quantity: quantity.clamp(1, 99));
    await _save(items);
  }

  Future<void> toggleSelection(String productId) async {
    final items = getItems();
    final idx = items.indexWhere((e) => e.productId == productId);
    if (idx < 0) return;
    items[idx] = items[idx].copyWith(isSelected: !items[idx].isSelected);
    await _save(items);
  }

  Future<void> setSelectAll(bool selected) async {
    final items =
        getItems().map((e) => e.copyWith(isSelected: selected)).toList();
    await _save(items);
  }

  Future<void> clear() async => _prefs.remove(_key);
}
