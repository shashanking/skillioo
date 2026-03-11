import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../constants/app_constants.dart';
import '../../../../core/widgets/common_background.dart';
import '../../../../core/widgets/custom_text.dart';
import '../../../chat/application/chat_providers.dart';
import '../../application/dashboard_providers.dart';
import '../../application/states/profile_list_state.dart';
import 'profile_cards.dart';

class ProfilesReelsPage extends ConsumerStatefulWidget {
  const ProfilesReelsPage({super.key});

  @override
  ConsumerState<ProfilesReelsPage> createState() => _ProfilesReelsPageState();
}

class _ProfilesReelsPageState extends ConsumerState<ProfilesReelsPage> {
  int _selectedFilter = 0; // 0 = All, 1 = Professional, 2 = Skilled

  static const int _perPage = 20;

  String? get _proficiency {
    if (_selectedFilter == 1) return 'PROFESSIONAL';
    if (_selectedFilter == 2) return 'SKILLED';
    return null;
  }

  Future<void> _handleCallTap(String recipientId) async {
    final success = await ref
        .read(chatNotifierProvider.notifier)
        .initiateCall(recipientId);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Calling $recipientId...' : 'Failed to initiate call',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  void _handleChatTap(String recipientId) {
    context.go(
      '/landing?tab=3&recipientId=${Uri.encodeComponent(recipientId)}',
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(profileListNotifierProvider.notifier)
          .loadProfiles(
            perPage: _perPage,
            refresh: true,
            proficiency: _proficiency,
          );
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
    final state = ref.watch(profileListNotifierProvider);
    final cards = state.profiles.map((ProfileItem profile) {
      final photo = profile.profilePhotoUrl;
      return ProfileCardData(
        profileId: profile.id,
        name: profile.displayName,
        role: '${profile.city}, ${profile.country}',
        imagePath: photo ?? AppAssets.profileImg1,
        followers: '0',
        posts: profile.videos.length.toString(),
        isProfessional: profile.proficiency == 'PROFESSIONAL',
        following: '0',
        views: '0',
        socialFollowers: '0',
        isOnline: false,
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
                  ? const Center(
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
                  : PageView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount:
                          cards.length +
                          (state.hasMore ||
                                  (state.isLoading && cards.isNotEmpty)
                              ? 1
                              : 0),
                      onPageChanged: (index) {
                        _loadMoreIfNeeded(index);
                      },
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
                          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 106.h),
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
                            rating: card.rating,
                            isOnline: card.isOnline,
                            isProfessional: card.isProfessional,
                            onCall: () => _handleCallTap(card.profileId),
                            onChat: () => _handleChatTap(card.profileId),
                          ),
                        );
                      },
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
