import '../../../core/config/api_config.dart';
import '../../../core/services/base_service_provider.dart';

class HiringRateService extends BaseServiceProvider {
  HiringRateService({super.client}) : super(baseUrl: ApiConfig.baseUrl);

  Future<Map<String, dynamic>> getHiringRate({
    required String portfolioId,
    required String accessToken,
  }) async {
    setAuthToken(accessToken);
    return getWithParams(ApiConfig.profileHiringRate, {
      'portfolioId': portfolioId,
    });
  }

  Future<Map<String, dynamic>> updateHiringRate({
    required String accessToken,
    required Map<String, dynamic> data,
  }) async {
    setAuthToken(accessToken);
    return put(ApiConfig.profileHiringRate, data);
  }
}
