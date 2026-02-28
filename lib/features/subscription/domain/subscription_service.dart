import '../../../core/config/api_config.dart';
import '../../../core/services/base_service_provider.dart';

class SubscriptionService extends BaseServiceProvider {
  SubscriptionService() : super(baseUrl: ApiConfig.customerBaseUrl);

  // ── Plan Master ──

  Future<Map<String, dynamic>> getPlans() async {
    return get(ApiConfig.planMasterPlans);
  }

  Future<Map<String, dynamic>> getPlanById(String id) async {
    return get('${ApiConfig.planMaster}/$id');
  }

  // ── User Subscription ──

  Future<Map<String, dynamic>> initiateSubscription(
      Map<String, dynamic> data) async {
    return post(ApiConfig.userSubscription, data);
  }

  Future<Map<String, dynamic>> fetchSubscription({
    required String planId,
  }) async {
    return getWithParams(ApiConfig.userSubscription, {'planId': planId});
  }

  Future<Map<String, dynamic>> syncSubscriptionStatus(
      Map<String, dynamic> data) async {
    return patch(ApiConfig.userSubscriptionStatus, data);
  }
}
