// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'follow_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$FollowState {
  // Set of profileIds the current user is following (for quick lookup)
  Set<String> get followingIds =>
      throw _privateConstructorUsedError; // Follow counts for current user
  int get followerCount => throw _privateConstructorUsedError;
  int get followingCount =>
      throw _privateConstructorUsedError; // Lists for followers/following screens
  List<FollowUserResponse> get followers => throw _privateConstructorUsedError;
  List<FollowUserResponse> get following =>
      throw _privateConstructorUsedError; // Status tracking
  FollowStatus get countStatus => throw _privateConstructorUsedError;
  FollowStatus get followersStatus => throw _privateConstructorUsedError;
  FollowStatus get followingStatus =>
      throw _privateConstructorUsedError; // Per-user toggle status (profileId -> loading)
  Set<String> get togglingIds =>
      throw _privateConstructorUsedError; // Per-profile follower count overrides — updated optimistically on follow/unfollow
  // so the UI reflects the change without re-fetching the profile list.
  Map<String, int> get followerCountOverrides =>
      throw _privateConstructorUsedError;
  String get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of FollowState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FollowStateCopyWith<FollowState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FollowStateCopyWith<$Res> {
  factory $FollowStateCopyWith(
    FollowState value,
    $Res Function(FollowState) then,
  ) = _$FollowStateCopyWithImpl<$Res, FollowState>;
  @useResult
  $Res call({
    Set<String> followingIds,
    int followerCount,
    int followingCount,
    List<FollowUserResponse> followers,
    List<FollowUserResponse> following,
    FollowStatus countStatus,
    FollowStatus followersStatus,
    FollowStatus followingStatus,
    Set<String> togglingIds,
    Map<String, int> followerCountOverrides,
    String errorMessage,
  });
}

