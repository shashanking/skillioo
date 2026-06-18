// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$PostState {
  PostStatus get feedStatus => throw _privateConstructorUsedError;
  List<MediaResponse> get feedPosts => throw _privateConstructorUsedError;
  int get feedPage => throw _privateConstructorUsedError;
  bool get feedHasMore => throw _privateConstructorUsedError;
  PostStatus get userPostsStatus => throw _privateConstructorUsedError;
  List<MediaResponse> get userPosts => throw _privateConstructorUsedError;
  int get userPostsPage => throw _privateConstructorUsedError;
  bool get userPostsHasMore => throw _privateConstructorUsedError;
  PostCreateStatus get createStatus => throw _privateConstructorUsedError;
  String get errorMessage => throw _privateConstructorUsedError; // Comments
  PostStatus get commentsStatus => throw _privateConstructorUsedError;
  List<CommentResponse> get comments => throw _privateConstructorUsedError;
  String get commentsTargetId => throw _privateConstructorUsedError;
  int get commentsPage => throw _privateConstructorUsedError;
  bool get commentsHasMore =>
      throw _privateConstructorUsedError; // Replies keyed by parent comment ID
  Map<String, List<CommentResponse>> get commentReplies =>
      throw _privateConstructorUsedError;
  Map<String, PostStatus> get commentRepliesStatus =>
      throw _privateConstructorUsedError; // Set of comment IDs that the current user has liked
  Set<String> get likedCommentIds =>
      throw _privateConstructorUsedError; // Reactions
  PostStatus get reactionsStatus => throw _privateConstructorUsedError;
  List<ReactionResponse> get reactions =>
      throw _privateConstructorUsedError; // Set of targetIds that the current user has liked
  Set<String> get likedPostIds => throw _privateConstructorUsedError;

  /// Create a copy of PostState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PostStateCopyWith<PostState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PostStateCopyWith<$Res> {
  factory $PostStateCopyWith(PostState value, $Res Function(PostState) then) =
      _$PostStateCopyWithImpl<$Res, PostState>;
  @useResult
  $Res call({
    PostStatus feedStatus,
    List<MediaResponse> feedPosts,
    int feedPage,
    bool feedHasMore,
    PostStatus userPostsStatus,
    List<MediaResponse> userPosts,
    int userPostsPage,
    bool userPostsHasMore,
    PostCreateStatus createStatus,
    String errorMessage,
    PostStatus commentsStatus,
    List<CommentResponse> comments,
    String commentsTargetId,
    int commentsPage,
    bool commentsHasMore,
    Map<String, List<CommentResponse>> commentReplies,
    Map<String, PostStatus> commentRepliesStatus,
    Set<String> likedCommentIds,
    PostStatus reactionsStatus,
    List<ReactionResponse> reactions,
    Set<String> likedPostIds,
  });
}

