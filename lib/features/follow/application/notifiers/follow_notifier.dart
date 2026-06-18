import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/session_prefs.dart';
import '../../domain/follow_models.dart';
import '../../domain/follow_service.dart';
import '../states/follow_state.dart';

class FollowNotifier extends StateNotifier<FollowState> {
  final FollowService _service;

  FollowNotifier(this._service) : super(const FollowState());

  Future<bool> _ensureAuth() async {
    final token = await SessionPrefs.instance.getAccessToken();
    if (token.isEmpty) return false;
    _service.setAuthToken(token);
    return true;
  }

  // ── Toggle follow / unfollow ──

  Future<void> toggleFollow(String profileId) async {
    if (state.togglingIds.contains(profileId)) return;

    final hasAuth = await _ensureAuth();
    if (!hasAuth) return;

    // Optimistic update
    final isCurrentlyFollowing = state.followingIds.contains(profileId);
    final updatedIds = Set<String>.from(state.followingIds);
    final updatedTogglingIds = Set<String>.from(state.togglingIds)
      ..add(profileId);

    // Track a pure delta (+1 / -1) so the UI can compute:
    //   effectiveFollowers = profile.followerCount + (delta ?? 0)
    // Accumulates correctly across repeated follow/unfollow in the same session.
    final previousDelta = state.followerCountOverrides[profileId] ?? 0;
    final newDelta = isCurrentlyFollowing ? previousDelta - 1 : previousDelta + 1;
    final updatedOverrides = Map<String, int>.from(state.followerCountOverrides);
    if (newDelta == 0) {
      updatedOverrides.remove(profileId);
    } else {
      updatedOverrides[profileId] = newDelta;
    }

    if (isCurrentlyFollowing) {
      updatedIds.remove(profileId);
      state = state.copyWith(
        followingIds: updatedIds,
        togglingIds: updatedTogglingIds,
        followingCount: (state.followingCount - 1).clamp(0, 999999),
        followerCountOverrides: updatedOverrides,
      );
    } else {
      updatedIds.add(profileId);
      state = state.copyWith(
        followingIds: updatedIds,
        togglingIds: updatedTogglingIds,
        followingCount: state.followingCount + 1,
        followerCountOverrides: updatedOverrides,
      );
    }

    try {
      Map<String, dynamic> response;
      if (isCurrentlyFollowing) {
        response = await _service.unfollowUser(profileId);
      } else {
        response = await _service.followUser(profileId);
      }

      final status = response['status'] as int? ?? 0;
      if (status != 200 && status != 201) {
        _revertToggle(profileId, isCurrentlyFollowing, previousDelta);
        if (kDebugMode) {
          debugPrint('toggleFollow failed: ${response['message']}');
        }
      }
    } catch (e) {
      _revertToggle(profileId, isCurrentlyFollowing, previousDelta);
      if (kDebugMode) debugPrint('toggleFollow error: $e');
    } finally {
      final doneTogglingIds = Set<String>.from(state.togglingIds)
        ..remove(profileId);
      state = state.copyWith(togglingIds: doneTogglingIds);
    }
  }

  void _revertToggle(String profileId, bool wasFollowing, int previousDelta) {
    final revertedIds = Set<String>.from(state.followingIds);
    final revertedOverrides = Map<String, int>.from(state.followerCountOverrides);
    if (wasFollowing) {
      revertedIds.add(profileId);
    } else {
      revertedIds.remove(profileId);
    }
    if (previousDelta == 0) {
      revertedOverrides.remove(profileId);
    } else {
      revertedOverrides[profileId] = previousDelta;
    }
    state = state.copyWith(
      followingIds: revertedIds,
      followingCount: wasFollowing
          ? state.followingCount + 1
          : (state.followingCount - 1).clamp(0, 999999),
      followerCountOverrides: revertedOverrides,
    );
  }

  // ── Check if following a specific user ──

