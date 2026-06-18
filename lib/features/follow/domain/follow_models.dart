import 'package:json_annotation/json_annotation.dart';

part 'follow_models.g.dart';

// ── Follow (check if following) ──

@JsonSerializable()
class FollowResponse {
  final String? id;
  final String? followerId;
  final String? followingId;

  const FollowResponse({
    this.id,
    this.followerId,
    this.followingId,
  });

  factory FollowResponse.fromJson(Map<String, dynamic> json) =>
      _$FollowResponseFromJson(json);

  Map<String, dynamic> toJson() => _$FollowResponseToJson(this);
}

// ── Follower / Following user item ──

@JsonSerializable()
class FollowUserResponse {
  final String? id;
  final String? nickName;
  final String? profilePictureUrl;
  final String? referenceId;

  const FollowUserResponse({
    this.id,
    this.nickName,
    this.profilePictureUrl,
    this.referenceId,
  });

  factory FollowUserResponse.fromJson(Map<String, dynamic> json) =>
      _$FollowUserResponseFromJson(json);

  Map<String, dynamic> toJson() => _$FollowUserResponseToJson(this);
}

// ── Follow count ──

@JsonSerializable()
class FollowCountResponse {
  final int followerCount;
  final int followingCount;

  const FollowCountResponse({
    this.followerCount = 0,
    this.followingCount = 0,
  });

  factory FollowCountResponse.fromJson(Map<String, dynamic> json) =>
      _$FollowCountResponseFromJson(json);

  Map<String, dynamic> toJson() => _$FollowCountResponseToJson(this);
}
