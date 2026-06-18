// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$SubscriptionState {
  // Plans
  SubscriptionStatus get plansStatus => throw _privateConstructorUsedError;
  List<PlanMasterResponse> get plans =>
      throw _privateConstructorUsedError; // Active subscription
  SubscriptionStatus get subscriptionStatus =>
      throw _privateConstructorUsedError;
  UserSubscriptionResponse? get activeSubscription =>
      throw _privateConstructorUsedError; // Plan Aggregator
  PlanAggregatorResponse? get aggregator =>
      throw _privateConstructorUsedError; // Initiate
  SubscriptionStatus get initiateStatus => throw _privateConstructorUsedError;
  String get paymentLink => throw _privateConstructorUsedError;
  String get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of SubscriptionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubscriptionStateCopyWith<SubscriptionState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubscriptionStateCopyWith<$Res> {
  factory $SubscriptionStateCopyWith(
    SubscriptionState value,
    $Res Function(SubscriptionState) then,
  ) = _$SubscriptionStateCopyWithImpl<$Res, SubscriptionState>;
  @useResult
  $Res call({
    SubscriptionStatus plansStatus,
    List<PlanMasterResponse> plans,
    SubscriptionStatus subscriptionStatus,
    UserSubscriptionResponse? activeSubscription,
    PlanAggregatorResponse? aggregator,
    SubscriptionStatus initiateStatus,
    String paymentLink,
    String errorMessage,
  });
}