/// @nodoc
class _$FollowStateCopyWithImpl<$Res, $Val extends FollowState>
    implements $FollowStateCopyWith<$Res> {
  _$FollowStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FollowState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? followingIds = null,
    Object? followerCount = null,
    Object? followingCount = null,
    Object? followers = null,
    Object? following = null,
    Object? countStatus = null,
    Object? followersStatus = null,
    Object? followingStatus = null,
    Object? togglingIds = null,
    Object? followerCountOverrides = null,
    Object? errorMessage = null,
  }) {
    return _then(
      _value.copyWith(
            followingIds: null == followingIds
                ? _value.followingIds
                : followingIds // ignore: cast_nullable_to_non_nullable
                      as Set<String>,
            followerCount: null == followerCount
                ? _value.followerCount
                : followerCount // ignore: cast_nullable_to_non_nullable
                      as int,
            followingCount: null == followingCount
                ? _value.followingCount
                : followingCount // ignore: cast_nullable_to_non_nullable
                      as int,
            followers: null == followers
                ? _value.followers
                : followers // ignore: cast_nullable_to_non_nullable
                      as List<FollowUserResponse>,
            following: null == following
                ? _value.following
                : following // ignore: cast_nullable_to_non_nullable
                      as List<FollowUserResponse>,
            countStatus: null == countStatus
                ? _value.countStatus
                : countStatus // ignore: cast_nullable_to_non_nullable
                      as FollowStatus,
            followersStatus: null == followersStatus
                ? _value.followersStatus
                : followersStatus // ignore: cast_nullable_to_non_nullable
                      as FollowStatus,
            followingStatus: null == followingStatus
                ? _value.followingStatus
                : followingStatus // ignore: cast_nullable_to_non_nullable
                      as FollowStatus,
            togglingIds: null == togglingIds
                ? _value.togglingIds
                : togglingIds // ignore: cast_nullable_to_non_nullable
                      as Set<String>,
            followerCountOverrides: null == followerCountOverrides
                ? _value.followerCountOverrides
                : followerCountOverrides // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            errorMessage: null == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FollowStateImplCopyWith<$Res>
    implements $FollowStateCopyWith<$Res> {
  factory _$$FollowStateImplCopyWith(
    _$FollowStateImpl value,
    $Res Function(_$FollowStateImpl) then,
  ) = __$$FollowStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Set<String> followingIds,
    int followerCount,
    int followingCount,
    List<FollowUserResponse> followers,
    List<FollowUserResponse> following,
    FollowStatus countStatus,
    FollowStatus followersStatus,
    FollowStatus followingStatus,
    Set<String> togglingIds,
    Map<String, int> followerCountOverrides,
    String errorMessage,
  });
}

/// @nodoc
class __$$FollowStateImplCopyWithImpl<$Res>
    extends _$FollowStateCopyWithImpl<$Res, _$FollowStateImpl>
    implements _$$FollowStateImplCopyWith<$Res> {
  __$$FollowStateImplCopyWithImpl(
    _$FollowStateImpl _value,
    $Res Function(_$FollowStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FollowState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? followingIds = null,
    Object? followerCount = null,
    Object? followingCount = null,
    Object? followers = null,
    Object? following = null,
    Object? countStatus = null,
    Object? followersStatus = null,
    Object? followingStatus = null,
    Object? togglingIds = null,
    Object? followerCountOverrides = null,
    Object? errorMessage = null,
  }) {
    return _then(
      _$FollowStateImpl(
        followingIds: null == followingIds
            ? _value._followingIds
            : followingIds // ignore: cast_nullable_to_non_nullable
                  as Set<String>,
        followerCount: null == followerCount
            ? _value.followerCount
            : followerCount // ignore: cast_nullable_to_non_nullable
                  as int,
        followingCount: null == followingCount
            ? _value.followingCount
            : followingCount // ignore: cast_nullable_to_non_nullable
                  as int,
        followers: null == followers
            ? _value._followers
            : followers // ignore: cast_nullable_to_non_nullable
                  as List<FollowUserResponse>,
        following: null == following
            ? _value._following
            : following // ignore: cast_nullable_to_non_nullable
                  as List<FollowUserResponse>,
        countStatus: null == countStatus
            ? _value.countStatus
            : countStatus // ignore: cast_nullable_to_non_nullable
                  as FollowStatus,
        followersStatus: null == followersStatus
            ? _value.followersStatus
            : followersStatus // ignore: cast_nullable_to_non_nullable
                  as FollowStatus,
        followingStatus: null == followingStatus
            ? _value.followingStatus
            : followingStatus // ignore: cast_nullable_to_non_nullable
                  as FollowStatus,
        togglingIds: null == togglingIds
            ? _value._togglingIds
            : togglingIds // ignore: cast_nullable_to_non_nullable
                  as Set<String>,
        followerCountOverrides: null == followerCountOverrides
            ? _value._followerCountOverrides
            : followerCountOverrides // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        errorMessage: null == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$FollowStateImpl implements _FollowState {
  const _$FollowStateImpl({
    final Set<String> followingIds = const {},
    this.followerCount = 0,
    this.followingCount = 0,
    final List<FollowUserResponse> followers = const [],
    final List<FollowUserResponse> following = const [],
    this.countStatus = FollowStatus.initial,
    this.followersStatus = FollowStatus.initial,
    this.followingStatus = FollowStatus.initial,
    final Set<String> togglingIds = const {},
    final Map<String, int> followerCountOverrides = const {},
    this.errorMessage = '',
  }) : _followingIds = followingIds,
       _followers = followers,
       _following = following,
       _togglingIds = togglingIds,
       _followerCountOverrides = followerCountOverrides;

  // Set of profileIds the current user is following (for quick lookup)
  final Set<String> _followingIds;
  // Set of profileIds the current user is following (for quick lookup)
  @override
  @JsonKey()
  Set<String> get followingIds {
    if (_followingIds is EqualUnmodifiableSetView) return _followingIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_followingIds);
  }

  // Follow counts for current user
  @override
  @JsonKey()
  final int followerCount;
  @override
  @JsonKey()
  final int followingCount;
  // Lists for followers/following screens
  final List<FollowUserResponse> _followers;
  // Lists for followers/following screens
  @override
  @JsonKey()
  List<FollowUserResponse> get followers {
    if (_followers is EqualUnmodifiableListView) return _followers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_followers);
  }

  final List<FollowUserResponse> _following;
  @override
  @JsonKey()
  List<FollowUserResponse> get following {
    if (_following is EqualUnmodifiableListView) return _following;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_following);
  }

  // Status tracking
  @override
  @JsonKey()
  final FollowStatus countStatus;
  @override
  @JsonKey()
  final FollowStatus followersStatus;
  @override
  @JsonKey()
  final FollowStatus followingStatus;
  // Per-user toggle status (profileId -> loading)
  final Set<String> _togglingIds;
  // Per-user toggle status (profileId -> loading)
  @override
  @JsonKey()
  Set<String> get togglingIds {
    if (_togglingIds is EqualUnmodifiableSetView) return _togglingIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_togglingIds);
  }

  // Per-profile follower count overrides — updated optimistically on follow/unfollow
  // so the UI reflects the change without re-fetching the profile list.
  final Map<String, int> _followerCountOverrides;
  // Per-profile follower count overrides — updated optimistically on follow/unfollow
  // so the UI reflects the change without re-fetching the profile list.
  @override
  @JsonKey()
  Map<String, int> get followerCountOverrides {
    if (_followerCountOverrides is EqualUnmodifiableMapView)
      return _followerCountOverrides;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_followerCountOverrides);
  }

  @override
  @JsonKey()
  final String errorMessage;

  @override
  String toString() {
    return 'FollowState(followingIds: $followingIds, followerCount: $followerCount, followingCount: $followingCount, followers: $followers, following: $following, countStatus: $countStatus, followersStatus: $followersStatus, followingStatus: $followingStatus, togglingIds: $togglingIds, followerCountOverrides: $followerCountOverrides, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FollowStateImpl &&
            const DeepCollectionEquality().equals(
              other._followingIds,
              _followingIds,
            ) &&
            (identical(other.followerCount, followerCount) ||
                other.followerCount == followerCount) &&
            (identical(other.followingCount, followingCount) ||
                other.followingCount == followingCount) &&
            const DeepCollectionEquality().equals(
              other._followers,
              _followers,
            ) &&
            const DeepCollectionEquality().equals(
              other._following,
              _following,
            ) &&
            (identical(other.countStatus, countStatus) ||
                other.countStatus == countStatus) &&
            (identical(other.followersStatus, followersStatus) ||
                other.followersStatus == followersStatus) &&
            (identical(other.followingStatus, followingStatus) ||
                other.followingStatus == followingStatus) &&
            const DeepCollectionEquality().equals(
              other._togglingIds,
              _togglingIds,
            ) &&
            const DeepCollectionEquality().equals(
              other._followerCountOverrides,
              _followerCountOverrides,
            ) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_followingIds),
    followerCount,
    followingCount,
    const DeepCollectionEquality().hash(_followers),
    const DeepCollectionEquality().hash(_following),
    countStatus,
    followersStatus,
    followingStatus,
    const DeepCollectionEquality().hash(_togglingIds),
    const DeepCollectionEquality().hash(_followerCountOverrides),
    errorMessage,
  );

  /// Create a copy of FollowState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FollowStateImplCopyWith<_$FollowStateImpl> get copyWith =>
      __$$FollowStateImplCopyWithImpl<_$FollowStateImpl>(this, _$identity);
}

