import '../../../core/config/api_config.dart';
import '../../../core/services/base_service_provider.dart';

class VerificationService extends BaseServiceProvider {
  VerificationService({super.client}) : super(baseUrl: ApiConfig.baseUrl);

  /// POST /verificationRequest
  ///
  /// New unified flow: backend decides what to do based on the phone number:
  ///  - new user → response carries `data.verification.id` and an OTP is sent.
  ///  - returning user without PIN → `data.isPinSet:false` + `verificationId`
  ///    (OTP sent so they can log in via OTP).
  ///  - returning user with PIN → `data.isPinSet:true` (no `verificationId`,
  ///    no OTP sent — client should show the PIN-entry screen instead).
  Future<Map<String, dynamic>> createVerificationRequest({
    required String phoneNumber,
  }) async {
    return post(ApiConfig.verificationRequest, {
      'phoneNumber': phoneNumber,
    });
  }

  /// POST /verificationRequest/resendOtp
  /// Resends OTP for an existing verification.
  Future<Map<String, dynamic>> resendOtp({
    required String phoneNumber,
    required String verificationId,
  }) async {
    return post(ApiConfig.resendOtp, {
      'phoneNumber': phoneNumber,
      'verificationId': verificationId,
    });
  }

  /// POST /verificationRequest/verifyOtp
  /// Verifies the OTP code.
  Future<Map<String, dynamic>> verifyOtp({
    required String otpCode,
    required String verificationId,
  }) async {
    return post(ApiConfig.verifyOtp, {
      'otpCode': otpCode,
      'verificationId': verificationId,
    });
  }
}
