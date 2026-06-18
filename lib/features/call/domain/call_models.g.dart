// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetCallTokenRequest _$GetCallTokenRequestFromJson(Map<String, dynamic> json) =>
    GetCallTokenRequest(
      provider: $enumDecode(_$CallProviderEnumMap, json['provider']),
      callerId: json['callerId'] as String,
    );

Map<String, dynamic> _$GetCallTokenRequestToJson(
  GetCallTokenRequest instance,
) => <String, dynamic>{
  'provider': _$CallProviderEnumMap[instance.provider]!,
  'callerId': instance.callerId,
};

const _$CallProviderEnumMap = {CallProvider.twilio: 'TWILIO'};

CallTokenResponse _$CallTokenResponseFromJson(Map<String, dynamic> json) =>
    CallTokenResponse(
      status: (json['status'] as num).toInt(),
      message: json['message'] as String,
      data: json['data'] as String,
    );

Map<String, dynamic> _$CallTokenResponseToJson(CallTokenResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
      'data': instance.data,
    };

InitiateCallRequest _$InitiateCallRequestFromJson(Map<String, dynamic> json) =>
    InitiateCallRequest(recipientId: json['recipientId'] as String);

Map<String, dynamic> _$InitiateCallRequestToJson(
  InitiateCallRequest instance,
) => <String, dynamic>{'recipientId': instance.recipientId};

CallData _$CallDataFromJson(Map<String, dynamic> json) => CallData(
  id: json['id'] as String,
  callerId: json['callerId'] as String,
  recipientId: json['recipientId'] as String,
  callStatus: $enumDecode(_$CallStatusEnumMap, json['callStatus']),
  startedAt: json['startedAt'] as String,
  endedAt: json['endedAt'] as String?,
);

Map<String, dynamic> _$CallDataToJson(CallData instance) => <String, dynamic>{
  'id': instance.id,
  'callerId': instance.callerId,
  'recipientId': instance.recipientId,
  'callStatus': _$CallStatusEnumMap[instance.callStatus]!,
  'startedAt': instance.startedAt,
  'endedAt': instance.endedAt,
};

const _$CallStatusEnumMap = {
  CallStatus.calling: 'CALLING',
  CallStatus.ringing: 'RINGING',
  CallStatus.accepted: 'ACCEPTED',
  CallStatus.rejected: 'REJECTED',
  CallStatus.ended: 'ENDED',
  CallStatus.missed: 'MISSED',
};

InitiateCallResponse _$InitiateCallResponseFromJson(
  Map<String, dynamic> json,
) => InitiateCallResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: CallData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$InitiateCallResponseToJson(
  InitiateCallResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};
