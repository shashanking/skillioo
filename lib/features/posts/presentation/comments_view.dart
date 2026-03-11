import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/app_constants.dart';
import '../../../core/services/session_prefs.dart';
import '../../../core/widgets/common_background.dart';
import '../../../core/widgets/custom_text.dart';
import '../../../core/widgets/icon_button.dart';
import '../application/post_providers.dart';
import '../application/states/post_state.dart';
import '../domain/post_models.dart';

class CommentModel {
  final String id;
  final String username;
  final String userImage;
  final String text;
  final int likes;
  final bool isLiked;

  CommentModel({
    required this.id,
    required this.username,
    required this.userImage,
    required this.text,
    this.likes = 0,
    this.isLiked = false,
  });
}

class CommentsScreen extends ConsumerStatefulWidget {
  const CommentsScreen({super.key, required this.targetId});

  final String targetId;

  @override
  ConsumerState<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSendingComment = false;
  String _currentUserId = '';
  String _currentUserNickName = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentUserIdentity();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.targetId.isEmpty) {
        return;
      }
      ref
          .read(postNotifierProvider.notifier)
          .fetchComments(targetId: widget.targetId, refresh: true);
    });
  }

  Future<void> _loadCurrentUserIdentity() async {
    final userId = (await SessionPrefs.instance.getProfileId()).trim();
    final nickName = (await SessionPrefs.instance.getNickName()).trim();
    if (!mounted) return;
    setState(() {
      _currentUserId = userId;
      _currentUserNickName = nickName;
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleSendComment() async {
    if (_isSendingComment) return;
    final text = _commentController.text.trim();
    if (text.isEmpty || widget.targetId.isEmpty) return;

    setState(() {
      _isSendingComment = true;
    });

    final success = await ref
        .read(postNotifierProvider.notifier)
        .createComment(targetId: widget.targetId, text: text);
    if (!mounted) return;
    setState(() {
      _isSendingComment = false;
    });

    if (success) {
      _commentController.clear();
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

  String _resolveAuthorLabel(CommentResponse comment) {
    final userRef = (comment.userReferenceId ?? '').trim();
    if (userRef.isEmpty) return 'User';
    if (userRef == _currentUserId || userRef == _currentUserNickName) {
      return _currentUserNickName.isNotEmpty ? _currentUserNickName : 'You';
    }
    return userRef;
  }

  @override
  Widget build(BuildContext context) {
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
                          AppStrings.noCommentsYet,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.foundationBlack80,
                        ),
                      )
                    : isLoading && comments.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : comments.isEmpty
                    ? Center(
                        child: CustomText(
                          AppStrings.noCommentsYet,
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
                          return _buildCommentCard(comments[index]);
                        },
                      ),
              ),
              _buildInputSection(),
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
            icon: Icons.arrow_back,
            onTap: () => Navigator.of(context).maybePop(),
          ),
          SizedBox(width: 24.w),
          CustomText(
            AppStrings.comments,
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            fontFamily: 'Neue',
            color: AppColors.foundationBlack20,
          ),
        ],
      ),
    );
  }

  Widget _buildCommentCard(CommentResponse comment) {
    final username = _resolveAuthorLabel(comment);
    final text = comment.content?.text ?? '';
    final totalLikes =
        comment.reach?.reactionsCount?['like'] as int? ??
        comment.reach?.reactionCount?['like'] as int? ??
        0;

    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.glassWhite12,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.glassWhite12,
                ),
                child: Icon(
                  Icons.person,
                  color: AppColors.foundationBlack80,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 24.w),
              Expanded(
                child: CustomText(
                  username,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Neue',
                  color: AppColors.foundationBlack20,
                ),
              ),
              IconCircleButton(icon: Icons.favorite_border, onTap: () {}),
            ],
          ),
          SizedBox(height: 12.h),
          CustomText(
            text,
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.foundationBlack20,
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              CustomText(
                '$totalLikes ${AppStrings.likes}',
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.foundationBlack100,
              ),
              SizedBox(width: 24.w),
              GestureDetector(
                onTap: () {},
                child: CustomText(
                  AppStrings.reply,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.foundationBlack20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.foundationBlack800,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(48.r),
          topRight: Radius.circular(48.r),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Container(
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
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.foundationBlack20,
                  ),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: AppStrings.shareYourThoughts,
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
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: Icon(
                    _isSendingComment
                        ? Icons.hourglass_top_rounded
                        : Icons.send_rounded,
                    color: AppColors.foundationBlack20,
                    size: 22.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
