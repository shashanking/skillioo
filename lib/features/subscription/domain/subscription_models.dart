import 'package:json_annotation/json_annotation.dart';

part 'subscription_models.g.dart';

// ── Plan Master ──

@JsonSerializable()
class PlanMasterResponse {
  final String? id;
  final String? code;
  final String? description;
  final String? type;
  final int? version;
  final int? priority;
  final int? priceInPaise;
  final bool? active;
  final int? callLimits;
  final int? chatLimits;
  final int? validity;
  final String? profileVisibility;
  final String? status;

  const PlanMasterResponse({
    this.id,
    this.code,
    this.description,
    this.type,
    this.version,
    this.priority,
    this.priceInPaise,
    this.active,
    this.callLimits,
    this.chatLimits,
    this.validity,
    this.profileVisibility,
    this.status,
  });

  factory PlanMasterResponse.fromJson(Map<String, dynamic> json) =>
      _$PlanMasterResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PlanMasterResponseToJson(this);
}

// ── User Subscription ──

@JsonSerializable()
class InitiateSubscriptionRequest {
  final String planId;

  const InitiateSubscriptionRequest({required this.planId});

  factory InitiateSubscriptionRequest.fromJson(Map<String, dynamic> json) =>
      _$InitiateSubscriptionRequestFromJson(json);
  Map<String, dynamic> toJson() => _$InitiateSubscriptionRequestToJson(this);
}

@JsonSerializable()
class SyncSubscriptionRequest {
  final String id;
  final bool? hard;

  const SyncSubscriptionRequest({required this.id, this.hard});

  factory SyncSubscriptionRequest.fromJson(Map<String, dynamic> json) =>
      _$SyncSubscriptionRequestFromJson(json);
  Map<String, dynamic> toJson() => _$SyncSubscriptionRequestToJson(this);
}

@JsonSerializable()
class SubscriptionPlanDetails {
  final String? code;
  final int? version;
  final int? priority;
  final int? validity;
  final int? callLimits;
  final int? chatLimits;
  final int? priceInPaise;

  const SubscriptionPlanDetails({
    this.code,
    this.version,
    this.priority,
    this.validity,
    this.callLimits,
    this.chatLimits,
    this.priceInPaise,
  });

  factory SubscriptionPlanDetails.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionPlanDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$SubscriptionPlanDetailsToJson(this);
}

@JsonSerializable()
class UserSubscriptionResponse {
  final String? id;
  final String? planCode;
  final SubscriptionPlanDetails? planDetails;
  final String? paymentLink;
  final String? status;

  const UserSubscriptionResponse({
    this.id,
    this.planCode,
    this.planDetails,
    this.paymentLink,
    this.status,
  });

  factory UserSubscriptionResponse.fromJson(Map<String, dynamic> json) =>
      _$UserSubscriptionResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UserSubscriptionResponseToJson(this);
}
