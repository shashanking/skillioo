import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../constants/app_constants.dart';
import '../../../../core/widgets/common_background.dart';
import '../../../../core/widgets/custom_text.dart';
import '../../../../core/widgets/icon_button.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

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
                      AppStrings.notifications,
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
                      _buildNotificationGroup([
                        _NotificationItem(
                          avatar: AppAssets.professionalProfileJpg,
                          text: 'Lisa Dancer ${AppStrings.likedYourPost}',
                          time: '12:30 PM',
                          isUnread: true,
                        ),
                        _NotificationItem(
                          avatar: AppAssets.professionalProfileJpg,
                          text:
                              'Lisa Dancer ${AppStrings.commentedOnYourPost} - "Excellent, Keep it up!".',
                          time: '12:30 PM',
                          isUnread: true,
                        ),
                        _NotificationItem(
                          avatar: AppAssets.skilledProfileJpg,
                          text: 'Sam Basketer ${AppStrings.likedYourPost}',
                          time: '12:30 PM',
                          isUnread: false,
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
                      _buildNotificationGroup([
                        _NotificationItem(
                          avatar: AppAssets.professionalProfileJpg,
                          text: 'Lisa Dancer ${AppStrings.likedYourPost}',
                          time: '12:30 PM',
                          isUnread: false,
                        ),
                        _NotificationItem(
                          avatar: AppAssets.professionalProfileJpg,
                          text:
                              'Lisa Dancer ${AppStrings.commentedOnYourPost} - "Excellent, Keep it up!".',
                          time: '12:30 PM',
                          isUnread: false,
                        ),
                        _NotificationItem(
                          avatar: AppAssets.skilledProfileJpg,
                          text: 'Sam Basketer ${AppStrings.likedYourPost}',
                          time: '12:30 PM',
                          isUnread: false,
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

  Widget _buildNotificationGroup(List<_NotificationItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassWhite06,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return _buildNotificationTile(
            item,
            isLast: index == items.length - 1,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNotificationTile(
    _NotificationItem item, {
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
            child: CustomText(
              item.text,
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.foundationBlack20,
            ),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (item.isUnread)
                Container(
                  width: 10.w,
                  height: 10.w,
                  margin: EdgeInsets.only(bottom: 8.h),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accentCyan,
                  ),
                ),
              CustomText(
                item.time,
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.foundationBlack80,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NotificationItem {
  final String avatar;
  final String text;
  final String time;
  final bool isUnread;

  const _NotificationItem({
    required this.avatar,
    required this.text,
    required this.time,
    this.isUnread = false,
  });
}
