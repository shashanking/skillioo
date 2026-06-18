// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hiring_rate_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$HiringRateState {
  HiringRateStatus get status => throw _privateConstructorUsedError;
  Map<String, dynamic> get hiringRateData => throw _privateConstructorUsedError;
  String get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of HiringRateState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HiringRateStateCopyWith<HiringRateState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HiringRateStateCopyWith<$Res> {
  factory $HiringRateStateCopyWith(
    HiringRateState value,
    $Res Function(HiringRateState) then,
  ) = _$HiringRateStateCopyWithImpl<$Res, HiringRateState>;
  @useResult
  $Res call({
    HiringRateStatus status,
    Map<String, dynamic> hiringRateData,
    String errorMessage,
  });
}

/// @nodoc
class _$HiringRateStateCopyWithImpl<$Res, $Val extends HiringRateState>
    implements $HiringRateStateCopyWith<$Res> {
  _$HiringRateStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HiringRateState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? hiringRateData = null,
    Object? errorMessage = null,
  }) {
    return _then(
      _value.copyWith(
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as HiringRateStatus,
            hiringRateData: null == hiringRateData
                ? _value.hiringRateData
                : hiringRateData // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
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
abstract class _$$HiringRateStateImplCopyWith<$Res>
    implements $HiringRateStateCopyWith<$Res> {
  factory _$$HiringRateStateImplCopyWith(
    _$HiringRateStateImpl value,
    $Res Function(_$HiringRateStateImpl) then,
  ) = __$$HiringRateStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    HiringRateStatus status,
    Map<String, dynamic> hiringRateData,
    String errorMessage,
  });
}

/// @nodoc
class __$$HiringRateStateImplCopyWithImpl<$Res>
    extends _$HiringRateStateCopyWithImpl<$Res, _$HiringRateStateImpl>
    implements _$$HiringRateStateImplCopyWith<$Res> {
  __$$HiringRateStateImplCopyWithImpl(
    _$HiringRateStateImpl _value,
    $Res Function(_$HiringRateStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HiringRateState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? hiringRateData = null,
    Object? errorMessage = null,
  }) {
    return _then(
      _$HiringRateStateImpl(
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as HiringRateStatus,
        hiringRateData: null == hiringRateData
            ? _value._hiringRateData
            : hiringRateData // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        errorMessage: null == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$HiringRateStateImpl implements _HiringRateState {
  const _$HiringRateStateImpl({
    this.status = HiringRateStatus.initial,
    final Map<String, dynamic> hiringRateData = const {},
    this.errorMessage = '',
  }) : _hiringRateData = hiringRateData;

  @override
  @JsonKey()
  final HiringRateStatus status;
  final Map<String, dynamic> _hiringRateData;
  @override
  @JsonKey()
  Map<String, dynamic> get hiringRateData {
    if (_hiringRateData is EqualUnmodifiableMapView) return _hiringRateData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_hiringRateData);
  }

  @override
  @JsonKey()
  final String errorMessage;

  @override
  String toString() {
    return 'HiringRateState(status: $status, hiringRateData: $hiringRateData, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HiringRateStateImpl &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(
              other._hiringRateData,
              _hiringRateData,
            ) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    status,
    const DeepCollectionEquality().hash(_hiringRateData),
    errorMessage,
  );

  /// Create a copy of HiringRateState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HiringRateStateImplCopyWith<_$HiringRateStateImpl> get copyWith =>
      __$$HiringRateStateImplCopyWithImpl<_$HiringRateStateImpl>(
        this,
        _$identity,
      );
}

abstract class _HiringRateState implements HiringRateState {
  const factory _HiringRateState({
    final HiringRateStatus status,
    final Map<String, dynamic> hiringRateData,
    final String errorMessage,
  }) = _$HiringRateStateImpl;

  @override
  HiringRateStatus get status;
  @override
  Map<String, dynamic> get hiringRateData;
  @override
  String get errorMessage;

  /// Create a copy of HiringRateState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HiringRateStateImplCopyWith<_$HiringRateStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