  Future<bool> checkIfFollowing(String profileId) async {
    // If toggleFollow is in flight for this profile, skip the API check to
    // avoid a race where the check resolves before the toggle and clobbers the
    // optimistic state (and the paired followerCountOverrides delta).
    if (state.togglingIds.contains(profileId)) {
      return state.followingIds.contains(profileId);
    }

    final hasAuth = await _ensureAuth();
    if (!hasAuth) return false;

    try {
      final response = await _service.checkFollowing(profileId);
      final status = response['status'] as int? ?? 0;
      final wasFollowing = state.followingIds.contains(profileId);

      if (status == 200 && response['data'] != null) {
        // Server confirms following. If we didn't know, add it — but do NOT
        // add a delta because the API base count already includes this follow.
        if (!wasFollowing) {
          final updatedIds = Set<String>.from(state.followingIds)..add(profileId);
          state = state.copyWith(followingIds: updatedIds);
        }
        return true;
      } else {
        // Server confirms not following.
        if (wasFollowing) {
          // Local state was wrong (stale fetchFollowing entry or an optimistic
          // follow whose API call hadn't landed yet). Revert both:
          //  - remove from followingIds
          //  - undo any positive delta in followerCountOverrides so the count
          //    stays consistent with the button state.
          final updatedIds = Set<String>.from(state.followingIds)
            ..remove(profileId);
          final overrides = Map<String, int>.from(state.followerCountOverrides);
          final currentDelta = overrides[profileId] ?? 0;
          if (currentDelta > 0) {
            final newDelta = currentDelta - 1;
            if (newDelta == 0) {
              overrides.remove(profileId);
            } else {
              overrides[profileId] = newDelta;
            }
          }
          state = state.copyWith(
            followingIds: updatedIds,
            followerCountOverrides: overrides,
          );
        } else {
          // Already in sync — just ensure the id is absent.
          final updatedIds = Set<String>.from(state.followingIds)
            ..remove(profileId);
          state = state.copyWith(followingIds: updatedIds);
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('checkIfFollowing error: $e');
      return false;
    }
  }

  // ── Batch check follow status for multiple profiles ──

  Future<void> checkFollowingBatch(List<String> profileIds) async {
    final hasAuth = await _ensureAuth();
    if (!hasAuth) return;

    for (final id in profileIds) {
      if (!state.followingIds.contains(id)) {
        await checkIfFollowing(id);
      }
    }
  }

  // ── Fetch follow counts ──

  Future<void> fetchFollowCount() async {
    final hasAuth = await _ensureAuth();
    if (!hasAuth) return;

    state = state.copyWith(countStatus: FollowStatus.loading);

    try {
      final response = await _service.getFollowCount();
      final status = response['status'] as int? ?? 0;

      if (status == 200 && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        final count = FollowCountResponse.fromJson(data);
        state = state.copyWith(
          countStatus: FollowStatus.success,
          followerCount: count.followerCount,
          followingCount: count.followingCount,
        );
      } else {
        state = state.copyWith(
          countStatus: FollowStatus.error,
          errorMessage: response['message'] as String? ?? 'Failed to fetch',
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('fetchFollowCount error: $e');
      state = state.copyWith(
        countStatus: FollowStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // ── Fetch followers list ──

  Future<void> fetchFollowers({int page = 1, int perPage = 20}) async {
    final hasAuth = await _ensureAuth();
    if (!hasAuth) return;

    state = state.copyWith(followersStatus: FollowStatus.loading);

    try {
      final response = await _service.getFollowers(
        page: page,
        perPage: perPage,
      );
      final status = response['status'] as int? ?? 0;

      if (status == 200 && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        final list = data['follwers'] as List<dynamic>? ?? [];
        final followers = list
            .map((e) => FollowUserResponse.fromJson(e as Map<String, dynamic>))
            .toList();

        state = state.copyWith(
          followersStatus: FollowStatus.success,
          followers: page == 1 ? followers : [...state.followers, ...followers],
        );
      } else {
        state = state.copyWith(
          followersStatus: FollowStatus.error,
          errorMessage: response['message'] as String? ?? 'Failed to fetch',
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('fetchFollowers error: $e');
      state = state.copyWith(
        followersStatus: FollowStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // ── Fetch following list ──

  Future<void> fetchFollowing({int page = 1, int perPage = 20}) async {
    final hasAuth = await _ensureAuth();
    if (!hasAuth) return;

    state = state.copyWith(followingStatus: FollowStatus.loading);

    try {
      final response = await _service.getFollowing(
        page: page,
        perPage: perPage,
      );
      final status = response['status'] as int? ?? 0;

      if (status == 200 && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        final list = data['following'] as List<dynamic>? ?? [];
        final following = list
            .map((e) => FollowUserResponse.fromJson(e as Map<String, dynamic>))
            .toList();

        // Also update followingIds from the list
        final ids = Set<String>.from(state.followingIds);
        for (final user in following) {
          if (user.referenceId != null) {
            ids.add(user.referenceId!);
          }
        }
        if (kDebugMode) {
          debugPrint('=== fetchFollowing: ${following.length} users ===');
          for (final u in following) {
            debugPrint('  id=${u.id}, referenceId=${u.referenceId}, nickName=${u.nickName}');
          }
          debugPrint('followingIds (${ids.length}): $ids');
        }

        state = state.copyWith(
          followingStatus: FollowStatus.success,
          following: page == 1 ? following : [...state.following, ...following],
          followingIds: ids,
        );
      } else {
        state = state.copyWith(
          followingStatus: FollowStatus.error,
          errorMessage: response['message'] as String? ?? 'Failed to fetch',
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('fetchFollowing error: $e');
      state = state.copyWith(
        followingStatus: FollowStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // ── Helper: is following ──

  bool isFollowing(String profileId) => state.followingIds.contains(profileId);
}
