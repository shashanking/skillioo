// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_list_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ProfileListState {
  List<ProfileItem> get profiles => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get hasError => throw _privateConstructorUsedError;
  String get errorMessage => throw _privateConstructorUsedError;
  int get currentPage => throw _privateConstructorUsedError;
  bool get hasMore => throw _privateConstructorUsedError;

  /// Create a copy of ProfileListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProfileListStateCopyWith<ProfileListState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileListStateCopyWith<$Res> {
  factory $ProfileListStateCopyWith(
    ProfileListState value,
    $Res Function(ProfileListState) then,
  ) = _$ProfileListStateCopyWithImpl<$Res, ProfileListState>;
  @useResult
  $Res call({
    List<ProfileItem> profiles,
    bool isLoading,
    bool hasError,
    String errorMessage,
    int currentPage,
    bool hasMore,
  });
}

/// @nodoc
class _$ProfileListStateCopyWithImpl<$Res, $Val extends ProfileListState>
    implements $ProfileListStateCopyWith<$Res> {
  _$ProfileListStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProfileListState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? profiles = null,
    Object? isLoading = null,
    Object? hasError = null,
    Object? errorMessage = null,
    Object? currentPage = null,
    Object? hasMore = null,
  }) {
    return _then(
      _value.copyWith(
            profiles: null == profiles
                ? _value.profiles
                : profiles // ignore: cast_nullable_to_non_nullable
                      as List<ProfileItem>,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            hasError: null == hasError
                ? _value.hasError
                : hasError // ignore: cast_nullable_to_non_nullable
                      as bool,
            errorMessage: null == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String,
            currentPage: null == currentPage
                ? _value.currentPage
                : currentPage // ignore: cast_nullable_to_non_nullable
                      as int,
            hasMore: null == hasMore
                ? _value.hasMore
                : hasMore // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProfileListStateImplCopyWith<$Res>
    implements $ProfileListStateCopyWith<$Res> {
  factory _$$ProfileListStateImplCopyWith(
    _$ProfileListStateImpl value,
    $Res Function(_$ProfileListStateImpl) then,
  ) = __$$ProfileListStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<ProfileItem> profiles,
    bool isLoading,
    bool hasError,
    String errorMessage,
    int currentPage,
    bool hasMore,
  });
}

/// @nodoc
class __$$ProfileListStateImplCopyWithImpl<$Res>
    extends _$ProfileListStateCopyWithImpl<$Res, _$ProfileListStateImpl>
    implements _$$ProfileListStateImplCopyWith<$Res> {
  __$$ProfileListStateImplCopyWithImpl(
    _$ProfileListStateImpl _value,
    $Res Function(_$ProfileListStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProfileListState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? profiles = null,
    Object? isLoading = null,
    Object? hasError = null,
    Object? errorMessage = null,
    Object? currentPage = null,
    Object? hasMore = null,
  }) {
    return _then(
      _$ProfileListStateImpl(
        profiles: null == profiles
            ? _value._profiles
            : profiles // ignore: cast_nullable_to_non_nullable
                  as List<ProfileItem>,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        hasError: null == hasError
            ? _value.hasError
            : hasError // ignore: cast_nullable_to_non_nullable
                  as bool,
        errorMessage: null == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String,
        currentPage: null == currentPage
            ? _value.currentPage
            : currentPage // ignore: cast_nullable_to_non_nullable
                  as int,
        hasMore: null == hasMore
            ? _value.hasMore
            : hasMore // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$ProfileListStateImpl implements _ProfileListState {
  const _$ProfileListStateImpl({
    final List<ProfileItem> profiles = const [],
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage = '',
    this.currentPage = 1,
    this.hasMore = false,
  }) : _profiles = profiles;

  final List<ProfileItem> _profiles;
  @override
  @JsonKey()
  List<ProfileItem> get profiles {
    if (_profiles is EqualUnmodifiableListView) return _profiles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_profiles);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool hasError;
  @override
  @JsonKey()
  final String errorMessage;
  @override
  @JsonKey()
  final int currentPage;
  @override
  @JsonKey()
  final bool hasMore;

  @override
  String toString() {
    return 'ProfileListState(profiles: $profiles, isLoading: $isLoading, hasError: $hasError, errorMessage: $errorMessage, currentPage: $currentPage, hasMore: $hasMore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileListStateImpl &&
            const DeepCollectionEquality().equals(other._profiles, _profiles) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.hasError, hasError) ||
                other.hasError == hasError) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_profiles),
    isLoading,
    hasError,
    errorMessage,
    currentPage,
    hasMore,
  );

  /// Create a copy of ProfileListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileListStateImplCopyWith<_$ProfileListStateImpl> get copyWith =>
      __$$ProfileListStateImplCopyWithImpl<_$ProfileListStateImpl>(
        this,
        _$identity,
      );
}

abstract class _ProfileListState implements ProfileListState {
  const factory _ProfileListState({
    final List<ProfileItem> profiles,
    final bool isLoading,
    final bool hasError,
    final String errorMessage,
    final int currentPage,
    final bool hasMore,
  }) = _$ProfileListStateImpl;

  @override
  List<ProfileItem> get profiles;
  @override
  bool get isLoading;
  @override
  bool get hasError;
  @override
  String get errorMessage;
  @override
  int get currentPage;
  @override
  bool get hasMore;

  /// Create a copy of ProfileListState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfileListStateImplCopyWith<_$ProfileListStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
