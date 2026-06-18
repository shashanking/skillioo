import '../../../core/config/api_config.dart';
import '../../../core/services/base_service_provider.dart';

class PrivacyService extends BaseServiceProvider {
  PrivacyService({super.client}) : super(baseUrl: ApiConfig.postBaseUrl);

  // Get privacy settings for a user
  Future<Map<String, dynamic>> getPrivacy({
    required String userReferenceId,
  }) async {
    return getWithParams(ApiConfig.privacy, {
      'userReferenceId': userReferenceId,
    });
  }

  // Update privacy settings (only type in body, auth token in headers)
  Future<Map<String, dynamic>> updatePrivacy({required String type}) async {
    return put(ApiConfig.privacy, {'type': type});
  }
}
