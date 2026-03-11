// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'online_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$OnlineState {
  // Map of userId -> isOnline status
  Map<String, bool> get userStatuses =>
      throw _privateConstructorUsedError; // Map of userId -> lastSeen timestamp
  Map<String, DateTime> get lastSeenMap =>
      throw _privateConstructorUsedError; // Current user's connection status
  bool get isConnected => throw _privateConstructorUsedError;

  /// Create a copy of OnlineState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OnlineStateCopyWith<OnlineState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OnlineStateCopyWith<$Res> {
  factory $OnlineStateCopyWith(
    OnlineState value,
    $Res Function(OnlineState) then,
  ) = _$OnlineStateCopyWithImpl<$Res, OnlineState>;
  @useResult
  $Res call({
    Map<String, bool> userStatuses,
    Map<String, DateTime> lastSeenMap,
    bool isConnected,
  });
}

/// @nodoc
class _$OnlineStateCopyWithImpl<$Res, $Val extends OnlineState>
    implements $OnlineStateCopyWith<$Res> {
  _$OnlineStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OnlineState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userStatuses = null,
    Object? lastSeenMap = null,
    Object? isConnected = null,
  }) {
    return _then(
      _value.copyWith(
            userStatuses: null == userStatuses
                ? _value.userStatuses
                : userStatuses // ignore: cast_nullable_to_non_nullable
                      as Map<String, bool>,
            lastSeenMap: null == lastSeenMap
                ? _value.lastSeenMap
                : lastSeenMap // ignore: cast_nullable_to_non_nullable
                      as Map<String, DateTime>,
            isConnected: null == isConnected
                ? _value.isConnected
                : isConnected // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OnlineStateImplCopyWith<$Res>
    implements $OnlineStateCopyWith<$Res> {
  factory _$$OnlineStateImplCopyWith(
    _$OnlineStateImpl value,
    $Res Function(_$OnlineStateImpl) then,
  ) = __$$OnlineStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Map<String, bool> userStatuses,
    Map<String, DateTime> lastSeenMap,
    bool isConnected,
  });
}

/// @nodoc
class __$$OnlineStateImplCopyWithImpl<$Res>
    extends _$OnlineStateCopyWithImpl<$Res, _$OnlineStateImpl>
    implements _$$OnlineStateImplCopyWith<$Res> {
  __$$OnlineStateImplCopyWithImpl(
    _$OnlineStateImpl _value,
    $Res Function(_$OnlineStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OnlineState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userStatuses = null,
    Object? lastSeenMap = null,
    Object? isConnected = null,
  }) {
    return _then(
      _$OnlineStateImpl(
        userStatuses: null == userStatuses
            ? _value._userStatuses
            : userStatuses // ignore: cast_nullable_to_non_nullable
                  as Map<String, bool>,
        lastSeenMap: null == lastSeenMap
            ? _value._lastSeenMap
            : lastSeenMap // ignore: cast_nullable_to_non_nullable
                  as Map<String, DateTime>,
        isConnected: null == isConnected
            ? _value.isConnected
            : isConnected // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$OnlineStateImpl implements _OnlineState {
  const _$OnlineStateImpl({
    final Map<String, bool> userStatuses = const {},
    final Map<String, DateTime> lastSeenMap = const {},
    this.isConnected = false,
  }) : _userStatuses = userStatuses,
       _lastSeenMap = lastSeenMap;

  // Map of userId -> isOnline status
  final Map<String, bool> _userStatuses;
  // Map of userId -> isOnline status
  @override
  @JsonKey()
  Map<String, bool> get userStatuses {
    if (_userStatuses is EqualUnmodifiableMapView) return _userStatuses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_userStatuses);
  }

  // Map of userId -> lastSeen timestamp
  final Map<String, DateTime> _lastSeenMap;
  // Map of userId -> lastSeen timestamp
  @override
  @JsonKey()
  Map<String, DateTime> get lastSeenMap {
    if (_lastSeenMap is EqualUnmodifiableMapView) return _lastSeenMap;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_lastSeenMap);
  }

  // Current user's connection status
  @override
  @JsonKey()
  final bool isConnected;

  @override
  String toString() {
    return 'OnlineState(userStatuses: $userStatuses, lastSeenMap: $lastSeenMap, isConnected: $isConnected)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OnlineStateImpl &&
            const DeepCollectionEquality().equals(
              other._userStatuses,
              _userStatuses,
            ) &&
            const DeepCollectionEquality().equals(
              other._lastSeenMap,
              _lastSeenMap,
            ) &&
            (identical(other.isConnected, isConnected) ||
                other.isConnected == isConnected));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_userStatuses),
    const DeepCollectionEquality().hash(_lastSeenMap),
    isConnected,
  );

  /// Create a copy of OnlineState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OnlineStateImplCopyWith<_$OnlineStateImpl> get copyWith =>
      __$$OnlineStateImplCopyWithImpl<_$OnlineStateImpl>(this, _$identity);
}

abstract class _OnlineState implements OnlineState {
  const factory _OnlineState({
    final Map<String, bool> userStatuses,
    final Map<String, DateTime> lastSeenMap,
    final bool isConnected,
  }) = _$OnlineStateImpl;

  // Map of userId -> isOnline status
  @override
  Map<String, bool> get userStatuses; // Map of userId -> lastSeen timestamp
  @override
  Map<String, DateTime> get lastSeenMap; // Current user's connection status
  @override
  bool get isConnected;

  /// Create a copy of OnlineState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OnlineStateImplCopyWith<_$OnlineStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
