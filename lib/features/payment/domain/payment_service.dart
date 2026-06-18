import '../../../core/config/api_config.dart';
import '../../../core/services/base_service_provider.dart';

class PaymentService extends BaseServiceProvider {
  PaymentService({super.client}) : super(baseUrl: ApiConfig.paymentBaseUrl);

  // ── Payment ──

  Future<Map<String, dynamic>> createPayment(Map<String, dynamic> data) async {
    return post(ApiConfig.payment, data);
  }

  Future<Map<String, dynamic>> fetchPayments({
    String? referenceIdSet,
    String? userReferenceIdSet,
    String? from,
    String? to,
  }) async {
    final params = <String, String>{};
    if (referenceIdSet != null) params['referenceIdSet'] = referenceIdSet;
    if (userReferenceIdSet != null) {
      params['userReferenceIdSet'] = userReferenceIdSet;
    }
    if (from != null) params['from'] = from;
    if (to != null) params['to'] = to;
    if (params.isEmpty) return get(ApiConfig.payment);
    return getWithParams(ApiConfig.payment, params);
  }

  // ── Payment User ──

  Future<Map<String, dynamic>> createPaymentUser(
    Map<String, dynamic> data,
  ) async {
    return post(ApiConfig.paymentUser, data);
  }

  Future<Map<String, dynamic>> getShortUser({
    String? referenceId,
    String? nickName,
  }) async {
    if (referenceId == null && nickName == null) {
      throw Exception('Either referenceId or nickName is required');
    }

    final params = <String, String>{};
    if (referenceId != null) params['referenceId'] = referenceId;
    if (nickName != null) params['nickName'] = nickName;

    return getWithParams(ApiConfig.shortUser, params);
  }

  Future<Map<String, dynamic>> fetchPaymentUser(String referenceId) async {
    return get('${ApiConfig.paymentUser}/$referenceId');
  }

  Future<Map<String, dynamic>> updatePaymentUser(
    Map<String, dynamic> data,
  ) async {
    return put(ApiConfig.paymentUser, data);
  }

  Future<Map<String, dynamic>> deletePaymentUser({
    required List<String> referenceIds,
    bool hard = false,
  }) async {
    return deleteWithBody(ApiConfig.paymentUser, {
      'referenceIds': referenceIds,
      'hard': hard,
    });
  }
}
