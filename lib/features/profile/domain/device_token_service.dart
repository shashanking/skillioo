import '../../../core/config/api_config.dart';
import '../../../core/services/base_service_provider.dart';

class DeviceTokenService extends BaseServiceProvider {
  DeviceTokenService({super.client}) : super(baseUrl: ApiConfig.baseUrl);

  /// POST /v1/profile/{profileId}/device-token
  Future<Map<String, dynamic>> updateDeviceToken({
    required String profileId,
    required String fcmToken,
    required String accessToken,
  }) async {
    setAuthToken(accessToken);
    return post('${ApiConfig.profile}/$profileId/device-token', {
      'deviceToken': fcmToken,
      'deviceType': 'MOBILE',
    });
  }
}
