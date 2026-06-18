// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlanAggregatorResponse _$PlanAggregatorResponseFromJson(
  Map<String, dynamic> json,
) => PlanAggregatorResponse(
  callLimits: (json['callLimits'] as num?)?.toInt(),
  chatLimits: (json['chatLimits'] as num?)?.toInt(),
  activePlans: (json['activePlans'] as num?)?.toInt(),
  profileVisibility: json['profileVisibility'] as String?,
  userSubscriptionIds: (json['userSubscriptionIds'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$PlanAggregatorResponseToJson(
  PlanAggregatorResponse instance,
) => <String, dynamic>{
  'callLimits': instance.callLimits,
  'chatLimits': instance.chatLimits,
  'activePlans': instance.activePlans,
  'profileVisibility': instance.profileVisibility,
  'userSubscriptionIds': instance.userSubscriptionIds,
};

PlanMasterResponse _$PlanMasterResponseFromJson(Map<String, dynamic> json) =>
    PlanMasterResponse(
      id: json['id'] as String?,
      code: json['code'] as String?,
      description: json['description'] as String?,
      type: json['type'] as String?,
      version: (json['version'] as num?)?.toInt(),
      priority: (json['priority'] as num?)?.toInt(),
      priceInPaise: (json['priceInPaise'] as num?)?.toInt(),
      active: json['active'] as bool?,
      callLimits: (json['callLimits'] as num?)?.toInt(),
      chatLimits: (json['chatLimits'] as num?)?.toInt(),
      validity: (json['validity'] as num?)?.toInt(),
      profileVisibility: json['profileVisibility'] as String?,
      status: json['status'] as String?,
    );

Map<String, dynamic> _$PlanMasterResponseToJson(PlanMasterResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'description': instance.description,
      'type': instance.type,
      'version': instance.version,
      'priority': instance.priority,
      'priceInPaise': instance.priceInPaise,
      'active': instance.active,
      'callLimits': instance.callLimits,
      'chatLimits': instance.chatLimits,
      'validity': instance.validity,
      'profileVisibility': instance.profileVisibility,
      'status': instance.status,
    };

InitiateSubscriptionRequest _$InitiateSubscriptionRequestFromJson(
  Map<String, dynamic> json,
) => InitiateSubscriptionRequest(planId: json['planId'] as String);

Map<String, dynamic> _$InitiateSubscriptionRequestToJson(
  InitiateSubscriptionRequest instance,
) => <String, dynamic>{'planId': instance.planId};

SyncSubscriptionRequest _$SyncSubscriptionRequestFromJson(
  Map<String, dynamic> json,
) => SyncSubscriptionRequest(
  id: json['id'] as String,
  hard: json['hard'] as bool?,
);

Map<String, dynamic> _$SyncSubscriptionRequestToJson(
  SyncSubscriptionRequest instance,
) => <String, dynamic>{'id': instance.id, 'hard': instance.hard};

SubscriptionPlanDetails _$SubscriptionPlanDetailsFromJson(
  Map<String, dynamic> json,
) => SubscriptionPlanDetails(
  code: json['code'] as String?,
  version: (json['version'] as num?)?.toInt(),
  priority: (json['priority'] as num?)?.toInt(),
  validity: (json['validity'] as num?)?.toInt(),
  callLimits: (json['callLimits'] as num?)?.toInt(),
  chatLimits: (json['chatLimits'] as num?)?.toInt(),
  priceInPaise: (json['priceInPaise'] as num?)?.toInt(),
);

Map<String, dynamic> _$SubscriptionPlanDetailsToJson(
  SubscriptionPlanDetails instance,
) => <String, dynamic>{
  'code': instance.code,
  'version': instance.version,
  'priority': instance.priority,
  'validity': instance.validity,
  'callLimits': instance.callLimits,
  'chatLimits': instance.chatLimits,
  'priceInPaise': instance.priceInPaise,
};

UserSubscriptionResponse _$UserSubscriptionResponseFromJson(
  Map<String, dynamic> json,
) => UserSubscriptionResponse(
  id: json['id'] as String?,
  planCode: json['planCode'] as String?,
  planDetails: json['planDetails'] == null
      ? null
      : SubscriptionPlanDetails.fromJson(
          json['planDetails'] as Map<String, dynamic>,
        ),
  paymentLink: json['paymentLink'] as String?,
  status: json['status'] as String?,
);

Map<String, dynamic> _$UserSubscriptionResponseToJson(
  UserSubscriptionResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'planCode': instance.planCode,
  'planDetails': instance.planDetails,
  'paymentLink': instance.paymentLink,
  'status': instance.status,
};
