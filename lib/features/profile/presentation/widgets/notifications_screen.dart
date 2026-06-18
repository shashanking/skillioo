import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../constants/app_constants.dart';
import '../../../../core/localization/locale_extension.dart';
import '../../../../core/widgets/common_background.dart';
import '../../../../core/widgets/custom_text.dart';
import '../../../../core/widgets/icon_button.dart';
import '../../../chat/application/chat_providers.dart';
import '../../../chat/application/states/chat_state.dart';
import '../../../dashboard/application/dashboard_providers.dart';
import '../../../dashboard/application/states/profile_list_state.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatNotifierProvider.notifier).fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.tr;
    final chatState = ref.watch(chatNotifierProvider);
    final apiNotifications = chatState.notifications;
    final isLoading = chatState.notificationsStatus == ChatStatus.loading;
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
                      assetPath: 'assets/images/arrow-left.png',
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                    SizedBox(width: 24.w),
                    CustomText(
                      tr.notifications,
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
                child: _buildNotificationsContent(apiNotifications, isLoading),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  ProfileItem? _findProfileById(List<ProfileItem> profiles, String id) {
    try {
      return profiles.firstWhere((p) => p.id == id || p.nickName == id);
    } catch (_) {
      return null;
    }
  }

  Widget _buildNotificationsContent(
    List<Map<String, dynamic>> apiNotifications,
    bool isLoading,
  ) {
    // If API returned data, map it
    if (apiNotifications.isNotEmpty) {
      final profileState = ref.watch(profileListNotifierProvider);

      final items = apiNotifications.map((n) {
        final body = n['bodyText'] as Map<String, dynamic>? ?? n;
        final actorId = body['actorId'] as String? ?? '';
        final profile = _findProfileById(profileState.profiles, actorId);

        final type = body['type'] as String? ?? '';
        final name =
            profile?.displayName ?? (actorId.isNotEmpty ? actorId : 'Someone');

        String text = '';
        if (type == 'REACTION') {
          final reaction = body['reactionType'] as String? ?? 'reacted to';
          text = '$name $reaction your post';
        } else if (type == 'COMMENT') {
          final content = body['content'] as Map<String, dynamic>? ?? {};
          final commentText = content['text'] as String? ?? '';
          text = '$name commented: "$commentText"';
        } else if ((body['text'] as String?)?.isNotEmpty == true) {
          text = body['text'] as String;
        } else {
          text = '$name sent you a notification';
        }

        // Parse timestamp
        final rawTs = n['createdAt'] ?? n['updatedAt'];
        String timeLabel = '';
        if (rawTs != null) {
          final dt = rawTs is DateTime
              ? rawTs
              : DateTime.tryParse(rawTs.toString());
          if (dt != null) timeLabel = _formatTime(dt);
        }

        return _NotificationItem(
          avatar: profile?.profilePhotoUrl,
          text: text,
          time: timeLabel.isEmpty ? 'Just now' : timeLabel,
          isUnread: body['read'] != true,
        );
      }).toList();

      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: _buildNotificationGroup(items),
      );
    }

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    // Empty state if no notifications
    return Center(
      child: CustomText(
        'No notifications yet',
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.foundationBlack80,
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

  Widget _buildNotificationTile(_NotificationItem item, {bool isLast = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(color: AppColors.glassWhite12, width: 0.5),
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
              color: AppColors.glassWhite12,
              image: item.avatar != null
                  ? DecorationImage(
                      image: NetworkImage(item.avatar!),
                      fit: BoxFit.cover,
                    )
                  : const DecorationImage(
                      image: AssetImage(AppAssets.professionalProfileJpg),
                      fit: BoxFit.cover,
                    ),
            ),
            child: item.avatar == null
                ? Icon(Icons.person, color: Colors.white, size: 24.w)
                : null,
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
  final String? avatar;
  final String text;
  final String time;
  final bool isUnread;

  const _NotificationItem({
    this.avatar,
    required this.text,
    required this.time,
    this.isUnread = false,
  });
}
