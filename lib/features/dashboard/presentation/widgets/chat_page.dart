import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../constants/app_constants.dart';
import '../../../../core/widgets/common_background.dart';
import '../../../../core/widgets/custom_text.dart';

// ─── View states for the chat page ───
enum ChatViewState { messages, search, searchResults, chat }

class ChatPage extends StatefulWidget {
  final Function(bool)? onChatStateChanged;

  const ChatPage({super.key, this.onChatStateChanged});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  ChatViewState _viewState = ChatViewState.messages;
  int _selectedChatIndex = -1;
  bool _isFullScreenChat = false;
  String _selectedSkill = '';
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();

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

  final List<ChatConversation> _conversations = [
    ChatConversation(
      id: '1',
      name: 'Lisa Dancer',
      role: 'Hip-Hop Dancer',
      avatar: AppAssets.professionalProfileJpg,
      lastMessage: AppStrings.nowTalking,
      timestamp: '',
      unreadCount: 0,
      isOnline: true,
      isNowTalking: true,
    ),
    ChatConversation(
      id: '2',
      name: 'Sam Dances',
      role: 'Classical Dancer',
      avatar: AppAssets.skilledProfileJpg,
      lastMessage: '',
      timestamp: '',
      unreadCount: 0,
      isOnline: true,
    ),
    ChatConversation(
      id: '3',
      name: 'Perfect Dance',
      role: 'Classical Dancer',
      avatar: AppAssets.profileImg1,
      lastMessage: '',
      timestamp: '',
      unreadCount: 0,
      isOnline: false,
    ),
    ChatConversation(
      id: '4',
      name: 'Sam Dances',
      role: 'Classical Dancer',
      avatar: AppAssets.professionalProfileJpg,
      lastMessage: '',
      timestamp: '',
      unreadCount: 0,
      isOnline: true,
    ),
    ChatConversation(
      id: '5',
      name: 'Perfect Dance',
      role: 'Classical Dancer',
      avatar: AppAssets.skilledProfileJpg,
      lastMessage: '',
      timestamp: '',
      unreadCount: 0,
      isOnline: true,
    ),
  ];

  final List<ChatMessage> _messages = [
    ChatMessage(
      text: 'Hello, How are you?',
      isOwn: false,
      timestamp: '12:00 PM',
    ),
    ChatMessage(
      text: "I'm fine thank you for asking",
      isOwn: true,
      timestamp: '12:00 PM',
    ),
    ChatMessage(
      text: 'Lets start discussion',
      isOwn: false,
      timestamp: '12:00 PM',
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
    return CommonBackground(
      child: SafeArea(
        child: AnimatedSwitcher(
          duration: AppTransitions.duration,
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: KeyedSubtree(
            key: ValueKey(_viewState),
            child: _buildCurrentView(),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (_viewState) {
      case ChatViewState.messages:
        return _buildMessagesScreen();
      case ChatViewState.search:
        return _buildSearchScreen();
      case ChatViewState.searchResults:
        return _buildSearchResultsScreen();
      case ChatViewState.chat:
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
                  setState(() {
                    _viewState = ChatViewState.search;
                    _searchController.clear();
                  });
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
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            itemCount: _conversations.length,
            itemBuilder: (context, index) {
              return _buildConversationTile(index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildConversationTile(int index) {
    final chat = _conversations[index];
    final isFirst = index == 0;
    final isLast = index == _conversations.length - 1;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedChatIndex = index;
          _viewState = ChatViewState.chat;
        });
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
                      image: AssetImage(chat.avatar),
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
                      setState(() {
                        _selectedChatIndex = index;
                        _viewState = ChatViewState.chat;
                      });
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
                      setState(() {
                        _viewState = ChatViewState.messages;
                        _searchController.clear();
                      });
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
                    _viewState = ChatViewState.searchResults;
                  });
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
                  setState(() {
                    _viewState = ChatViewState.search;
                  });
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
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      decoration: BoxDecoration(color: Colors.white12),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedChatIndex = -1;
                _isFullScreenChat = false;
                _viewState = ChatViewState.messages;
              });
              widget.onChatStateChanged?.call(false);
            },
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
                image: AssetImage(_conversations[_selectedChatIndex].avatar),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          // "Chat With" + animated role text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
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
    final talkingChat = _conversations.where((c) => c.isNowTalking).toList();
    if (talkingChat.isEmpty) return const SizedBox.shrink();
    final chat = talkingChat.first;
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
                      image: AssetImage(chat.avatar),
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
                  SizedBox(height: 4.h),
                  CustomText(
                    chat.role,
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
    return Container(
      height: 260.h,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24.r)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: _conversations.length,
          itemBuilder: (context, index) => _buildHirerTile(index),
        ),
      ),
    );
  }

  Widget _buildHirerTile(int index) {
    final chat = _conversations[index];
    final isFirst = index == 0;
    final isLast = index == _conversations.length - 1;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white12,
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
                    image: AssetImage(chat.avatar),
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
                Container(
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
                SizedBox(width: 12.w),
                Container(
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
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildChatMessagesContainer({double? height}) {
    final content = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white12, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: ListView(
          shrinkWrap: height != null,
          physics: height != null
              ? const NeverScrollableScrollPhysics()
              : const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(24.w),
          children: [
            for (int i = 0; i < _messages.length; i++) ...[
              _buildMessageBubble(_messages[i]),
              if (i < _messages.length - 1) SizedBox(height: 24.h),
            ],
          ],
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
                    onTap: () {
                      if (_messageController.text.trim().isNotEmpty) {
                        setState(() {
                          _messages.add(
                            ChatMessage(
                              text: _messageController.text.trim(),
                              isOwn: true,
                              timestamp: '12:00 PM',
                            ),
                          );
                          _messageController.clear();
                        });
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
            onTap: () {
              setState(() {
                _selectedChatIndex = -1;
                _isFullScreenChat = false;
                _viewState = ChatViewState.messages;
              });
              widget.onChatStateChanged?.call(false);
            },
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
  final String id;
  final String name;
  final String role;
  final String avatar;
  final String lastMessage;
  final String timestamp;
  final int unreadCount;
  final bool isOnline;
  final bool isNowTalking;

  ChatConversation({
    required this.id,
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
