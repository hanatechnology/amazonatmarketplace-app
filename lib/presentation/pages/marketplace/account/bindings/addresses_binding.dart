import 'package:get/get.dart';
import 'package:marketplace/data/repositories/address_repository.dart';
import 'package:marketplace/data/services/api_service.dart';
import 'package:marketplace/domain/usecases/marketplace/address/delete_address_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/address/get_addresses_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/address/get_cities_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/address/set_default_address_use_case.dart';
import 'package:marketplace/presentation/controllers/addresses_controller.dart';

class AddressesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddressRepository>(
      () => AddressRepository(Get.find<ApiService>()),
    );
    Get.lazyPut<GetAddressesUseCase>(
      () => GetAddressesUseCase(Get.find<AddressRepository>()),
    );
    Get.lazyPut<DeleteAddressUseCase>(
      () => DeleteAddressUseCase(Get.find<AddressRepository>()),
    );
    Get.lazyPut<SetDefaultAddressUseCase>(
      () => SetDefaultAddressUseCase(Get.find<AddressRepository>()),
    );
    Get.lazyPut<GetCitiesUseCase>(
      () => GetCitiesUseCase(Get.find<AddressRepository>()),
    );
    Get.lazyPut<AddressesController>(() => AddressesController());
  }
}
