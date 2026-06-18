import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../constants/app_constants.dart';
import '../../../../core/widgets/custom_text.dart';
import '../../../chat/application/chat_providers.dart';
import '../../../dashboard/application/dashboard_providers.dart';
import '../../../dashboard/application/states/profile_list_state.dart';

class SharePostBottomSheet extends ConsumerStatefulWidget {
  final String postUrl;

  const SharePostBottomSheet({super.key, required this.postUrl});

  @override
  ConsumerState<SharePostBottomSheet> createState() =>
      _SharePostBottomSheetState();
}

class _SharePostBottomSheetState extends ConsumerState<SharePostBottomSheet> {
  final Set<String> _selectedUserIds = {};
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatNotifierProvider.notifier).fetchConversations();
    });
  }

  ProfileItem? _findProfileById(List<ProfileItem> profiles, String id) {
    try {
      return profiles.firstWhere((p) => p.id == id || p.nickName == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> _handleSend() async {
    if (_selectedUserIds.isEmpty) return;

    setState(() => _isSending = true);

    try {
      final chatNotifier = ref.read(chatNotifierProvider.notifier);
      final textMessage = 'Check out this post: ${widget.postUrl}';

      for (final recipientId in _selectedUserIds) {
        await chatNotifier.sendMessage(
          recipientId: recipientId,
          text: textMessage,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send post'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatNotifierProvider);
    final profileState = ref.watch(profileListNotifierProvider);

    final conversations = chatState.conversations;

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      padding: EdgeInsets.fromLTRB(
        20.w,
        20.h,
        20.w,
        MediaQuery.of(context).viewInsets.bottom + 20.h,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                'Send to...',
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              if (_selectedUserIds.isNotEmpty)
                GestureDetector(
                  onTap: _isSending ? null : _handleSend,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: _isSending ? Colors.grey : AppColors.accentCyan,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: _isSending
                        ? SizedBox(
                            width: 16.w,
                            height: 16.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : CustomText(
                            'Send',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 20.h),
          Expanded(
            child: conversations.isEmpty
                ? Center(
                    child: CustomText(
                      'No recent chats to share with.',
                      fontSize: 14.sp,
                      color: Colors.white54,
                    ),
                  )
                : ListView.builder(
                    itemCount: conversations.length,
                    itemBuilder: (context, index) {
                      final c = conversations[index];
                      final participantId = c.participantId ?? '';
                      if (participantId.isEmpty) return const SizedBox.shrink();

                      final profile = _findProfileById(
                        profileState.profiles,
                        participantId,
                      );
                      final name = profile?.displayName ?? participantId;
                      final avatar = profile?.profilePhotoUrl;
                      final isSelected = _selectedUserIds.contains(
                        participantId,
                      );

                      return ListTile(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedUserIds.remove(participantId);
                            } else {
                              _selectedUserIds.add(participantId);
                            }
                          });
                        },
                        leading: CircleAvatar(
                          radius: 24.r,
                          backgroundColor: AppColors.glassWhite12,
                          backgroundImage: avatar != null
                              ? NetworkImage(avatar)
                              : null,
                          child: avatar == null
                              ? Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 24.sp,
                                )
                              : null,
                        ),
                        title: CustomText(
                          name,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        trailing: Container(
                          width: 24.w,
                          height: 24.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.accentCyan
                                  : Colors.white54,
                              width: 2,
                            ),
                            color: isSelected
                                ? AppColors.accentCyan
                                : Colors.transparent,
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check,
                                  size: 16.sp,
                                  color: Colors.black,
                                )
                              : null,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
