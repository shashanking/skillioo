import 'package:json_annotation/json_annotation.dart';

part 'privacy_models.g.dart';

enum PrivacyType {
  @JsonValue('PRIVATE')
  private,
  @JsonValue('FOLLOWERS')
  followers,
  @JsonValue('PUBLIC')
  public,
}

@JsonSerializable()
class PrivacyResponse {
  final String? type;
  final String? userReferenceId;

  const PrivacyResponse({
    this.type,
    this.userReferenceId,
  });

  factory PrivacyResponse.fromJson(Map<String, dynamic> json) =>
      _$PrivacyResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PrivacyResponseToJson(this);
}

@JsonSerializable()
class CreatePrivacyRequest {
  final String type;
  final String userReferenceId;

  const CreatePrivacyRequest({
    required this.type,
    required this.userReferenceId,
  });

  factory CreatePrivacyRequest.fromJson(Map<String, dynamic> json) =>
      _$CreatePrivacyRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreatePrivacyRequestToJson(this);
}

@JsonSerializable()
class UpdatePrivacyRequest {
  final String type;
  final String userReferenceId;

  const UpdatePrivacyRequest({
    required this.type,
    required this.userReferenceId,
  });

  factory UpdatePrivacyRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdatePrivacyRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdatePrivacyRequestToJson(this);
}
