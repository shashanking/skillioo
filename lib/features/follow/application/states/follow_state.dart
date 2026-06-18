import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/follow_models.dart';

part 'follow_state.freezed.dart';

enum FollowStatus { initial, loading, success, error }

@freezed
class FollowState with _$FollowState {
  const factory FollowState({
    // Set of profileIds the current user is following (for quick lookup)
    @Default({}) Set<String> followingIds,

    // Follow counts for current user
    @Default(0) int followerCount,
    @Default(0) int followingCount,

    // Lists for followers/following screens
    @Default([]) List<FollowUserResponse> followers,
    @Default([]) List<FollowUserResponse> following,

    // Status tracking
    @Default(FollowStatus.initial) FollowStatus countStatus,
    @Default(FollowStatus.initial) FollowStatus followersStatus,
    @Default(FollowStatus.initial) FollowStatus followingStatus,

    // Per-user toggle status (profileId -> loading)
    @Default({}) Set<String> togglingIds,

    // Per-profile follower count overrides — updated optimistically on follow/unfollow
    // so the UI reflects the change without re-fetching the profile list.
    @Default({}) Map<String, int> followerCountOverrides,

    @Default('') String errorMessage,
  }) = _FollowState;
}
