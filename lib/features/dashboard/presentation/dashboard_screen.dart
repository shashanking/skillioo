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
import 'widgets/combined_media_grid.dart';
import 'widgets/profile_tab.dart';
import 'widgets/tab_toggle.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, this.onScrollChanged});

  final ValueChanged<bool>? onScrollChanged;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedTabIndex = 0;
  final GlobalKey _profileTabKey = GlobalKey();
  final GlobalKey _galleryGridKey = GlobalKey();
  final GlobalKey<DashboardSearchBarState> _searchBarKey =
      GlobalKey<DashboardSearchBarState>();
  String? _selectedCategory;
  final ScrollController _scrollController = ScrollController();
  static const double _scrollThreshold = 200.0;
  static const double _loadMoreThreshold = 300.0;

  static const _categories = [
    'All',
    'Cricketer',
    'Dancer',
    'Singer',
    'Gymnast',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final shouldShowNavBar = _scrollController.offset > _scrollThreshold;
    widget.onScrollChanged?.call(shouldShowNavBar);

    final shouldLoadMore =
        _scrollController.position.maxScrollExtent - _scrollController.offset <=
        _loadMoreThreshold;
    if (_selectedTabIndex == 0 && shouldLoadMore) {
      final galleryGridState =
          _galleryGridKey.currentState as CombinedMediaGridState?;
      galleryGridState?.loadMorePosts();
    }
  }

  void _scrollToSearch() async {
    final ctx = _searchBarKey.currentContext;
    if (ctx == null) return;

    await Scrollable.ensureVisible(
      ctx,
      alignment: 0.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );

    // After scroll completes, focus the search field to show keyboard
    await Future.delayed(const Duration(milliseconds: 50));
    _searchBarKey.currentState?.requestFocus();
  }

  static final _trendingTalents = [
    TrendingTalent(
      name: 'Top Artist',
      views: '1.2M Views',
      likes: '8K Likes',
      timer: '1:25',
      imagePath: AppAssets.welcomeCardLeft,
      tintColor: const Color(0xFF8F39B2),
    ),
    TrendingTalent(
      name: 'Top Talent',
      views: '2.5M Views',
      likes: '12K Likes',
      timer: '2:10',
      imagePath: AppAssets.welcomeCardCenter,
      tintColor: const Color(0xFF1A7F8F),
    ),
    TrendingTalent(
      name: 'Top Creator',
      views: '980K Views',
      likes: '5K Likes',
      timer: '0:55',
      imagePath: AppAssets.welcomeCardRight,
      tintColor: const Color(0xFF2F208E),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CommonBackground(
        child: SafeArea(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              FocusScope.of(context).unfocus();
              _searchBarKey.currentState?.reset();
            },
            child: SingleChildScrollView(
              controller: _scrollController,
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
                  DashboardSearchBar(
                    key: _searchBarKey,
                    onTap: _scrollToSearch,
                  ),
                  SizedBox(height: 16.h),
                  CategoryChips(
                    categories: _categories,
                    onCategoryChanged: (category) {
                      setState(() => _selectedCategory = category);
                      // Reload profiles with category filter
                      final profileTabState =
                          _profileTabKey.currentState as ProfileTabState?;
                      profileTabState?.loadProfilesWithCategory(
                        _selectedCategory,
                      );
                      // Reload gallery grid
                      final galleryGridState =
                          _galleryGridKey.currentState
                              as CombinedMediaGridState?;
                      galleryGridState?.loadProfilesWithCategory(
                        _selectedCategory,
                      );
                    },
                  ),
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
                    CombinedMediaGrid(key: _galleryGridKey)
                  else
                    ProfileTab(key: _profileTabKey),
                  SizedBox(height: 100.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
