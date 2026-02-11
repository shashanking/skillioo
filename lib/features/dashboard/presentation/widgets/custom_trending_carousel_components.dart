import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/custom_text.dart';
import '../../data/trending_talent_model.dart';

class TrendingTalentSimpleCard extends StatelessWidget {
  final TrendingTalent talent;

  const TrendingTalentSimpleCard({super.key, required this.talent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 124.w,
      height: 124.w,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24.r)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(talent.imagePath, fit: BoxFit.cover),
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
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TrendingTalentStatChip(text: talent.views),
                  SizedBox(height: 4.h),
                  TrendingTalentStatChip(text: talent.likes),
                  const Spacer(),
                  TrendingTalentNameChip(
                    name: talent.name,
                    imagePath: talent.imagePath,
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

  const TrendingTalentCenterStackCard({
    super.key,
    required this.talent,
    required this.timerText,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180.w,
      height: 180.w,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Center(
            child: _ClearGlassPanel(
              width: 170.w,
              height: 170.w,
              radius: 32.r,
              tintAlpha: 0.06,
              blurSigma: 2.0,
              refractDx: 1.2,
              refractDy: 0.8,
            ),
          ),
          Center(
            child: _ClearGlassPanel(
              width: 148.w,
              height: 148.w,
              radius: 28.r,
              tintAlpha: 0.045,
              blurSigma: 1.6,
              refractDx: 0.9,
              refractDy: 0.6,
            ),
          ),
          Center(
            child: Container(
              width: 124.w,
              height: 124.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24.r),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(talent.imagePath, fit: BoxFit.cover),
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
                      padding: EdgeInsets.all(12.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TrendingTalentStatChip(text: talent.views),
                          SizedBox(height: 4.h),
                          TrendingTalentStatChip(text: talent.likes),
                          const Spacer(),
                          TrendingTalentNameChip(
                            name: talent.name,
                            imagePath: talent.imagePath,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: CustomPaint(
              size: Size(170.w, 170.w),
              painter: TrendingTalentGradientBorderPainter(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFC00F8B), Color(0xFF05DAF1)],
                ),
                borderRadius: 32.r,
                strokeWidth: 1.w,
              ),
            ),
          ),
          Positioned(
            bottom: 10,
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

  const TrendingTalentNameChip({
    super.key,
    required this.name,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
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
              CircleAvatar(radius: 6.r, backgroundImage: AssetImage(imagePath)),
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
