import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../chat/application/chat_providers.dart';
import '../../application/dashboard_providers.dart';
import 'profile_cards.dart';
import 'profile_dropdown.dart';

class ProfileTab extends ConsumerStatefulWidget {
  const ProfileTab({super.key});

  @override
  ProfileTabState createState() => ProfileTabState();
}

class ProfileTabState extends ConsumerState<ProfileTab> {
  static const int _perPage = 20;

  String? _category;
  String? _proficiency;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(profileListNotifierProvider.notifier)
          .loadProfiles(perPage: _perPage, refresh: true);
    });
  }

  void updateProfileType(ProfileType? type) {
    String? proficiency;
    if (type == ProfileType.professional) {
      proficiency = 'PROFESSIONAL';
    } else if (type == ProfileType.skilled) {
      proficiency = 'SKILLED';
    }

    _proficiency = proficiency;

    ref
        .read(profileListNotifierProvider.notifier)
        .loadProfiles(
          perPage: _perPage,
          refresh: true,
          category: _category,
          proficiency: _proficiency,
        );
  }

  void loadProfilesWithCategory(String? category) {
    _category = category;
    ref
        .read(profileListNotifierProvider.notifier)
        .loadProfiles(
          perPage: _perPage,
          refresh: true,
          category: _category,
          proficiency: _proficiency,
        );
  }

  Future<void> _loadMore() async {
    final state = ref.read(profileListNotifierProvider);
    if (state.isLoading || !state.hasMore) return;
    await ref
        .read(profileListNotifierProvider.notifier)
        .loadProfiles(
          perPage: _perPage,
          page: state.currentPage + 1,
          refresh: false,
          category: _category,
          proficiency: _proficiency,
        );
  }

  Future<void> _retry() async {
    await ref
        .read(profileListNotifierProvider.notifier)
        .loadProfiles(
          perPage: _perPage,
          refresh: true,
          category: _category,
          proficiency: _proficiency,
        );
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
  Widget build(BuildContext context) {
    final state = ref.watch(profileListNotifierProvider);

    if (state.isLoading && state.profiles.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32.h),
          child: CircularProgressIndicator(
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      );
    }

    if (state.hasError && state.profiles.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.errorMessage.isNotEmpty
                    ? state.errorMessage
                    : 'Failed to load profiles',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 16.sp,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                height: 44.h,
                child: TextButton(
                  onPressed: state.isLoading ? null : _retry,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(48.r),
                    ),
                    backgroundColor: Colors.white.withValues(alpha: 0.12),
                  ),
                  child: Text(
                    'Retry',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state.profiles.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32.h),
          child: Text(
            'No profiles available',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 16.sp,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    }

    final cards = state.profiles.map((profile) {
      return ProfileCardData(
        profileId: profile.id,
        name: profile.displayName,
        role: '${profile.city}, ${profile.country}',
        imagePath: profile.profilePhotoUrl ?? 'assets/images/profile-img-1.jpg',
        followers: '0',
        posts: profile.videos.length.toString(),
        isProfessional: profile.proficiency == 'PROFESSIONAL',
        following: '0',
        views: '0',
        socialFollowers: '0',
        isOnline: false,
      );
    }).toList();

    return ProfileCardGrid(
      cards: cards,
      showLoadMore: state.hasMore,
      isLoadingMore: state.isLoading && state.profiles.isNotEmpty,
      onLoadMore: _loadMore,
      onCall: (card) => _handleCallTap(card.profileId),
      onChat: (card) => _handleChatTap(card.profileId),
    );
  }
}