/// @nodoc
class _$PostStateCopyWithImpl<$Res, $Val extends PostState>
    implements $PostStateCopyWith<$Res> {
  _$PostStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PostState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? feedStatus = null,
    Object? feedPosts = null,
    Object? feedPage = null,
    Object? feedHasMore = null,
    Object? userPostsStatus = null,
    Object? userPosts = null,
    Object? userPostsPage = null,
    Object? userPostsHasMore = null,
    Object? createStatus = null,
    Object? errorMessage = null,
    Object? commentsStatus = null,
    Object? comments = null,
    Object? commentsTargetId = null,
    Object? commentsPage = null,
    Object? commentsHasMore = null,
    Object? commentReplies = null,
    Object? commentRepliesStatus = null,
    Object? likedCommentIds = null,
    Object? reactionsStatus = null,
    Object? reactions = null,
    Object? likedPostIds = null,
  }) {
    return _then(
      _value.copyWith(
            feedStatus: null == feedStatus
                ? _value.feedStatus
                : feedStatus // ignore: cast_nullable_to_non_nullable
                      as PostStatus,
            feedPosts: null == feedPosts
                ? _value.feedPosts
                : feedPosts // ignore: cast_nullable_to_non_nullable
                      as List<MediaResponse>,
            feedPage: null == feedPage
                ? _value.feedPage
                : feedPage // ignore: cast_nullable_to_non_nullable
                      as int,
            feedHasMore: null == feedHasMore
                ? _value.feedHasMore
                : feedHasMore // ignore: cast_nullable_to_non_nullable
                      as bool,
            userPostsStatus: null == userPostsStatus
                ? _value.userPostsStatus
                : userPostsStatus // ignore: cast_nullable_to_non_nullable
                      as PostStatus,
            userPosts: null == userPosts
                ? _value.userPosts
                : userPosts // ignore: cast_nullable_to_non_nullable
                      as List<MediaResponse>,
            userPostsPage: null == userPostsPage
                ? _value.userPostsPage
                : userPostsPage // ignore: cast_nullable_to_non_nullable
                      as int,
            userPostsHasMore: null == userPostsHasMore
                ? _value.userPostsHasMore
                : userPostsHasMore // ignore: cast_nullable_to_non_nullable
                      as bool,
            createStatus: null == createStatus
                ? _value.createStatus
                : createStatus // ignore: cast_nullable_to_non_nullable
                      as PostCreateStatus,
            errorMessage: null == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String,
            commentsStatus: null == commentsStatus
                ? _value.commentsStatus
                : commentsStatus // ignore: cast_nullable_to_non_nullable
                      as PostStatus,
            comments: null == comments
                ? _value.comments
                : comments // ignore: cast_nullable_to_non_nullable
                      as List<CommentResponse>,
            commentsTargetId: null == commentsTargetId
                ? _value.commentsTargetId
                : commentsTargetId // ignore: cast_nullable_to_non_nullable
                      as String,
            commentsPage: null == commentsPage
                ? _value.commentsPage
                : commentsPage // ignore: cast_nullable_to_non_nullable
                      as int,
            commentsHasMore: null == commentsHasMore
                ? _value.commentsHasMore
                : commentsHasMore // ignore: cast_nullable_to_non_nullable
                      as bool,
            commentReplies: null == commentReplies
                ? _value.commentReplies
                : commentReplies // ignore: cast_nullable_to_non_nullable
                      as Map<String, List<CommentResponse>>,
            commentRepliesStatus: null == commentRepliesStatus
                ? _value.commentRepliesStatus
                : commentRepliesStatus // ignore: cast_nullable_to_non_nullable
                      as Map<String, PostStatus>,
            likedCommentIds: null == likedCommentIds
                ? _value.likedCommentIds
                : likedCommentIds // ignore: cast_nullable_to_non_nullable
                      as Set<String>,
            reactionsStatus: null == reactionsStatus
                ? _value.reactionsStatus
                : reactionsStatus // ignore: cast_nullable_to_non_nullable
                      as PostStatus,
            reactions: null == reactions
                ? _value.reactions
                : reactions // ignore: cast_nullable_to_non_nullable
                      as List<ReactionResponse>,
            likedPostIds: null == likedPostIds
                ? _value.likedPostIds
                : likedPostIds // ignore: cast_nullable_to_non_nullable
                      as Set<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PostStateImplCopyWith<$Res>
    implements $PostStateCopyWith<$Res> {
  factory _$$PostStateImplCopyWith(
    _$PostStateImpl value,
    $Res Function(_$PostStateImpl) then,
  ) = __$$PostStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    PostStatus feedStatus,
    List<MediaResponse> feedPosts,
    int feedPage,
    bool feedHasMore,
    PostStatus userPostsStatus,
    List<MediaResponse> userPosts,
    int userPostsPage,
    bool userPostsHasMore,
    PostCreateStatus createStatus,
    String errorMessage,
    PostStatus commentsStatus,
    List<CommentResponse> comments,
    String commentsTargetId,
    int commentsPage,
    bool commentsHasMore,
    Map<String, List<CommentResponse>> commentReplies,
    Map<String, PostStatus> commentRepliesStatus,
    Set<String> likedCommentIds,
    PostStatus reactionsStatus,
    List<ReactionResponse> reactions,
    Set<String> likedPostIds,
  });
}

/// @nodoc
class __$$PostStateImplCopyWithImpl<$Res>
    extends _$PostStateCopyWithImpl<$Res, _$PostStateImpl>
    implements _$$PostStateImplCopyWith<$Res> {
  __$$PostStateImplCopyWithImpl(
    _$PostStateImpl _value,
    $Res Function(_$PostStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PostState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? feedStatus = null,
    Object? feedPosts = null,
    Object? feedPage = null,
    Object? feedHasMore = null,
    Object? userPostsStatus = null,
    Object? userPosts = null,
    Object? userPostsPage = null,
    Object? userPostsHasMore = null,
    Object? createStatus = null,
    Object? errorMessage = null,
    Object? commentsStatus = null,
    Object? comments = null,
    Object? commentsTargetId = null,
    Object? commentsPage = null,
    Object? commentsHasMore = null,
    Object? commentReplies = null,
    Object? commentRepliesStatus = null,
    Object? likedCommentIds = null,
    Object? reactionsStatus = null,
    Object? reactions = null,
    Object? likedPostIds = null,
  }) {
    return _then(
      _$PostStateImpl(
        feedStatus: null == feedStatus
            ? _value.feedStatus
            : feedStatus // ignore: cast_nullable_to_non_nullable
                  as PostStatus,
        feedPosts: null == feedPosts
            ? _value._feedPosts
            : feedPosts // ignore: cast_nullable_to_non_nullable
                  as List<MediaResponse>,
        feedPage: null == feedPage
            ? _value.feedPage
            : feedPage // ignore: cast_nullable_to_non_nullable
                  as int,
        feedHasMore: null == feedHasMore
            ? _value.feedHasMore
            : feedHasMore // ignore: cast_nullable_to_non_nullable
                  as bool,
        userPostsStatus: null == userPostsStatus
            ? _value.userPostsStatus
            : userPostsStatus // ignore: cast_nullable_to_non_nullable
                  as PostStatus,
        userPosts: null == userPosts
            ? _value._userPosts
            : userPosts // ignore: cast_nullable_to_non_nullable
                  as List<MediaResponse>,
        userPostsPage: null == userPostsPage
            ? _value.userPostsPage
            : userPostsPage // ignore: cast_nullable_to_non_nullable
                  as int,
        userPostsHasMore: null == userPostsHasMore
            ? _value.userPostsHasMore
            : userPostsHasMore // ignore: cast_nullable_to_non_nullable
                  as bool,
        createStatus: null == createStatus
            ? _value.createStatus
            : createStatus // ignore: cast_nullable_to_non_nullable
                  as PostCreateStatus,
        errorMessage: null == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String,
        commentsStatus: null == commentsStatus
            ? _value.commentsStatus
            : commentsStatus // ignore: cast_nullable_to_non_nullable
                  as PostStatus,
        comments: null == comments
            ? _value._comments
            : comments // ignore: cast_nullable_to_non_nullable
                  as List<CommentResponse>,
        commentsTargetId: null == commentsTargetId
            ? _value.commentsTargetId
            : commentsTargetId // ignore: cast_nullable_to_non_nullable
                  as String,
        commentsPage: null == commentsPage
            ? _value.commentsPage
            : commentsPage // ignore: cast_nullable_to_non_nullable
                  as int,
        commentsHasMore: null == commentsHasMore
            ? _value.commentsHasMore
            : commentsHasMore // ignore: cast_nullable_to_non_nullable
                  as bool,
        commentReplies: null == commentReplies
            ? _value._commentReplies
            : commentReplies // ignore: cast_nullable_to_non_nullable
                  as Map<String, List<CommentResponse>>,
        commentRepliesStatus: null == commentRepliesStatus
            ? _value._commentRepliesStatus
            : commentRepliesStatus // ignore: cast_nullable_to_non_nullable
                  as Map<String, PostStatus>,
        likedCommentIds: null == likedCommentIds
            ? _value._likedCommentIds
            : likedCommentIds // ignore: cast_nullable_to_non_nullable
                  as Set<String>,
        reactionsStatus: null == reactionsStatus
            ? _value.reactionsStatus
            : reactionsStatus // ignore: cast_nullable_to_non_nullable
                  as PostStatus,
        reactions: null == reactions
            ? _value._reactions
            : reactions // ignore: cast_nullable_to_non_nullable
                  as List<ReactionResponse>,
        likedPostIds: null == likedPostIds
            ? _value._likedPostIds
            : likedPostIds // ignore: cast_nullable_to_non_nullable
                  as Set<String>,
      ),
    );
  }
}

/// @nodoc

class _$PostStateImpl implements _PostState {
  const _$PostStateImpl({
    this.feedStatus = PostStatus.initial,
    final List<MediaResponse> feedPosts = const [],
    this.feedPage = 1,
    this.feedHasMore = false,
    this.userPostsStatus = PostStatus.initial,
    final List<MediaResponse> userPosts = const [],
    this.userPostsPage = 1,
    this.userPostsHasMore = false,
    this.createStatus = PostCreateStatus.initial,
    this.errorMessage = '',
    this.commentsStatus = PostStatus.initial,
    final List<CommentResponse> comments = const [],
    this.commentsTargetId = '',
    this.commentsPage = 1,
    this.commentsHasMore = false,
    final Map<String, List<CommentResponse>> commentReplies = const {},
    final Map<String, PostStatus> commentRepliesStatus = const {},
    final Set<String> likedCommentIds = const {},
    this.reactionsStatus = PostStatus.initial,
    final List<ReactionResponse> reactions = const [],
    final Set<String> likedPostIds = const {},
  }) : _feedPosts = feedPosts,
       _userPosts = userPosts,
       _comments = comments,
       _commentReplies = commentReplies,
       _commentRepliesStatus = commentRepliesStatus,
       _likedCommentIds = likedCommentIds,
       _reactions = reactions,
       _likedPostIds = likedPostIds;

  @override
  @JsonKey()
  final PostStatus feedStatus;
  final List<MediaResponse> _feedPosts;
  @override
  @JsonKey()
  List<MediaResponse> get feedPosts {
    if (_feedPosts is EqualUnmodifiableListView) return _feedPosts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_feedPosts);
  }

  @override
  @JsonKey()
  final int feedPage;
  @override
  @JsonKey()
  final bool feedHasMore;
  @override
  @JsonKey()
  final PostStatus userPostsStatus;
  final List<MediaResponse> _userPosts;
  @override
  @JsonKey()
  List<MediaResponse> get userPosts {
    if (_userPosts is EqualUnmodifiableListView) return _userPosts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_userPosts);
  }

  @override
  @JsonKey()
  final int userPostsPage;
  @override
  @JsonKey()
  final bool userPostsHasMore;
  @override
  @JsonKey()
  final PostCreateStatus createStatus;
  @override
  @JsonKey()
  final String errorMessage;
  // Comments
  @override
  @JsonKey()
  final PostStatus commentsStatus;
  final List<CommentResponse> _comments;
  @override
  @JsonKey()
  List<CommentResponse> get comments {
    if (_comments is EqualUnmodifiableListView) return _comments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_comments);
  }

  @override
  @JsonKey()
  final String commentsTargetId;
  @override
  @JsonKey()
  final int commentsPage;
  @override
  @JsonKey()
  final bool commentsHasMore;
  // Replies keyed by parent comment ID
  final Map<String, List<CommentResponse>> _commentReplies;
  // Replies keyed by parent comment ID
  @override
  @JsonKey()
  Map<String, List<CommentResponse>> get commentReplies {
    if (_commentReplies is EqualUnmodifiableMapView) return _commentReplies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_commentReplies);
  }

  final Map<String, PostStatus> _commentRepliesStatus;
  @override
  @JsonKey()
  Map<String, PostStatus> get commentRepliesStatus {
    if (_commentRepliesStatus is EqualUnmodifiableMapView)
      return _commentRepliesStatus;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_commentRepliesStatus);
  }

  // Set of comment IDs that the current user has liked
  final Set<String> _likedCommentIds;
  // Set of comment IDs that the current user has liked
  @override
  @JsonKey()
  Set<String> get likedCommentIds {
    if (_likedCommentIds is EqualUnmodifiableSetView) return _likedCommentIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_likedCommentIds);
  }

  // Reactions
  @override
  @JsonKey()
  final PostStatus reactionsStatus;
  final List<ReactionResponse> _reactions;
  @override
  @JsonKey()
  List<ReactionResponse> get reactions {
    if (_reactions is EqualUnmodifiableListView) return _reactions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_reactions);
  }

  // Set of targetIds that the current user has liked
  final Set<String> _likedPostIds;
  // Set of targetIds that the current user has liked
  @override
  @JsonKey()
  Set<String> get likedPostIds {
    if (_likedPostIds is EqualUnmodifiableSetView) return _likedPostIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_likedPostIds);
  }

  @override
  String toString() {
    return 'PostState(feedStatus: $feedStatus, feedPosts: $feedPosts, feedPage: $feedPage, feedHasMore: $feedHasMore, userPostsStatus: $userPostsStatus, userPosts: $userPosts, userPostsPage: $userPostsPage, userPostsHasMore: $userPostsHasMore, createStatus: $createStatus, errorMessage: $errorMessage, commentsStatus: $commentsStatus, comments: $comments, commentsTargetId: $commentsTargetId, commentsPage: $commentsPage, commentsHasMore: $commentsHasMore, commentReplies: $commentReplies, commentRepliesStatus: $commentRepliesStatus, likedCommentIds: $likedCommentIds, reactionsStatus: $reactionsStatus, reactions: $reactions, likedPostIds: $likedPostIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PostStateImpl &&
            (identical(other.feedStatus, feedStatus) ||
                other.feedStatus == feedStatus) &&
            const DeepCollectionEquality().equals(
              other._feedPosts,
              _feedPosts,
            ) &&
            (identical(other.feedPage, feedPage) ||
                other.feedPage == feedPage) &&
            (identical(other.feedHasMore, feedHasMore) ||
                other.feedHasMore == feedHasMore) &&
            (identical(other.userPostsStatus, userPostsStatus) ||
                other.userPostsStatus == userPostsStatus) &&
            const DeepCollectionEquality().equals(
              other._userPosts,
              _userPosts,
            ) &&
            (identical(other.userPostsPage, userPostsPage) ||
                other.userPostsPage == userPostsPage) &&
            (identical(other.userPostsHasMore, userPostsHasMore) ||
                other.userPostsHasMore == userPostsHasMore) &&
            (identical(other.createStatus, createStatus) ||
                other.createStatus == createStatus) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.commentsStatus, commentsStatus) ||
                other.commentsStatus == commentsStatus) &&
            const DeepCollectionEquality().equals(other._comments, _comments) &&
            (identical(other.commentsTargetId, commentsTargetId) ||
                other.commentsTargetId == commentsTargetId) &&
            (identical(other.commentsPage, commentsPage) ||
                other.commentsPage == commentsPage) &&
            (identical(other.commentsHasMore, commentsHasMore) ||
                other.commentsHasMore == commentsHasMore) &&
            const DeepCollectionEquality().equals(
              other._commentReplies,
              _commentReplies,
            ) &&
            const DeepCollectionEquality().equals(
              other._commentRepliesStatus,
              _commentRepliesStatus,
            ) &&
            const DeepCollectionEquality().equals(
              other._likedCommentIds,
              _likedCommentIds,
            ) &&
            (identical(other.reactionsStatus, reactionsStatus) ||
                other.reactionsStatus == reactionsStatus) &&
            const DeepCollectionEquality().equals(
              other._reactions,
              _reactions,
            ) &&
            const DeepCollectionEquality().equals(
              other._likedPostIds,
              _likedPostIds,
            ));
  }

  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    feedStatus,
    const DeepCollectionEquality().hash(_feedPosts),
    feedPage,
    feedHasMore,
    userPostsStatus,
    const DeepCollectionEquality().hash(_userPosts),
    userPostsPage,
    userPostsHasMore,
    createStatus,
    errorMessage,
    commentsStatus,
    const DeepCollectionEquality().hash(_comments),
    commentsTargetId,
    commentsPage,
    commentsHasMore,
    const DeepCollectionEquality().hash(_commentReplies),
    const DeepCollectionEquality().hash(_commentRepliesStatus),
    const DeepCollectionEquality().hash(_likedCommentIds),
    reactionsStatus,
    const DeepCollectionEquality().hash(_reactions),
    const DeepCollectionEquality().hash(_likedPostIds),
  ]);

  /// Create a copy of PostState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PostStateImplCopyWith<_$PostStateImpl> get copyWith =>
      __$$PostStateImplCopyWithImpl<_$PostStateImpl>(this, _$identity);
}

