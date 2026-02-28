import '../../../core/config/api_config.dart';
import '../../../core/services/base_service_provider.dart';

class RegistrationService extends BaseServiceProvider {
  RegistrationService() : super(baseUrl: ApiConfig.baseUrl);

  /// POST /v1/profile
  /// Creates/registers a new user profile.
  Future<Map<String, dynamic>> registerProfile(
    Map<String, dynamic> profileData,
  ) async {
    return post(ApiConfig.profile, profileData);
  }
}
