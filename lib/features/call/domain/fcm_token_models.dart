import 'package:json_annotation/json_annotation.dart';

part 'fcm_token_models.g.dart';

@JsonSerializable()
class SetFcmTokenRequest {
  final String token;
  final String userId;

  SetFcmTokenRequest({
    required this.token,
    required this.userId,
  });

  factory SetFcmTokenRequest.fromJson(Map<String, dynamic> json) =>
      _$SetFcmTokenRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SetFcmTokenRequestToJson(this);
}

@JsonSerializable()
class FcmTokenData {
  final String id;
  final bool deleted;
  final String createdAt;
  final String updatedAt;
  final String token;
  final String userId;

  FcmTokenData({
    required this.id,
    required this.deleted,
    required this.createdAt,
    required this.updatedAt,
    required this.token,
    required this.userId,
  });

  factory FcmTokenData.fromJson(Map<String, dynamic> json) =>
      _$FcmTokenDataFromJson(json);

  Map<String, dynamic> toJson() => _$FcmTokenDataToJson(this);
}

@JsonSerializable()
class FcmTokenResponse {
  final int status;
  final String message;
  final FcmTokenData data;

  FcmTokenResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory FcmTokenResponse.fromJson(Map<String, dynamic> json) =>
      _$FcmTokenResponseFromJson(json);

  Map<String, dynamic> toJson() => _$FcmTokenResponseToJson(this);
}
