import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/session_prefs.dart';
import '../../domain/profile_list_service.dart';
import '../states/profile_list_state.dart';

class ProfileListNotifier extends StateNotifier<ProfileListState> {
  final ProfileListService _service;

  ProfileListNotifier(this._service) : super(const ProfileListState());

  Future<void> loadProfiles({
    int perPage = 20,
    int page = 1,
    String? category,
    String? subCategory,
    String? nickName,
    String? profileType,
    String? proficiency,
    String? city,
    bool refresh = false,
  }) async {
    if (state.isLoading && !refresh) return;

    if (refresh) {
      state = const ProfileListState();
    }

    state = state.copyWith(isLoading: true, hasError: false);

    try {
      final accessToken = await SessionPrefs.instance.getAccessToken();
      if (accessToken.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          hasError: true,
          errorMessage: 'Not authenticated',
        );
        return;
      }

      final response = await _service.getProfiles(
        accessToken: accessToken,
        perPage: perPage,
        page: page,
        category: category,
        subCategory: subCategory,
        nickName: nickName,
        profileType: profileType,
        proficiency: proficiency,
        city: city,
      );

      final status = response['status'] as int? ?? 0;
      final success = response['success'] as bool? ?? (status == 200);
      if (status != 200 && !success) {
        // Don't leak raw backend errors (e.g. Postgres "column pro.status
        // does not exist") to the user. Map to a friendly fallback unless
        // it's a known auth failure.
        final raw = (response['message'] as String? ?? '').trim();
        final lower = raw.toLowerCase();
        final isAuth = lower.contains('authentication failed') ||
            lower.contains('unauthorized') ||
            lower.contains('invalid token') ||
            lower.contains('token expired');
        final friendly = isAuth
            ? 'Please sign in again to see profiles.'
            : "We couldn't load profiles right now. Please try again.";
        state = state.copyWith(
          isLoading: false,
          hasError: true,
          errorMessage: friendly,
        );
        return;
      }

      final data = response['data'] as Map<String, dynamic>? ?? {};
      final items = data['items'] as List<dynamic>? ?? [];
      final currentUserId = await SessionPrefs.instance.getProfileId();

      final profiles = items
          .whereType<Map<String, dynamic>>()
          .where((json) {
            final id = json['id'] as String? ?? '';
            return id.isNotEmpty && id != currentUserId;
          })
          .map(ProfileItem.fromJson)
          .toList();

      final currentProfiles = refresh ? <ProfileItem>[] : state.profiles;

      state = state.copyWith(
        profiles: [...currentProfiles, ...profiles],
        isLoading: false,
        currentPage: page,
        hasMore: profiles.length >= perPage,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage:
            "We couldn't load profiles right now. Please try again.",
      );
    }
  }

  void reset() {
    state = const ProfileListState();
  }
}
