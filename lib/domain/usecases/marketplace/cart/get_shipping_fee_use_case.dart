import 'package:marketplace/core/states/app_state.dart';
import 'package:marketplace/data/repositories/checkout_repository.dart';
import 'package:marketplace/domain/entities/marketplace/shipping_fee_entity.dart';
import 'package:marketplace/domain/usecases/base_use_case.dart';

class ShippingFeeInput {
  const ShippingFeeInput({required this.vendorId, required this.addressId});

  final String vendorId;
  final String addressId;
}

class GetShippingFeeUseCase extends BaseUseCase<ShippingFeeInput,
    ShippingFeeEntity, CheckoutRepository> {
  GetShippingFeeUseCase(super.repository);

  @override
  Future<AppState<ShippingFeeEntity>> call(ShippingFeeInput input) async {
    final result = await repository.getShippingFee(
      vendorId: input.vendorId,
      addressId: input.addressId,
    );
    return resultToStateWithMapping(
      result: result,
      mapper: (model) => model.toEntity(),
    );
  }
}
