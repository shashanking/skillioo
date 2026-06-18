import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:skillioo/features/profile/presentation/widgets/bio_tab.dart';
import 'package:skillioo/features/profile/presentation/widgets/certificates_tab.dart';
import 'package:skillioo/features/profile/presentation/widgets/posts_tab.dart';
import '../../../constants/app_constants.dart';
import '../../../core/widgets/custom_text.dart';
import '../../../core/widgets/gradient_cta_button.dart';
import '../../profile/application/current_profile_provider.dart';
import '../../profile/application/profile_detail_provider.dart';
import '../../dashboard/application/states/profile_list_state.dart';
import '../../follow/application/follow_providers.dart';
import '../../online/application/online_providers.dart';

class MyProfileScreen extends ConsumerStatefulWidget {
  const MyProfileScreen({super.key, this.isOwnProfile = true});

  final bool isOwnProfile;

  @override
  ConsumerState<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends ConsumerState<MyProfileScreen> {
  int _selectedTabIndex = 0;
  final GlobalKey<CertificatesTabState> _certificatesTabKey = GlobalKey();

  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  @override
  Widget build(BuildContext context) {
    final currentProfileAsync = ref.watch(currentProfileProvider);

    return currentProfileAsync.when(
      loading: () => const Scaffold(
        backgroundColor: Color(0xFF050505),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      ),
      error: (_, __) => const Scaffold(
        backgroundColor: Color(0xFF050505),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      ),
      data: (profile) {
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
              Positioned.fill(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 400.h),
                    child: Column(
                      children: [
                        _buildHeaderSection(profile),
                        SizedBox(height: 24.h),

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
                        SizedBox(height: 16.h),

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
                                : profile.onlineStatus.toUpperCase() ==
                                    'ONLINE';
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

                        Consumer(
                          builder: (context, ref, _) {
                            final followState = ref.watch(
                              followNotifierProvider,
                            );
                            return _buildStatsContainer(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatItem(
                                    _formatCount(followState.followerCount),
                                    'Followers',
                                  ),
                                  _buildStatItem(
                                    _formatCount(followState.followingCount),
                                    'Following',
                                  ),
                                  _buildStatItem('0', 'Reactions'),
                                  _buildStatItem('0', 'Impressions'),
                                ],
                              ),
                            );
                          },
                        ),

                        SizedBox(height: 16.h),

                        _buildStatsContainer(
                          transparent: false,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                profile.eventsDone.toString(),
                                'Events',
                              ),
                              ...profile.follows.take(2).map((social) {
                                return _buildSocialStatItem(
                                  Image.asset(
                                    social.socialMedia.toLowerCase() ==
                                            'facebook'
                                        ? 'assets/images/facebook.png'
                                        : 'assets/images/instagram.png',
                                    width: 24.w,
                                    height: 24.w,
                                    color: Colors.white,
                                  ),
                                  social.formattedFollowers,
                                );
                              }),
                              if (profile.follows.isEmpty) ...[
                                _buildSocialStatItem(
                                  Image.asset(
                                    'assets/images/facebook.png',
                                    width: 24.w,
                                    height: 24.w,
                                    color: Colors.white,
                                  ),
                                  '0',
                                ),
                                _buildSocialStatItem(
                                  Image.asset(
                                    'assets/images/instagram.png',
                                    width: 24.w,
                                    height: 24.w,
                                    color: Colors.white,
                                  ),
                                  '0',
                                ),
                              ] else if (profile.follows.length == 1) ...[
                                _buildSocialStatItem(
                                  Image.asset(
                                    'assets/images/instagram.png',
                                    width: 24.w,
                                    height: 24.w,
                                    color: Colors.white.withValues(alpha: 0.3),
                                  ),
                                  '0',
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 50.h,
                left: 20.w,
                right: 20.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                    ),
                    if (widget.isOwnProfile)
                      GestureDetector(
                        onTap: () => context.push('/edit-profile'),
                        child: Container(
                          width: 44.w,
                          height: 44.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(10.w),
                            child: Image.asset(
                              'assets/images/edit.png',
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                  ],
                ),
              ),

              DraggableScrollableSheet(
                controller: _sheetController,
                initialChildSize: 0.2,
                minChildSize: 0.2,
                maxChildSize: 1.0,
                builder:
                    (BuildContext context, ScrollController scrollController) {
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
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Column(
                            children: [
                              SizedBox(height: 22.h),
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

                              IndexedStack(
                                index: _selectedTabIndex,
                                children: [
                                  Builder(builder: (context) {
                                    final detail = ref.watch(
                                      profileDetailProvider(profile.id),
                                    );
                                    final detailBio = detail.whenOrNull(
                                      data: (d) {
                                        final bio = d['bio'] as String? ??
                                            (d['portfolio'] is Map
                                                ? (d['portfolio']
                                                        as Map)['bio']
                                                    as String?
                                                : null);
                                        return (bio != null && bio.isNotEmpty)
                                            ? bio
                                            : null;
                                      },
                                    );
                                    return BioTab(
                                      profile: profile,
                                      isOwnProfile: true,
                                      bioOverride: detailBio,
                                    );
                                  }),
                                  PostsTab(profile: profile),
                                  CertificatesTab(
                                    key: _certificatesTabKey,
                                    portfolioId: profile.portfolioId,
                                  ),
                                ],
                              ),

                              SizedBox(height: 20.h),
                              if (widget.isOwnProfile)
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20.w,
                                    vertical: 20.h,
                                  ),
                                  child: _buildActionButton(),
                                ),
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
      },
    );
  }

  Widget _buildActionButton() {
    String text;
    String assetPath;
    VoidCallback onTap;

    switch (_selectedTabIndex) {
      case 0:
        text = "Edit Charges";
        assetPath = 'assets/images/edit.png';
        onTap = () => context.push('/edit-hiring-charges');
        break;
      case 1:
        text = "Create Post";
        assetPath = 'assets/images/Follow.png';
        onTap = () => context.push('/profile-create-post');
        break;
      case 2:
        text = "Upload Certificate";
        assetPath = AppAssets.uploadIconPng;
        onTap = () async {
          await context.push('/profile-upload-certificate');
          _certificatesTabKey.currentState?.refresh();
        };
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

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

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

  Widget _buildHeaderSection(ProfileItem profile) {
    final photoUrl = profile.profilePhotoUrl;
    final hasUrl = photoUrl != null && photoUrl.isNotEmpty;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Background hero image — asset always rendered first so that if
        // NetworkImage fails it shows through instead of leaving the area blank.
        SizedBox(
          height: 220.h,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/professional-profile.jpg',
                fit: BoxFit.cover,
              ),
              if (hasUrl)
                Image.network(
                  photoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              // Gradient overlay
              Container(
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
            ],
          ),
        ),
        // Circle avatar
        Positioned(
          bottom: 0.h,
          child: Container(
            width: 130.w,
            height: 130.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF050505), width: 1.w),
            ),
            child: ClipOval(
              child: hasUrl
                  ? Image.network(
                      photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.asset(
                        'assets/images/professional-profile.jpg',
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(
                      'assets/images/professional-profile.jpg',
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

}
