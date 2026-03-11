// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageContent _$MessageContentFromJson(Map<String, dynamic> json) =>
    MessageContent(
      text: json['text'] as String?,
      fileUrl: json['fileUrl'] as String?,
    );

Map<String, dynamic> _$MessageContentToJson(MessageContent instance) =>
    <String, dynamic>{'text': instance.text, 'fileUrl': instance.fileUrl};

SendMessageRequest _$SendMessageRequestFromJson(Map<String, dynamic> json) =>
    SendMessageRequest(
      recipientId: json['recipientId'] as String,
      content: MessageContent.fromJson(json['content'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SendMessageRequestToJson(SendMessageRequest instance) =>
    <String, dynamic>{
      'recipientId': instance.recipientId,
      'content': instance.content,
    };

MessageResponse _$MessageResponseFromJson(Map<String, dynamic> json) =>
    MessageResponse(
      id: json['id'] as String?,
      senderId: json['senderId'] as String?,
      recipientId: json['recipientId'] as String?,
      content: json['content'] == null
          ? null
          : MessageContent.fromJson(json['content'] as Map<String, dynamic>),
      status: json['status'] as String?,
      readAt: json['readAt'] as String?,
      isDeleted: json['isDeleted'] as bool?,
      createdAt: json['createdAt'] as String?,
    );

Map<String, dynamic> _$MessageResponseToJson(MessageResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'senderId': instance.senderId,
      'recipientId': instance.recipientId,
      'content': instance.content,
      'status': instance.status,
      'readAt': instance.readAt,
      'isDeleted': instance.isDeleted,
      'createdAt': instance.createdAt,
    };

ConversationResponse _$ConversationResponseFromJson(
  Map<String, dynamic> json,
) => ConversationResponse(
  participantId: json['participantId'] as String?,
  conversationId: json['conversationId'] as String?,
  latestMessage: json['latestMessage'] == null
      ? null
      : MessageResponse.fromJson(json['latestMessage'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ConversationResponseToJson(
  ConversationResponse instance,
) => <String, dynamic>{
  'participantId': instance.participantId,
  'conversationId': instance.conversationId,
  'latestMessage': instance.latestMessage,
};

InitiateCallRequest _$InitiateCallRequestFromJson(Map<String, dynamic> json) =>
    InitiateCallRequest(recipientId: json['recipientId'] as String);

Map<String, dynamic> _$InitiateCallRequestToJson(
  InitiateCallRequest instance,
) => <String, dynamic>{'recipientId': instance.recipientId};

CallActionRequest _$CallActionRequestFromJson(Map<String, dynamic> json) =>
    CallActionRequest(callId: json['callId'] as String);

Map<String, dynamic> _$CallActionRequestToJson(CallActionRequest instance) =>
    <String, dynamic>{'callId': instance.callId};

CallResponse _$CallResponseFromJson(Map<String, dynamic> json) => CallResponse(
  id: json['id'] as String?,
  callerId: json['callerId'] as String?,
  recipientId: json['recipientId'] as String?,
  callStatus: json['callStatus'] as String?,
  startedAt: json['startedAt'] as String?,
  endedAt: json['endedAt'] as String?,
);

Map<String, dynamic> _$CallResponseToJson(CallResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'callerId': instance.callerId,
      'recipientId': instance.recipientId,
      'callStatus': instance.callStatus,
      'startedAt': instance.startedAt,
      'endedAt': instance.endedAt,
    };

NotificationBody _$NotificationBodyFromJson(Map<String, dynamic> json) =>
    NotificationBody(bodyText: json['bodyText'] as Map<String, dynamic>?);

Map<String, dynamic> _$NotificationBodyToJson(NotificationBody instance) =>
    <String, dynamic>{'bodyText': instance.bodyText};
