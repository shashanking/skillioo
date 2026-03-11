// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'online_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OnlineStatusResponse _$OnlineStatusResponseFromJson(
  Map<String, dynamic> json,
) => OnlineStatusResponse(
  profileId: json['profileId'] as String?,
  status: json['status'] as String?,
  lastSeen: json['lastSeen'] == null
      ? null
      : DateTime.parse(json['lastSeen'] as String),
);

Map<String, dynamic> _$OnlineStatusResponseToJson(
  OnlineStatusResponse instance,
) => <String, dynamic>{
  'profileId': instance.profileId,
  'status': instance.status,
  'lastSeen': instance.lastSeen?.toIso8601String(),
};
