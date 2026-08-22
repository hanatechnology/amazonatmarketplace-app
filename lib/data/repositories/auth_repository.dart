import 'package:marketplace/core/bases/base_repository.dart';
import 'package:marketplace/core/bases/base_response.dart';
import 'package:marketplace/core/network/result.dart';
import 'package:marketplace/data/models/marketplace/auth_user_model.dart';
import 'package:marketplace/data/services/api_service.dart';

class AuthRepository extends BaseRepository<ApiService> {
  AuthRepository(super.service);

  /// Step 1 — send OTP to the given phone number.
  ///
  /// Phone alone acts as sign-in. When the number has never been registered the
  /// API answers `registration_required`; retrying with [firstName] and [email]
  /// registers the customer and then sends the code. Profile fields are ignored
  /// once they are already set on the account.
  Future<Result<void>> requestOtp(
    String phone, {
    String? firstName,
    String? lastName,
    String? email,
  }) {
    return post<void>(
      '/auth/request-otp',
      (_) {},
      body: {
        'phone': phone,
        if (firstName != null && firstName.isNotEmpty) 'first_name': firstName,
        if (lastName != null && lastName.isNotEmpty) 'last_name': lastName,
        if (email != null && email.isNotEmpty) 'email': email,
      },
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
