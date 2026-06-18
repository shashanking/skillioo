import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../constants/app_constants.dart';
import '../../../../core/localization/locale_extension.dart';
import '../../../../core/services/session_prefs.dart';
import '../../../../core/services/session_state_provider.dart';
import '../../../../core/utils/call_utils.dart';
import '../../../../core/widgets/common_background.dart';
import '../../../../core/widgets/custom_text.dart';
import '../../../../core/widgets/online_indicator.dart';
import '../../../../core/widgets/voice_search_mic_button.dart';
import '../../application/dashboard_providers.dart';
import '../../application/states/profile_list_state.dart';
import '../../../chat/application/chat_providers.dart';
import '../../../chat/application/states/chat_state.dart';
import '../../../../core/services/socket_service.dart';
import '../../../online/application/online_providers.dart';
import '../../../posts/presentation/full_post_view.dart';
import '../../../onboarding/application/category_provider.dart';

class ChatPage extends ConsumerStatefulWidget {
  final Function(bool)? onChatStateChanged;
  final String initialRecipientId;

  const ChatPage({
    super.key,
    this.onChatStateChanged,
    this.initialRecipientId = '',
  });

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage>
    with TickerProviderStateMixin {
  String _currentUserId = '';
  bool _isFullScreenChat = false;
  String _selectedCategory = '';
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _didOpenInitialRecipient = false;
  Timer? _pollTimer;

  // Animated text flip for chat header
  static const List<String> _roleWords = [
    'Coach',
    'Choreographer',
    'Musician',
    'Drummer',
  ];
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  int _currentRoleIndex = 0;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _flipAnimation = CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOut,
    );
    _startRoleFlip();

    // Load current user ID and fetch conversations
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _currentUserId = await SessionPrefs.instance.getProfileId();

      final notifier = ref.read(chatNotifierProvider.notifier);
      await notifier.fetchConversations(refresh: true);

      // Seed online statuses from profile list (API data) and ask the socket
      // for current status of all conversation participants.
      _seedAndRequestOnlineStatuses();

      // Open chat with initial recipient if provided. Fire-and-forget so
      // the chat view appears as soon as state flips — the messages
      // fetch inside continues in the background.
      if (widget.initialRecipientId.isNotEmpty && !_didOpenInitialRecipient) {
        _didOpenInitialRecipient = true;
        notifier.openChatWithRecipient(widget.initialRecipientId);
      }

