import '../../../core/config/api_config.dart';
import '../../../core/services/base_service_provider.dart';

class ProfileService extends BaseServiceProvider {
  ProfileService({super.client}) : super(baseUrl: ApiConfig.baseUrl);

  /// GET /v1/profile/:profileId
  Future<Map<String, dynamic>> getProfile({
    required String profileId,
    required String accessToken,
  }) async {
    setAuthToken(accessToken);
    return get('${ApiConfig.profile}/$profileId');
  }

  /// DELETE /v1/profile/:profileId
  Future<Map<String, dynamic>> deleteProfile({
    required String profileId,
    required String accessToken,
  }) async {
    setAuthToken(accessToken);
    return delete('${ApiConfig.profile}/$profileId');
  }

  /// PATCH /v1/profile/:profileId
  Future<Map<String, dynamic>> updatePin({
    required String profileId,
    required String pin,
    required String accessToken,
  }) async {
    setAuthToken(accessToken);
    return put('${ApiConfig.profile}/$profileId', {'pin': pin});
  }
}
