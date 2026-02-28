import 'package:json_annotation/json_annotation.dart';

part 'post_models.g.dart';

// ── Short User ──

@JsonSerializable()
class CreateShortUserRequest {
  final String nickName;
  final String profilePictureUrl;
  final String referenceId;

  const CreateShortUserRequest({
    required this.nickName,
    required this.profilePictureUrl,
    required this.referenceId,
  });

  factory CreateShortUserRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateShortUserRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateShortUserRequestToJson(this);
}

@JsonSerializable()
class UpdateShortUserRequest {
  final String referenceId;
  final String? nickName;
  final String? profilePictureUrl;

  const UpdateShortUserRequest({
    required this.referenceId,
    this.nickName,
    this.profilePictureUrl,
  });

  factory UpdateShortUserRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateShortUserRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateShortUserRequestToJson(this);
}

@JsonSerializable()
class ShortUserResponse {
  final String? nickName;
  final String? profilePictureUrl;
  final String? referenceId;

  const ShortUserResponse({this.nickName, this.profilePictureUrl, this.referenceId});

  factory ShortUserResponse.fromJson(Map<String, dynamic> json) =>
      _$ShortUserResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ShortUserResponseToJson(this);
}

// ── Media (Post / Reel / Story) ──

@JsonSerializable()
class CreateMediaRequest {
  final String? description;
  final List<String>? documentId;
  final List<String>? mentions;
  final String userReferenceId;
  final String mediaType;

  const CreateMediaRequest({
    this.description,
    this.documentId,
    this.mentions,
    required this.userReferenceId,
    required this.mediaType,
  });

  factory CreateMediaRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateMediaRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateMediaRequestToJson(this);
}

@JsonSerializable()
class UpdateMediaRequest {
  final String id;
  final String? description;
  final List<String>? mentions;
  final String? mediaType;

  const UpdateMediaRequest({
    required this.id,
    this.description,
    this.mentions,
    this.mediaType,
  });

  factory UpdateMediaRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateMediaRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateMediaRequestToJson(this);
}

@JsonSerializable()
class MediaReach {
  final int? totalComments;
  final Map<String, dynamic>? reactionsCount;
  final Map<String, dynamic>? reactionCount;
  final int? totalViews;

  const MediaReach({
    this.totalComments,
    this.reactionsCount,
    this.reactionCount,
    this.totalViews,
  });

  factory MediaReach.fromJson(Map<String, dynamic> json) =>
      _$MediaReachFromJson(json);
  Map<String, dynamic> toJson() => _$MediaReachToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.none)
class MediaResponse {
  @JsonKey(name: '_id')
  final String? id;
  final String? description;
  final List<String>? documentId;
  final MediaReach? reach;
  final List<String>? mentions;
  final String? mediaType;
  final String? userReferenceId;

  const MediaResponse({
    this.id,
    this.description,
    this.documentId,
    this.reach,
    this.mentions,
    this.mediaType,
    this.userReferenceId,
  });

  factory MediaResponse.fromJson(Map<String, dynamic> json) =>
      _$MediaResponseFromJson(json);
  Map<String, dynamic> toJson() => _$MediaResponseToJson(this);
}

// ── Comment ──

@JsonSerializable()
class CommentContent {
  final String? text;
  final List<String>? mentions;

  const CommentContent({this.text, this.mentions});

  factory CommentContent.fromJson(Map<String, dynamic> json) =>
      _$CommentContentFromJson(json);
  Map<String, dynamic> toJson() => _$CommentContentToJson(this);
}

@JsonSerializable()
class CreateCommentRequest {
  final String targetId;
  final String userReferenceId;
  final String type;
  final CommentContent content;

  const CreateCommentRequest({
    required this.targetId,
    required this.userReferenceId,
    required this.type,
    required this.content,
  });

  factory CreateCommentRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateCommentRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateCommentRequestToJson(this);
}

@JsonSerializable()
class UpdateCommentRequest {
  final String id;
  final CommentContent content;

  const UpdateCommentRequest({required this.id, required this.content});

  factory UpdateCommentRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateCommentRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateCommentRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.none)
class CommentResponse {
  @JsonKey(name: '_id')
  final String? id;
  final String? userReferenceId;
  final String? type;
  final CommentContent? content;
  final MediaReach? reach;

  const CommentResponse({
    this.id,
    this.userReferenceId,
    this.type,
    this.content,
    this.reach,
  });

  factory CommentResponse.fromJson(Map<String, dynamic> json) =>
      _$CommentResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CommentResponseToJson(this);
}

// ── Reaction ──

@JsonSerializable()
class CreateReactionRequest {
  final String targetId;
  final String userReferenceId;
  final String reactionType;

  const CreateReactionRequest({
    required this.targetId,
    required this.userReferenceId,
    required this.reactionType,
  });

  factory CreateReactionRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateReactionRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateReactionRequestToJson(this);
}

@JsonSerializable()
class UpdateReactionRequest {
  final String id;
  final String reactionType;

  const UpdateReactionRequest({required this.id, required this.reactionType});

  factory UpdateReactionRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateReactionRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateReactionRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.none)
class ReactionResponse {
  @JsonKey(name: '_id')
  final String? id;
  final String? userReferenceId;
  final String? reactionType;

  const ReactionResponse({this.id, this.userReferenceId, this.reactionType});

  factory ReactionResponse.fromJson(Map<String, dynamic> json) =>
      _$ReactionResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ReactionResponseToJson(this);
}
