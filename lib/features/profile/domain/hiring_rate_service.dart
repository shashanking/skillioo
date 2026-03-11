import '../../../core/config/api_config.dart';
import '../../../core/services/base_service_provider.dart';

class HiringRateService extends BaseServiceProvider {
  HiringRateService() : super(baseUrl: ApiConfig.baseUrl);

  Future<Map<String, dynamic>> getHiringRate({
    required String portfolioId,
    required String accessToken,
  }) async {
    setAuthToken(accessToken);
    return getWithParams(ApiConfig.profileHiringRate, {
      'portfolioId': portfolioId,
    });
  }
}