abstract class _PostState implements PostState {
  const factory _PostState({
    final PostStatus feedStatus,
    final List<MediaResponse> feedPosts,
    final int feedPage,
    final bool feedHasMore,
    final PostStatus userPostsStatus,
    final List<MediaResponse> userPosts,
    final int userPostsPage,
    final bool userPostsHasMore,
    final PostCreateStatus createStatus,
    final String errorMessage,
    final PostStatus commentsStatus,
    final List<CommentResponse> comments,
    final String commentsTargetId,
    final int commentsPage,
    final bool commentsHasMore,
    final Map<String, List<CommentResponse>> commentReplies,
    final Map<String, PostStatus> commentRepliesStatus,
    final Set<String> likedCommentIds,
    final PostStatus reactionsStatus,
    final List<ReactionResponse> reactions,
    final Set<String> likedPostIds,
  }) = _$PostStateImpl;

  @override
  PostStatus get feedStatus;
  @override
  List<MediaResponse> get feedPosts;
  @override
  int get feedPage;
  @override
  bool get feedHasMore;
  @override
  PostStatus get userPostsStatus;
  @override
  List<MediaResponse> get userPosts;
  @override
  int get userPostsPage;
  @override
  bool get userPostsHasMore;
  @override
  PostCreateStatus get createStatus;
  @override
  String get errorMessage; // Comments
  @override
  PostStatus get commentsStatus;
  @override
  List<CommentResponse> get comments;
  @override
  String get commentsTargetId;
  @override
  int get commentsPage;
  @override
  bool get commentsHasMore; // Replies keyed by parent comment ID
  @override
  Map<String, List<CommentResponse>> get commentReplies;
  @override
  Map<String, PostStatus> get commentRepliesStatus; // Set of comment IDs that the current user has liked
  @override
  Set<String> get likedCommentIds; // Reactions
  @override
  PostStatus get reactionsStatus;
  @override
  List<ReactionResponse> get reactions; // Set of targetIds that the current user has liked
  @override
  Set<String> get likedPostIds;

  /// Create a copy of PostState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PostStateImplCopyWith<_$PostStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
