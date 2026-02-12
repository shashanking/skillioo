import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/app_constants.dart';
import '../../../core/widgets/common_background.dart';
import '../../../core/widgets/custom_text.dart';
import '../data/trending_talent_model.dart';
import 'widgets/category_chips.dart';
import 'widgets/custom_trending_carousel.dart';
import 'widgets/dashboard_search_bar.dart';
import 'widgets/dashboard_top_bar.dart';
import 'widgets/gallery_grid.dart';
import 'widgets/profile_tab.dart';
import 'widgets/tab_toggle.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedTabIndex = 0;
  final GlobalKey _profileTabKey = GlobalKey();

  static const _categories = ['Cricketer', 'Dancer', 'Singer', 'Gymnast'];

  static final _trendingTalents = [
    TrendingTalent(
      name: 'Lisa Singer',
      views: '2.5M Views',
      likes: '2K Likes',
      timer: '1:25',
      imagePath: AppAssets.professionalJpg,
      tintColor: const Color(0xFF1A7F8F),
    ),
    TrendingTalent(
      name: 'Lisa Singer',
      views: '2.5M Views',
      likes: '2K Likes',
      timer: '1:25',
      imagePath: AppAssets.professionalJpg,
      tintColor: const Color(0xFF6B2FA0),
    ),
    TrendingTalent(
      name: 'Lisa Singer',
      views: '2.5M Views',
      likes: '2K Likes',
      timer: '1:25',
      imagePath: AppAssets.professionalJpg,
      tintColor: const Color(0xFF8A9F3F),
    ),
    TrendingTalent(
      name: 'Lisa Singer',
      views: '2.5M Views',
      likes: '2K Likes',
      timer: '1:25',
      imagePath: AppAssets.professionalJpg,
      tintColor: const Color(0xFF3F5F9F),
    ),
  ];

  static final _galleryItems = [
    GalleryItem(
      type: 'Professional',
      imagePath: AppAssets.professionalProfileJpg,
    ),
    GalleryItem(
      type: 'Professional',
      imagePath: AppAssets.professionalProfileJpg,
    ),
    GalleryItem(type: 'Skilled', imagePath: AppAssets.skilledProfileJpg),
    GalleryItem(
      type: 'Professional',
      imagePath: AppAssets.professionalProfileJpg,
    ),
    GalleryItem(
      type: 'Professional',
      imagePath: AppAssets.professionalProfileJpg,
    ),
    GalleryItem(type: 'Skilled', imagePath: AppAssets.skilledProfileJpg),
    GalleryItem(
      type: 'Professional',
      imagePath: AppAssets.professionalProfileJpg,
    ),
    GalleryItem(
      type: 'Professional',
      imagePath: AppAssets.professionalProfileJpg,
    ),
    GalleryItem(type: 'Skilled', imagePath: AppAssets.skilledProfileJpg),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CommonBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DashboardTopBar(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: CustomText(
                    'Trending Talent',
                    fontFamily: 'Neue',
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                CustomTrendingCarousel(talents: _trendingTalents),
                SizedBox(height: 54.h),
                const DashboardSearchBar(),
                SizedBox(height: 16.h),
                CategoryChips(categories: _categories),
                SizedBox(height: 24.h),
                TabToggle(
                  selectedIndex: _selectedTabIndex,
                  onTabChanged: (i) => setState(() => _selectedTabIndex = i),
                  onProfileTypeChanged: (type) {
                    // Notify profile tab of the change
                    final profileTabState =
                        _profileTabKey.currentState as ProfileTabState?;
                    if (profileTabState != null) {
                      profileTabState.updateProfileType(type);
                    }
                  },
                ),
                SizedBox(height: 16.h),
                if (_selectedTabIndex == 0)
                  GalleryGrid(items: _galleryItems)
                else
                  ProfileTab(key: _profileTabKey),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
