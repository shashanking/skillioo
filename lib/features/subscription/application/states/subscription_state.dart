import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/subscription_models.dart';

part 'subscription_state.freezed.dart';

enum SubscriptionStatus { initial, loading, success, error }

@freezed
class SubscriptionState with _$SubscriptionState {
  const factory SubscriptionState({
    // Plans
    @Default(SubscriptionStatus.initial) SubscriptionStatus plansStatus,
    @Default([]) List<PlanMasterResponse> plans,

    // Active subscription
    @Default(SubscriptionStatus.initial) SubscriptionStatus subscriptionStatus,
    @Default(null) UserSubscriptionResponse? activeSubscription,

    // Plan Aggregator
    @Default(null) PlanAggregatorResponse? aggregator,

    // Initiate
    @Default(SubscriptionStatus.initial) SubscriptionStatus initiateStatus,
    @Default('') String paymentLink,

    @Default('') String errorMessage,
  }) = _SubscriptionState;
}
