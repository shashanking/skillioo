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
    bool refresh = false,
  }) async {
    if (state.isLoading) return;

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
        status: 'APPROVED, PENDING',
      );

      final status = response['status'] as int? ?? 0;
      if (status != 200) {
        state = state.copyWith(
          isLoading: false,
          hasError: true,
          errorMessage:
              response['message'] as String? ?? 'Failed to load profiles',
        );
        return;
      }

      final data = response['data'] as Map<String, dynamic>? ?? {};
      final items = data['items'] as List<dynamic>? ?? [];

      final profiles = items
          .whereType<Map<String, dynamic>>()
          .map((json) => ProfileItem.fromJson(json))
          .toList();

      final currentProfiles = refresh ? <ProfileItem>[] : state.profiles;
      final allProfiles = [...currentProfiles, ...profiles];

      state = state.copyWith(
        profiles: allProfiles,
        isLoading: false,
        currentPage: page,
        hasMore: profiles.length >= perPage,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() {
    state = const ProfileListState();
  }
}
