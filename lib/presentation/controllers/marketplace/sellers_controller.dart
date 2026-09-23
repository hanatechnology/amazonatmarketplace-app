import 'package:get/get.dart';
import 'package:marketplace/app/routes/app_routes.dart';
import 'package:marketplace/core/bases/base_state_controller.dart';
import 'package:marketplace/core/states/app_state.dart';
import 'package:marketplace/domain/entities/marketplace/seller_entity.dart';
import 'package:marketplace/domain/usecases/base_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/seller/get_sellers_use_case.dart';
import 'package:marketplace/app/routes/app_router.dart';

const String kSellers = 'sellers';

class SellersController extends BaseStateController<GetSellersUseCase> {
  static const int kPageSize = 20;

  final searchQuery = ''.obs;
  final hasMore = false.obs;
  final isLoadingMore = false.obs;

  int _page = 1;

  @override
  void onInit() {
    super.onInit();
    loadSellers();
  }

  Future<void> loadSellers() async {
    _page = 1;
    await _fetchPage(append: false);
  }

  Future<void> refreshSellers() => loadSellers();

  /// Called by SearchBarWidget with an already-debounced query.
  Future<void> onSearch(String query) async {
    if (searchQuery.value == query) return;
    searchQuery.value = query;
    await loadSellers();
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;
    isLoadingMore.value = true;
    _page += 1;
    await _fetchPage(append: true);
    isLoadingMore.value = false;
  }

  Future<void> _fetchPage({required bool append}) async {
    await handlePaginationState<SellerEntity>(
      kSellers,
      () async {
        final state = await useCase.call(
          PaginationInput(
            page: _page,
            limit: kPageSize,
            filters: searchQuery.value.isEmpty ? null : searchQuery.value,
          ),
        );
        return state.when(
          onInitial: () => const AppStateInitial<List<SellerEntity>>(),
          onLoading: () => const AppStateLoading<List<SellerEntity>>(),
          onSuccess: (paged, message) {
            hasMore.value = paged.hasMore;
            _page = paged.currentPage;
            return AppStateSuccess(paged.items, message: message);
          },
          onError: (message, code) {
            // Roll the cursor back so a retry re-requests the failed page.
            if (append && _page > 1) _page -= 1;
            return AppStateError<List<SellerEntity>>(message, code: code);
          },
        );
      },
      append: append,
    );
  }

  void openSeller(SellerEntity seller) =>
      AppRouter.toNamed(Routes.MARKETPLACE_SELLER, arguments: seller.id);
}