/// @nodoc
class _$SubscriptionStateCopyWithImpl<$Res, $Val extends SubscriptionState>
    implements $SubscriptionStateCopyWith<$Res> {
  _$SubscriptionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubscriptionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? plansStatus = null,
    Object? plans = null,
    Object? subscriptionStatus = null,
    Object? activeSubscription = freezed,
    Object? aggregator = freezed,
    Object? initiateStatus = null,
    Object? paymentLink = null,
    Object? errorMessage = null,
  }) {
    return _then(
      _value.copyWith(
            plansStatus: null == plansStatus
                ? _value.plansStatus
                : plansStatus // ignore: cast_nullable_to_non_nullable
                      as SubscriptionStatus,
            plans: null == plans
                ? _value.plans
                : plans // ignore: cast_nullable_to_non_nullable
                      as List<PlanMasterResponse>,
            subscriptionStatus: null == subscriptionStatus
                ? _value.subscriptionStatus
                : subscriptionStatus // ignore: cast_nullable_to_non_nullable
                      as SubscriptionStatus,
            activeSubscription: freezed == activeSubscription
                ? _value.activeSubscription
                : activeSubscription // ignore: cast_nullable_to_non_nullable
                      as UserSubscriptionResponse?,
            aggregator: freezed == aggregator
                ? _value.aggregator
                : aggregator // ignore: cast_nullable_to_non_nullable
                      as PlanAggregatorResponse?,
            initiateStatus: null == initiateStatus
                ? _value.initiateStatus
                : initiateStatus // ignore: cast_nullable_to_non_nullable
                      as SubscriptionStatus,
            paymentLink: null == paymentLink
                ? _value.paymentLink
                : paymentLink // ignore: cast_nullable_to_non_nullable
                      as String,
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
abstract class _$$SubscriptionStateImplCopyWith<$Res>
    implements $SubscriptionStateCopyWith<$Res> {
  factory _$$SubscriptionStateImplCopyWith(
    _$SubscriptionStateImpl value,
    $Res Function(_$SubscriptionStateImpl) then,
  ) = __$$SubscriptionStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    SubscriptionStatus plansStatus,
    List<PlanMasterResponse> plans,
    SubscriptionStatus subscriptionStatus,
    UserSubscriptionResponse? activeSubscription,
    PlanAggregatorResponse? aggregator,
    SubscriptionStatus initiateStatus,
    String paymentLink,
    String errorMessage,
  });
}

/// @nodoc
class __$$SubscriptionStateImplCopyWithImpl<$Res>
    extends _$SubscriptionStateCopyWithImpl<$Res, _$SubscriptionStateImpl>
    implements _$$SubscriptionStateImplCopyWith<$Res> {
  __$$SubscriptionStateImplCopyWithImpl(
    _$SubscriptionStateImpl _value,
    $Res Function(_$SubscriptionStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SubscriptionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? plansStatus = null,
    Object? plans = null,
    Object? subscriptionStatus = null,
    Object? activeSubscription = freezed,
    Object? aggregator = freezed,
    Object? initiateStatus = null,
    Object? paymentLink = null,
    Object? errorMessage = null,
  }) {
    return _then(
      _$SubscriptionStateImpl(
        plansStatus: null == plansStatus
            ? _value.plansStatus
            : plansStatus // ignore: cast_nullable_to_non_nullable
                  as SubscriptionStatus,
        plans: null == plans
            ? _value._plans
            : plans // ignore: cast_nullable_to_non_nullable
                  as List<PlanMasterResponse>,
        subscriptionStatus: null == subscriptionStatus
            ? _value.subscriptionStatus
            : subscriptionStatus // ignore: cast_nullable_to_non_nullable
                  as SubscriptionStatus,
        activeSubscription: freezed == activeSubscription
            ? _value.activeSubscription
            : activeSubscription // ignore: cast_nullable_to_non_nullable
                  as UserSubscriptionResponse?,
        aggregator: freezed == aggregator
            ? _value.aggregator
            : aggregator // ignore: cast_nullable_to_non_nullable
                  as PlanAggregatorResponse?,
        initiateStatus: null == initiateStatus
            ? _value.initiateStatus
            : initiateStatus // ignore: cast_nullable_to_non_nullable
                  as SubscriptionStatus,
        paymentLink: null == paymentLink
            ? _value.paymentLink
            : paymentLink // ignore: cast_nullable_to_non_nullable
                  as String,
        errorMessage: null == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$SubscriptionStateImpl implements _SubscriptionState {
  const _$SubscriptionStateImpl({
    this.plansStatus = SubscriptionStatus.initial,
    final List<PlanMasterResponse> plans = const [],
    this.subscriptionStatus = SubscriptionStatus.initial,
    this.activeSubscription = null,
    this.aggregator = null,
    this.initiateStatus = SubscriptionStatus.initial,
    this.paymentLink = '',
    this.errorMessage = '',
  }) : _plans = plans;

  // Plans
  @override
  @JsonKey()
  final SubscriptionStatus plansStatus;
  final List<PlanMasterResponse> _plans;
  @override
  @JsonKey()
  List<PlanMasterResponse> get plans {
    if (_plans is EqualUnmodifiableListView) return _plans;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_plans);
  }

  // Active subscription
  @override
  @JsonKey()
  final SubscriptionStatus subscriptionStatus;
  @override
  @JsonKey()
  final UserSubscriptionResponse? activeSubscription;
  // Plan Aggregator
  @override
  @JsonKey()
  final PlanAggregatorResponse? aggregator;
  // Initiate
  @override
  @JsonKey()
  final SubscriptionStatus initiateStatus;
  @override
  @JsonKey()
  final String paymentLink;
  @override
  @JsonKey()
  final String errorMessage;

  @override
  String toString() {
    return 'SubscriptionState(plansStatus: $plansStatus, plans: $plans, subscriptionStatus: $subscriptionStatus, activeSubscription: $activeSubscription, aggregator: $aggregator, initiateStatus: $initiateStatus, paymentLink: $paymentLink, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscriptionStateImpl &&
            (identical(other.plansStatus, plansStatus) ||
                other.plansStatus == plansStatus) &&
            const DeepCollectionEquality().equals(other._plans, _plans) &&
            (identical(other.subscriptionStatus, subscriptionStatus) ||
                other.subscriptionStatus == subscriptionStatus) &&
            (identical(other.activeSubscription, activeSubscription) ||
                other.activeSubscription == activeSubscription) &&
            (identical(other.aggregator, aggregator) ||
                other.aggregator == aggregator) &&
            (identical(other.initiateStatus, initiateStatus) ||
                other.initiateStatus == initiateStatus) &&
            (identical(other.paymentLink, paymentLink) ||
                other.paymentLink == paymentLink) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    plansStatus,
    const DeepCollectionEquality().hash(_plans),
    subscriptionStatus,
    activeSubscription,
    aggregator,
    initiateStatus,
    paymentLink,
    errorMessage,
  );

  /// Create a copy of SubscriptionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubscriptionStateImplCopyWith<_$SubscriptionStateImpl> get copyWith =>
      __$$SubscriptionStateImplCopyWithImpl<_$SubscriptionStateImpl>(
        this,
        _$identity,
      );
}

abstract class _SubscriptionState implements SubscriptionState {
  const factory _SubscriptionState({
    final SubscriptionStatus plansStatus,
    final List<PlanMasterResponse> plans,
    final SubscriptionStatus subscriptionStatus,
    final UserSubscriptionResponse? activeSubscription,
    final PlanAggregatorResponse? aggregator,
    final SubscriptionStatus initiateStatus,
    final String paymentLink,
    final String errorMessage,
  }) = _$SubscriptionStateImpl;

  // Plans
  @override
  SubscriptionStatus get plansStatus;
  @override
  List<PlanMasterResponse> get plans; // Active subscription
  @override
  SubscriptionStatus get subscriptionStatus;
  @override
  UserSubscriptionResponse? get activeSubscription; // Plan Aggregator
  @override
  PlanAggregatorResponse? get aggregator; // Initiate
  @override
  SubscriptionStatus get initiateStatus;
  @override
  String get paymentLink;
  @override
  String get errorMessage;

  /// Create a copy of SubscriptionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubscriptionStateImplCopyWith<_$SubscriptionStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
