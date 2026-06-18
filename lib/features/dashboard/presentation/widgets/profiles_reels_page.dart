import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:skillioo/constants/app_constants.dart';
import 'package:skillioo/core/widgets/common_background.dart';
import 'package:skillioo/core/widgets/custom_text.dart';

import '../../../../core/utils/call_utils.dart';
import '../../application/dashboard_providers.dart';
import '../../application/states/profile_list_state.dart';
import '../../../follow/application/follow_providers.dart';
import 'profile_cards.dart';

class ProfilesReelsPage extends ConsumerStatefulWidget {
  const ProfilesReelsPage({super.key});

  @override
  ConsumerState<ProfilesReelsPage> createState() => _ProfilesReelsPageState();
}

class _ProfilesReelsPageState extends ConsumerState<ProfilesReelsPage> {
  int _selectedFilter = 0; // 0 = All, 1 = Professional, 2 = Skilled
  bool _didAutoRetry = false;

  static const int _perPage = 20;

  String? get _proficiency {
    if (_selectedFilter == 1) return 'PROFESSIONAL';
    if (_selectedFilter == 2) return 'SKILLED';
    return null;
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  Future<void> _handleCallTap(String recipientId) async {
    await initiateCallWithSubscriptionCheck(
      context: context,
      ref: ref,
      recipientId: recipientId,
    );
  }

  void _handleChatTap(String recipientId) async {
    final allowed = await checkChatSubscription(context: context, ref: ref);
    if (!allowed || !mounted) return;
    context.go(
      '/landing?tab=3&recipientId=${Uri.encodeComponent(recipientId)}',
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Profiles are preloaded by Landing — only fetch if missing
      final state = ref.read(profileListNotifierProvider);
      if (state.profiles.isEmpty && !state.isLoading) {
        ref
            .read(profileListNotifierProvider.notifier)
            .loadProfiles(
              perPage: _perPage,
              refresh: true,
              proficiency: _proficiency,
            );
      }
    });
  }

  Future<void> _loadMoreIfNeeded(int index) async {
    final state = ref.read(profileListNotifierProvider);
    if (state.isLoading || !state.hasMore) return;
    if (index < state.profiles.length - 2) return;
    await ref
        .read(profileListNotifierProvider.notifier)
        .loadProfiles(
          perPage: _perPage,
          page: state.currentPage + 1,
          refresh: false,
          proficiency: _proficiency,
        );
  }

  Future<void> _retry() async {
    await ref
        .read(profileListNotifierProvider.notifier)
        .loadProfiles(
          perPage: _perPage,
          refresh: true,
          proficiency: _proficiency,
        );
  }

