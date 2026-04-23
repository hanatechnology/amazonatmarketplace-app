import 'package:marketplace/core/network/result.dart';
import 'package:marketplace/data/models/marketplace/auth_user_model.dart';
import 'package:marketplace/data/repositories/auth_repository.dart';

class VerifyOtpUseCase {
  VerifyOtpUseCase(this._repository);
  final AuthRepository _repository;

  Future<Result<AuthResponseModel>> call(String phone, String otp) =>
      _repository.verifyOtp(phone, otp);
}
