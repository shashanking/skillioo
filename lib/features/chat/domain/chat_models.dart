import 'package:json_annotation/json_annotation.dart';

part 'chat_models.g.dart';

// ── Message ──

@JsonSerializable()
class MessageContent {
  final String? text;
  final String? fileUrl;

  const MessageContent({this.text, this.fileUrl});

  factory MessageContent.fromJson(Map<String, dynamic> json) =>
      _$MessageContentFromJson(json);
  Map<String, dynamic> toJson() => _$MessageContentToJson(this);
}

@JsonSerializable()
class SendMessageRequest {
  final String recipientId;
  final MessageContent content;

  const SendMessageRequest({
    required this.recipientId,
    required this.content,
  });

  factory SendMessageRequest.fromJson(Map<String, dynamic> json) =>
      _$SendMessageRequestFromJson(json);
  Map<String, dynamic> toJson() => _$SendMessageRequestToJson(this);
}

@JsonSerializable()
class MessageResponse {
  final String? id;
  final String? senderId;
  final String? recipientId;
  final MessageContent? content;
  final String? status;
  final String? readAt;
  final bool? isDeleted;
  final String? createdAt;

  const MessageResponse({
    this.id,
    this.senderId,
    this.recipientId,
    this.content,
    this.status,
    this.readAt,
    this.isDeleted,
    this.createdAt,
  });

  factory MessageResponse.fromJson(Map<String, dynamic> json) =>
      _$MessageResponseFromJson(json);
  Map<String, dynamic> toJson() => _$MessageResponseToJson(this);
}

// ── Conversation ──

@JsonSerializable()
class ConversationResponse {
  final String? participantId;
  final String? conversationId;
  final MessageResponse? latestMessage;

  const ConversationResponse({
    this.participantId,
    this.conversationId,
    this.latestMessage,
  });

  factory ConversationResponse.fromJson(Map<String, dynamic> json) =>
      _$ConversationResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ConversationResponseToJson(this);
}

// ── Call ──

@JsonSerializable()
class InitiateCallRequest {
  final String recipientId;

  const InitiateCallRequest({required this.recipientId});

  factory InitiateCallRequest.fromJson(Map<String, dynamic> json) =>
      _$InitiateCallRequestFromJson(json);
  Map<String, dynamic> toJson() => _$InitiateCallRequestToJson(this);
}

@JsonSerializable()
class CallActionRequest {
  final String callId;

  const CallActionRequest({required this.callId});

  factory CallActionRequest.fromJson(Map<String, dynamic> json) =>
      _$CallActionRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CallActionRequestToJson(this);
}

@JsonSerializable()
class CallResponse {
  final String? id;
  final String? callerId;
  final String? recipientId;
  final String? callStatus;
  final String? startedAt;
  final String? endedAt;

  const CallResponse({
    this.id,
    this.callerId,
    this.recipientId,
    this.callStatus,
    this.startedAt,
    this.endedAt,
  });

  factory CallResponse.fromJson(Map<String, dynamic> json) =>
      _$CallResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CallResponseToJson(this);
}

// ── Notification ──

@JsonSerializable()
class NotificationBody {
  final Map<String, dynamic>? bodyText;

  const NotificationBody({this.bodyText});

  factory NotificationBody.fromJson(Map<String, dynamic> json) =>
      _$NotificationBodyFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationBodyToJson(this);
}
