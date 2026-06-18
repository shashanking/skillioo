// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'follow_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FollowResponse _$FollowResponseFromJson(Map<String, dynamic> json) =>
    FollowResponse(
      id: json['id'] as String?,
      followerId: json['followerId'] as String?,
      followingId: json['followingId'] as String?,
    );

Map<String, dynamic> _$FollowResponseToJson(FollowResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'followerId': instance.followerId,
      'followingId': instance.followingId,
    };

FollowUserResponse _$FollowUserResponseFromJson(Map<String, dynamic> json) =>
    FollowUserResponse(
      id: json['id'] as String?,
      nickName: json['nickName'] as String?,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      referenceId: json['referenceId'] as String?,
    );

Map<String, dynamic> _$FollowUserResponseToJson(FollowUserResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nickName': instance.nickName,
      'profilePictureUrl': instance.profilePictureUrl,
      'referenceId': instance.referenceId,
    };

FollowCountResponse _$FollowCountResponseFromJson(Map<String, dynamic> json) =>
    FollowCountResponse(
      followerCount: (json['followerCount'] as num?)?.toInt() ?? 0,
      followingCount: (json['followingCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$FollowCountResponseToJson(
  FollowCountResponse instance,
) => <String, dynamic>{
  'followerCount': instance.followerCount,
  'followingCount': instance.followingCount,
};
