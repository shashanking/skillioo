import '../../../core/config/api_config.dart';
import '../../../core/services/base_service_provider.dart';

class ProfileService extends BaseServiceProvider {
  ProfileService() : super(baseUrl: ApiConfig.baseUrl);

  /// GET /v1/profile/:profileId
  Future<Map<String, dynamic>> getProfile({
    required String profileId,
    required String accessToken,
  }) async {
    setAuthToken(accessToken);
    return get('${ApiConfig.profile}/$profileId');
  }
}
