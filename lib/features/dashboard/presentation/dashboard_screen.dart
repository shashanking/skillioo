import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/locale_extension.dart';
import '../../../core/services/session_prefs.dart';
import '../../../core/services/session_state_provider.dart';
import '../../../core/widgets/common_background.dart';
import '../../../core/widgets/custom_text.dart';
import '../../../core/widgets/pin_reauth_bottom_sheet.dart';
import '../../dashboard/application/dashboard_providers.dart';
import '../../dashboard/application/top_talent_photos_provider.dart';
import '../../dashboard/data/trending_talent_model.dart';
import '../../onboarding/application/category_provider.dart';
import '../../posts/application/post_providers.dart';
import '../../posts/presentation/full_post_view.dart';
import '../../profile/presentation/user_profile.dart';
import '../../subscription/application/subscription_providers.dart';
import 'widgets/category_chips.dart';
import 'widgets/custom_trending_carousel.dart';
import 'widgets/dashboard_search_bar.dart';
import 'widgets/dashboard_top_bar.dart';
import 'widgets/combined_media_grid.dart';
import 'widgets/profile_tab.dart';
import 'widgets/tab_toggle.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key, this.onScrollChanged});

  final ValueChanged<bool>? onScrollChanged;

  @override
  ConsumerState<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedTabIndex = 0;
  final GlobalKey _profileTabKey = GlobalKey();
  final GlobalKey _galleryGridKey = GlobalKey();
  final GlobalKey<DashboardSearchBarState> _searchBarKey =
      GlobalKey<DashboardSearchBarState>();
  final GlobalKey<CategoryChipsState> _categoryChipsKey =
      GlobalKey<CategoryChipsState>();
  String? _selectedCategory;
  String _searchQuery = '';
  final ScrollController _scrollController = ScrollController();
  static const double _scrollThreshold = 200.0;
  static const double _loadMoreThreshold = 300.0;
  bool _navVisibilitySyncScheduled = false;


  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Validate token in background (notifier sets tokenExpired if invalid)
      ref.read(sessionStateProvider.notifier).validateToken();

      // Sync subscription data
      final session = ref.read(sessionStateProvider);
      if (session.isLoggedIn) {
        ref.read(subscriptionNotifierProvider.notifier).fetchPlanAggregatorAndSync();
      }

      _scheduleNavBarVisibilitySync();
    });
  }

  // ── Trending carousel tap handlers ──────────────────────────────────────

  void _onTrendingNameTap(TrendingTalent talent) {
    if (talent.profileId.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserProfileScreen(profileId: talent.profileId),
      ),
    );
  }

  Future<void> _onTrendingImageTap(TrendingTalent talent) async {
    if (talent.profileId.isEmpty) return;

    final post = talent.latestPost;
    if (post == null) {
      _openTrendingProfile(talent.profileId);
      return;
    }

    String mediaUrl = (post.mediaUrl ?? '').trim();

    if (mediaUrl.isEmpty && post.documentIds.isNotEmpty) {
      final token = await SessionPrefs.instance.getAccessToken();
      if (token.isNotEmpty) {
        try {
          final docService = ref.read(postDocumentServiceProvider);
          final res = await docService.getDocumentsByIds(
            ids: post.documentIds.take(1).toList(),
            accessToken: token,
          );
          final list = res['data'];
          if (list is List) {
            final doc = list
                .whereType<Map<String, dynamic>>()
                .firstOrNull;
            final url = (doc?['url'] as String? ?? '').trim();
            if (url.isNotEmpty) {
              mediaUrl = url.startsWith('http://')
                  ? url.replaceFirst('http://', 'https://')
                  : url;
            }
          }
        } catch (_) {}
      }
    }

    if (!mounted) return;

    if (mediaUrl.isEmpty) {
      _openTrendingProfile(talent.profileId);
      return;
    }

    if (mediaUrl.startsWith('http://')) {
      mediaUrl = mediaUrl.replaceFirst('http://', 'https://');
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullPostViewScreen.single(
          mediaUrl: mediaUrl,
          isVideo: post.isVideo,
          recipientId: talent.profileId,
          profileName: talent.name,
          profilePhotoUrl: talent.profilePhotoUrl,
          category: post.category,
          subcategory: post.subCategory,
          proficiency: post.proficiency,
          description: post.description,
          mediaId: post.mediaId,
          totalLikes: post.totalLikes,
          totalComments: post.totalComments,
          totalViews: post.totalViews,
        ),
      ),
    );
  }

  void _openTrendingProfile(String profileId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserProfileScreen(profileId: profileId),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────

  Future<void> _handleLocationSelected(String? city) async {
    final normalizedCity = city?.trim() ?? '';
    await SessionPrefs.instance.setDashboardCityFilter(normalizedCity);
    if (!mounted) return;
    ref.read(dashboardCityFilterProvider.notifier).state =
        normalizedCity.isEmpty ? null : normalizedCity;
  }

  Future<void> _handleLocationCleared() async {
    await SessionPrefs.instance.setDashboardCityFilter(null);
    if (!mounted) return;
    ref.read(dashboardCityFilterProvider.notifier).state = null;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    _syncNavBarVisibility();

    final shouldLoadMore =
        _scrollController.position.maxScrollExtent - _scrollController.offset <=
        _loadMoreThreshold;
    if (_selectedTabIndex == 0 && shouldLoadMore) {
      final galleryGridState =
          _galleryGridKey.currentState as CombinedMediaGridState?;
      galleryGridState?.loadMorePosts();
    }
  }

  void _scheduleNavBarVisibilitySync() {
    if (_navVisibilitySyncScheduled) return;
    _navVisibilitySyncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navVisibilitySyncScheduled = false;
      _syncNavBarVisibility();
    });
  }

  void _syncNavBarVisibility() {
    if (!mounted) return;
    if (!_scrollController.hasClients) {
      widget.onScrollChanged?.call(true);
      return;
    }

    final position = _scrollController.position;
    final canScroll = position.maxScrollExtent > 0;
    if (!canScroll) {
      widget.onScrollChanged?.call(true);
      return;
    }

    final shouldShowNavBar = position.pixels > _scrollThreshold;
    widget.onScrollChanged?.call(shouldShowNavBar);
  }

  void _scrollToSearch() async {
    final ctx = _searchBarKey.currentContext;
    if (ctx == null) return;

    // First activate interactive mode (no keyboard yet)
    _searchBarKey.currentState?.setInteractive();

    await Scrollable.ensureVisible(
      ctx,
      alignment: 0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );

    widget.onScrollChanged?.call(true);

    // Wait for the scroll to fully settle before opening the keyboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchBarKey.currentState?.requestFocus();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  /// Called when speech-to-text yields a FINAL transcript. We try to
  /// auto-select a matching category chip so the user sees results
  /// pre-filtered by what they actually said. The text is also already
  /// dispatched via [_onSearchChanged] from the search bar — this hook
  /// only handles the chip side-effect.
  void _onVoiceResult(String spoken) {
    _categoryChipsKey.currentState?.selectByName(spoken);
  }

  /// Reset the dashboard back to a fresh state. Called by [Landing] when
  /// the user switches bottom-nav tabs so that the next visit starts
  /// at the top with no stale search/category filter.
  void resetForTabChange() {
    if (!mounted) return;

    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
    _searchBarKey.currentState?.reset();
    _categoryChipsKey.currentState?.resetSelection();

    if (_selectedCategory != null || _searchQuery.isNotEmpty) {
      setState(() {
        _selectedCategory = null;
        _searchQuery = '';
      });
    }
  }

  /// Smoothly scrolls Home back to the top and drops any active focus
  /// (e.g. dismisses the search-field keyboard). Used when the user taps
  /// the Home tab while already on Home. Unlike [resetForTabChange] this
  /// keeps the current search/category filter intact.
  void scrollToTopAndUnfocus() {
    if (!mounted) return;
    FocusScope.of(context).unfocus();
    if (_scrollController.hasClients && _scrollController.offset > 0) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cityFilter = ref.watch(dashboardCityFilterProvider);
    final isAnonymous = ref.watch(isAnonymousProvider);
    final categoryNames = ref.watch(categoryNamesProvider);

    // Show re-auth sheet when notifier detects an expired token
    ref.listen<SessionData>(sessionStateProvider, (prev, next) {
      if (next.tokenExpired && !(prev?.tokenExpired ?? false)) {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          isDismissible: false,
          enableDrag: false,
          builder: (_) => const PinReauthBottomSheet(),
        ).then((success) {
          ref.read(sessionStateProvider.notifier).clearTokenExpired();
          if (success != true && mounted) {
            SessionPrefs.instance.clear();
            ref.read(sessionStateProvider.notifier).refresh();
            context.go('/');
          }
        });
      }
    });

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
                  DashboardTopBar(
                    onLocationSelected: _handleLocationSelected,
                    onClearLocation: _handleLocationCleared,
                    selectedCity: cityFilter,
                  ),
                  // Non-creator users get the location picker but their
                  // top-bar pills (Logout + Create Profile) are too wide
                  // to fit a chip alongside. Render the chip on its own
                  // row beneath the bar instead.
                  Builder(
                    builder: (_) {
                      final session = ref.watch(sessionStateProvider);
                      final isCreator =
                          session.profile?['isCreator'] as bool? ?? false;
                      final showBelow = !session.isAnonymous &&
                          !isCreator &&
                          (cityFilter?.trim().isNotEmpty == true);
                      if (!showBelow) return const SizedBox.shrink();
                      return Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 12.h),
                        child: SelectedLocationCard(
                          city: cityFilter!.trim(),
                          onClear: _handleLocationCleared,
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: CustomText(
                      ref.tr.trending,
                      fontFamily: 'Neue',
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  CustomTrendingCarousel(
                    talents: ref.watch(topTalentsProvider),
                    onImageTap: _onTrendingImageTap,
                    onNameTap: _onTrendingNameTap,
                  ),
                  SizedBox(height: 54.h),
                  DashboardSearchBar(
                    key: _searchBarKey,
                    onTap: _scrollToSearch,
                    onSearchChanged: _onSearchChanged,
                    onVoiceResult: _onVoiceResult,
                  ),
                  SizedBox(height: 12.h),
                  categoryNames.when(
                    loading: () => SizedBox(
                      height: 40.h,
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (names) => CategoryChips(
                      key: _categoryChipsKey,
                      categories: ['All', ...names],
                      onCategoryChanged: (category) {
                        setState(() => _selectedCategory = category);
                        final profileTabState =
                            _profileTabKey.currentState as ProfileTabState?;
                        profileTabState?.loadProfilesWithCategory(
                          _selectedCategory,
                          city: cityFilter,
                        );
                        final galleryGridState =
                            _galleryGridKey.currentState
                                as CombinedMediaGridState?;
                        galleryGridState?.loadProfilesWithCategory(
                          _selectedCategory,
                          city: cityFilter,
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 12.h),
                  if (!isAnonymous) ...[
                    TabToggle(
                      selectedIndex: _selectedTabIndex,
                      onTabChanged: (i) =>
                          setState(() => _selectedTabIndex = i),
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
                  ],
                  // Keep both tabs alive to avoid re-fetching on every switch
                  Offstage(
                    offstage: !isAnonymous && _selectedTabIndex != 0,
                    child: CombinedMediaGrid(
                      key: _galleryGridKey,
                      cityFilter: cityFilter,
                      searchQuery: _searchQuery,
                    ),
                  ),
                  if (!isAnonymous)
                    Offstage(
                      offstage: _selectedTabIndex != 1,
                      child: ProfileTab(
                        key: _profileTabKey,
                        cityFilter: cityFilter,
                        searchQuery: _searchQuery,
                      ),
                    ),
                  // Ensure enough scroll space so search bar can always scroll to top
                  SizedBox(height: MediaQuery.of(context).size.height * 0.8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
