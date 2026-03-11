import '../../../core/config/api_config.dart';
import '../../../core/services/base_service_provider.dart';

class ProfileAuthService extends BaseServiceProvider {
  ProfileAuthService() : super(baseUrl: ApiConfig.baseUrl);

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
}
