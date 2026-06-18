import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/onboarding/domain/document_service.dart';
import '../../features/profile/domain/profile_service.dart';
import 'session_prefs.dart';

/// Reactive session state — widgets watch these instead of calling SessionPrefs directly.
/// Updated once at startup (via [SessionStateNotifier.refresh]) and after login/logout.

class SessionData {
  final bool isLoggedIn;
  final bool isAnonymous;
  final String userId;
  final String accessToken;
  final String nickName;
  final String portfolioId;
  final Map<String, dynamic>? profile;
  final bool tokenExpired;

  const SessionData({
    this.isLoggedIn = false,
    this.isAnonymous = true,
    this.userId = '',
    this.accessToken = '',
    this.nickName = '',
    this.portfolioId = '',
    this.profile,
    this.tokenExpired = false,
  });

  SessionData copyWith({
    bool? isLoggedIn,
    bool? isAnonymous,
    String? userId,
    String? accessToken,
    String? nickName,
    String? portfolioId,
    Map<String, dynamic>? profile,
    bool? tokenExpired,
  }) {
    return SessionData(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      userId: userId ?? this.userId,
      accessToken: accessToken ?? this.accessToken,
      nickName: nickName ?? this.nickName,
      portfolioId: portfolioId ?? this.portfolioId,
      profile: profile ?? this.profile,
      tokenExpired: tokenExpired ?? this.tokenExpired,
    );
  }
}

class SessionStateNotifier extends StateNotifier<SessionData> {
  SessionStateNotifier() : super(const SessionData());

  /// Re-read everything from SessionPrefs into state.
  /// Call after login, logout, or profile update.
  Future<void> refresh() async {
    final prefs = SessionPrefs.instance;
    final isLoggedIn = await prefs.isLoggedIn();
    final profile = await prefs.getProfile();
    state = SessionData(
      isLoggedIn: isLoggedIn,
      isAnonymous: !isLoggedIn,
      userId: profile?['id'] as String? ?? '',
      accessToken: await prefs.getAccessToken(),
      nickName: profile?['nickName'] as String? ?? '',
      portfolioId: profile?['portfolioId'] as String? ?? '',
      profile: profile,
    );
  }

  /// Validate the current token against the backend.
  /// Sets [tokenExpired] = true ONLY for actual auth failures
  /// (401/403, "Authentication failed", "invalid token", "expired").
  /// Network errors and unrelated 5xx responses do NOT mark the session
  /// expired — otherwise a single buggy backend response would log every
  /// user out.
  Future<void> validateToken() async {
    if (!state.isLoggedIn) return;

    final prefs = SessionPrefs.instance;
    final isRecent = await prefs.isRecentLogin();
    if (isRecent) return;

    if (state.accessToken.isEmpty || state.userId.isEmpty) return;

    try {
      final service = ProfileService();
      final response = await service.getProfile(
        profileId: state.userId,
        accessToken: state.accessToken,
      );
      final success = response['success'] as bool? ?? true;
      if (success) return;

      final message = (response['message'] as String? ?? '').toLowerCase();
      final isAuthFailure = message.contains('authentication failed') ||
          message.contains('unauthorized') ||
          message.contains('invalid token') ||
          message.contains('token expired') ||
          message.contains('jwt expired');
      if (isAuthFailure) {
        state = state.copyWith(tokenExpired: true);
      }
    } catch (e) {
      // Network / 5xx — keep the session and let the user retry.
      debugPrint('SessionStateNotifier.validateToken: ignoring $e');
    }
  }

  void clearTokenExpired() {
    state = state.copyWith(tokenExpired: false);
  }

