import 'package:get/get.dart';
import 'package:marketplace/data/repositories/address_repository.dart';
import 'package:marketplace/data/services/api_service.dart';
import 'package:marketplace/domain/usecases/marketplace/address/create_address_use_case.dart';
import 'package:marketplace/domain/usecases/marketplace/address/get_cities_use_case.dart';
import 'package:marketplace/presentation/controllers/add_address_controller.dart';

class AddAddressBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddressRepository>(
      () => AddressRepository(Get.find<ApiService>()),
      fenix: true,
    );
    Get.lazyPut<CreateAddressUseCase>(
      () => CreateAddressUseCase(Get.find<AddressRepository>()),
    );
    Get.lazyPut<GetCitiesUseCase>(
      () => GetCitiesUseCase(Get.find<AddressRepository>()),
      fenix: true,
    );
    Get.lazyPut<AddAddressController>(() => AddAddressController());
  }
}
