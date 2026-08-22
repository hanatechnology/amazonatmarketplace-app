import 'package:marketplace/core/network/result.dart';
import 'package:marketplace/data/repositories/auth_repository.dart';

class RequestOtpUseCase {
  RequestOtpUseCase(this._repository);
  final AuthRepository _repository;

  Future<Result<void>> call(
    String phone, {
    String? firstName,
    String? lastName,
    String? email,
  }) =>
      _repository.requestOtp(
        phone,
        firstName: firstName,
        lastName: lastName,
        email: email,
      );
}
