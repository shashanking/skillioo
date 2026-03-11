import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionPrefs {
  SessionPrefs._internal();

  static final SessionPrefs instance = SessionPrefs._internal();

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _profileKey = 'profile_json';
  static const _profileCreatedKey = 'profile_created';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> setSession({
    required String accessToken,
    required String refreshToken,
    required Map<String, dynamic> profile,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    await _storage.write(key: _profileKey, value: jsonEncode(profile));
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
    return await _storage.read(key: _accessTokenKey) ?? '';
  }

  Future<String> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey) ?? '';
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final raw = await _storage.read(key: _profileKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> mergeProfile(Map<String, dynamic> updates) async {
    final current = await getProfile() ?? <String, dynamic>{};
    final next = <String, dynamic>{...current, ...updates};
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

  Future<String> getNickName() async {
    final profile = await getProfile();
    return profile?['nickName'] as String? ?? '';
  }

  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _profileKey);
    await _storage.delete(key: _profileCreatedKey);
  }
}
