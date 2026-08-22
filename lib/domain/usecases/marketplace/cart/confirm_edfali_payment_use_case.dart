import 'package:marketplace/core/network/result.dart';
import 'package:marketplace/data/repositories/checkout_repository.dart';
import 'package:marketplace/domain/entities/marketplace/edfali_payment_entity.dart';

class ConfirmEdfaliInput {
  const ConfirmEdfaliInput({required this.orderId, required this.otp});

  final String orderId;
  final String otp;
}

/// Returns the raw [Result] rather than an `AppState` — the caller has to read
/// the error `code` and `attempts_remaining` to tell a retryable wrong PIN from
/// a terminal failure, and `AppState` keeps only the message.
class ConfirmEdfaliPaymentUseCase {
  ConfirmEdfaliPaymentUseCase(this._repository);

  final CheckoutRepository _repository;

  Future<Result<PaymentStatus>> call(ConfirmEdfaliInput input) =>
      _repository.confirmEdfaliPayment(
        orderId: input.orderId,
        otp: input.otp,
      );
}
