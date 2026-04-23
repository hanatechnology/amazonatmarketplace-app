import 'package:marketplace/core/bases/base_repository.dart';
import 'package:marketplace/core/bases/base_response.dart';
import 'package:marketplace/core/network/result.dart';
import 'package:marketplace/data/models/marketplace/auth_user_model.dart';
import 'package:marketplace/data/services/api_service.dart';

class AuthRepository extends BaseRepository<ApiService> {
  AuthRepository(super.service);

  /// Step 1 — send OTP to the given phone number.
  Future<Result<void>> requestOtp(String phone) {
    return post<void>(
      '/auth/request-otp',
      (_) {},
      body: {'phone': phone},
    );
  }

  /// Step 2 — verify OTP and receive tokens + user data.
  Future<Result<AuthResponseModel>> verifyOtp(String phone, String otp) {
    return post<AuthResponseModel>(
      '/auth/verify-otp',
      (json) {
        final response = BaseResponse<AuthResponseModel>.fromJson(
          json,
          (jsonData) => AuthResponseModel.fromJson(jsonData),
        );
        return response.data;
      },
      body: {'phone': phone, 'otp': otp},
    );
  }
}
