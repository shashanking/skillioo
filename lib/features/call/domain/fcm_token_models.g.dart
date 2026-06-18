// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fcm_token_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SetFcmTokenRequest _$SetFcmTokenRequestFromJson(Map<String, dynamic> json) =>
    SetFcmTokenRequest(
      token: json['token'] as String,
      userId: json['userId'] as String,
    );

Map<String, dynamic> _$SetFcmTokenRequestToJson(SetFcmTokenRequest instance) =>
    <String, dynamic>{'token': instance.token, 'userId': instance.userId};

FcmTokenData _$FcmTokenDataFromJson(Map<String, dynamic> json) => FcmTokenData(
  id: json['id'] as String,
  deleted: json['deleted'] as bool,
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
  token: json['token'] as String,
  userId: json['userId'] as String,
);

Map<String, dynamic> _$FcmTokenDataToJson(FcmTokenData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'deleted': instance.deleted,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'token': instance.token,
      'userId': instance.userId,
    };

FcmTokenResponse _$FcmTokenResponseFromJson(Map<String, dynamic> json) =>
    FcmTokenResponse(
      status: (json['status'] as num).toInt(),
      message: json['message'] as String,
      data: FcmTokenData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FcmTokenResponseToJson(FcmTokenResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
      'data': instance.data,
    };
