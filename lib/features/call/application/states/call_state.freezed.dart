// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'call_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CallState {
  CallStateStatus get status => throw _privateConstructorUsedError;
  String get errorMessage => throw _privateConstructorUsedError;
  String get twilioToken => throw _privateConstructorUsedError;
  CallData? get currentCall => throw _privateConstructorUsedError;
  bool get isInCall => throw _privateConstructorUsedError;
  String get callerId => throw _privateConstructorUsedError;
  String get recipientId => throw _privateConstructorUsedError;
  String get callerName => throw _privateConstructorUsedError;
  String get callerAvatar => throw _privateConstructorUsedError;

  /// Create a copy of CallState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CallStateCopyWith<CallState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CallStateCopyWith<$Res> {
  factory $CallStateCopyWith(CallState value, $Res Function(CallState) then) =
      _$CallStateCopyWithImpl<$Res, CallState>;
  @useResult
  $Res call({
    CallStateStatus status,
    String errorMessage,
    String twilioToken,
    CallData? currentCall,
    bool isInCall,
    String callerId,
    String recipientId,
    String callerName,
    String callerAvatar,
  });
}

/// @nodoc
class _$CallStateCopyWithImpl<$Res, $Val extends CallState>
    implements $CallStateCopyWith<$Res> {
  _$CallStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CallState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? errorMessage = null,
    Object? twilioToken = null,
    Object? currentCall = freezed,
    Object? isInCall = null,
    Object? callerId = null,
    Object? recipientId = null,
    Object? callerName = null,
    Object? callerAvatar = null,
  }) {
    return _then(
      _value.copyWith(
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as CallStateStatus,
            errorMessage: null == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String,
            twilioToken: null == twilioToken
                ? _value.twilioToken
                : twilioToken // ignore: cast_nullable_to_non_nullable
                      as String,
            currentCall: freezed == currentCall
                ? _value.currentCall
                : currentCall // ignore: cast_nullable_to_non_nullable
                      as CallData?,
            isInCall: null == isInCall
                ? _value.isInCall
                : isInCall // ignore: cast_nullable_to_non_nullable
                      as bool,
            callerId: null == callerId
                ? _value.callerId
                : callerId // ignore: cast_nullable_to_non_nullable
                      as String,
            recipientId: null == recipientId
                ? _value.recipientId
                : recipientId // ignore: cast_nullable_to_non_nullable
                      as String,
            callerName: null == callerName
                ? _value.callerName
                : callerName // ignore: cast_nullable_to_non_nullable
                      as String,
            callerAvatar: null == callerAvatar
                ? _value.callerAvatar
                : callerAvatar // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CallStateImplCopyWith<$Res>
    implements $CallStateCopyWith<$Res> {
  factory _$$CallStateImplCopyWith(
    _$CallStateImpl value,
    $Res Function(_$CallStateImpl) then,
  ) = __$$CallStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    CallStateStatus status,
    String errorMessage,
    String twilioToken,
    CallData? currentCall,
    bool isInCall,
    String callerId,
    String recipientId,
    String callerName,
    String callerAvatar,
  });
}

/// @nodoc
class __$$CallStateImplCopyWithImpl<$Res>
    extends _$CallStateCopyWithImpl<$Res, _$CallStateImpl>
    implements _$$CallStateImplCopyWith<$Res> {
  __$$CallStateImplCopyWithImpl(
    _$CallStateImpl _value,
    $Res Function(_$CallStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CallState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? errorMessage = null,
    Object? twilioToken = null,
    Object? currentCall = freezed,
    Object? isInCall = null,
    Object? callerId = null,
    Object? recipientId = null,
    Object? callerName = null,
    Object? callerAvatar = null,
  }) {
    return _then(
      _$CallStateImpl(
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as CallStateStatus,
        errorMessage: null == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String,
        twilioToken: null == twilioToken
            ? _value.twilioToken
            : twilioToken // ignore: cast_nullable_to_non_nullable
                  as String,
        currentCall: freezed == currentCall
            ? _value.currentCall
            : currentCall // ignore: cast_nullable_to_non_nullable
                  as CallData?,
        isInCall: null == isInCall
            ? _value.isInCall
            : isInCall // ignore: cast_nullable_to_non_nullable
                  as bool,
        callerId: null == callerId
            ? _value.callerId
            : callerId // ignore: cast_nullable_to_non_nullable
                  as String,
        recipientId: null == recipientId
            ? _value.recipientId
            : recipientId // ignore: cast_nullable_to_non_nullable
                  as String,
        callerName: null == callerName
            ? _value.callerName
            : callerName // ignore: cast_nullable_to_non_nullable
                  as String,
        callerAvatar: null == callerAvatar
            ? _value.callerAvatar
            : callerAvatar // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$CallStateImpl implements _CallState {
  const _$CallStateImpl({
    this.status = CallStateStatus.idle,
    this.errorMessage = '',
    this.twilioToken = '',
    this.currentCall,
    this.isInCall = false,
    this.callerId = '',
    this.recipientId = '',
    this.callerName = '',
    this.callerAvatar = '',
  });

  @override
  @JsonKey()
  final CallStateStatus status;
  @override
  @JsonKey()
  final String errorMessage;
  @override
  @JsonKey()
  final String twilioToken;
  @override
  final CallData? currentCall;
  @override
  @JsonKey()
  final bool isInCall;
  @override
  @JsonKey()
  final String callerId;
  @override
  @JsonKey()
  final String recipientId;
  @override
  @JsonKey()
  final String callerName;
  @override
  @JsonKey()
  final String callerAvatar;

  @override
  String toString() {
    return 'CallState(status: $status, errorMessage: $errorMessage, twilioToken: $twilioToken, currentCall: $currentCall, isInCall: $isInCall, callerId: $callerId, recipientId: $recipientId, callerName: $callerName, callerAvatar: $callerAvatar)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CallStateImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.twilioToken, twilioToken) ||
                other.twilioToken == twilioToken) &&
            (identical(other.currentCall, currentCall) ||
                other.currentCall == currentCall) &&
            (identical(other.isInCall, isInCall) ||
                other.isInCall == isInCall) &&
            (identical(other.callerId, callerId) ||
                other.callerId == callerId) &&
            (identical(other.recipientId, recipientId) ||
                other.recipientId == recipientId) &&
            (identical(other.callerName, callerName) ||
                other.callerName == callerName) &&
            (identical(other.callerAvatar, callerAvatar) ||
                other.callerAvatar == callerAvatar));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    status,
    errorMessage,
    twilioToken,
    currentCall,
    isInCall,
    callerId,
    recipientId,
    callerName,
    callerAvatar,
  );

  /// Create a copy of CallState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CallStateImplCopyWith<_$CallStateImpl> get copyWith =>
      __$$CallStateImplCopyWithImpl<_$CallStateImpl>(this, _$identity);
}

abstract class _CallState implements CallState {
  const factory _CallState({
    final CallStateStatus status,
    final String errorMessage,
    final String twilioToken,
    final CallData? currentCall,
    final bool isInCall,
    final String callerId,
    final String recipientId,
    final String callerName,
    final String callerAvatar,
  }) = _$CallStateImpl;

  @override
  CallStateStatus get status;
  @override
  String get errorMessage;
  @override
  String get twilioToken;
  @override
  CallData? get currentCall;
  @override
  bool get isInCall;
  @override
  String get callerId;
  @override
  String get recipientId;
  @override
  String get callerName;
  @override
  String get callerAvatar;

  /// Create a copy of CallState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CallStateImplCopyWith<_$CallStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
