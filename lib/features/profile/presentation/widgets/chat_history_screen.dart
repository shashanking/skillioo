import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../constants/app_constants.dart';
import '../../../../core/widgets/common_background.dart';
import '../../../../core/widgets/custom_text.dart';
import '../../../../core/widgets/icon_button.dart';

class ChatHistoryScreen extends StatelessWidget {
  const ChatHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CommonBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
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
                      AppStrings.chatHistory,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Neue',
                      color: AppColors.foundationBlack20,
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 24.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Today
                      CustomText(
                        AppStrings.today,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Neue',
                        color: AppColors.foundationBlack20,
                      ),
                      SizedBox(height: 12.h),
                      _buildChatGroup([
                        _ChatItem(
                          name: 'Lisa Dancer',
                          duration: '${AppStrings.chatLastedFor} 20 ${AppStrings.mins}',
                          avatar: AppAssets.professionalProfileJpg,
                        ),
                        _ChatItem(
                          name: 'SamSinger',
                          duration: '${AppStrings.chatLastedFor} 20 ${AppStrings.mins}',
                          avatar: AppAssets.skilledProfileJpg,
                        ),
                        _ChatItem(
                          name: 'Lisa Dancer',
                          duration: '${AppStrings.chatLastedFor} 1 ${AppStrings.hour}',
                          avatar: AppAssets.professionalProfileJpg,
                        ),
                      ]),
                      SizedBox(height: 24.h),
                      // Yesterday
                      CustomText(
                        AppStrings.yesterday,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Neue',
                        color: AppColors.foundationBlack20,
                      ),
                      SizedBox(height: 12.h),
                      _buildChatGroup([
                        _ChatItem(
                          name: 'SamSinger',
                          duration: '${AppStrings.chatLastedFor} 5 ${AppStrings.mins}',
                          avatar: AppAssets.skilledProfileJpg,
                        ),
                        _ChatItem(
                          name: 'Lisa Dancer',
                          duration: '${AppStrings.chatLastedFor} 20 ${AppStrings.mins}',
                          avatar: AppAssets.professionalProfileJpg,
                        ),
                        _ChatItem(
                          name: 'Lisa Dancer',
                          duration: '${AppStrings.chatLastedFor} 1 ${AppStrings.hour}',
                          avatar: AppAssets.professionalProfileJpg,
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatGroup(List<_ChatItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassWhite06,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return _buildChatTile(
            item,
            isFirst: index == 0,
            isLast: index == items.length - 1,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChatTile(
    _ChatItem item, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: AppColors.glassWhite12,
                  width: 0.5,
                ),
              ),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage(item.avatar),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  item.name,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.foundationBlack20,
                ),
                SizedBox(height: 4.h),
                CustomText(
                  item.duration,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.foundationBlack80,
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: AppColors.foundationBlack20,
            size: 24.sp,
          ),
        ],
      ),
    );
  }
}

class _ChatItem {
  final String name;
  final String duration;
  final String avatar;

  const _ChatItem({
    required this.name,
    required this.duration,
    required this.avatar,
  });
}
