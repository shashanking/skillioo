import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../constants/app_constants.dart';
import '../../../../core/localization/locale_extension.dart';
import '../../../../core/widgets/common_background.dart';
import '../../../../core/widgets/custom_text.dart';
import '../../../../core/widgets/icon_button.dart';
import '../../../../core/widgets/subscription_required_dialog.dart';
import '../../../call/application/call_providers.dart';
import '../../../chat/application/chat_providers.dart';
import '../../../chat/application/states/chat_state.dart';
import '../../../chat/domain/chat_models.dart' show ConversationResponse;
import '../../../dashboard/application/dashboard_providers.dart';
import '../../../dashboard/application/states/profile_list_state.dart';
import '../../../subscription/application/subscription_providers.dart';
import '../../../subscription/presentation/subscription.dart';

class ChatHistoryScreen extends ConsumerStatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  ConsumerState<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends ConsumerState<ChatHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatNotifierProvider.notifier).fetchConversations(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.tr;
    final chatState = ref.watch(chatNotifierProvider);
    final apiConversations = chatState.conversations;
    final isLoading = chatState.conversationsStatus == ChatStatus.loading;
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
                      tr.chatHistory,
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
                child: _buildChatHistoryContent(
                  chatState,
                  apiConversations,
                  isLoading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ProfileItem? _findProfileById(List<ProfileItem> profiles, String id) {
    try {
      return profiles.firstWhere((p) => p.id == id || p.nickName == id);
    } catch (_) {
      return null;
    }
  }

  Widget _buildChatHistoryContent(
    ChatState chatState,
    List<ConversationResponse> apiConversations,
    bool isLoading,
  ) {
    // If API returned data, map it
    if (apiConversations.isNotEmpty) {
      final profileState = ref.watch(profileListNotifierProvider);

      final items = apiConversations.map((c) {
        final participantId = c.participantId ?? '';
        final profile = _findProfileById(profileState.profiles, participantId);

        // Note: the main chat UI currently hardcodes isOnline to true
        // and SocketService handles online status, but it's not exposed
        // via ChatState yet. For now, we'll follow the main UI pattern.
        final isOnline = true;

        return _ChatItem(
          id: participantId,
          name:
              profile?.displayName ??
              (participantId.isNotEmpty ? participantId : 'User'),
          duration: c.latestMessage?.content?.text ?? '',
          avatar: profile?.profilePhotoUrl,
          isOnline: isOnline,
        );
      }).toList();

      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: _buildChatGroup(items),
      );
    }

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    // Fallback dummy data
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            ref.tr.today,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            fontFamily: 'Neue',
            color: AppColors.foundationBlack20,
          ),
          SizedBox(height: 12.h),
          _buildChatGroup([
            _ChatItem(
              id: '',
              name: 'Lisa Dancer',
              duration: '${ref.tr.chatLastedFor} 20 ${ref.tr.mins}',
              avatar: null,
            ),
            _ChatItem(
              id: '',
              name: 'SamSinger',
              duration: '${ref.tr.chatLastedFor} 20 ${ref.tr.mins}',
              avatar: null,
            ),
            _ChatItem(
              id: '',
              name: 'Lisa Dancer',
              duration: '${ref.tr.chatLastedFor} 1 ${ref.tr.hour}',
              avatar: null,
            ),
          ]),
          SizedBox(height: 24.h),
          CustomText(
            ref.tr.yesterday,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            fontFamily: 'Neue',
            color: AppColors.foundationBlack20,
          ),
          SizedBox(height: 12.h),
          _buildChatGroup([
            _ChatItem(
              id: '',
              name: 'SamSinger',
              duration: '${ref.tr.chatLastedFor} 5 ${ref.tr.mins}',
              avatar: null,
            ),
            _ChatItem(
              id: '',
              name: 'Lisa Dancer',
              duration: '${ref.tr.chatLastedFor} 20 ${ref.tr.mins}',
              avatar: null,
            ),
            _ChatItem(
              id: '',
              name: 'Lisa Dancer',
              duration: '${ref.tr.chatLastedFor} 1 ${ref.tr.hour}',
              avatar: null,
            ),
          ]),
        ],
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
    return GestureDetector(
      onTap: () {
        if (item.id.isNotEmpty) {
          // Navigate to the chat tab in dashboard
          context.go(
            '/landing?tab=3&recipientId=${Uri.encodeComponent(item.id)}',
          );
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.only(bottom: 16),
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
              Stack(
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
                              image: AssetImage(
                                AppAssets.professionalProfileJpg,
                              ),
                              fit: BoxFit.cover,
                            ),
                    ),
                    child: item.avatar == null
                        ? Icon(Icons.person, color: Colors.white, size: 24.w)
                        : null,
                  ),
                  if (item.isOnline)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF1E1E1E),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
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
              if (item.id.isNotEmpty) ...[
                GestureDetector(
                  onTap: () async {
                    final hasActiveSubscription = await ref
                        .read(subscriptionNotifierProvider.notifier)
                        .hasUsableCallSubscription();

                    if (!hasActiveSubscription) {
                      // Show subscription required popup
                      if (context.mounted) {
                        await SubscriptionRequiredDialog.show(
                          context,
                          onViewPlans: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const SubscriptionScreen(),
                              ),
                            );
                          },
                        );
                      }
                      return;
                    }

                    // User has active subscription, proceed with call
                    final success = await ref
                        .read(callNotifierProvider.notifier)
                        .initiateCall(item.id);
                    if (success && mounted) {
                      context.go('/landing?tab=4');
                    } else if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to initiate call'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.accentCyan.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.call,
                      color: AppColors.accentCyan,
                      size: 20.sp,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
              ],
              Icon(
                Icons.chevron_right,
                color: AppColors.foundationBlack20,
                size: 24.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatItem {
  final String id;
  final String name;
  final String duration;
  final String? avatar;
  final bool isOnline;

  const _ChatItem({
    required this.id,
    required this.name,
    required this.duration,
    this.avatar,
    this.isOnline = false,
  });
}
