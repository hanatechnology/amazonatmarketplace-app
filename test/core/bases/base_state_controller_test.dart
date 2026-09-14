import 'package:flutter_test/flutter_test.dart';
import 'package:marketplace/core/bases/base_state_controller.dart';
import 'package:marketplace/core/states/app_state.dart';

/// Stands in for a real entity — only its identity as a distinct type matters.
class _Banner {
  const _Banner(this.id);
  final String id;
}

class _Category {
  const _Category(this.name);
  final String name;
}

class _TestController extends BaseStateController<Object> {
  Future<void> loadParallel() => handleMultipleStates([
        StateOperation<List<_Banner>>(
          'banners',
          () async => const AppStateSuccess([_Banner('a')]),
        ),
        StateOperation<List<_Category>>(
          'categories',
          () async => const AppStateSuccess([_Category('c')]),
        ),
      ]);

  Future<void> loadFailing() => handleMultipleStates([
        StateOperation<List<_Banner>>('banners', () async => throw StateError('boom')),
      ]);
}

void main() {
  group('handleMultipleStates keeps each operation\'s type', () {
    test('typed read after a parallel load does not throw', () async {
      final c = _TestController();
      await c.loadParallel();

      // Regression: this previously threw
      //   type 'Rx<AppState<dynamic>>' is not a subtype of
      //   type 'Rx<AppState<List<BannerEntity>>>' in type cast
      // because the map-based API erased T when creating the state.
      expect(c.getOperationData<List<_Banner>>('banners')?.single.id, 'a');
      expect(c.getOperationData<List<_Category>>('categories')?.single.name, 'c');
    });

    test('states carry the right generic, so isSuccess reports correctly', () async {
      final c = _TestController();
      await c.loadParallel();

      // AppStateSuccess<dynamic> would fail `is AppStateSuccess<List<_Banner>>`
      // and silently report false here.
      expect(c.getState<List<_Banner>>('banners').isSuccess, isTrue);
      expect(c.stateFor<List<_Banner>>('banners').value, isA<AppStateSuccess<List<_Banner>>>());
    });

    test('each key is independent — one type does not pin another', () async {
      final c = _TestController();
      await c.loadParallel();

      expect(c.stateFor<List<_Category>>('categories').value,
          isA<AppStateSuccess<List<_Category>>>());
    });

    test('a thrown operation lands as a typed error state', () async {
      final c = _TestController();
      await c.loadFailing();

      final state = c.stateFor<List<_Banner>>('banners').value;
      expect(state, isA<AppStateError<List<_Banner>>>());
      expect(c.getState<List<_Banner>>('banners').isError, isTrue);
    });
  });
}
