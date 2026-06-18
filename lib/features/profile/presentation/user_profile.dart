import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:skillioo/constants/app_constants.dart';
import 'package:skillioo/features/profile/presentation/widgets/bio_tab.dart';
import 'package:skillioo/features/profile/presentation/widgets/certificates_tab.dart';
import 'package:skillioo/features/profile/presentation/widgets/posts_tab.dart';
import '../../../core/widgets/gradient_cta_button.dart';

import '../../../../core/widgets/custom_text.dart';
import '../../../../core/utils/call_utils.dart';
import '../../../core/services/session_prefs.dart';
import '../../dashboard/application/dashboard_providers.dart';
import '../../dashboard/application/states/profile_list_state.dart';
import '../../follow/application/follow_providers.dart';
import '../../online/application/online_providers.dart';
import '../../posts/application/post_providers.dart';
import '../../profile/application/profile_detail_provider.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({
    super.key,
    required this.profileId,
    this.isOwnProfile = false,
  });

  final String profileId;
  final bool isOwnProfile;

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  int _selectedTabIndex = 0; // 0: Bio, 1: Posts, 2: Certificates
  bool _isLiked = false;
  bool _likeAnimating = false;
  bool _isLikeLoading = false;

  // This controller allows the sheet to scroll the internal list
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Restore like state from session-scoped provider.
      _isLiked = ref.read(likedProfileIdsProvider).contains(widget.profileId);
      if (mounted) setState(() {});

      if (!widget.isOwnProfile) {
        ref
            .read(followNotifierProvider.notifier)
            .checkIfFollowing(widget.profileId);
      }
    });
  }

  Future<void> _toggleLike() async {
    if (_isLikeLoading) return;
    final wasLiked = _isLiked;
    setState(() {
      _isLiked = !_isLiked;
      _likeAnimating = true;
      _isLikeLoading = true;
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _likeAnimating = false);
    });

    try {
      final token = await SessionPrefs.instance.getAccessToken();
      final service = ref.read(postServiceProvider);
      service.setAuthToken(token);
      Map<String, dynamic> res;
      if (wasLiked) {
        res = await service.unlikeProfile(widget.profileId);
      } else {
        res = await service.likeProfile(widget.profileId);
      }
      debugPrint('LikeProfile: status=${res['status']} message=${res['message']} error=${res['error']}');
      final status = res['status'] as int? ?? 0;
      final errorMsg = (res['error'] as String? ?? '').toLowerCase();

      // 400 "already liked" means the server already has the like — treat as success.
      final alreadyLiked = status == 400 && errorMsg.contains('already');

      if (status != 200 && status != 201 && !alreadyLiked) {
        throw Exception('${res['message'] ?? res['error'] ?? 'Failed'}');
      }

      // Persist the resolved like state in the session provider.
      final likedIds = ref.read(likedProfileIdsProvider);
      final newSet = Set<String>.from(likedIds);
      final nowLiked = alreadyLiked ? true : _isLiked;
      if (nowLiked) {
        newSet.add(widget.profileId);
      } else {
        newSet.remove(widget.profileId);
      }
      ref.read(likedProfileIdsProvider.notifier).state = newSet;
      if (mounted && alreadyLiked && !_isLiked) {
        setState(() => _isLiked = true);
      }
    } catch (e) {
      debugPrint('LikeProfile error: $e');
      if (mounted) {
        setState(() => _isLiked = wasLiked);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLikeLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileListNotifierProvider);
    final ProfileItem? profile = state.profiles
        .where((p) => p.id == widget.profileId)
        .firstOrNull;

    if (profile == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF050505),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: Stack(
        children: [
          // ------------------------------------------------
          // LAYER 1: Background Content (Header & Stats)
          // ------------------------------------------------
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.only(bottom: 400.h),
                child: Column(
                  children: [
                    _buildHeaderSection(),
                    SizedBox(height: 20.h),

                    // Name & Title
                    Consumer(
                      builder: (context, ref, child) {
                        return Column(
                          children: [
                            CustomText(
                              profile.displayName,
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            SizedBox(height: 8.h),
                            CustomText(
                              profile.category.isNotEmpty
                                  ? profile.category.toUpperCase()
                                  : profile.profileType == 'GROUP'
                                  ? 'GROUP'
                                  : 'INDIVIDUAL',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.white70,
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 16.h),

                    // Online Badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Builder(builder: (context) {
                        final onlineState = ref.watch(onlineNotifierProvider);
                        final isOnline = onlineState.userStatuses
                                .containsKey(profile.id)
                            ? onlineState.userStatuses[profile.id]!
                            : profile.onlineStatus.toUpperCase() == 'ONLINE';
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 10.w,
                              height: 10.w,
                              decoration: BoxDecoration(
                                color: isOnline
                                    ? const Color(0xff198754)
                                    : Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            CustomText(
                              isOnline ? 'Online' : 'Offline',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: isOnline
                                  ? const Color(0xFF198754)
                                  : Colors.red,
                            ),
                          ],
                        );
                      }),
                    ),

                    SizedBox(height: 32.h),

                    // Stats Row 1
                    Consumer(
                      builder: (context, ref, child) {
                        final followState = ref.watch(followNotifierProvider);
                        final followerDelta = followState.followerCountOverrides[widget.profileId] ?? 0;
                        final effectiveFollowers = (profile.followerCount + followerDelta).clamp(0, 999999);
                        return Column(
                          children: [
                            _buildStatsContainer(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatItem(
                                    '$effectiveFollowers',
                                    'Followers',
                                  ),
                                  _buildStatItem(
                                    '${profile.followingCount}',
                                    'Following',
                                  ),
                                  _buildStatItem('0', 'Reactions'),
                                  _buildStatItem('0', 'Impressions'),
                                ],
                              ),
                            ),
                            SizedBox(height: 16.h),
                            _buildStatsContainer(
                              transparent: false,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatItem(
                                    '${profile.eventsDone}',
                                    'Events',
                                  ),
                                  ...profile.follows.take(2).map((follow) {
                                    Widget iconWidget;
                                    switch (follow.socialMedia.toUpperCase()) {
                                      case 'FACEBOOK':
                                        iconWidget = Image.asset(
                                          'assets/images/facebook.png',
                                          width: 24.w,
                                          height: 24.w,
                                          color: Colors.white,
                                        );
                                        break;
                                      case 'INSTAGRAM':
                                        iconWidget = Image.asset(
                                          'assets/images/instagram.png',
                                          width: 24.w,
                                          height: 24.w,
                                          color: Colors.white,
                                        );
                                        break;
                                      case 'TWITTER':
                                      case 'X':
                                        iconWidget = Icon(
                                          Icons.tag,
                                          color: Colors.white,
                                          size: 24.sp,
                                        );
                                        break;
                                      case 'YOUTUBE':
                                        iconWidget = Icon(
                                          Icons.play_circle_outline,
                                          color: Colors.white,
                                          size: 24.sp,
                                        );
                                        break;
                                      default:
                                        iconWidget = Icon(
                                          Icons.public,
                                          color: Colors.white,
                                          size: 24.sp,
                                        );
                                    }
                                    return _buildSocialStatItem(
                                      iconWidget,
                                      '${follow.formattedFollowers} Followers',
                                    );
                                  }),
                                ],
                              ),
                            ),

                            if (!widget.isOwnProfile) ...[
                              SizedBox(height: 20.h),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20.h),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Builder(builder: (context) {
                                        final isFollowing = followState
                                            .followingIds
                                            .contains(widget.profileId);
                                        final isToggling = followState
                                            .togglingIds
                                            .contains(widget.profileId);
                                        return GradientCtaButton(
                                          label: isFollowing
                                              ? 'Unfollow'
                                              : 'Follow',
                                          height: 52,
                                          width: double.infinity,
                                          leading: isToggling
                                              ? SizedBox(
                                                  width: 18.w,
                                                  height: 18.w,
                                                  child:
                                                      const CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 2,
                                                  ),
                                                )
                                              : Image.asset(
                                                  isFollowing
                                                      ? 'assets/images/unfollow.png'
                                                      : 'assets/add.png',
                                                  width: 20.w,
                                                  height: 20.w,
                                                  errorBuilder: (_, __, ___) =>
                                                      Icon(
                                                    isFollowing
                                                        ? Icons
                                                            .person_remove_outlined
                                                        : Icons
                                                            .person_add_outlined,
                                                    color: Colors.white,
                                                    size: 20.sp,
                                                  ),
                                                ),
                                          onPressed: isToggling
                                              ? null
                                              : () => ref
                                                  .read(
                                                    followNotifierProvider
                                                        .notifier,
                                                  )
                                                  .toggleFollow(
                                                    widget.profileId,
                                                  ),
                                        );
                                      }),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: _toggleLike,
                                        child: Container(
                                          padding: EdgeInsets.all(1.w),
                                          height: 52.h,
                                          decoration: BoxDecoration(
                                            gradient: _isLiked
                                                ? AppColors.ctaGradient
                                                : AppColors.ctaBorderGradient,
                                            borderRadius: BorderRadius.circular(
                                              29.r,
                                            ),
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: _isLiked
                                                  ? null
                                                  : const Color(0xFF0D0D0D),
                                              gradient: _isLiked
                                                  ? AppColors.ctaGradient
                                                  : null,
                                              borderRadius:
                                                  BorderRadius.circular(28.r),
                                            ),
                                            child: Center(
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  AnimatedScale(
                                                    scale: _likeAnimating
                                                        ? 1.4
                                                        : 1.0,
                                                    duration: const Duration(
                                                      milliseconds: 200,
                                                    ),
                                                    curve: Curves.elasticOut,
                                                    child: _isLiked
                                                        ? Icon(
                                                            Icons.favorite,
                                                            color: Colors.white,
                                                            size: 20.sp,
                                                          )
                                                        : Image.asset(
                                                            'assets/images/favourite.png',
                                                            width: 20.w,
                                                            height: 20.w,
                                                          ),
                                                  ),
                                                  SizedBox(width: 8.w),
                                                  _isLiked
                                                      ? CustomText(
                                                          'Liked',
                                                          fontSize: 16.sp,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors.white,
                                                        )
                                                      : ShaderMask(
                                                          shaderCallback:
                                                              (bounds) =>
                                                                  AppColors
                                                                      .ctaBorderGradient
                                                                      .createShader(
                                                                        bounds,
                                                                      ),
                                                          child: CustomText(
                                                            'Like',
                                                            fontSize: 16.sp,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ------------------------------------------------
          // LAYER 2: Fixed Top Navigation
          // ------------------------------------------------
          Positioned(
            top: 50.h,
            left: 20.w,
            right: 20.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!widget.isOwnProfile)
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/images/arrow-left.png',
                          color: Colors.white,
                          width: 22.sp,
                          height: 22.sp,
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),
                if (widget.isOwnProfile)
                  _buildNavButton(icon: Icons.edit_outlined, onTap: () {})
                else
                  const SizedBox.shrink(),
              ],
            ),
          ),

          // ------------------------------------------------
          // LAYER 3: Draggable Bottom Sheet
          // ------------------------------------------------
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: 0.2,
            minChildSize: 0.2,
            maxChildSize: 1.0,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.r),
                    topRight: Radius.circular(30.r),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withValues(alpha: 0.6),
                      width: 1,
                    ),
                  ),
                ),
                // Using SingleChildScrollView here ensures the top notch area is draggable
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      SizedBox(height: 22.h),
                      // Drag Handle
                      Center(
                        child: Container(
                          width: 84.w,
                          height: 24.h,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(48.r),
                          ),
                        ),
                      ),
                      SizedBox(height: 35.h),

                      // Tab Switcher
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 20.w),
                        padding: EdgeInsets.all(4.w),
                        height: 58.h,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(48.r),
                        ),
                        child: Row(
                          children: [
                            _buildTabItem(0, "Bio"),
                            _buildTabItem(1, "Posts"),
                            _buildTabItem(2, "Certificates"),
                          ],
                        ),
                      ),
                      SizedBox(height: 30.h),

                      // Tab Content (Wrapped in SizedBox/Constraint to allow internal content)
                      // We don't use Expanded here because we are inside a SingleChildScrollView
                      // The content is rendered directly.
                      // Note: We don't pass scrollController down because the parent SingleChildScrollView handles the sheet drag
                      IndexedStack(
                        index: _selectedTabIndex,
                        children: [
                          Builder(builder: (context) {
                            final detail = ref.watch(
                              profileDetailProvider(widget.profileId),
                            );
                            final detailBio = detail.whenOrNull(
                              data: (d) {
                                final bio = d['bio'] as String? ??
                                    (d['portfolio'] is Map
                                        ? (d['portfolio']
                                                as Map)['bio'] as String?
                                        : null);
                                return (bio != null && bio.isNotEmpty)
                                    ? bio
                                    : null;
                              },
                            );
                            return BioTab(
                              profile: profile,
                              isOwnProfile: widget.isOwnProfile,
                              bioOverride: detailBio,
                            );
                          }),
                          PostsTab(profile: profile),
                          CertificatesTab(portfolioId: profile.portfolioId),
                        ],
                      ),

                      // Call & Chat buttons for other users
                      if (!widget.isOwnProfile) ...[
                        SizedBox(height: 20.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Row(
                            children: [
                              Expanded(
                                child: GradientCtaButton(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/images/call (1).png',
                                        width: 22.w,
                                        height: 22.w,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 8.w),
                                      CustomText(
                                        'Call',
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                  onPressed: () => _handleCallTap(profile),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: _buildCallChatButton(
                                  label: 'Chat',
                                  assetPath: 'assets/images/Comment.png',
                                  isFilled: false,
                                  onTap: () => _handleChatTap(profile),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // DYNAMIC ACTION BUTTON (Moved here to scroll with sheet)
                      SizedBox(height: 20.h),
                      if (widget.isOwnProfile)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 20.h,
                          ),
                          child: _buildActionButton(),
                        ),
                      // Extra padding for safe area bottom
                      SizedBox(height: 30.h),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- Dynamic Button Logic ---
  Widget _buildActionButton() {
    String text;
    String assetPath;
    VoidCallback onTap;

    switch (_selectedTabIndex) {
      case 0:
        text = "Edit Charges";
        assetPath = 'assets/images/edit.png';
        onTap = () {};
        break;
      case 1:
        text = "Create Post";
        assetPath = 'assets/images/Follow.png';
        onTap = () => context.push('/profile-create-post');
        break;
      case 2:
        text = "Upload Certificate";
        assetPath = AppAssets.uploadIconPng;
        onTap = () {};
        break;
      default:
        return const SizedBox.shrink();
    }

    return GradientCtaButton(
      label: text,
      onPressed: onTap,
      width: double.infinity,
      height: 56,
      leading: Image.asset(
        assetPath,
        width: 20.sp,
        height: 20.sp,
        color: Colors.white,
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildTabItem(int index, String text) {
    final bool isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedTabIndex = index);
        },
        child: AnimatedContainer(
          height: 46,
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),
            gradient: isSelected ? AppColors.ctaGradient : null,
            color: isSelected ? null : Colors.transparent,
          ),
          alignment: Alignment.center,
          child: CustomText(
            text,
            fontSize: 14.sp,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    final state = ref.watch(profileListNotifierProvider);
    final profilePhotoUrl = state.profiles
        .where((p) => p.id == widget.profileId)
        .map((p) => p.profilePhotoUrl)
        .firstOrNull;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          height: 220.h,
          width: double.infinity,
          decoration: BoxDecoration(
            image: profilePhotoUrl != null && profilePhotoUrl.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(profilePhotoUrl),
                    fit: BoxFit.cover,
                  )
                : const DecorationImage(
                    image: AssetImage('assets/images/skilled-profile.jpg'),
                    fit: BoxFit.cover,
                  ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  const Color(0xFF050505).withValues(alpha: 0.9),
                  const Color(0xFF050505),
                ],
                stops: const [0.0, 0.7, 1.0],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 20.h,
          child: Container(
            width: 130.w,
            height: 130.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF050505), width: 4.w),
              image: profilePhotoUrl != null && profilePhotoUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(profilePhotoUrl),
                      fit: BoxFit.cover,
                    )
                  : const DecorationImage(
                      image: AssetImage(
                        'assets/images/professional-profile.jpg',
                      ),
                      fit: BoxFit.cover,
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsContainer({
    required Widget child,
    bool transparent = false,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: transparent ? Colors.transparent : Colors.white.withAlpha(16),
        borderRadius: BorderRadius.circular(48.r),
      ),
      child: child,
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        CustomText(
          value,
          fontSize: 18.sp,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
        SizedBox(height: 4.h),
        CustomText(
          label,
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
          color: Colors.white70,
        ),
      ],
    );
  }

  Widget _buildSocialStatItem(Widget iconWidget, String text) {
    return Column(
      children: [
        iconWidget,
        SizedBox(height: 4.h),
        CustomText(
          text,
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
          color: Colors.white70,
        ),
      ],
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44.w,
        height: 44.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.15),
        ),
        child: Icon(icon, color: Colors.white, size: 22.sp),
      ),
    );
  }

  // ── Call & Chat ──

  Widget _buildCallChatButton({
    required String label,
    required String assetPath,
    required bool isFilled,
    required VoidCallback onTap,
  }) {
    const gradient = AppColors.ctaGradient;

    if (isFilled) {
      // Filled gradient button (Call)
      return GestureDetector(
        onTap: onTap,
        child: Container(
          height: 56.h,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(28.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                assetPath,
                width: 22.w,
                height: 22.w,
                color: Colors.white,
              ),
              SizedBox(width: 8.w),
              CustomText(
                label,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ],
          ),
        ),
      );
    }

    // Gradient border-only button (Chat)
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            height: 56.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28.r),
              color: Colors.transparent,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  assetPath,
                  width: 22.w,
                  height: 22.w,
                  color: Colors.white,
                ),
                SizedBox(width: 8.w),
                CustomText(
                  label,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: ShaderMask(
                shaderCallback: (Rect bounds) => gradient.createShader(bounds),
                blendMode: BlendMode.srcIn,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28.r),
                    border: Border.all(color: Colors.white, width: 1.5.w),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCallTap(ProfileItem profile) async {
    final success = await initiateCallWithSubscriptionCheck(
      context: context,
      ref: ref,
      recipientId: profile.id,
    );
    if (success && context.mounted) {
      context.go('/landing?tab=4');
    }
  }

  void _handleChatTap(ProfileItem profile) async {
    final allowed = await checkChatSubscription(context: context, ref: ref);
    if (!allowed || !context.mounted) return;
    context.go('/landing?tab=3&recipientId=${Uri.encodeComponent(profile.id)}');
  }
}
