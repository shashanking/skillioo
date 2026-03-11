import '../../../core/config/api_config.dart';
import '../../../core/services/base_service_provider.dart';

class ProfileUpdateService extends BaseServiceProvider {
  ProfileUpdateService() : super(baseUrl: ApiConfig.baseUrl);

  Future<Map<String, dynamic>> updateProfile({
    required String accessToken,
    required Map<String, dynamic> body,
  }) async {
    setAuthToken(accessToken);
    return put(ApiConfig.profile, body);
  }
}
