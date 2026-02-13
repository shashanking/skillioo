import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/custom_text.dart'; // Ensure correct path

// Simple Data Model for a Comment
class CommentModel {
  final String id;
  final String username;
  final String userImage;
  final String text;
  final int likes;
  final bool isLiked;
  // To distinguish between the gradient style and dark style cards shown in image
  final bool isTopComment;

  CommentModel({
    required this.id,
    required this.username,
    required this.userImage,
    required this.text,
    this.likes = 0,
    this.isLiked = false,
    this.isTopComment = false,
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

  // Initial dummy data matching the image roughly
  final List<CommentModel> _comments = [
    CommentModel(
      id: '1',
      username: 'Lisa Dancer',
      userImage: 'assets/images/post-img.jpg', // Use your assets
      text: 'You’re improving every day, love to see it!',
      likes: 20,
      isLiked: true,
      isTopComment: true,
    ),
    CommentModel(
      id: '2',
      username: 'SamSinger',
      userImage: 'assets/images/professional-profile.jpg', // Replace with asset
      text: 'Why is this better than my whole life?',
      likes: 15,
      isLiked: false,
      isTopComment: true,
    ),
    CommentModel(
      id: '3',
      username: 'Alex Beats',
      userImage: 'assets/images/profile-img-1.jpg',
      text: 'That high note at the end was incredible! 🔥',
      likes: 4,
      isLiked: false,
      isTopComment: false,
    ),
  ];

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Function to add a new comment locally
  void _handleSendComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      // Add new comment to the top of the list
      _comments.insert(
        0,
        CommentModel(
          id: DateTime.now().toString(),
          // Using current user info (hardcoded for demo)
          username: 'Lisa Dancer',
          userImage: 'assets/images/skilled-profile.jpg',
          text: text,
          likes: 0,
          isTopComment: false, // New comments are standard style
        ),
      );
    });

    _commentController.clear();
    // Dismiss keyboard
    FocusScope.of(context).unfocus();
    // Scroll to top to see new comment
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
    // Using a Scaffold to ensure the bottom input doesn't get covered by keyboard easily
    return Scaffold(
      // Main gradient background
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4A148C), // Purple top
              Color(0xFF121212), // Dark middle
              Color(0xFF000000), // Black bottom
            ],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 1. Header
              _buildHeader(),

              // 2. Comments List
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  itemCount: _comments.length,
                  itemBuilder: (context, index) {
                    return _buildCommentCard(_comments[index]);
                  },
                ),
              ),

              // 3. Input Section
              _buildInputSection(),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widgets ---

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.15),
              ),
              child: Icon(Icons.arrow_back, color: Colors.white, size: 20.sp),
            ),
          ),
          SizedBox(width: 20.w),
          CustomText(
            'Comments',
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildCommentCard(CommentModel comment) {
    // Determine decoration based on whether it's a "Top Comment" style or standard
    final BoxDecoration decoration = comment.isTopComment
        ? BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF6A1B9A).withValues(alpha: 0.8),
                const Color(0xFF283593).withValues(alpha: 0.8),
              ],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          )
        : BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),
            color: const Color(
              0xFF1E1E2C,
            ).withValues(alpha: 0.8), // Dark glassy style
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          );

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Avatar, Name, Heart
          Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundImage: AssetImage(comment.userImage),
                backgroundColor: Colors.grey.shade800, // fallback
              ),
              SizedBox(width: 12.w),
              CustomText(
                comment.username,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              const Spacer(),
              Icon(
                comment.isLiked ? Icons.favorite : Icons.favorite_border,
                color: comment.isLiked ? Colors.redAccent : Colors.white54,
                size: 20.sp,
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Comment Text
          Padding(
            padding: EdgeInsets.only(left: 52.w), // Align with name
            child: CustomText(
              comment.text,
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.3,
            ),
          ),
          SizedBox(height: 12.h),

          // Bottom Row: Likes & Reply
          Padding(
            padding: EdgeInsets.only(left: 52.w),
            child: Row(
              children: [
                CustomText(
                  '${comment.likes} Likes',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white54,
                ),
                SizedBox(width: 16.w),
                CustomText(
                  'Reply',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(
          alpha: 0.6,
        ), // Slight background for input area
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50.h,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(30.r),
              ),
              alignment: Alignment.centerLeft,
              child: TextField(
                controller: _commentController,
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
                decoration: InputDecoration(
                  hintText: 'Share your thoughts....',
                  hintStyle: TextStyle(color: Colors.white54, fontSize: 14.sp),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onSubmitted: (_) => _handleSendComment(),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          // Send Button
          GestureDetector(
            onTap: _handleSendComment,
            child: Container(
              width: 50.h,
              height: 50.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF05DAF1), Color(0xFFC00F8B)],
                ),
              ),
              child: Icon(Icons.send_rounded, color: Colors.white, size: 22.sp),
            ),
          ),
        ],
      ),
    );
  }
}
