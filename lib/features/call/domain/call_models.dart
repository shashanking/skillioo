import 'package:json_annotation/json_annotation.dart';

part 'call_models.g.dart';

enum CallProvider {
  @JsonValue('TWILIO')
  twilio,
}

enum CallStatus {
  @JsonValue('CALLING')
  calling,
  @JsonValue('RINGING')
  ringing,
  @JsonValue('ACCEPTED')
  accepted,
  @JsonValue('REJECTED')
  rejected,
  @JsonValue('ENDED')
  ended,
  @JsonValue('MISSED')
  missed,
}

@JsonSerializable()
class GetCallTokenRequest {
  final CallProvider provider;
  final String callerId;

  GetCallTokenRequest({required this.provider, required this.callerId});

  factory GetCallTokenRequest.fromJson(Map<String, dynamic> json) =>
      _$GetCallTokenRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GetCallTokenRequestToJson(this);
}

@JsonSerializable()
class CallTokenResponse {
  final int status;
  final String message;
  final String data;

  CallTokenResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CallTokenResponse.fromJson(Map<String, dynamic> json) =>
      _$CallTokenResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CallTokenResponseToJson(this);
}

@JsonSerializable()
class InitiateCallRequest {
  final String recipientId;
  // final String registrationToken;

  InitiateCallRequest({
    required this.recipientId,
    // required this.registrationToken,
  });

  factory InitiateCallRequest.fromJson(Map<String, dynamic> json) =>
      _$InitiateCallRequestFromJson(json);

  Map<String, dynamic> toJson() => _$InitiateCallRequestToJson(this);
}

@JsonSerializable()
class CallData {
  final String id;
  final String callerId;
  final String recipientId;
  final CallStatus callStatus;
  final String startedAt;
  final String? endedAt;

  CallData({
    required this.id,
    required this.callerId,
    required this.recipientId,
    required this.callStatus,
    required this.startedAt,
    this.endedAt,
  });

  factory CallData.fromJson(Map<String, dynamic> json) =>
      _$CallDataFromJson(json);

  Map<String, dynamic> toJson() => _$CallDataToJson(this);
}

@JsonSerializable()
class InitiateCallResponse {
  final bool success;
  final String message;
  final CallData data;

  InitiateCallResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory InitiateCallResponse.fromJson(Map<String, dynamic> json) =>
      _$InitiateCallResponseFromJson(json);

  Map<String, dynamic> toJson() => _$InitiateCallResponseToJson(this);
}