  @override
  Widget build(BuildContext context) {
    // Auto-retry once when the first profile load transitions to error with
    // empty data — covers transient cold-start failures.
    ref.listen<ProfileListState>(profileListNotifierProvider, (prev, next) {
      final wasLoading = prev?.isLoading ?? false;
      if (wasLoading &&
          !next.isLoading &&
          next.hasError &&
          next.profiles.isEmpty &&
          !_didAutoRetry) {
        _didAutoRetry = true;
        Future.delayed(const Duration(milliseconds: 800), () {
          if (!mounted) return;
          _retry();
        });
      }
    });

    final state = ref.watch(profileListNotifierProvider);
    final followerDeltas = ref.watch(followNotifierProvider.select((s) => s.followerCountOverrides));
    // Exclude hirer profiles — only show talent profiles that have a category
    // or proficiency set. Hirers have neither.
    final talentProfiles = state.profiles
        .where((p) => p.category.isNotEmpty || p.proficiency.isNotEmpty)
        .toList();
    final cards = talentProfiles.map((ProfileItem profile) {
      final photo = profile.profilePhotoUrl;
      final effectiveFollowers = profile.followerCount + (followerDeltas[profile.id] ?? 0);
      return ProfileCardData(
        profileId: profile.id,
        name: profile.displayName,
        role: profile.category.isNotEmpty
            ? profile.category.toUpperCase()
            : 'Category',
        imagePath: photo ?? AppAssets.profileImg1,
        followers: _formatCount(effectiveFollowers.clamp(0, 999999)),
        posts: profile.videos.length.toString(),
        isProfessional: profile.proficiency == 'PROFESSIONAL',
        following: _formatCount(profile.followingCount),
        views: _formatCount(profile.totalViews),
        socialFollowers: '0',
        socialMediaFollows: profile.follows,
        eventsDone: profile.eventsDone,
        isOnline: profile.onlineStatus.toUpperCase() == 'ONLINE',
      );
    }).toList();

    return CommonBackground(
      child: SafeArea(
        child: Column(
          children: [
            // Toggle header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  CustomText(
                    'Profiles',
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Neue',
                    color: AppColors.foundationBlack20,
                  ),
                  const Spacer(),
                  _buildFilterChip(0, 'All'),
                  SizedBox(width: 8.w),
                  _buildFilterChip(1, 'Professional'),
                  SizedBox(width: 8.w),
                  _buildFilterChip(2, 'Skilled'),
                ],
              ),
            ),
            // PageView of profile cards
            Expanded(
              child: (state.isLoading && cards.isEmpty)
                  ? Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : (state.hasError && cards.isEmpty)
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.w),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomText(
                              state.errorMessage.isNotEmpty
                                  ? state.errorMessage
                                  : 'Failed to load profiles',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.foundationBlack80,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 12.h),
                            SizedBox(
                              height: 44.h,
                              child: TextButton(
                                onPressed: _retry,
                                style: TextButton.styleFrom(
                                  backgroundColor: AppColors.glassWhite12,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                ),
                                child: CustomText(
                                  'Retry',
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.foundationBlack20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : cards.isEmpty
                  ? Center(
                      child: CustomText(
                        'No profiles found',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.foundationBlack80,
                      ),
                    )
                  : NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification is ScrollEndNotification) {
                          final metrics = notification.metrics;
                          if (metrics.pixels >= metrics.maxScrollExtent - 300) {
                            _loadMoreIfNeeded(cards.length - 1);
                          }
                        }
                        return false;
                      },
                      child: ListView.builder(
                        padding: EdgeInsets.only(bottom: 140.h),
                        itemCount:
                            cards.length +
                            (state.hasMore ||
                                    (state.isLoading && cards.isNotEmpty)
                                ? 1
                                : 0),
                        itemBuilder: (context, index) {
                          if (index >= cards.length) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.w),
                                child: SizedBox(
                                  width: 22.w,
                                  height: 22.w,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                ),
                              ),
                            );
                          }

                          final card = cards[index];
                          return Padding(
                            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
                            child: ProfileCard(
                              profileId: card.profileId,
                              name: card.name,
                              role: card.role,
                              imagePath: card.imagePath,
                              followers: card.followers,
                              following: card.following,
                              views: card.views,
                              posts: card.posts,
                              socialFollowers: card.socialFollowers,
                              socialMediaFollows: card.socialMediaFollows,
                              eventsDone: card.eventsDone,
                              isOnline: card.isOnline,
                              isProfessional: card.isProfessional,
                              onCall: () => _handleCallTap(card.profileId),
                              onChat: () => _handleChatTap(card.profileId),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(int index, String label) {
    final isSelected = _selectedFilter == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedFilter = index);
        ref
            .read(profileListNotifierProvider.notifier)
            .loadProfiles(
              perPage: _perPage,
              refresh: true,
              proficiency: _proficiency,
            );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [AppColors.accentCyan, AppColors.accentPink],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                )
              : null,
          color: isSelected ? null : AppColors.glassWhite12,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: CustomText(
          label,
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.foundationBlack20,
        ),
      ),
    );
  }
}
