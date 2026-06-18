import '../../../core/config/api_config.dart';
import '../../../core/services/base_service_provider.dart';

class ChatService extends BaseServiceProvider {
  ChatService({super.client}) : super(baseUrl: ApiConfig.customerBaseUrl);

  // ── Messages ──

  Future<Map<String, dynamic>> sendMessage(Map<String, dynamic> data) async {
    return post(ApiConfig.message, data);
  }

  Future<Map<String, dynamic>> getMessages({
    required String conversationId,
    String? before,
    int limit = 30,
  }) async {
    return getWithParams(ApiConfig.message, {
      'conversationId': conversationId,
      'limit': '$limit',
      if (before != null) 'before': before,
    });
  }

  Future<Map<String, dynamic>> softDeleteMessage(String messageId) async {
    return put('${ApiConfig.chat}/$messageId', {});
  }

  // ── Conversations ──

  Future<Map<String, dynamic>> getConversations({
    int page = 1,
    int limit = 10,
  }) async {
    return getWithParams(ApiConfig.conversations, {
      'page': '$page',
      'limit': '$limit',
    });
  }

  Future<Map<String, dynamic>> softDeleteConversation(
    String conversationId,
  ) async {
    return put(
      '${ApiConfig.conversations.replaceAll('/conversations', '/conversation')}/$conversationId',
      {},
    );
  }

  // ── Calls ──

  Future<Map<String, dynamic>> initiateCall(Map<String, dynamic> data) async {
    return post(ApiConfig.call, data);
  }

  Future<Map<String, dynamic>> acceptCall(Map<String, dynamic> data) async {
    return put(ApiConfig.callAccept, data);
  }

  Future<Map<String, dynamic>> rejectCall(Map<String, dynamic> data) async {
    return put(ApiConfig.callReject, data);
  }

  Future<Map<String, dynamic>> endCall(Map<String, dynamic> data) async {
    return put(ApiConfig.callEnd, data);
  }

  // ── Notifications ──

  Future<Map<String, dynamic>> getNotifications({
    required String profileId,
  }) async {
    return getWithParams(ApiConfig.notification, {'profileId': profileId});
  }
}