abstract class _FollowState implements FollowState {
  const factory _FollowState({
    final Set<String> followingIds,
    final int followerCount,
    final int followingCount,
    final List<FollowUserResponse> followers,
    final List<FollowUserResponse> following,
    final FollowStatus countStatus,
    final FollowStatus followersStatus,
    final FollowStatus followingStatus,
    final Set<String> togglingIds,
    final Map<String, int> followerCountOverrides,
    final String errorMessage,
  }) = _$FollowStateImpl;

  // Set of profileIds the current user is following (for quick lookup)
  @override
  Set<String> get followingIds; // Follow counts for current user
  @override
  int get followerCount;
  @override
  int get followingCount; // Lists for followers/following screens
  @override
  List<FollowUserResponse> get followers;
  @override
  List<FollowUserResponse> get following; // Status tracking
  @override
  FollowStatus get countStatus;
  @override
  FollowStatus get followersStatus;
  @override
  FollowStatus get followingStatus; // Per-user toggle status (profileId -> loading)
  @override
  Set<String> get togglingIds; // Per-profile follower count overrides — updated optimistically on follow/unfollow
  // so the UI reflects the change without re-fetching the profile list.
  @override
  Map<String, int> get followerCountOverrides;
  @override
  String get errorMessage;

  /// Create a copy of FollowState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FollowStateImplCopyWith<_$FollowStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
