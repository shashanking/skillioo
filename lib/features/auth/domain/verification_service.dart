import '../../../core/config/api_config.dart';
import '../../../core/services/base_service_provider.dart';

class VerificationService extends BaseServiceProvider {
  VerificationService() : super(baseUrl: ApiConfig.baseUrl);

  /// POST /verificationRequest
  /// Creates a new verification request (sends OTP).
  Future<Map<String, dynamic>> createVerificationRequest({
    required String phoneNumber,
    required String purpose,
  }) async {
    return post(ApiConfig.verificationRequest, {
      'phoneNumber': phoneNumber,
      'purpose': purpose,
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