  /// Fetches the profile from the backend and reconciles the locally
  /// cached `profileType` / `isCreator`.
  ///
  /// The login response only carries `isCreator`/`isOnboarded` — not
  /// `profileType` — so without this the app can't tell that a user
  /// already completed the lightweight (hirer) profile flow in a prior
  /// session or out-of-band, and would wrongly offer to create one
  /// (then fail with a duplicate-key error on submit).
  Future<void> syncProfile() async {
    if (!state.isLoggedIn ||
        state.userId.isEmpty ||
        state.accessToken.isEmpty) {
      return;
    }
    try {
      final service = ProfileService();
      final response = await service.getProfile(
        profileId: state.userId,
        accessToken: state.accessToken,
      );
      if (response['success'] != true) return;
      final data = response['data'];
      if (data is! Map) return;
      final profileType = (data['profileType'] as String? ?? '').trim();
      if (profileType.isEmpty) return;

      // Merge the full profile data so currentProfileProvider can read
      // photo URL, portfolioId, bio, etc. on first launch after onboarding.
      final updates = <String, dynamic>{
        ...Map<String, dynamic>.from(data),
        'profileType': profileType,
      };
      if (profileType == 'HIRER') {
        updates['isCreator'] = false;
      } else if (profileType == 'INDIVIDUAL' || profileType == 'GROUP') {
        updates['isCreator'] = true;
      }
      await SessionPrefs.instance.mergeProfile(updates);

      // Resolve profile photo URL if not already stored.
      // On first-time signup the login/pin flow never ran _bootstrapProfilePhotoUrl,
      // so the picture ID is stored but the URL is still empty.
      await _resolveProfilePhotoIfNeeded(
        data: Map<String, dynamic>.from(data),
        accessToken: state.accessToken,
      );

      await refresh();
    } catch (e) {
      // Network / transient — keep existing local state.
      debugPrint('SessionStateNotifier.syncProfile: ignoring $e');
    }
  }

  /// Resolves the profile picture document ID to a real URL and stores it.
  /// Only runs when profilePhotoUrl is not already cached — so it only costs
  /// a network call on first-time signup, not on every app launch.
  Future<void> _resolveProfilePhotoIfNeeded({
    required Map<String, dynamic> data,
    required String accessToken,
  }) async {
    try {
      final existing = await SessionPrefs.instance.getProfile();
      final existingUrl = existing?['profilePhotoUrl'] as String? ?? '';
      if (existingUrl.isNotEmpty) return;

      // Extract picture ID — backend sends it as a string or { id: "..." },
      // at either the top level or inside a nested 'profile' object.
      final nestedData = data['profile'] as Map<String, dynamic>?;
      final rawPic =
          data['profilePictureId'] ?? nestedData?['profilePictureId'];
      String picId = '';
      if (rawPic is Map) {
        picId = (rawPic['id'] as String? ?? '').trim();
      } else if (rawPic is String) {
        picId = rawPic.trim();
      }
      if (picId.isEmpty) return;

      final docService = DocumentService();
      final response = await docService.getDocumentsByIds(
        ids: [picId],
        accessToken: accessToken,
      );
      final success = response['success'] as bool? ?? false;
      final docData = response['data'];
      if (!success || docData is! List) return;

      final doc = docData
          .cast<dynamic>()
          .whereType<Map<String, dynamic>>()
          .firstWhere((e) => e['id'] == picId, orElse: () => {});
      final url = (doc['url'] as String? ?? '').trim();
      if (url.isEmpty) return;

      final normalized = url.startsWith('http://')
          ? url.replaceFirst('http://', 'https://')
          : url;
      await SessionPrefs.instance.mergeProfile({'profilePhotoUrl': normalized});
    } catch (_) {}
  }
}

final sessionStateProvider =
    StateNotifierProvider<SessionStateNotifier, SessionData>((ref) {
  return SessionStateNotifier();
});

/// Convenience selectors
final isAnonymousProvider = Provider<bool>((ref) {
  return ref.watch(sessionStateProvider).isAnonymous;
});

final currentUserIdProvider = Provider<String>((ref) {
  return ref.watch(sessionStateProvider).userId;
});
