// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateShortUserRequest _$CreateShortUserRequestFromJson(
  Map<String, dynamic> json,
) => CreateShortUserRequest(
  nickName: json['nickName'] as String,
  profilePictureUrl: json['profilePictureUrl'] as String,
  referenceId: json['referenceId'] as String,
);

Map<String, dynamic> _$CreateShortUserRequestToJson(
  CreateShortUserRequest instance,
) => <String, dynamic>{
  'nickName': instance.nickName,
  'profilePictureUrl': instance.profilePictureUrl,
  'referenceId': instance.referenceId,
};

UpdateShortUserRequest _$UpdateShortUserRequestFromJson(
  Map<String, dynamic> json,
) => UpdateShortUserRequest(
  referenceId: json['referenceId'] as String,
  nickName: json['nickName'] as String?,
  profilePictureUrl: json['profilePictureUrl'] as String?,
);

Map<String, dynamic> _$UpdateShortUserRequestToJson(
  UpdateShortUserRequest instance,
) => <String, dynamic>{
  'referenceId': instance.referenceId,
  'nickName': instance.nickName,
  'profilePictureUrl': instance.profilePictureUrl,
};

ShortUserResponse _$ShortUserResponseFromJson(Map<String, dynamic> json) =>
    ShortUserResponse(
      nickName: json['nickName'] as String?,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      referenceId: json['referenceId'] as String?,
    );

Map<String, dynamic> _$ShortUserResponseToJson(ShortUserResponse instance) =>
    <String, dynamic>{
      'nickName': instance.nickName,
      'profilePictureUrl': instance.profilePictureUrl,
      'referenceId': instance.referenceId,
    };

