import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../constants/app_constants.dart';
import '../../../../core/widgets/common_background.dart';
import '../../../../core/widgets/custom_text.dart';
import 'profile_cards.dart';

class ProfilesReelsPage extends StatefulWidget {
  const ProfilesReelsPage({super.key});

  @override
  State<ProfilesReelsPage> createState() => _ProfilesReelsPageState();
}

class _ProfilesReelsPageState extends State<ProfilesReelsPage> {
  int _selectedFilter = 0; // 0 = All, 1 = Professional, 2 = Skilled

  final List<ProfileCardData> _allCards = [
    ProfileCardData(
      name: 'Alex Johnson',
      role: 'UI/UX Designer',
      imagePath: AppAssets.professionalProfileJpg,
      followers: '12.5K',
      posts: '48',
      isProfessional: true,
      following: '23K',
      views: '2M',
      socialFollowers: '312K',
      isOnline: true,
    ),
    ProfileCardData(
      name: 'Sarah Williams',
      role: 'Photographer',
      imagePath: AppAssets.skilledProfileJpg,
      followers: '8.2K',
      posts: '126',
      isProfessional: false,
      following: '23K',
      views: '2M',
      socialFollowers: '312K',
      isOnline: true,
    ),
    ProfileCardData(
      name: 'Mike Chen',
      role: 'Video Editor',
      imagePath: AppAssets.profileImg1,
      followers: '15.7K',
      posts: '89',
      isProfessional: true,
      following: '23K',
      views: '2M',
      socialFollowers: '312K',
    ),
    ProfileCardData(
      name: 'Emma Davis',
      role: 'Content Creator',
      imagePath: AppAssets.profileImg1,
      followers: '6.8K',
      posts: '234',
      isProfessional: false,
      following: '23K',
      views: '2M',
      socialFollowers: '312K',
    ),
    ProfileCardData(
      name: 'James Wilson',
      role: 'Brand Designer',
      imagePath: AppAssets.professionalProfileJpg,
      followers: '9.3K',
      posts: '67',
      isProfessional: true,
      following: '23K',
      views: '2M',
      socialFollowers: '312K',
    ),
  ];

  List<ProfileCardData> get _filteredCards {
    if (_selectedFilter == 0) return _allCards;
    if (_selectedFilter == 1) {
      return _allCards.where((c) => c.isProfessional).toList();
    }
    return _allCards.where((c) => !c.isProfessional).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cards = _filteredCards;
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
              child: cards.isEmpty
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
                      itemCount: cards.length,
                      itemBuilder: (context, index) {
                        final card = cards[index];
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          child: ProfileCard(
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
      onTap: () => setState(() => _selectedFilter = index),
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
