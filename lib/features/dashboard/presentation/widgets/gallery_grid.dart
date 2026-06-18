import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../application/dashboard_providers.dart';
import '../../application/states/profile_list_state.dart';
import '../../../profile/presentation/user_profile.dart';

class GalleryItem {
  final String type;
  final String imagePath;

  const GalleryItem({required this.type, required this.imagePath});
}

class GalleryGrid extends ConsumerStatefulWidget {
  const GalleryGrid({super.key});

  @override
  ConsumerState<GalleryGrid> createState() => GalleryGridState();
}

class GalleryGridState extends ConsumerState<GalleryGrid> {
  bool _didAutoRetry = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(profileListNotifierProvider.notifier)
          .loadProfiles(perPage: 20, refresh: true);
    });
  }

  void loadProfilesWithCategory(String? category) {
    ref
        .read(profileListNotifierProvider.notifier)
        .loadProfiles(perPage: 20, refresh: true, category: category);
  }

  Future<void> _retry() async {
    await ref
        .read(profileListNotifierProvider.notifier)
        .loadProfiles(perPage: 20, refresh: true);
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
                    : "We couldn't load the gallery right now.",
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

    final allVideos = <VideoItem>[];
    for (final profile in state.profiles) {
      for (final video in profile.videos) {
        allVideos.add(
          VideoItem(
            url: video.normalizedUrl,
            proficiency: profile.proficiency,
            profileName: profile.displayName,
            profileId: profile.id,
          ),
        );
      }
    }

    if (allVideos.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32.h),
          child: Text(
            'No videos available',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 16.sp,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 1.0,
        ),
        itemCount: allVideos.length,
        itemBuilder: (context, index) {
          return _GalleryCard(item: allVideos[index]);
        },
      ),
    );
  }
}

class _VideoPreview extends StatefulWidget {
  const _VideoPreview({super.key, required this.url});

  final String url;

  @override
  State<_VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<_VideoPreview> {
  @override
  Widget build(BuildContext context) {
    // IMPORTANT: don't create VideoPlayerController inside grid tiles.
    // It quickly creates many ExoPlayer instances and can OOM.
    return Container(
      color: Colors.black.withValues(alpha: 0.15),
      alignment: Alignment.center,
      child: Icon(
        Icons.play_circle_fill,
        color: Colors.white.withValues(alpha: 0.7),
        size: 34.sp,
      ),
    );
  }
}

class VideoItem {
  final String url;
  final String proficiency;
  final String profileName;
  final String profileId;

  const VideoItem({
    required this.url,
    required this.proficiency,
    required this.profileName,
    required this.profileId,
  });
}

class _GalleryCard extends StatelessWidget {
  final VideoItem item;

  const _GalleryCard({required this.item});

  bool _isVideoUrl(String url) {
    final lower = url.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.webm') ||
        lower.contains('/video/upload/');
  }

  @override
  Widget build(BuildContext context) {
    final isProfessional = item.proficiency == 'PROFESSIONAL';
    final borderColor = isProfessional
        ? const Color(0xFF8F39B2).withValues(alpha: 0.6)
        : const Color(0xFF2F208E).withValues(alpha: 0.6);

    final isVideo = item.url.isNotEmpty && _isVideoUrl(item.url);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => UserProfileScreen(profileId: item.profileId),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: borderColor, width: 1.5.w),
          color: Colors.white.withValues(alpha: 0.1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            if (item.url.isNotEmpty && !isVideo)
              Positioned.fill(
                child: Image.network(
                  item.url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      color: Colors.black.withValues(alpha: 0.15),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white.withValues(alpha: 0.85),
                        size: 26.sp,
                      ),
                    );
                  },
                ),
              )
            else if (isVideo)
              Positioned.fill(
                child: _VideoPreview(key: ValueKey(item.url), url: item.url),
              )
            else
              Positioned.fill(
                child: Container(color: Colors.black.withValues(alpha: 0.15)),
              ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.r),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 6.w,
              left: 6.w,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6.r),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: isProfessional
                          ? const Color(0xFF8F39B2).withValues(alpha: 0.5)
                          : const Color(0xFF2F208E).withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      isProfessional ? 'Professional' : 'Skilled',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