CreateMediaRequest _$CreateMediaRequestFromJson(Map<String, dynamic> json) =>
    CreateMediaRequest(
      description: json['description'] as String?,
      documentId: (json['documentId'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      mentions: (json['mentions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      userReferenceId: json['userReferenceId'] as String,
      mediaType: json['mediaType'] as String,
      city: json['city'] as String?,
    );

Map<String, dynamic> _$CreateMediaRequestToJson(CreateMediaRequest instance) =>
    <String, dynamic>{
      'description': instance.description,
      'documentId': instance.documentId,
      'mentions': instance.mentions,
      'userReferenceId': instance.userReferenceId,
      'mediaType': instance.mediaType,
      'city': instance.city,
    };

UpdateMediaRequest _$UpdateMediaRequestFromJson(Map<String, dynamic> json) =>
    UpdateMediaRequest(
      id: json['id'] as String,
      description: json['description'] as String?,
      mentions: (json['mentions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      mediaType: json['mediaType'] as String?,
    );

Map<String, dynamic> _$UpdateMediaRequestToJson(UpdateMediaRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'mentions': instance.mentions,
      'mediaType': instance.mediaType,
    };

MediaShortUser _$MediaShortUserFromJson(Map<String, dynamic> json) =>
    MediaShortUser(
      nickName: json['nickName'] as String?,
      name: json['name'] as String?,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      userReferenceId: json['userReferenceId'] as String?,
      category: json['category'] as String?,
      subCategory: json['subCategory'] as String?,
    );

Map<String, dynamic> _$MediaShortUserToJson(MediaShortUser instance) =>
    <String, dynamic>{
      'nickName': instance.nickName,
      'name': instance.name,
      'profilePictureUrl': instance.profilePictureUrl,
      'userReferenceId': instance.userReferenceId,
      'category': instance.category,
      'subCategory': instance.subCategory,
    };

MediaReach _$MediaReachFromJson(Map<String, dynamic> json) => MediaReach(
  totalComments: (json['totalComments'] as num?)?.toInt(),
  reactionsCount: json['reactionsCount'] as Map<String, dynamic>?,
  reactionCount: json['reactionCount'] as Map<String, dynamic>?,
  totalViews: (json['totalViews'] as num?)?.toInt(),
);

Map<String, dynamic> _$MediaReachToJson(MediaReach instance) =>
    <String, dynamic>{
      'totalComments': instance.totalComments,
      'reactionsCount': instance.reactionsCount,
      'reactionCount': instance.reactionCount,
      'totalViews': instance.totalViews,
    };

MediaResponse _$MediaResponseFromJson(Map<String, dynamic> json) =>
    MediaResponse(
      id: json['_id'] as String?,
      description: json['description'] as String?,
      documentId: (json['documentId'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      reach: json['reach'] == null
          ? null
          : MediaReach.fromJson(json['reach'] as Map<String, dynamic>),
      mentions: (json['mentions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      mediaType: json['mediaType'] as String?,
      userReferenceId: json['userReferenceId'] as String?,
      mediaUrl: json['mediaUrl'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      shortUser: json['shortUser'] == null
          ? null
          : MediaShortUser.fromJson(json['shortUser'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MediaResponseToJson(MediaResponse instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'description': instance.description,
      'documentId': instance.documentId,
      'reach': instance.reach,
      'mentions': instance.mentions,
      'mediaType': instance.mediaType,
      'userReferenceId': instance.userReferenceId,
      'mediaUrl': instance.mediaUrl,
      'createdAt': instance.createdAt?.toIso8601String(),
      'shortUser': instance.shortUser,
    };

CommentContent _$CommentContentFromJson(Map<String, dynamic> json) =>
    CommentContent(
      text: json['text'] as String?,
      mentions: (json['mentions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$CommentContentToJson(CommentContent instance) =>
    <String, dynamic>{'text': instance.text, 'mentions': instance.mentions};

CreateCommentRequest _$CreateCommentRequestFromJson(
  Map<String, dynamic> json,
) => CreateCommentRequest(
  targetId: json['targetId'] as String,
  userReferenceId: json['userReferenceId'] as String,
  type: json['type'] as String,
  content: CommentContent.fromJson(json['content'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CreateCommentRequestToJson(
  CreateCommentRequest instance,
) => <String, dynamic>{
  'targetId': instance.targetId,
  'userReferenceId': instance.userReferenceId,
  'type': instance.type,
  'content': instance.content,
};

UpdateCommentRequest _$UpdateCommentRequestFromJson(
  Map<String, dynamic> json,
) => UpdateCommentRequest(
  id: json['id'] as String,
  content: CommentContent.fromJson(json['content'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UpdateCommentRequestToJson(
  UpdateCommentRequest instance,
) => <String, dynamic>{'id': instance.id, 'content': instance.content};

CommentShortUser _$CommentShortUserFromJson(Map<String, dynamic> json) =>
    CommentShortUser(
      nickName: json['nickName'] as String?,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      userReferenceId: json['userReferenceId'] as String?,
    );

Map<String, dynamic> _$CommentShortUserToJson(CommentShortUser instance) =>
    <String, dynamic>{
      'nickName': instance.nickName,
      'profilePictureUrl': instance.profilePictureUrl,
      'userReferenceId': instance.userReferenceId,
    };

CommentResponse _$CommentResponseFromJson(Map<String, dynamic> json) =>
    CommentResponse(
      id: json['_id'] as String?,
      userReferenceId: json['userReferenceId'] as String?,
      type: json['type'] as String?,
      content: json['content'] == null
          ? null
          : CommentContent.fromJson(json['content'] as Map<String, dynamic>),
      reach: json['reach'] == null
          ? null
          : MediaReach.fromJson(json['reach'] as Map<String, dynamic>),
      shortUser: json['shortUser'] == null
          ? null
          : CommentShortUser.fromJson(
              json['shortUser'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$CommentResponseToJson(CommentResponse instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'userReferenceId': instance.userReferenceId,
      'type': instance.type,
      'content': instance.content,
      'reach': instance.reach,
      'shortUser': instance.shortUser,
    };

CreateReactionRequest _$CreateReactionRequestFromJson(
  Map<String, dynamic> json,
) => CreateReactionRequest(
  targetId: json['targetId'] as String,
  userReferenceId: json['userReferenceId'] as String,
  reactionType: json['reactionType'] as String,
);

Map<String, dynamic> _$CreateReactionRequestToJson(
  CreateReactionRequest instance,
) => <String, dynamic>{
  'targetId': instance.targetId,
  'userReferenceId': instance.userReferenceId,
  'reactionType': instance.reactionType,
};

UpdateReactionRequest _$UpdateReactionRequestFromJson(
  Map<String, dynamic> json,
) => UpdateReactionRequest(
  id: json['id'] as String,
  reactionType: json['reactionType'] as String,
);

Map<String, dynamic> _$UpdateReactionRequestToJson(
  UpdateReactionRequest instance,
) => <String, dynamic>{
  'id': instance.id,
  'reactionType': instance.reactionType,
};

ReactionResponse _$ReactionResponseFromJson(Map<String, dynamic> json) =>
    ReactionResponse(
      id: json['_id'] as String?,
      userReferenceId: json['userReferenceId'] as String?,
      reactionType: json['reactionType'] as String?,
    );

Map<String, dynamic> _$ReactionResponseToJson(ReactionResponse instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'userReferenceId': instance.userReferenceId,
      'reactionType': instance.reactionType,
    };
