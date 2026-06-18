import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/app_constants.dart';
import '../../../core/localization/locale_extension.dart';
import '../../../core/services/session_prefs.dart';
import '../../../core/utils/hirer_gate.dart';
import '../../../core/widgets/common_background.dart';
import '../../../core/widgets/custom_text.dart';
import '../../../core/widgets/icon_button.dart';
import '../application/post_providers.dart';
import '../application/states/post_state.dart';
import '../domain/post_models.dart';

class CommentsScreen extends ConsumerStatefulWidget {
  const CommentsScreen({super.key, required this.targetId});

  final String targetId;

  @override
  ConsumerState<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocusNode = FocusNode();
  bool _isSendingComment = false;
  String _currentUserId = '';
  String _currentUserNickName = '';
  String _currentUserDisplayName = '';
  String _currentUserProfilePic = '';

  // Reply mode state
  String? _replyToCommentId;
  String? _replyToUsername;

  // Track which comments have their replies expanded
  final Set<String> _expandedReplies = {};

  @override
  void initState() {
    super.initState();
    _initScreen();
  }

  Future<void> _initScreen() async {
    final userId = (await SessionPrefs.instance.getProfileId()).trim();
    final nickName = (await SessionPrefs.instance.getNickName()).trim();
    final profile = await SessionPrefs.instance.getProfile();
    final nestedProfile =
        profile?['profile'] as Map<String, dynamic>? ?? const {};
    final source = <String, dynamic>{...?profile, ...nestedProfile};
    final profileType = (source['profileType'] as String? ?? '').trim();
    final firstName = (source['firstName'] as String? ?? '').trim();
    final lastName = (source['lastName'] as String? ?? '').trim();
    final groupName = (source['groupName'] as String? ?? '').trim();

    String displayName;
    if (profileType.toUpperCase() == 'GROUP' && groupName.isNotEmpty) {
      displayName = groupName;
    } else {
      displayName = [firstName, lastName].where((e) => e.isNotEmpty).join(' ');
    }
    if (displayName.isEmpty) displayName = nickName;

    final profilePic = (source['profilePictureUrl'] as String? ?? '').trim();

    if (!mounted) return;
    setState(() {
      _currentUserId = userId;
      _currentUserNickName = nickName;
      _currentUserDisplayName = displayName;
      _currentUserProfilePic = profilePic;
    });

    if (widget.targetId.isNotEmpty) {
      ref
          .read(postNotifierProvider.notifier)
          .fetchComments(targetId: widget.targetId, refresh: true);
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  void _enterReplyMode(String commentId, String username) {
    setState(() {
      _replyToCommentId = commentId;
      _replyToUsername = username;
    });
    _inputFocusNode.requestFocus();
  }

  void _cancelReplyMode() {
    setState(() {
      _replyToCommentId = null;
      _replyToUsername = null;
    });
  }

  Future<void> _handleSendComment() async {
    if (_isSendingComment) return;
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    if (blockIfHirer(context, ref)) return;

    final isReply = _replyToCommentId != null;
    final targetId = isReply ? _replyToCommentId! : widget.targetId;
    if (targetId.isEmpty) return;

    setState(() {
      _isSendingComment = true;
    });

    final notifier = ref.read(postNotifierProvider.notifier);
    final userShort = CommentShortUser(
      nickName: _currentUserNickName,
      profilePictureUrl: _currentUserProfilePic,
      userReferenceId: _currentUserId,
    );

    bool success;
    if (isReply) {
      success = await notifier.createReply(
        commentId: targetId,
        text: text,
        currentUserShort: userShort,
      );
    } else {
      success = await notifier.createComment(
        targetId: targetId,
        text: text,
        currentUserShort: userShort,
      );
    }

    if (!mounted) return;
    setState(() {
      _isSendingComment = false;
    });

    if (success) {
      _commentController.clear();
      if (isReply) {
        // Expand replies for this comment and exit reply mode
        _expandedReplies.add(_replyToCommentId!);
        _cancelReplyMode();
      } else {
        FocusScope.of(context).unfocus();
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      }
    }
  }

  void _toggleReplies(String commentId) {
    setState(() {
      if (_expandedReplies.contains(commentId)) {
        _expandedReplies.remove(commentId);
      } else {
        _expandedReplies.add(commentId);
        // Fetch replies if not already loaded
        final postState = ref.read(postNotifierProvider);
        if (!postState.commentReplies.containsKey(commentId)) {
          ref
              .read(postNotifierProvider.notifier)
              .fetchReplies(commentId: commentId);
        }
      }
    });
  }

  void _handleCommentLike(String commentId) {
    if (blockIfHirer(context, ref)) return;
    ref.read(postNotifierProvider.notifier).toggleCommentLike(
          commentId: commentId,
        );
  }

  bool _isCurrentUser(String userRef) {
    if (userRef.isEmpty) return false;
    if (_currentUserId.isNotEmpty && userRef == _currentUserId) return true;
    if (_currentUserNickName.isNotEmpty && userRef == _currentUserNickName) {
      return true;
    }
    return false;
  }

  String _resolveAuthorLabel(CommentResponse comment) {
    final userRef = (comment.shortUser?.userReferenceId ??
            comment.userReferenceId ??
            '')
        .trim();
    if (userRef.isEmpty) return 'User';
    if (_isCurrentUser(userRef)) {
      return _currentUserDisplayName.isNotEmpty
          ? _currentUserDisplayName
          : 'You';
    }
    final nickName = (comment.shortUser?.nickName ?? '').trim();
    if (nickName.isNotEmpty) return nickName;
    if (RegExp(r'^[a-f0-9]{24}$').hasMatch(userRef)) {
      return 'User';
    }
    return userRef;
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.tr;
    final postState = ref.watch(postNotifierProvider);
    final comments = postState.comments;
    final isLoading = postState.commentsStatus == PostStatus.loading;
    final hasTargetId = widget.targetId.isNotEmpty;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: CommonBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: !hasTargetId
                    ? Center(
                        child: CustomText(
                          tr.noCommentsYet,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.foundationBlack80,
                        ),
                      )
                    : isLoading && comments.isEmpty
                        ? Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          )
                        : comments.isEmpty
                            ? Center(
                                child: CustomText(
                                  tr.noCommentsYet,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.foundationBlack80,
                                ),
                              )
                            : ListView.builder(
                                controller: _scrollController,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 24.h,
                                ),
                                itemCount: comments.length,
                                itemBuilder: (context, index) {
                                  return _buildCommentCard(
                                    comments[index],
                                    postState,
                                  );
                                },
                              ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(28.r),
                ),
                child: _buildInputSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      decoration: BoxDecoration(color: AppColors.glassWhite12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconCircleButton(
            assetPath: 'assets/images/arrow-left.png',
            onTap: () => Navigator.of(context).maybePop(),
          ),
          SizedBox(width: 24.w),
          CustomText(
            ref.tr.comments,
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            fontFamily: 'Neue',
            color: AppColors.foundationBlack20,
          ),
        ],
      ),
    );
  }

  Widget _buildCommentCard(CommentResponse comment, PostState postState) {
    final commentId = comment.id ?? '';
    final username = _resolveAuthorLabel(comment);
    final text = comment.content?.text ?? '';
    final profilePicUrl =
        (comment.shortUser?.profilePictureUrl ?? '').trim();
    final totalLikes = comment.reach?.reactionsCount?['like'] as int? ??
        comment.reach?.reactionCount?['like'] as int? ??
        0;
    final isLiked = commentId.isNotEmpty &&
        postState.likedCommentIds.contains(commentId);
    final totalComments = comment.reach?.totalComments ?? 0;

    final isExpanded =
        commentId.isNotEmpty && _expandedReplies.contains(commentId);
    final replies = postState.commentReplies[commentId] ?? [];
    final repliesStatus = postState.commentRepliesStatus[commentId];

    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.glassWhite12,
        borderRadius: BorderRadius.circular(28.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Comment header row
          Row(
            children: [
              _buildAvatar(profilePicUrl, 48.w),
              SizedBox(width: 8.w),
              Expanded(
                child: CustomText(
                  username,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Neue',
                  color: AppColors.foundationBlack20,
                ),
              ),
              _buildLikeButton(
                commentId: commentId,
                isLiked: isLiked,
                size: 24.w,
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Comment text
          CustomText(
            text,
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.foundationBlack20,
          ),

          SizedBox(height: 12.h),

          // Actions row: likes count, reply button
          Row(
            children: [
              CustomText(
                '$totalLikes ${ref.tr.likes}',
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.foundationBlack100,
              ),
              SizedBox(width: 24.w),
              GestureDetector(
                onTap: commentId.isNotEmpty
                    ? () => _enterReplyMode(commentId, username)
                    : null,
                child: CustomText(
                  ref.tr.reply,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.foundationBlack20,
                ),
              ),
            ],
          ),

          // View replies toggle
          if (commentId.isNotEmpty && totalComments > 0) ...[
            SizedBox(height: 12.h),
            GestureDetector(
              onTap: () => _toggleReplies(commentId),
              child: Row(
                children: [
                  Container(
                    width: 24.w,
                    height: 1,
                    color: AppColors.foundationBlack80,
                  ),
                  SizedBox(width: 8.w),
                  CustomText(
                    isExpanded
                        ? 'Hide replies'
                        : 'View $totalComments ${totalComments == 1 ? 'reply' : 'replies'}',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.foundationBlack80,
                  ),
                ],
              ),
            ),
          ],

          // Also allow viewing replies even if totalComments is 0 but replies exist locally
          if (commentId.isNotEmpty &&
              totalComments == 0 &&
              replies.isNotEmpty) ...[
            SizedBox(height: 12.h),
            GestureDetector(
              onTap: () => _toggleReplies(commentId),
              child: Row(
                children: [
                  Container(
                    width: 24.w,
                    height: 1,
                    color: AppColors.foundationBlack80,
                  ),
                  SizedBox(width: 8.w),
                  CustomText(
                    isExpanded
                        ? 'Hide replies'
                        : 'View ${replies.length} ${replies.length == 1 ? 'reply' : 'replies'}',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.foundationBlack80,
                  ),
                ],
              ),
            ),
          ],

          // Expanded replies section
          if (isExpanded) ...[
            SizedBox(height: 16.h),
            if (repliesStatus == PostStatus.loading && replies.isEmpty)
              Padding(
                padding: EdgeInsets.only(left: 32.w),
                child: SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              )
            else
              ...replies.map((reply) => _buildReplyCard(reply, postState)),
          ],
        ],
      ),
    );
  }

  Widget _buildReplyCard(CommentResponse reply, PostState postState) {
    final replyId = reply.id ?? '';
    final username = _resolveAuthorLabel(reply);
    final text = reply.content?.text ?? '';
    final profilePicUrl =
        (reply.shortUser?.profilePictureUrl ?? '').trim();
    final totalLikes = reply.reach?.reactionsCount?['like'] as int? ??
        reply.reach?.reactionCount?['like'] as int? ??
        0;
    final isLiked =
        replyId.isNotEmpty && postState.likedCommentIds.contains(replyId);

    return Padding(
      padding: EdgeInsets.only(left: 32.w, bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildAvatar(profilePicUrl, 36.w),
              SizedBox(width: 8.w),
              Expanded(
                child: CustomText(
                  username,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Neue',
                  color: AppColors.foundationBlack20,
                ),
              ),
              _buildLikeButton(
                commentId: replyId,
                isLiked: isLiked,
                size: 20.w,
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.only(left: 44.w),
            child: CustomText(
              text,
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.foundationBlack20,
            ),
          ),
          SizedBox(height: 6.h),
          Padding(
            padding: EdgeInsets.only(left: 44.w),
            child: CustomText(
              '$totalLikes ${ref.tr.likes}',
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.foundationBlack100,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String profilePicUrl, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.glassWhite12,
        image: profilePicUrl.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(profilePicUrl),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: profilePicUrl.isEmpty
          ? Icon(
              Icons.person,
              color: AppColors.foundationBlack80,
              size: size * 0.5,
            )
          : null,
    );
  }

  Widget _buildLikeButton({
    required String commentId,
    required bool isLiked,
    required double size,
  }) {
    return GestureDetector(
      onTap: commentId.isNotEmpty ? () => _handleCommentLike(commentId) : null,
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: AppColors.glassWhite12,
          shape: BoxShape.circle,
        ),
        child: isLiked
            ? Icon(
                Icons.favorite,
                color: Colors.redAccent,
                size: size,
              )
            : Image.asset(
                'assets/images/like.png',
                width: size,
                height: size,
              ),
      ),
    );
  }

  Widget _buildInputSection() {
    final isReplyMode = _replyToCommentId != null;

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.foundationBlack800,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(48.r),
          topRight: Radius.circular(48.r),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Reply indicator
            if (isReplyMode)
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 12.w, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomText(
                        'Replying to @$_replyToUsername',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.foundationBlack80,
                      ),
                    ),
                    GestureDetector(
                      onTap: _cancelReplyMode,
                      child: Padding(
                        padding: EdgeInsets.all(4.w),
                        child: Icon(
                          Icons.close,
                          color: AppColors.foundationBlack80,
                          size: 18.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(height: 12.h),

            // Input field
            Container(
              height: 56.h,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(
                color: AppColors.glassWhite12,
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      focusNode: _inputFocusNode,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.foundationBlack20,
                      ),
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        hintText: isReplyMode
                            ? 'Write a reply...'
                            : ref.tr.shareYourThoughts,
                        hintStyle: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.foundationHint,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onSubmitted: (_) => _handleSendComment(),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  GestureDetector(
                    onTap: _isSendingComment ? null : _handleSendComment,
                    child: Container(
                      width: 44.w,
                      height: 44.w,
                      decoration:
                          const BoxDecoration(shape: BoxShape.circle),
                      child: _isSendingComment
                          ? Icon(
                              Icons.hourglass_top_rounded,
                              color: AppColors.foundationBlack20,
                              size: 22.sp,
                            )
                          : Image.asset(
                              'assets/images/send.png',
                              width: 22.w,
                              height: 22.w,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
