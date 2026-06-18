// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'privacy_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrivacyResponse _$PrivacyResponseFromJson(Map<String, dynamic> json) =>
    PrivacyResponse(
      type: json['type'] as String?,
      userReferenceId: json['userReferenceId'] as String?,
    );

Map<String, dynamic> _$PrivacyResponseToJson(PrivacyResponse instance) =>
    <String, dynamic>{
      'type': instance.type,
      'userReferenceId': instance.userReferenceId,
    };

CreatePrivacyRequest _$CreatePrivacyRequestFromJson(
  Map<String, dynamic> json,
) => CreatePrivacyRequest(
  type: json['type'] as String,
  userReferenceId: json['userReferenceId'] as String,
);

Map<String, dynamic> _$CreatePrivacyRequestToJson(
  CreatePrivacyRequest instance,
) => <String, dynamic>{
  'type': instance.type,
  'userReferenceId': instance.userReferenceId,
};

UpdatePrivacyRequest _$UpdatePrivacyRequestFromJson(
  Map<String, dynamic> json,
) => UpdatePrivacyRequest(
  type: json['type'] as String,
  userReferenceId: json['userReferenceId'] as String,
);

Map<String, dynamic> _$UpdatePrivacyRequestToJson(
  UpdatePrivacyRequest instance,
) => <String, dynamic>{
  'type': instance.type,
  'userReferenceId': instance.userReferenceId,
};
