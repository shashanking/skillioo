import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/call_utils.dart';
import '../../application/dashboard_providers.dart';
import '../../application/states/profile_list_state.dart';
import '../../../follow/application/follow_providers.dart';
import 'profile_cards.dart';
import 'profile_dropdown.dart';

class ProfileTab extends ConsumerStatefulWidget {
  const ProfileTab({super.key, this.cityFilter, this.searchQuery = ''});

  final String? cityFilter;
  final String searchQuery;

  @override
  ProfileTabState createState() => ProfileTabState();
}

class ProfileTabState extends ConsumerState<ProfileTab> {
  static const int _perPage = 20;

  String? _category;
  String? _proficiency;
  bool _didAutoRetry = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Only load profiles if not already loaded (Landing preloads shared data)
      final state = ref.read(profileListNotifierProvider);
      if (state.profiles.isEmpty && !state.isLoading) {
        ref
            .read(profileListNotifierProvider.notifier)
            .loadProfiles(
              perPage: _perPage,
              refresh: true,
              city: widget.cityFilter,
            );
      }
      // Follow data is preloaded by Landing — no duplicate calls needed
    });
  }

  @override
  void didUpdateWidget(covariant ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cityFilter != widget.cityFilter) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref
            .read(profileListNotifierProvider.notifier)
            .loadProfiles(
              perPage: _perPage,
              refresh: true,
              category: _category,
              proficiency: _proficiency,
              city: widget.cityFilter,
            );
      });
    }
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
          city: widget.cityFilter,
        );
  }

  void loadProfilesWithCategory(String? category, {String? city}) {
    _category = category;
    ref
        .read(profileListNotifierProvider.notifier)
        .loadProfiles(
          perPage: _perPage,
          refresh: true,
          category: _category,
          proficiency: _proficiency,
          city: city ?? widget.cityFilter,
        );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
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
          city: widget.cityFilter,
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
    final success = await initiateCallWithSubscriptionCheck(
      context: context,
      ref: ref,
      recipientId: recipientId,
    );
    if (!mounted || !success) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling $recipientId...'),
        backgroundColor: Colors.green,
      ),
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
  Widget build(BuildContext context) {
    // Auto-retry once on first failed load (transient cold-start failures).
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

    if (state.isLoading && state.profiles.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32.h),
          child: CircularProgressIndicator(color: Colors.white),
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

    // Exclude hirer profiles — only show talent profiles that have a category
    // or proficiency set. Hirers have neither.
    final talentProfiles = state.profiles
        .where((p) => p.category.isNotEmpty || p.proficiency.isNotEmpty)
        .toList();

    // Client-side search filter — match across every meaningful profile
    // field we hold locally so the user can search by name, nickname,
    // category, location, contact, or profile-type.
    final query = widget.searchQuery.toLowerCase().trim();
    final filteredProfiles = query.isEmpty
        ? talentProfiles
        : talentProfiles.where((profile) {
            bool matches(String s) =>
                s.isNotEmpty && s.toLowerCase().contains(query);
            return matches(profile.displayName) ||
                matches(profile.firstName) ||
                matches(profile.lastName) ||
                matches(profile.groupName) ||
                matches(profile.nickName) ||
                matches(profile.category) ||
                matches(profile.subCategory) ||
                matches(profile.bio) ||
                matches(profile.proficiency) ||
                matches(profile.profileType) ||
                matches(profile.city) ||
                matches(profile.country) ||
                profile.email.any(matches) ||
                profile.phoneNumber.any(matches);
          }).toList();

    if (filteredProfiles.isEmpty && query.isNotEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32.h),
          child: Text(
            'No profiles match "$query"',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 16.sp,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    }

    final cards = filteredProfiles.map((profile) {
      final effectiveFollowers = profile.followerCount + (followerDeltas[profile.id] ?? 0);
      return ProfileCardData(
        profileId: profile.id,
        name: profile.displayName,
        role: profile.category.isNotEmpty ? profile.category.toUpperCase() : 'Category',
        imagePath: profile.profilePhotoUrl ?? 'assets/images/profile-img-1.jpg',
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
