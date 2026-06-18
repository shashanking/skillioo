import '../../../core/config/api_config.dart';
import '../../../core/services/base_service_provider.dart';

class ProfileAuthService extends BaseServiceProvider {
  ProfileAuthService({super.client}) : super(baseUrl: ApiConfig.baseUrl);

  /// POST /v1/profile/login
  Future<Map<String, dynamic>> login({
    required String credential,
    required String pin,
  }) async {
    return post(ApiConfig.profileLogin, {
      'credential': credential,
      'pin': pin,
    });
  }

  /// PUT /v1/profile/pin (Bearer auth required)
  Future<Map<String, dynamic>> updatePin({
    required String credential,
    required String pin,
    required String accessToken,
  }) async {
    setAuthToken(accessToken);
    return put(ApiConfig.profilePin, {
      'credential': credential,
      'pin': pin,
    });
  }

  /// PUT /v1/profile/forgotPin (NO auth — backend allows anonymous reset).
  Future<Map<String, dynamic>> forgotPin({
    required String credential,
    required String pin,
    required String confirmPin,
  }) async {
    clearAuthToken();
    return put(ApiConfig.profileForgotPin, {
      'credential': credential,
      'pin': pin,
      'confirmPin': confirmPin,
    });
  }
}
