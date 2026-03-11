import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/post_models.dart';

part 'post_state.freezed.dart';

enum PostStatus { initial, loading, success, error }

enum PostCreateStatus { initial, uploadingMedia, creatingPost, success, error }

@freezed
class PostState with _$PostState {
  const factory PostState({
    @Default(PostStatus.initial) PostStatus feedStatus,
    @Default([]) List<MediaResponse> feedPosts,
    @Default(1) int feedPage,
    @Default(false) bool feedHasMore,

    @Default(PostStatus.initial) PostStatus userPostsStatus,
    @Default([]) List<MediaResponse> userPosts,
    @Default(1) int userPostsPage,
    @Default(false) bool userPostsHasMore,

    @Default(PostCreateStatus.initial) PostCreateStatus createStatus,
    @Default('') String errorMessage,

    // Comments
    @Default(PostStatus.initial) PostStatus commentsStatus,
    @Default([]) List<CommentResponse> comments,
    @Default('') String commentsTargetId,
    @Default(1) int commentsPage,
    @Default(false) bool commentsHasMore,

    // Reactions
    @Default(PostStatus.initial) PostStatus reactionsStatus,
    @Default([]) List<ReactionResponse> reactions,

    // Set of targetIds that the current user has liked
    @Default({}) Set<String> likedPostIds,
  }) = _PostState;
}
