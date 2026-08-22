import 'package:marketplace/core/states/app_state.dart';
import 'package:marketplace/data/repositories/banner_repository.dart';
import 'package:marketplace/domain/entities/marketplace/banner_entity.dart';
import 'package:marketplace/domain/usecases/base_use_case.dart';

class GetBannersUseCase
    extends NoInputUseCase<List<BannerEntity>, BannerRepository> {
  GetBannersUseCase(super.repository);

  @override
  Future<AppState<List<BannerEntity>>> call(_) async {
    final result = await repository.getBanners();
    return resultToStateWithMapping(
      result: result,
      mapper: (models) => models.map((model) => model.toEntity()).toList(),
    );
  }
}
