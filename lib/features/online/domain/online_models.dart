import 'package:json_annotation/json_annotation.dart';

part 'online_models.g.dart';

@JsonSerializable()
class OnlineStatusResponse {
  final String? profileId;
  final String? status; // 'online' or 'offline'
  final DateTime? lastSeen;

  const OnlineStatusResponse({
    this.profileId,
    this.status,
    this.lastSeen,
  });

  factory OnlineStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$OnlineStatusResponseFromJson(json);
  Map<String, dynamic> toJson() => _$OnlineStatusResponseToJson(this);
}