      _startPolling();
    });
  }

  @override
  void didUpdateWidget(covariant ChatPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialRecipientId != oldWidget.initialRecipientId &&
        widget.initialRecipientId.isNotEmpty) {
      _didOpenInitialRecipient = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final notifier = ref.read(chatNotifierProvider.notifier);
        // Flip into the chat view immediately. fetchConversations and the
        // messages fetch both happen in the background.
        notifier.openChatWithRecipient(widget.initialRecipientId);
        await notifier.fetchConversations(refresh: true);
      });
    }
  }

  void _startRoleFlip() {
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      _flipController.forward().then((_) {
        if (!mounted) return;
        setState(() {
          _currentRoleIndex = (_currentRoleIndex + 1) % _roleWords.length;
        });
        _flipController.reverse().then((_) {
          if (!mounted) return;
          _startRoleFlip();
        });
      });
    });
  }

  void _seedAndRequestOnlineStatuses() {
    final chatState = ref.read(chatNotifierProvider);
    final profileState = ref.read(profileListNotifierProvider);
    final onlineNotifier = ref.read(onlineNotifierProvider.notifier);

    // Collect all participant IDs from conversations
    final participantIds = chatState.conversations
        .map((c) => c.participantId ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();

    if (widget.initialRecipientId.isNotEmpty) {
      participantIds.add(widget.initialRecipientId);
    }

    // Seed from profile list (API data) for participants we have profile data for
    final seeds = <String, bool>{};
    for (final id in participantIds) {
      final profile = profileState.profiles
          .where((p) => p.id == id || p.nickName == id)
          .firstOrNull;
      if (profile != null) {
        seeds[id] = profile.onlineStatus.toUpperCase() == 'ONLINE';
      }
    }
    if (seeds.isNotEmpty) {
      onlineNotifier.seedStatuses(seeds);
    }

    // Ask socket to push current status for all participants
    SocketService().requestUsersStatus(participantIds.toList());
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (!mounted) return;
      ref.read(chatNotifierProvider.notifier).silentRefresh();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _flipController.dispose();
    _messageController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  /// Groups category names A-Z, filtered by the current search query.
  Map<String, List<String>> _groupCategories(List<String> categories) {
    final query = _searchController.text.trim().toLowerCase();
    final grouped = <String, List<String>>{};
    for (final name in categories) {
      if (name.isEmpty) continue;
      if (query.isNotEmpty && !name.toLowerCase().contains(query)) continue;
      final letter = name[0].toUpperCase();
      grouped.putIfAbsent(letter, () => []).add(name);
    }
    for (final list in grouped.values) {
      list.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    }
    return grouped;
  }

  /// Groups profiles A-Z by display name.
  Map<String, List<ProfileItem>> _groupProfiles(List<ProfileItem> profiles) {
    final grouped = <String, List<ProfileItem>>{};
    for (final p in profiles) {
      final name = p.displayName.trim();
      final letter = name.isEmpty ? '#' : name[0].toUpperCase();
      grouped.putIfAbsent(letter, () => []).add(p);
    }
    for (final list in grouped.values) {
      list.sort(
        (a, b) => a.displayName.toLowerCase().compareTo(
              b.displayName.toLowerCase(),
            ),
      );
    }
    return grouped;
  }

  List<ChatConversation> _mapConversations(ChatState chatState) {
    final profileState = ref.watch(profileListNotifierProvider);
    final onlineState = ref.watch(onlineNotifierProvider);
    final activeRecipientId = chatState.activeRecipientId;
    final currentUserId = ref.read(currentUserIdProvider);
    final conversations = chatState.conversations.map((c) {
      final participantId = c.participantId ?? '';
      final profile = _findProfileById(profileState.profiles, participantId);
      final latestMsg = c.latestMessage;
      final isFromOther =
          latestMsg != null && latestMsg.senderId != currentUserId;
      final isUnread =
          isFromOther && latestMsg.readAt == null && latestMsg.status != 'READ';
      // Use live socket status; fall back to API profile status if available
      final apiIsOnline = profile?.onlineStatus.toUpperCase() == 'ONLINE';
      final isOnline = onlineState.userStatuses.containsKey(participantId)
          ? onlineState.userStatuses[participantId]!
          : apiIsOnline;
      return ChatConversation(
        conversationId: c.conversationId ?? '',
        participantId: participantId,
        name:
            profile?.displayName ??
            (participantId.isNotEmpty ? participantId : 'User'),
        role: profile?.category ?? '',
        avatar: profile?.profilePhotoUrl ?? AppAssets.professionalProfileJpg,
        lastMessage: latestMsg?.content?.text ?? '',
        timestamp: _formatMessageTime(latestMsg?.createdAt),
        unreadCount: isUnread ? 1 : 0,
        isOnline: isOnline,
        isNowTalking:
            chatState.viewMode == ChatViewMode.chat &&
            participantId == activeRecipientId,
      );
    }).toList();

    // Sort by most recent message first
    conversations.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return conversations;
  }

  ProfileItem? _findProfileById(List<ProfileItem> profiles, String profileId) {
    for (final profile in profiles) {
      if (profile.id == profileId) {
        return profile;
      }
    }
    return null;
  }

  String _displayNameForRecipient(String recipientId) {
    if (recipientId.isEmpty) {
      return 'User';
    }
    final profiles = ref.read(profileListNotifierProvider).profiles;
    return _findProfileById(profiles, recipientId)?.displayName ?? recipientId;
  }

  ChatConversation? _activeConversationForState(
    ChatState chatState,
    List<ChatConversation> conversations,
  ) {
    final activeRecipientId = chatState.activeRecipientId;
    if (activeRecipientId.isEmpty) {
      return null;
    }

    for (final conversation in conversations) {
      if (conversation.participantId == activeRecipientId) {
        return conversation;
      }
    }
    return null;
  }

  String _avatarForRecipient(String recipientId) {
    if (recipientId.isEmpty) {
      return AppAssets.professionalProfileJpg;
    }

    final profiles = ref.read(profileListNotifierProvider).profiles;
    final profile = _findProfileById(profiles, recipientId);
    return profile?.profilePhotoUrl ?? AppAssets.professionalProfileJpg;
  }

  String _formatMessageTime(String? rawTimestamp) {
    if (rawTimestamp == null || rawTimestamp.trim().isEmpty) {
      return '';
    }

    final parsed = DateTime.tryParse(rawTimestamp)?.toLocal();
    if (parsed == null) {
      return rawTimestamp;
    }

    final hour = parsed.hour % 12 == 0 ? 12 : parsed.hour % 12;
    final minute = parsed.minute.toString().padLeft(2, '0');
    final period = parsed.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  void _exitChatDetail() {
    ref.read(chatNotifierProvider.notifier).exitChat();
    setState(() {
      _isFullScreenChat = false;
    });
    widget.onChatStateChanged?.call(false);
    if (widget.initialRecipientId.isNotEmpty) {
      context.go('/landing');
    }
  }

  ImageProvider _avatarImage(String avatarPath) {
    if (avatarPath.startsWith('http://') || avatarPath.startsWith('https://')) {
      return NetworkImage(avatarPath);
    }
    return AssetImage(avatarPath);
  }

  /// Opens a chat with [profile] after the standard subscription gate.
  ///
  /// The view-mode flip inside [openChatWithRecipient] is synchronous —
  /// fire-and-forget so the chat screen appears immediately. The network
  /// fetch for messages continues in the background; UI shows a loader
  /// in the meantime.
  ///
  /// We also don't await `onChatStateChanged` here — the post-frame
  /// callback in [build] already fires it the moment viewMode changes,
  /// so an extra call after the await would just be a delayed duplicate.
  Future<void> _openChatWith(ProfileItem profile) async {
    final allowed = await checkChatSubscription(context: context, ref: ref);
    if (!allowed || !mounted) return;
    ref
        .read(chatNotifierProvider.notifier)
        .openChatWithRecipient(profile.id);
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatNotifierProvider);
    final viewMode = chatState.viewMode;

    // Hide nav bar on all internal pages — only show on chat list (messages)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final shouldHideNav = viewMode != ChatViewMode.messages;
      widget.onChatStateChanged?.call(shouldHideNav);
    });

    // Page switch between messages/search/chat needs to feel instant —
    // the default `AppTransitions.duration` (800ms) made opening a chat
    // feel laggy. A short fade keeps the polish without the wait.
    return CommonBackground(
      child: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 120),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: KeyedSubtree(
            key: ValueKey(viewMode),
            child: _buildCurrentView(viewMode),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentView(ChatViewMode viewMode) {
    switch (viewMode) {
      case ChatViewMode.messages:
        return _buildMessagesScreen();
      case ChatViewMode.search:
        return _buildSearchScreen();
      case ChatViewMode.searchResults:
        return _buildSearchResultsScreen();
      case ChatViewMode.chat:
        return _buildChatScreen();
    }
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // ─── Messages Landing Screen (no back button) ───
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildMessagesScreen() {
    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.h),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                ref.tr.messages,
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                fontFamily: 'Neue',
                color: AppColors.foundationBlack20,
              ),
              SizedBox(height: 24.h),
              // Search Bar (tappable, navigates to search)
              GestureDetector(
                onTap: () {
                  ref
                      .read(chatNotifierProvider.notifier)
                      .setViewMode(ChatViewMode.search);
                  _searchController.clear();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _searchFocusNode.requestFocus();
                  });
                },
                child: Container(
                  height: 56.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 16.w),
                        child: Icon(
                          Icons.search,
                          color: AppColors.foundationHint,
                          size: 24.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: CustomText(
                          ref.tr.searchHintCoach,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.foundationHint,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 16.w),
                        child: Icon(
                          Icons.mic_none,
                          color: AppColors.foundationHint,
                          size: 24.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Conversation List
        Expanded(child: _buildConversationList()),
      ],
    );
  }

  Widget _buildConversationList() {
    final chatState = ref.watch(chatNotifierProvider);
    final apiConversations = chatState.conversations;
    final isLoading = chatState.conversationsStatus == ChatStatus.loading;

    // Show loading indicator
    if (isLoading && apiConversations.isEmpty) {
      return Center(child: CircularProgressIndicator(color: Colors.white));
    }

    // Show empty state if no conversations
    if (apiConversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64.w,
              color: AppColors.foundationBlack80,
            ),
            SizedBox(height: 16.h),
            CustomText(
              'No conversations yet',
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.foundationBlack80,
            ),
            SizedBox(height: 8.h),
            CustomText(
              'Start a conversation by searching for creators',
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.foundationBlack80,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Build conversation list from API data
    final displayConversations = _mapConversations(chatState);

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount: displayConversations.length,
      itemBuilder: (context, index) {
        return _buildConversationTile(index, displayConversations);
      },
    );
  }

  Widget _buildConversationTile(
    int index,
    List<ChatConversation> conversations,
  ) {
    final chat = conversations[index];
    final isFirst = index == 0;
    final isLast = index == conversations.length - 1;

    return GestureDetector(
      onTap: () {
        // Use notifier to select conversation
        ref.read(chatNotifierProvider.notifier).selectConversation(index);
        widget.onChatStateChanged?.call(true);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.vertical(
            top: isFirst ? Radius.circular(24.r) : Radius.zero,
            bottom: isLast ? Radius.circular(24.r) : Radius.zero,
          ),
        ),
        child: Row(
          children: [
            // Avatar with online indicator
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: _avatarImage(chat.avatar),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: OnlineIndicator(
                    userId: chat.participantId,
                    size: 10,
                    onlineColor: AppColors.foundationGreenNormal,
                    offlineColor: AppColors.foundationErrorDark,
                  ),
                ),
              ],
            ),
            SizedBox(width: 12.w),

            // Name + last message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    chat.name,
                    fontSize: 16.sp,
                    fontWeight: chat.unreadCount > 0
                        ? FontWeight.w700
                        : FontWeight.w600,
                    fontFamily: 'Neue',
                    color: AppColors.foundationBlack20,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  CustomText(
                    chat.lastMessage.isNotEmpty ? chat.lastMessage : chat.role,
                    fontSize: 13.sp,
                    fontWeight: chat.unreadCount > 0
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: chat.unreadCount > 0
                        ? Colors.white
                        : AppColors.foundationBlack80,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),

            SizedBox(width: 8.w),

            // Timestamp + unread + call
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (chat.timestamp.isNotEmpty)
                  CustomText(
                    chat.timestamp,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                    color: chat.unreadCount > 0
                        ? AppColors.foundationGreenNormal
                        : AppColors.foundationBlack80,
                  ),
                SizedBox(height: 4.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (chat.unreadCount > 0)
                      Container(
                        width: 8.w,
                        height: 8.w,
                        margin: EdgeInsets.only(right: 8.w),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.foundationGreenNormal,
                        ),
                      ),
                    GestureDetector(
                      onTap: () {
                        initiateCallWithSubscriptionCheck(
                          context: context,
                          ref: ref,
                          recipientId: chat.participantId,
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                        child: SvgPicture.asset(
                          AppAssets.callSvg,
                          width: 20.w,
                          height: 20.w,
                          colorFilter: ColorFilter.mode(
                            AppColors.foundationBlack20,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // ─── Search Screen (skills alphabetically) ───
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildSearchScreen() {
    return Column(
      children: [
        // Header with back + search
        Container(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      ref
                          .read(chatNotifierProvider.notifier)
                          .setViewMode(ChatViewMode.messages);
                      _searchController.clear();
                    },
                    child: Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  CustomText(
                    AppStrings.messages,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Neue',
                    color: AppColors.foundationBlack20,
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              // Active Search Bar
              Container(
                height: 56.h,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: ref.tr.searchHintGeneric,
                    hintStyle: TextStyle(
                      color: AppColors.foundationHint,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Icon(
                        Icons.search,
                        color: AppColors.foundationHint,
                        size: 24.sp,
                      ),
                    ),
                    suffixIcon: Padding(
                      padding: EdgeInsets.only(right: 16.w),
                      child: VoiceSearchMicButton(
                        controller: _searchController,
                        textFocusNode: _searchFocusNode,
                        iconColor: AppColors.foundationHint,
                        size: 24,
                        onFinalResult: (_) => setState(() {}),
                      ),
                    ),
                    suffixIconConstraints: BoxConstraints(
                      minWidth: 40.w,
                      minHeight: 40.w,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 18.h,
                      horizontal: 24.w,
                    ),
                  ),
                  style: TextStyle(
                    color: AppColors.foundationBlack20,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Categories list (alphabetical) — real categories from the backend.
        Expanded(
          child: ref.watch(categoryNamesProvider).when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
                error: (_, __) => Center(
                  child: CustomText(
                    ref.tr.noSkillsFound,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
                data: (categories) {
                  final grouped = _groupCategories(categories);
                  final sortedLetters = grouped.keys.toList()..sort();
                  if (sortedLetters.isEmpty) {
                    return Center(
                      child: CustomText(
                        ref.tr.noSkillsFound,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 16.h,
                    ),
                    itemCount: sortedLetters.length,
                    itemBuilder: (context, index) {
                      final letter = sortedLetters[index];
                      return _buildSkillGroup(letter, grouped[letter]!);
                    },
                  );
                },
              ),
        ),
      ],
    );
  }

  Widget _buildSkillGroup(String letter, List<String> skills) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.h),
        CustomText(
          letter,
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
          fontFamily: 'Neue',
          color: AppColors.foundationBlack20,
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            children: skills.asMap().entries.map((entry) {
              final isLast = entry.key == skills.length - 1;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = entry.value;
                  });
                  ref
                      .read(chatNotifierProvider.notifier)
                      .setViewMode(ChatViewMode.searchResults);
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 16.h,
                  ),
                  decoration: BoxDecoration(
                    border: isLast
                        ? null
                        : Border(
                            bottom: BorderSide(
                              color: Colors.white.withValues(alpha: 0.06),
                              width: 1,
                            ),
                          ),
                  ),
                  child: CustomText(
                    entry.value,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.foundationBlack20,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // ─── Search Results Screen ───
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildSearchResultsScreen() {
    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  ref
                      .read(chatNotifierProvider.notifier)
                      .setViewMode(ChatViewMode.search);
                },
                child: Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Row(
                  children: [
                    CustomText(
                      ref.tr.resultsFor,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Neue',
                      color: AppColors.foundationBlack20,
                    ),
                    CustomText(
                      '"$_selectedCategory"',
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Neue',
                      color: AppColors.foundationBlack20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Filters chip
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.foundationFilterPurpleStart,
                      AppColors.foundationFilterPurpleEnd,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.tune, color: Colors.white, size: 18.sp),
                    SizedBox(width: 8.w),
                    CustomText(
                      ref.tr.filters,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Creators list — real profiles in the selected category.
        Expanded(
          child:
              ref.watch(chatCategoryProfilesProvider(_selectedCategory)).when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            error: (_, __) => Center(
              child: CustomText(
                ref.tr.noCreatorsFound,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
            data: (profiles) {
              final grouped = _groupProfiles(profiles);
              final sortedLetters = grouped.keys.toList()..sort();
              if (sortedLetters.isEmpty) {
                return Center(
                  child: CustomText(
                    ref.tr.noCreatorsFound,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                );
              }
              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: sortedLetters.length,
                itemBuilder: (context, index) {
                  final letter = sortedLetters[index];
                  return _buildCreatorGroup(letter, grouped[letter]!);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCreatorGroup(String letter, List<ProfileItem> profiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.h),
        CustomText(
          letter,
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
          fontFamily: 'Neue',
          color: AppColors.foundationBlack20,
        ),
        SizedBox(height: 8.h),
        ...profiles.map((profile) => _buildCreatorTile(profile)),
      ],
    );
  }

  Widget _buildCreatorTile(ProfileItem profile) {
    final avatar = profile.profilePhotoUrl ?? AppAssets.professionalProfileJpg;
    final isOnline = profile.onlineStatus.toUpperCase() == 'ONLINE';
    // Every profile here was filtered by the selected category, so fall
    // back to that when the trimmed list payload omits `category`.
    final role = profile.category.isNotEmpty
        ? profile.category
        : _selectedCategory;

    return GestureDetector(
      onTap: () => _openChatWith(profile),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        margin: EdgeInsets.only(bottom: 4.h),
        child: Row(
          children: [
            // Avatar with online indicator
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: _avatarImage(avatar),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: OnlineIndicator(
                    userId: profile.id,
                    size: 12,
                    initialIsOnline: isOnline,
                    showBorder: false,
                    onlineColor: AppColors.foundationGreenNormal,
                    offlineColor: AppColors.foundationErrorDark,
                  ),
                ),
              ],
            ),
            SizedBox(width: 16.w),
            // Name and Role
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    profile.displayName,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Neue',
                    color: AppColors.foundationBlack20,
                  ),
                  SizedBox(height: 4.h),
                  CustomText(
                    role,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.foundationHint,
                  ),
                ],
              ),
            ),
            // Call and Message buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => initiateCallWithSubscriptionCheck(
                    context: context,
                    ref: ref,
                    recipientId: profile.id,
                  ),
                  child: Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white12,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        AppAssets.callSvg,
                        width: 20.w,
                        height: 20.w,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                GestureDetector(
                  onTap: () => _openChatWith(profile),
                  child: Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white12,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        AppAssets.messageSvg,
                        width: 20.w,
                        height: 20.w,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // ─── Chat Screen ───
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildChatScreen() {
    return Column(
      children: [
        _buildChatHeader(),
        Expanded(
          child: _isFullScreenChat
              ? _buildFullScreenContent()
              : _buildHalfScreenContent(),
        ),
        _buildSwitchModeLink(),
        _buildBottomInputBar(),
      ],
    );
  }

  Widget _buildChatHeader() {
    final chatState = ref.watch(chatNotifierProvider);
    final displayConversations = _mapConversations(chatState);
    final activeRecipientId = chatState.activeRecipientId;
    final activeConversation = _activeConversationForState(
      chatState,
      displayConversations,
    );
    final headerAvatar =
        activeConversation?.avatar ?? _avatarForRecipient(activeRecipientId);

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      decoration: BoxDecoration(color: Colors.white12),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: _exitChatDetail,
            child: Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white12,
              ),
              child: Icon(Icons.arrow_back, color: Colors.white, size: 24.sp),
            ),
          ),
          SizedBox(width: 16.w),
          // Avatar
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: _avatarImage(headerAvatar),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          // "Chat With" + animated role text
          Expanded(
            child: Row(
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [AppColors.accentPink, AppColors.accentCyan],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ).createShader(bounds),
                  child: CustomText(
                    ref.tr.chatWith,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Neue',
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 4.w),
                AnimatedBuilder(
                  animation: _flipAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: 1.0 - _flipAnimation.value,
                      child: Transform.translate(
                        offset: Offset(0, _flipAnimation.value * -12),
                        child: CustomText(
                          _roleWords[_currentRoleIndex],
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Neue',
                          color: AppColors.foundationBlack20,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHalfScreenContent() {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            SizedBox(height: 12.h),
            _buildAvailableHirersList(),
            SizedBox(height: 12.h),
            _buildChatMessagesContainer(height: 324.h),
          ],
        ),
      ),
    );
  }

  Widget _buildFullScreenContent() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          SizedBox(height: 12.h),
          _buildNowTalkingCard(),
          SizedBox(height: 12.h),
          Expanded(child: _buildChatMessagesContainer()),
        ],
      ),
    );
  }

  Widget _buildNowTalkingCard() {
    final chatState = ref.watch(chatNotifierProvider);
    final displayConversations = _mapConversations(chatState);
    final chat = _activeConversationForState(chatState, displayConversations);

    // Get recipient info - either from existing conversation or from activeRecipientId
    final activeRecipientId = chatState.activeRecipientId;
    if (chat == null && activeRecipientId.isEmpty) {
      return const SizedBox.shrink();
    }

    // Use chat data if available, otherwise build from activeRecipientId
    final displayName =
        chat?.name ?? _displayNameForRecipient(activeRecipientId);
    final displayAvatar =
        chat?.avatar ?? _avatarForRecipient(activeRecipientId);
    final displayRole = chat?.role ?? '';
    final participantId = chat?.participantId ?? activeRecipientId;
    return Container(
      padding: EdgeInsets.all(1.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: AppColors.ctaBorderGradient,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 54.w,
                  height: 54.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: _avatarImage(displayAvatar),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: OnlineIndicator(
                    userId: participantId,
                    size: 12,
                    onlineColor: AppColors.foundationGreenNormal,
                    offlineColor: AppColors.foundationErrorDark,
                  ),
                ),
              ],
            ),
            SizedBox(width: 24.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    displayName,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Neue',
                    color: AppColors.foundationBlack20,
                  ),
                  SizedBox(height: 4.h),
                  if (displayRole.isNotEmpty)
                    CustomText(
                      displayRole,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.foundationBlack20,
                    ),
                ],
              ),
            ),
            CustomText(
              ref.tr.nowTalking,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.foundationBlack20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableHirersList() {
    final chatState = ref.watch(chatNotifierProvider);
    final displayConversations = _mapConversations(chatState);

    // Check if we need to show the new recipient card that isn't in conversations yet
    final activeRecipientId = chatState.activeRecipientId;
    final hasActiveRecipient = activeRecipientId.isNotEmpty;
    final activeChatInList = displayConversations.any(
      (c) => c.participantId == activeRecipientId,
    );

    // If no conversations and no active recipient, show empty
    if (displayConversations.isEmpty &&
        (!hasActiveRecipient || activeChatInList)) {
      return const SizedBox.shrink();
    }

    // We either have conversations, or a new active recipient, or both
    int itemCount = displayConversations.length;
    if (hasActiveRecipient &&
        !activeChatInList &&
        chatState.viewMode == ChatViewMode.chat) {
      itemCount += 1; // Add one for the new recipient
    }

    if (itemCount == 0) return const SizedBox.shrink();

    return Container(
      height: 0.27.sh,
      padding: EdgeInsets.all(1.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: AppColors.ctaBorderGradient,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(22.r),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22.r),
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: itemCount,
            itemBuilder: (context, index) {
              // Handle the new recipient case (we put it at the top)
              if (hasActiveRecipient &&
                  !activeChatInList &&
                  chatState.viewMode == ChatViewMode.chat) {
                if (index == 0) {
                  // Build a temporary ChatConversation for the new recipient
                  final profileState = ref.read(profileListNotifierProvider);
                  final profile = _findProfileById(
                    profileState.profiles,
                    activeRecipientId,
                  );

                  final onlineState = ref.read(onlineNotifierProvider);
                  final apiIsOnline =
                      profile?.onlineStatus.toUpperCase() == 'ONLINE';
                  final newChat = ChatConversation(
                    conversationId: '',
                    participantId: activeRecipientId,
                    name: profile?.displayName ?? 'User',
                    role: profile?.category ?? '',
                    avatar:
                        profile?.profilePhotoUrl ??
                        AppAssets.professionalProfileJpg,
                    lastMessage: '',
                    timestamp: '',
                    unreadCount: 0,
                    isOnline: onlineState.userStatuses.containsKey(activeRecipientId)
                        ? onlineState.userStatuses[activeRecipientId]!
                        : apiIsOnline,
                    isNowTalking: true,
                  );

                  // We pass a single item list to _buildHirerTile since it just needs the index and list to determine isFirst/isLast
                  return _buildHirerTile(0, [newChat]);
                }
                // For other items, offset the index
                return _buildHirerTile(index - 1, displayConversations);
              }

              // Normal case
              return _buildHirerTile(index, displayConversations);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHirerTile(int index, List<ChatConversation> conversations) {
    final chat = conversations[index];
    final isFirst = index == 0;
    final isLast = index == conversations.length - 1;

    Widget child = Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: isFirst ? Radius.circular(24.r) : Radius.zero,
          bottom: isLast ? Radius.circular(24.r) : Radius.zero,
        ),
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 54.w,
                height: 54.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: _avatarImage(chat.avatar),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: OnlineIndicator(
                  userId: chat.participantId,
                  size: 12,
                  initialIsOnline: chat.isOnline,
                  onlineColor: AppColors.foundationGreenNormal,
                  offlineColor: AppColors.foundationErrorDark,
                ),
              ),
            ],
          ),
          SizedBox(width: 8.w),
          // Name and Role
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  chat.name,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Neue',
                  color: AppColors.foundationBlack20,
                ),
                SizedBox(height: 8.h),
                CustomText(
                  chat.role,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.foundationBlack20,
                ),
              ],
            ),
          ),
          if (chat.isNowTalking)
            CustomText(
              ref.tr.nowTalking,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.foundationBlack20,
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => initiateCallWithSubscriptionCheck(
                    context: context,
                    ref: ref,
                    recipientId: chat.participantId,
                  ),
                  child: Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white12,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        AppAssets.callSvg,
                        width: 22.w,
                        height: 22.w,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
                // SizedBox(width: 12.w),
                // GestureDetector(
                //   onTap: () {
                //     ref
                //         .read(chatNotifierProvider.notifier)
                //         .selectConversation(index);
                //     widget.onChatStateChanged?.call(true);
                //   },
                //   child: Container(
                //     width: 40.w,
                //     height: 40.w,
                //     decoration: BoxDecoration(
                //       shape: BoxShape.circle,
                //       color: Colors.white12,
                //     ),
                //     child: Center(
                //       child: SvgPicture.asset(
                //         AppAssets.messageSvg,
                //         width: 22.w,
                //         height: 22.w,
                //         colorFilter: const ColorFilter.mode(
                //           Colors.white,
                //           BlendMode.srcIn,
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
        ],
      ),
    );

    if (chat.isNowTalking) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24.r),
            bottom: Radius.circular(24.r),
          ),
        ),
        padding: EdgeInsets.all(1.w), // Border width
        child: Container(
          decoration: BoxDecoration(
            // color: const Color(
            //   0xFF1E1E2A,
            // ), // Match the background color to create the border effect
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(23.r),
              bottom: Radius.circular(23.r),
            ),
          ),
          child: child,
        ),
      );
    }

    return child;
  }

  Widget _buildChatMessagesContainer({double? height}) {
    final chatState = ref.watch(chatNotifierProvider);
    final apiMessages = [...chatState.messages]
      ..sort((a, b) {
        final aTime =
            DateTime.tryParse(a.createdAt ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final bTime =
            DateTime.tryParse(b.createdAt ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return aTime.compareTo(bTime);
      });

    final displayMessages = apiMessages.map((m) {
      return ChatMessage(
        text: m.content?.text ?? '',
        isOwn: m.senderId == _currentUserId,
        timestamp: _formatMessageTime(m.createdAt),
      );
    }).toList();

    final content = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white12, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: ListView.builder(
          reverse: true, // Reverse the list to keep it at the bottom
          shrinkWrap: height != null,
          physics: height != null
              ? const NeverScrollableScrollPhysics()
              : const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(24.w),
          itemCount: displayMessages.length,
          itemBuilder: (context, index) {
            // Since it's reversed, index 0 is the last item in the list
            final reversedIndex = displayMessages.length - 1 - index;
            return Padding(
              padding: EdgeInsets.only(
                // Add bottom padding to all items except the visually bottom one (which is index 0 in reversed list)
                bottom: index == 0 ? 0 : 24.h,
              ),
              child: _buildMessageBubble(displayMessages[reversedIndex]),
            );
          },
        ),
      ),
    );

    if (height != null) {
      return SizedBox(height: height, child: content);
    }
    return content;
  }

  Widget _buildMessageBubble(ChatMessage message) {
    // Check if message contains a post URL
    final postUrlMatch = RegExp(
      r'Check out this post: (.+)',
    ).firstMatch(message.text);
    final hasPostUrl = postUrlMatch != null;
    final postUrl = hasPostUrl ? postUrlMatch.group(1) : null;

    return Column(
      crossAxisAlignment: message.isOwn
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: hasPostUrl && postUrl != null
              ? () => _handlePostUrlTap(postUrl)
              : null,
          child: Container(
            constraints: BoxConstraints(maxWidth: 240.w),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: message.isOwn
                  ? Colors.white.withValues(alpha: 0.48)
                  : Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(24.r),
              border: hasPostUrl
                  ? Border.all(
                      color: const Color(0xFF00D9FF).withValues(alpha: 0.5),
                      width: 1.5,
                    )
                  : null,
            ),
            child: Column(
              crossAxisAlignment: message.isOwn
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (hasPostUrl) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.article_outlined,
                        color: const Color(0xFF00D9FF),
                        size: 16.sp,
                      ),
                      SizedBox(width: 6.w),
                      CustomText(
                        'Shared Post',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF00D9FF),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  CustomText(
                    'Tap to view',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: message.isOwn
                        ? Colors.white.withValues(alpha: 0.8)
                        : AppColors.foundationBlack20.withValues(alpha: 0.8),
                  ),
                ] else
                  CustomText(
                    message.text,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: message.isOwn
                        ? Colors.white
                        : AppColors.foundationBlack20,
                  ),
                SizedBox(height: 10.h),
                CustomText(
                  message.timestamp,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  color: message.isOwn
                      ? AppColors.foundationTimestamp
                      : AppColors.foundationBlack100,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _handlePostUrlTap(String postUrl) {
    // Parse the shared URL: https://skillioo.in/post/{mediaId}?src={encodedUrl}&t={video|image}
    // The ?src param carries the already-resolved Cloudinary URL so no API
    // call is needed. Legacy shares without ?src fall through to a best-effort
    // URL detection.
    Uri uri;
    try {
      uri = Uri.parse(postUrl);
    } catch (_) {
      return;
    }

    // Prefer the embedded src param (new share format).
    final encodedSrc = uri.queryParameters['src'];
    if (encodedSrc != null && encodedSrc.isNotEmpty) {
      var mediaUrl = Uri.decodeComponent(encodedSrc);
      if (mediaUrl.startsWith('http://')) {
        mediaUrl = mediaUrl.replaceFirst('http://', 'https://');
      }
      final isVideo = uri.queryParameters['t'] == 'video' ||
          mediaUrl.contains('/video/upload/') ||
          mediaUrl.endsWith('.mp4');
      final rawMediaId = uri.pathSegments.lastOrNull ?? '';
      // Treat 'null' string, empty, or direct URLs as absent mediaId
      final mediaId = (rawMediaId == 'null' ||
              rawMediaId.isEmpty ||
              rawMediaId.startsWith('http'))
          ? null
          : rawMediaId;

      String _d(String? key) {
        final v = uri.queryParameters[key ?? ''];
        return v != null && v.isNotEmpty ? Uri.decodeComponent(v) : '';
      }

      var avatarUrl = _d('avatar');
      if (avatarUrl.startsWith('http://')) {
        avatarUrl = avatarUrl.replaceFirst('http://', 'https://');
      }

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => FullPostViewScreen.single(
              mediaUrl: mediaUrl,
              isVideo: isVideo,
              recipientId: _d('uid'),
              profileName: _d('name'),
              profilePhotoUrl: avatarUrl.isNotEmpty ? avatarUrl : null,
              category: _d('cat'),
              subcategory: _d('sub'),
              proficiency: _d('pro'),
              mediaId: mediaId,
              totalComments: 0,
              totalLikes: 0,
              totalViews: 0,
              description: '',
            ),
          ),
        );
      }
      return;
    }

    // Legacy format — mediaId might be a direct Cloudinary URL embedded in path.
    final pathToken = uri.pathSegments.lastOrNull ?? '';
    if (pathToken.isEmpty || pathToken == 'null') return;

    final isDirectUrl =
        pathToken.startsWith('http://') || pathToken.startsWith('https://');
    if (isDirectUrl) {
      final mediaUrl = pathToken.startsWith('http://')
          ? pathToken.replaceFirst('http://', 'https://')
          : pathToken;
      final isVideo =
          mediaUrl.contains('/video/upload/') || mediaUrl.endsWith('.mp4');
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => FullPostViewScreen.single(
              mediaUrl: mediaUrl,
              isVideo: isVideo,
              recipientId: '',
              profileName: '',
              category: '',
              subcategory: '',
              proficiency: '',
              mediaId: '',
              totalComments: 0,
              totalLikes: 0,
              totalViews: 0,
              description: '',
            ),
          ),
        );
      }
    }
  }

  Widget _buildSwitchModeLink() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isFullScreenChat = !_isFullScreenChat;
        });
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.accentPink, AppColors.accentCyan],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ).createShader(bounds),
          child: CustomText(
            _isFullScreenChat
                ? ref.tr.switchToHalfScreen
                : ref.tr.switchToFullScreen,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            decoration: TextDecoration.underline,
            decorationColor: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomInputBar() {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h + bottomPadding),
      decoration: BoxDecoration(
        color: AppColors.foundationBlack800,
        borderRadius: BorderRadius.vertical(top: Radius.circular(48.r)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 56.h,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: ref.tr.typeMessage,
                        hintStyle: TextStyle(
                          color: AppColors.foundationHint,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 18.h,
                        ),
                      ),
                      style: TextStyle(
                        color: AppColors.foundationBlack20,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final text = _messageController.text.trim();
                      final activeRecipient = ref
                          .read(chatNotifierProvider)
                          .activeRecipientId;

                      if (text.isEmpty || activeRecipient.isEmpty) {
                        return;
                      }

                      _messageController.clear();
                      final success = await ref
                          .read(chatNotifierProvider.notifier)
                          .sendMessage(
                            recipientId: activeRecipient,
                            text: text,
                          );

                      if (!success && mounted) {
                        _messageController.text = text;
                      }
                    },
                    child: Container(
                      width: 44.w,
                      height: 44.w,
                      margin: EdgeInsets.only(right: 6.w),
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: Center(
                        child: Image.asset(
                          AppAssets.sendPng,
                          width: 24.w,
                          height: 24.w,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 16.w),
          GestureDetector(
            onTap: _exitChatDetail,
            child: Container(
              height: 56.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: AppColors.foundationErrorDark,
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Center(
                child: CustomText(
                  ref.tr.endChat,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.foundationBlack20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Data Models ───

class ChatConversation {
  final String conversationId;
  final String participantId;
  final String name;
  final String role;
  final String avatar;
  final String lastMessage;
  final String timestamp;
  final int unreadCount;
  final bool isOnline;
  final bool isNowTalking;

  ChatConversation({
    required this.conversationId,
    required this.participantId,
    required this.name,
    required this.role,
    required this.avatar,
    required this.lastMessage,
    required this.timestamp,
    required this.unreadCount,
    required this.isOnline,
    this.isNowTalking = false,
  });
}

class ChatMessage {
  final String text;
  final bool isOwn;
  final String timestamp;

  ChatMessage({
    required this.text,
    required this.isOwn,
    required this.timestamp,
  });
}
