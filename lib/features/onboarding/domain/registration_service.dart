import 'dart:convert';

import '../../../core/config/api_config.dart';
import '../../../core/services/base_service_provider.dart';

class RegistrationService extends BaseServiceProvider {
  RegistrationService({super.client}) : super(baseUrl: ApiConfig.baseUrl);

  /// POST /v1/profile (Bearer auth required)
  ///
  /// Completes onboarding for the OTP-created account. The backend now
  /// requires the access token from `verifyOtp` / `login` — without it
  /// the response is HTTP 500 "Authentication failed".
  Future<Map<String, dynamic>> registerProfile(
    Map<String, dynamic> profileData, {
    required String accessToken,
  }) async {
    setAuthToken(accessToken);
    return post(ApiConfig.profile, profileData);
  }

  /// POST /v1/profile/details (Bearer auth required)
  ///
  /// Creates a lightweight (hirer) profile — name + addresses only, no
  /// portfolio. Used by the non-creator onboarding flow.
  ///
  /// Verified body shape (backend confirmed 2026-05-19, HTTP 201):
  /// firstName, lastName, nickName, profileType, profileId, and an
  /// `address` array of { streetAddress, type, city, state, country,
  /// pinCode, location{latitude,longitude} }.
  ///
  /// Uses a raw request (not the shared `post()` helper) so the full
  /// response body is captured for every status code. The backend
  /// returns HTTP 500 — not a 4xx — for business errors such as a
  /// duplicate profile ("duplicate key value violates unique
  /// constraint…"); `post()`/`_handleResponse` would discard that body
  /// and throw a generic "HTTP Error: 500", hiding the real reason.
  Future<Map<String, dynamic>> createProfileDetails(
    Map<String, dynamic> profileData, {
    required String accessToken,
  }) async {
    final response = await client.post(
      Uri.parse('$baseUrl${ApiConfig.profileDetails}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: json.encode(profileData),
    );
    try {
      final decoded = json.decode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {
      // Non-JSON body — fall through to a synthetic error map.
    }
    return {
      'success': false,
      'status': response.statusCode,
      'message': 'Unexpected response (${response.statusCode}).',
    };
  }
}
