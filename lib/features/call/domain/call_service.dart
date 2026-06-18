import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import 'call_models.dart';
import 'fcm_token_models.dart';

class CallService {
  final http.Client _client;

  CallService({http.Client? client}) : _client = client ?? http.Client();

  Map<String, dynamic> handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    }
    if (response.statusCode >= 400 && response.statusCode < 500) {
      try {
        return json.decode(response.body) as Map<String, dynamic>;
      } catch (_) {}
    }
    throw Exception('HTTP Error: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> setFcmToken({
    required String token,
    required String userId,
    required String accessToken,
  }) async {
    final url = Uri.parse('${ApiConfig.customerBaseUrl}${ApiConfig.fcmToken}');

    final request = SetFcmTokenRequest(token: token, userId: userId);

    final response = await _client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(request.toJson()),
    );

    return handleResponse(response);
  }

  Future<Map<String, dynamic>> getFcmToken({
    required String userId,
    required String accessToken,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.customerBaseUrl}${ApiConfig.fcmToken}?userId=$userId',
    );

    final response = await _client.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    return handleResponse(response);
  }

  /// GET /v1/call/:userId — the user's call history.
  Future<Map<String, dynamic>> getCalls({
    required String userId,
    required String accessToken,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.customerBaseUrl}${ApiConfig.call}/$userId',
    );
    final response = await _client.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
    return handleResponse(response);
  }

  Future<Map<String, dynamic>> getCallToken({
    required CallProvider provider,
    required String callerId,
    required String accessToken,
  }) async {
    final providerStr = provider == CallProvider.twilio ? 'TWILIO' : 'TWILIO';
    final url = Uri.parse(
      '${ApiConfig.customerBaseUrl}${ApiConfig.callToken}?provider=$providerStr&callerId=$callerId',
    );

    final response = await _client.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    return handleResponse(response);
  }

  Future<Map<String, dynamic>> initiateCall({
    required String recipientId,
    // required String registrationToken,
    required String accessToken,
  }) async {
    final url = Uri.parse('${ApiConfig.customerBaseUrl}${ApiConfig.call}');

    final request = InitiateCallRequest(
      recipientId: recipientId,
      // registrationToken: registrationToken,
    );

    final response = await _client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(request.toJson()),
    );

    return handleResponse(response);
  }

  Future<Map<String, dynamic>> acceptCall({
    required String callId,
    required String accessToken,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.customerBaseUrl}${ApiConfig.callAccept}',
    );

    final response = await _client.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({'callId': callId}),
    );

    return handleResponse(response);
  }

  Future<Map<String, dynamic>> rejectCall({
    required String callId,
    required String accessToken,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.customerBaseUrl}${ApiConfig.callReject}',
    );

    final response = await _client.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({'callId': callId}),
    );

    return handleResponse(response);
  }

  Future<Map<String, dynamic>> endCall({
    required String callId,
    required String accessToken,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.customerBaseUrl}${ApiConfig.callEnd}',
    );

    final response = await _client.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({'callId': callId}),
    );

    return handleResponse(response);
  }
}
