import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionPrefs {
  SessionPrefs._internal();

  static final SessionPrefs instance = SessionPrefs._internal();

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _profileKey = 'profile_json';
  static const _profileCreatedKey = 'profile_created';
  static const _localeKey = 'app_locale';
  static const _lastSubscriptionIdKey = 'last_subscription_id';
  static const _lastPhoneNumberKey = 'last_phone_number';
  static const _verificationIdKey = 'last_verification_id';
  static const _lastPhoneVerificationIdKey = 'last_phone_verification_id';
  static const _lastLoginTimestampKey = 'last_login_timestamp';
  static const _dashboardCityFilterKey = 'dashboard_city_filter';
  static const _dashboardRecentLocationsKey = 'dashboard_recent_locations';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // ── In-memory cache ──────────────────────────────────────────────
  // Avoids hitting platform-channel secure storage on every read.
  // Writes go through to storage AND update the cache.
  // Call clear() or invalidateCache() to reset.

  String? _cachedAccessToken;
  String? _cachedRefreshToken;
  Map<String, dynamic>? _cachedProfile;
  bool _profileCacheValid = false;
  bool _tokenCacheValid = false;

  /// Pre-warm the in-memory cache from secure storage.
  /// Call once at app startup (e.g. in main() before runApp).
  Future<void> warmUp() async {
    _cachedAccessToken = await _storage.read(key: _accessTokenKey) ?? '';
    _cachedRefreshToken = await _storage.read(key: _refreshTokenKey) ?? '';
    _tokenCacheValid = true;

    final raw = await _storage.read(key: _profileKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        _cachedProfile = jsonDecode(raw) as Map<String, dynamic>;
      } catch (_) {
        _cachedProfile = null;
      }
    } else {
      _cachedProfile = null;
    }
    _profileCacheValid = true;
  }

  void invalidateCache() {
    _tokenCacheValid = false;
    _profileCacheValid = false;
    _cachedAccessToken = null;
    _cachedRefreshToken = null;
    _cachedProfile = null;
  }

  Future<void> setSession({
    required String accessToken,
    required String refreshToken,
    required Map<String, dynamic> profile,
  }) async {
    // Update cache immediately
    _cachedAccessToken = accessToken;
    _cachedRefreshToken = refreshToken;
    _cachedProfile = profile;
    _tokenCacheValid = true;
    _profileCacheValid = true;

    // Persist to storage
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    await _storage.write(key: _profileKey, value: jsonEncode(profile));
    await _storage.write(
      key: _lastLoginTimestampKey,
      value: DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  Future<void> setProfileCreated(bool created) async {
    await _storage.write(
      key: _profileCreatedKey,
      value: created ? 'true' : 'false',
    );
  }

  Future<bool> isProfileCreated() async {
    final raw = await _storage.read(key: _profileCreatedKey);
    return raw == 'true';
  }

  Future<String> getAccessToken() async {
    if (_tokenCacheValid && _cachedAccessToken != null) {
      return _cachedAccessToken!;
    }
    final token = await _storage.read(key: _accessTokenKey) ?? '';
    _cachedAccessToken = token;
    _tokenCacheValid = true;
    return token;
  }

  Future<String> getRefreshToken() async {
    if (_tokenCacheValid && _cachedRefreshToken != null) {
      return _cachedRefreshToken!;
    }
    final token = await _storage.read(key: _refreshTokenKey) ?? '';
    _cachedRefreshToken = token;
    return token;
  }

  Future<Map<String, dynamic>?> getProfile() async {
    if (_profileCacheValid) return _cachedProfile;
    final raw = await _storage.read(key: _profileKey);
    if (raw == null || raw.isEmpty) {
      _cachedProfile = null;
      _profileCacheValid = true;
      return null;
    }
    try {
      _cachedProfile = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      _cachedProfile = null;
    }
    _profileCacheValid = true;
    return _cachedProfile;
  }

  Future<void> mergeProfile(Map<String, dynamic> updates) async {
    final current = await getProfile() ?? <String, dynamic>{};
    final next = <String, dynamic>{...current, ...updates};
    _cachedProfile = next;
    _profileCacheValid = true;
    await _storage.write(key: _profileKey, value: jsonEncode(next));
  }

  Future<bool> isLoggedIn() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    final profile = await getProfile();
    return accessToken.isNotEmpty &&
        refreshToken.isNotEmpty &&
        profile != null &&
        profile['id'] != null;
  }

  Future<String> getProfileId() async {
    final profile = await getProfile();
    return profile?['id'] as String? ?? '';
  }

  Future<String> getUserId() async {
    return await getProfileId();
  }

  Future<bool> isAnonymous() async {
    return !(await isLoggedIn());
  }

  Future<String> getNickName() async {
    final profile = await getProfile();
    return profile?['nickName'] as String? ?? '';
  }

  /// Phone number used for the most recent successful auth flow (OTP
  /// verify or PIN login). This is the credential the backend expects
  /// for endpoints like `/v1/profile/pin` — nickName works for some
  /// existing creator accounts but not for hirer-type profiles whose
  /// nickName is a generated handle the backend can't resolve.
  Future<void> setLastPhoneNumber(String phoneNumber) async {
    final value = phoneNumber.trim();
    if (value.isEmpty) return;
    await _storage.write(key: _lastPhoneNumberKey, value: value);
  }

  Future<String> getLastPhoneNumber() async {
    return await _storage.read(key: _lastPhoneNumberKey) ?? '';
  }

  Future<String> getPortfolioId() async {
    final profile = await getProfile();
    return profile?['portfolioId'] as String? ?? '';
  }

  Future<void> setLocale(String localeCode) async {
    await _storage.write(key: _localeKey, value: localeCode);
  }

  Future<String> getLocale() async {
    return await _storage.read(key: _localeKey) ?? 'en';
  }

  Future<void> setLastSubscriptionId(String subscriptionId) async {
    await _storage.write(key: _lastSubscriptionIdKey, value: subscriptionId);
  }

  Future<String> getLastSubscriptionId() async {
    return await _storage.read(key: _lastSubscriptionIdKey) ?? '';
  }

  Future<void> clearLastSubscriptionId() async {
    await _storage.delete(key: _lastSubscriptionIdKey);
  }

  Future<void> setDashboardCityFilter(String? city) async {
    final value = city?.trim() ?? '';
    if (value.isEmpty) {
      await _storage.delete(key: _dashboardCityFilterKey);
      return;
    }
    await _storage.write(key: _dashboardCityFilterKey, value: value);
  }

  Future<String> getDashboardCityFilter() async {
    return await _storage.read(key: _dashboardCityFilterKey) ?? '';
  }

  Future<List<String>> getDashboardRecentLocations() async {
    final raw = await _storage.read(key: _dashboardRecentLocationsKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<String>()
            .map((value) => value.trim())
            .where((value) => value.isNotEmpty)
            .toList();
      }
    } catch (_) {}
    return const [];
  }

  Future<void> addDashboardRecentLocation(String city) async {
    final value = city.trim();
    if (value.isEmpty) return;

    final current = await getDashboardRecentLocations();
    final next = <String>[
      value,
      ...current.where((item) => item != value),
    ].take(5).toList();
    await _storage.write(
      key: _dashboardRecentLocationsKey,
      value: jsonEncode(next),
    );
  }

  Future<void> clearDashboardRecentLocations() async {
    await _storage.delete(key: _dashboardRecentLocationsKey);
  }

  Future<bool> isRecentLogin({int minutesThreshold = 5}) async {
    final timestampStr = await _storage.read(key: _lastLoginTimestampKey);
    if (timestampStr == null || timestampStr.isEmpty) return false;

    final timestamp = int.tryParse(timestampStr);
    if (timestamp == null) return false;

    final loginTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(loginTime);

    return difference.inMinutes < minutesThreshold;
  }

  Future<void> clear() async {
    invalidateCache();
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _profileKey);
    await _storage.delete(key: _profileCreatedKey);
    await _storage.delete(key: _localeKey);
    await _storage.delete(key: _lastSubscriptionIdKey);
    await _storage.delete(key: _lastPhoneNumberKey);
    await _storage.delete(key: _verificationIdKey);
    await _storage.delete(key: _lastPhoneVerificationIdKey);
    await _storage.delete(key: _lastLoginTimestampKey);
    await _storage.delete(key: _dashboardCityFilterKey);
    await _storage.delete(key: _dashboardRecentLocationsKey);
  }
}
