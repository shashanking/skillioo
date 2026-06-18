import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/custom_text.dart';
import '../../data/trending_talent_model.dart';

/// Renders the inner image for a trending-talent card.
///
/// Swap-only widget: same `BoxFit.cover` fill as the original
/// `Image.asset` call, so size/border/styling on the parent containers
/// stay untouched. When [TrendingTalent.profilePhotoUrl] is non-empty
/// we draw the user's profile photo; otherwise we fall back to the
/// static asset.
class _TalentInnerImage extends StatelessWidget {
  final TrendingTalent talent;

  const _TalentInnerImage({required this.talent});

  @override
  Widget build(BuildContext context) {
    final url = talent.profilePhotoUrl;
    if (url == null || url.isEmpty) {
      return Image.asset(talent.imagePath, fit: BoxFit.cover);
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      // Don't flash an empty box while the photo loads — keep the
      // placeholder asset visible until the network image is ready.
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) return child;
        return Image.asset(talent.imagePath, fit: BoxFit.cover);
      },
      errorBuilder: (context, error, stackTrace) =>
          Image.asset(talent.imagePath, fit: BoxFit.cover),
    );
  }
}

class TrendingTalentSimpleCard extends StatelessWidget {
  final TrendingTalent talent;

  static const double _cardSize = 124;

  const TrendingTalentSimpleCard({super.key, required this.talent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _cardSize,
      height: _cardSize,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24.r)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _TalentInnerImage(talent: talent),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TrendingTalentStatChip(text: talent.views),
                  SizedBox(height: 4.h),
                  TrendingTalentStatChip(text: talent.likes),
                  const Spacer(),
                  Center(
                    child: TrendingTalentNameChip(
                      name: talent.name,
                      imagePath: talent.imagePath,
                      profilePhotoUrl: talent.profilePhotoUrl,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClearGlassPanel extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final double tintAlpha;
  final double blurSigma;
  final double refractDx;
  final double refractDy;

  const _ClearGlassPanel({
    required this.width,
    required this.height,
    required this.radius,
    required this.tintAlpha,
    required this.blurSigma,
    required this.refractDx,
    required this.refractDy,
  });

  @override
  Widget build(BuildContext context) {
    final matrix = Float64List.fromList(<double>[
      1.0,
      0.0,
      0.0,
      0.0,
      0.0,
      1.0,
      0.0,
      0.0,
      0.0,
      0.0,
      1.0,
      0.0,
      refractDx,
      refractDy,
      0.0,
      1.0,
    ]);

    final filter = ImageFilter.compose(
      outer: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
      inner: ImageFilter.matrix(matrix),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: filter,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: tintAlpha),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: Colors.white.withValues(alpha: tintAlpha * 1.4),
              width: 0.6.w,
            ),
          ),
        ),
      ),
    );
  }
}

class TrendingTalentCenterStackCard extends StatelessWidget {
  final TrendingTalent talent;
  final String timerText;

  static const double _outerSize = 180;
  static const double _outerPanelSize = 178;
  static const double _innerPanelSize = 154;
  static const double _imageSize = 124;

  const TrendingTalentCenterStackCard({
    super.key,
    required this.talent,
    required this.timerText,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _outerSize,
      height: _outerSize,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Center(
            child: _ClearGlassPanel(
              width: _outerPanelSize,
              height: _outerPanelSize,
              radius: 48.r,
              tintAlpha: 0.06,
              blurSigma: 2.0,
              refractDx: 1.2,
              refractDy: 0.8,
            ),
          ),
          Center(
            child: _ClearGlassPanel(
              width: _innerPanelSize,
              height: _innerPanelSize,
              radius: 40.r,
              tintAlpha: 0.045,
              blurSigma: 1.6,
              refractDx: 0.9,
              refractDy: 0.6,
            ),
          ),

          Center(
            child: CustomPaint(
              size: const Size(_outerPanelSize, _outerSize),
              painter: TrendingTalentGradientBorderPainter(
                gradient: const LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [Color(0xFFC00F8B), Color(0xFF05DAF1)],
                ),
                borderRadius: 48.r,
                strokeWidth: 1.w,
              ),
            ),
          ),
          Center(
            child: Container(
              width: _imageSize,
              height: _imageSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40.r),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24.r),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _TalentInnerImage(talent: talent),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.1),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TrendingTalentStatChip(text: talent.views),
                          SizedBox(height: 4.h),
                          TrendingTalentStatChip(text: talent.likes),
                          const Spacer(),
                          Center(
                            child: TrendingTalentNameChip(
                              name: talent.name,
                              imagePath: talent.imagePath,
                              profilePhotoUrl: talent.profilePhotoUrl,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 6,
            child: TrendingTalentTimerChip(timer: timerText),
          ),
        ],
      ),
    );
  }
}

class TrendingTalentGradientBorderPainter extends CustomPainter {
  final Gradient gradient;
  final double borderRadius;
  final double strokeWidth;

  TrendingTalentGradientBorderPainter({
    required this.gradient,
    required this.borderRadius,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(TrendingTalentGradientBorderPainter oldDelegate) => false;
}

class TrendingTalentStatChip extends StatelessWidget {
  final String text;

  const TrendingTalentStatChip({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: CustomText(
            text,
            fontSize: 9.sp,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class TrendingTalentNameChip extends StatelessWidget {
  final String name;
  final String imagePath;
  final String? profilePhotoUrl;

  const TrendingTalentNameChip({
    super.key,
    required this.name,
    required this.imagePath,
    this.profilePhotoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final photoUrl = profilePhotoUrl?.trim() ?? '';
    final ImageProvider avatar = photoUrl.isNotEmpty
        ? NetworkImage(photoUrl)
        : AssetImage(imagePath) as ImageProvider;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(radius: 6.r, backgroundImage: avatar),
              SizedBox(width: 4.w),
              CustomText(
                name,
                fontFamily: 'Outfit',
                fontSize: 9.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TrendingTalentTimerChip extends StatelessWidget {
  final String timer;

  const TrendingTalentTimerChip({super.key, required this.timer});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 0.h),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 1.w,
            ),
          ),
          child: CustomText(
            timer,
            fontFamily: 'Outfit',
            fontSize: 9.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
