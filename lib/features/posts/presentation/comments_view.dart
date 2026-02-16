import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/app_constants.dart';
import '../../../core/widgets/common_background.dart';
import '../../../core/widgets/custom_text.dart';
import '../../../core/widgets/icon_button.dart';

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

class CommentsScreen extends StatefulWidget {
  const CommentsScreen({super.key});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<CommentModel> _comments = [
    CommentModel(
      id: '1',
      username: 'Lisa Dancer',
      userImage: AppAssets.professionalProfileJpg,
      text: "You\u2019re improving every day, love to see it!",
      likes: 20,
      isLiked: true,
    ),
    CommentModel(
      id: '2',
      username: 'SamSinger',
      userImage: AppAssets.skilledProfileJpg,
      text: 'Why is this better than my whole life?',
      likes: 15,
      isLiked: false,
    ),
    CommentModel(
      id: '3',
      username: 'Lisa Dancer',
      userImage: AppAssets.professionalProfileJpg,
      text: "You\u2019re improving every day, love to see it!",
      likes: 20,
      isLiked: true,
    ),
  ];

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSendComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _comments.insert(
        0,
        CommentModel(
          id: DateTime.now().toString(),
          username: 'Lisa Dancer',
          userImage: AppAssets.skilledProfileJpg,
          text: text,
          likes: 0,
        ),
      );
    });

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: CommonBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 24.h,
                  ),
                  itemCount: _comments.length,
                  itemBuilder: (context, index) {
                    return _buildCommentCard(_comments[index]);
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

  Widget _buildCommentCard(CommentModel comment) {
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
                  image: DecorationImage(
                    image: AssetImage(comment.userImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 24.w),
              Expanded(
                child: CustomText(
                  comment.username,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Neue',
                  color: AppColors.foundationBlack20,
                ),
              ),
              IconCircleButton(
                icon: comment.isLiked ? Icons.favorite : Icons.favorite_border,
                onTap: () {},
              ),
            ],
          ),
          SizedBox(height: 12.h),
          CustomText(
            comment.text,
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.foundationBlack20,
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              CustomText(
                '${comment.likes} ${AppStrings.likes}',
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
                onTap: _handleSendComment,
                child: Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: Icon(
                    Icons.send_rounded,
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
