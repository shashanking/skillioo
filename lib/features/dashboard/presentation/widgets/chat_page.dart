import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../constants/app_constants.dart';
import '../../../../core/services/session_prefs.dart';
import '../../../../core/widgets/common_background.dart';
import '../../../../core/widgets/custom_text.dart';
import '../../../../core/widgets/online_indicator.dart';
import '../../application/dashboard_providers.dart';
import '../../application/states/profile_list_state.dart';
import '../../../chat/application/chat_providers.dart';
import '../../../chat/application/states/chat_state.dart';

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
  String _selectedSkill = '';
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _didOpenInitialRecipient = false;

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

  // ─── Skills Data (alphabetical) ───
  final Map<String, List<String>> _skillsByLetter = {
    'A': ['Acting', 'Anchoring', 'Animation', 'Athletics'],
    'B': ['Baking', 'Bartending', 'Beatboxing', 'Branding', 'Blogging'],
    'C': ['Calligraphy', 'Carpentry', 'Choreography', 'Comedy', 'Cooking'],
    'D': ['Dance', 'DJing', 'Drawing', 'Drumming'],
    'E': ['Editing', 'Embroidery', 'Event Planning'],
    'F': ['Fashion Design', 'Filmmaking', 'Fitness Training', 'Floral Design'],
    'G': ['Gaming', 'Gardening', 'Graphic Design', 'Guitar'],
    'H': ['Hairstyling', 'Handicrafts'],
    'I': ['Illustration', 'Interior Design'],
    'J': ['Jewelry Making', 'Journalism'],
    'K': ['Knitting', 'Karate'],
    'L': ['Landscaping', 'Leather Crafting'],
    'M': ['Makeup', 'Martial Arts', 'Music Production', 'Modeling'],
    'N': ['Nail Art', 'Nutrition'],
    'O': ['Origami'],
    'P': ['Painting', 'Photography', 'Pottery', 'Public Speaking'],
    'Q': ['Quilting'],
    'R': ['Rapping', 'Robotics'],
    'S': ['Sculpting', 'Singing', 'Sketching', 'Storytelling'],
    'T': ['Tattooing', 'Teaching', 'Theater'],
    'U': ['Ukulele', 'UI/UX Design'],
    'V': ['Videography', 'Voice Acting'],
    'W': ['Web Design', 'Woodworking', 'Writing'],
    'Y': ['Yoga'],
  };

  // ─── Creators Data (for search results) ───
  final List<CreatorProfile> _allCreators = [
    CreatorProfile(
      name: 'Alan Tuts',
      role: 'Classical Dancer',
      avatar: AppAssets.professionalProfileJpg,
      skill: 'Dance',
      isOnline: true,
    ),
    CreatorProfile(
      name: 'Akash Dance',
      role: 'Hip-Hop Dancer',
      avatar: AppAssets.skilledProfileJpg,
      skill: 'Dance',
      isOnline: true,
    ),
    CreatorProfile(
      name: 'AlansTurn',
      role: 'All Styles',
      avatar: AppAssets.profileImg1,
      skill: 'Dance',
      isOnline: true,
    ),
    CreatorProfile(
      name: 'BobsLand',
      role: 'Classical Dancer',
      avatar: AppAssets.professionalProfileJpg,
      skill: 'Dance',
      isOnline: true,
    ),
    CreatorProfile(
      name: 'Akash Dance',
      role: 'All Styles',
      avatar: AppAssets.skilledProfileJpg,
      skill: 'Dance',
      isOnline: false,
    ),
    CreatorProfile(
      name: 'AlansTurn',
      role: 'All Styles',
      avatar: AppAssets.profileImg1,
      skill: 'Dance',
      isOnline: true,
    ),
    CreatorProfile(
      name: 'Charlie Arts',
      role: 'Contemporary',
      avatar: AppAssets.professionalProfileJpg,
      skill: 'Acting',
      isOnline: true,
    ),
    CreatorProfile(
      name: 'Diana Flow',
      role: 'Ballet',
      avatar: AppAssets.skilledProfileJpg,
      skill: 'Animation',
      isOnline: false,
    ),
  ];

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

      // Open chat with initial recipient if provided
      if (widget.initialRecipientId.isNotEmpty && !_didOpenInitialRecipient) {
        _didOpenInitialRecipient = true;
        await notifier.openChatWithRecipient(widget.initialRecipientId);
        widget.onChatStateChanged?.call(true);
      }
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
        await notifier.fetchConversations(refresh: true);
        await notifier.openChatWithRecipient(widget.initialRecipientId);
        widget.onChatStateChanged?.call(true);
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

  @override
  void dispose() {
    _flipController.dispose();
    _messageController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Map<String, List<String>> get _filteredSkills {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _skillsByLetter;
    final filtered = <String, List<String>>{};
    for (final entry in _skillsByLetter.entries) {
      final matching = entry.value
          .where((s) => s.toLowerCase().contains(query))
          .toList();
      if (matching.isNotEmpty) {
        filtered[entry.key] = matching;
      }
    }
    return filtered;
  }

  List<CreatorProfile> get _filteredCreators {
    return _allCreators
        .where((c) => c.skill.toLowerCase() == _selectedSkill.toLowerCase())
        .toList();
  }

  List<ChatConversation> _mapConversations(ChatState chatState) {
    final profileState = ref.watch(profileListNotifierProvider);
    final activeRecipientId = chatState.activeRecipientId;
    return chatState.conversations.map((c) {
      final participantId = c.participantId ?? '';
      final profile = _findProfileById(profileState.profiles, participantId);
      return ChatConversation(
        conversationId: c.conversationId ?? '',
        participantId: participantId,
        name:
            profile?.displayName ??
            (participantId.isNotEmpty ? participantId : 'User'),
        role: profile?.proficiency ?? '',
        avatar: profile?.profilePhotoUrl ?? AppAssets.professionalProfileJpg,
        lastMessage: c.latestMessage?.content?.text ?? '',
        timestamp: '',
        unreadCount: 0,
        isOnline: true,
        isNowTalking:
            chatState.viewMode == ChatViewMode.chat &&
            participantId == activeRecipientId,
      );
    }).toList();
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

  Map<String, List<CreatorProfile>> get _creatorsGrouped {
    final creators = _filteredCreators;
    final grouped = <String, List<CreatorProfile>>{};
    for (final c in creators) {
      final letter = c.name[0].toUpperCase();
      grouped.putIfAbsent(letter, () => []);
      grouped[letter]!.add(c);
    }
    final sortedKeys = grouped.keys.toList()..sort();
    return {for (final k in sortedKeys) k: grouped[k]!};
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatNotifierProvider);
    final viewMode = chatState.viewMode;

    return CommonBackground(
      child: SafeArea(
        child: AnimatedSwitcher(
          duration: AppTransitions.duration,
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
                AppStrings.messages,
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
                          AppStrings.searchHintCoach,
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
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
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
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
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
                AppStrings.nowTalking,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.foundationBlack20,
              )
            else
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          AppAssets.callSvg,
                          width: 24.w,
                          height: 24.w,
                          colorFilter: ColorFilter.mode(
                            AppColors.foundationBlack20,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  GestureDetector(
                    onTap: () {
                      ref
                          .read(chatNotifierProvider.notifier)
                          .selectConversation(index);
                      widget.onChatStateChanged?.call(true);
                    },
                    child: Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          AppAssets.messageSvg,
                          width: 24.w,
                          height: 24.w,
                          colorFilter: ColorFilter.mode(
                            AppColors.foundationBlack20,
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
  // ─── Search Screen (skills alphabetically) ───
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildSearchScreen() {
    final skills = _filteredSkills;
    final sortedLetters = skills.keys.toList()..sort();

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
                    hintText: AppStrings.searchHintGeneric,
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
                      padding: EdgeInsets.all(16.w),
                      child: Icon(
                        Icons.mic_none,
                        color: AppColors.foundationHint,
                        size: 24.sp,
                      ),
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
        // Skills List (alphabetical)
        Expanded(
          child: sortedLetters.isEmpty
              ? Center(
                  child: CustomText(
                    AppStrings.noSkillsFound,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 16.h,
                  ),
                  itemCount: sortedLetters.length,
                  itemBuilder: (context, index) {
                    final letter = sortedLetters[index];
                    final items = skills[letter]!;
                    return _buildSkillGroup(letter, items);
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
                    _selectedSkill = entry.value;
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
    final grouped = _creatorsGrouped;
    final sortedLetters = grouped.keys.toList()..sort();

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
                      AppStrings.resultsFor,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Neue',
                      color: AppColors.foundationBlack20,
                    ),
                    CustomText(
                      '"$_selectedSkill"',
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
                      AppStrings.filters,
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
        // Creators list grouped alphabetically
        Expanded(
          child: sortedLetters.isEmpty
              ? Center(
                  child: CustomText(
                    AppStrings.noCreatorsFound,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: sortedLetters.length,
                  itemBuilder: (context, index) {
                    final letter = sortedLetters[index];
                    final creators = grouped[letter]!;
                    return _buildCreatorGroup(letter, creators);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCreatorGroup(String letter, List<CreatorProfile> creators) {
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
        ...creators.map((creator) => _buildCreatorTile(creator)),
      ],
    );
  }

  Widget _buildCreatorTile(CreatorProfile creator) {
    return Container(
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
                    image: AssetImage(creator.avatar),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: creator.isOnline
                        ? AppColors.foundationGreenNormal
                        : AppColors.foundationErrorDark,
                  ),
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
                  creator.name,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Neue',
                  color: AppColors.foundationBlack20,
                ),
                SizedBox(height: 4.h),
                CustomText(
                  creator.role,
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
                onTap: () {},
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
                onTap: () {},
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
    final headerName =
        activeConversation?.name ?? _displayNameForRecipient(activeRecipientId);

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
                    AppStrings.chatWith,
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
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: const LinearGradient(
          colors: [AppColors.accentCyan, AppColors.accentPink],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
        decoration: BoxDecoration(
          // color: AppColors.foundationBlack800,
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
              AppStrings.nowTalking,
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
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24.r)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
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

                final newChat = ChatConversation(
                  conversationId: '',
                  participantId: activeRecipientId,
                  name: profile?.displayName ?? 'User',
                  role: profile?.proficiency ?? '',
                  avatar:
                      profile?.profilePhotoUrl ??
                      AppAssets.professionalProfileJpg,
                  lastMessage: '',
                  timestamp: '',
                  unreadCount: 0,
                  isOnline: true,
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
                child: Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: chat.isOnline
                        ? AppColors.foundationGreenNormal
                        : AppColors.foundationErrorDark,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 24.w),
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
              AppStrings.nowTalking,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.foundationBlack20,
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    ref
                        .read(chatNotifierProvider.notifier)
                        .initiateCall(chat.participantId);
                  },
                  child: Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white12,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        AppAssets.callSvg,
                        width: 24.w,
                        height: 24.w,
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
                  onTap: () {
                    ref
                        .read(chatNotifierProvider.notifier)
                        .selectConversation(index);
                    widget.onChatStateChanged?.call(true);
                  },
                  child: Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white12,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        AppAssets.messageSvg,
                        width: 24.w,
                        height: 24.w,
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
    );

    if (chat.isNowTalking) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24.r),
            bottom: Radius.circular(24.r),
          ),
          gradient: const LinearGradient(
            colors: [AppColors.accentCyan, AppColors.accentPink],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
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
    return Column(
      crossAxisAlignment: message.isOwn
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: 240.w),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: message.isOwn
                ? Colors.white.withValues(alpha: 0.48)
                : Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Column(
            crossAxisAlignment: message.isOwn
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
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
      ],
    );
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
                ? AppStrings.switchToHalfScreen
                : AppStrings.switchToFullScreen,
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
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
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
                        hintText: AppStrings.typeMessage,
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
                  AppStrings.endChat,
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

class CreatorProfile {
  final String name;
  final String role;
  final String avatar;
  final String skill;
  final bool isOnline;

  CreatorProfile({
    required this.name,
    required this.role,
    required this.avatar,
    required this.skill,
    required this.isOnline,
  });
}
