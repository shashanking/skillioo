import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/trending_talent_model.dart';
import 'timer_badge.dart';

class GlassCarouselCard extends StatelessWidget {
  final TrendingTalent talent;
  final double scale;
  final double opacity;
  final bool isCenterCard;
  final Color? leftNeighborColor;
  final Color? rightNeighborColor;

  const GlassCarouselCard({
    super.key,
    required this.talent,
    this.scale = 1.0,
    this.opacity = 1.0,
    this.isCenterCard = false,
    this.leftNeighborColor,
    this.rightNeighborColor,
  });

  @override
  Widget build(BuildContext context) {
    // Center card should be SQUARE, side cards rectangular
    final cardWidth = isCenterCard ? 170.w : 130.w;
    final cardHeight = isCenterCard ? 190.h : 150.h;
    final outerRadius = isCenterCard ? 36.r : 28.r;
    final innerRadius = isCenterCard ? 26.r : 20.r;
    final glassPadding = isCenterCard ? 12.w : 8.w; // 11px from Figma

    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: SizedBox(
        width: cardWidth,
        height: cardHeight + (isCenterCard ? 30.h : 0),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Enhanced glass outer container with multi-layer effect
            _EnhancedGlassContainer(
              width: cardWidth,
              height: cardHeight,
              outerRadius: outerRadius,
              innerRadius: innerRadius,
              glassPadding: glassPadding,
              tintColor: talent.tintColor,
              leftNeighborColor: leftNeighborColor,
              rightNeighborColor: rightNeighborColor,
              isCenterCard: isCenterCard,
              child: _CardContent(
                talent: talent,
                innerRadius: innerRadius,
                isCenterCard: isCenterCard,
              ),
            ),
            // Timer badge – only on center card at top
            if (isCenterCard)
              Positioned(
                top: -18.h,
                left: 0,
                right: 0,
                child: Center(child: TimerBadge(timer: talent.timer)),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Enhanced Glass Container with Multi-Layer Effect ───────────────────────

class _EnhancedGlassContainer extends StatelessWidget {
  final double width;
  final double height;
  final double outerRadius;
  final double innerRadius;
  final double glassPadding;
  final Color tintColor;
  final Color? leftNeighborColor;
  final Color? rightNeighborColor;
  final bool isCenterCard;
  final Widget child;

  const _EnhancedGlassContainer({
    required this.width,
    required this.height,
    required this.outerRadius,
    required this.innerRadius,
    required this.glassPadding,
    required this.tintColor,
    required this.isCenterCard,
    required this.child,
    this.leftNeighborColor,
    this.rightNeighborColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(outerRadius),
        // Advanced depth shadows ONLY for center card
        // Side cards have NO shadows per reference image
        boxShadow: isCenterCard
            ? [
                // Primary shadow for depth
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 24,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
                // Secondary shadow for more depth
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.20),
                  blurRadius: 12,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
                // Ambient shadow
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 32,
                  spreadRadius: 4,
                  offset: const Offset(0, 12),
                ),
              ]
            : null, // NO shadows for side cards
      ),

      child: ClipRRect(
        child: Stack(
          children: [
            // Layer 1: Outer glass border (most transparent)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(outerRadius),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    tintColor.withValues(alpha: 0.20),
                    tintColor.withValues(alpha: 0.10),
                    Colors.white.withValues(alpha: 0.03),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 1.5.w,
                ),
              ),
            ),

            // Layer 2: Inner blurry border container
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(outerRadius - 4.r),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      tintColor.withValues(alpha: 0.30),
                      tintColor.withValues(alpha: 0.15),
                      Colors.white.withValues(alpha: 0.05),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 1.2.w,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(outerRadius - 5.r),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: isCenterCard ? 20 : 14,
                      sigmaY: isCenterCard ? 20 : 14,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(outerRadius - 5.r),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            tintColor.withValues(
                              alpha: isCenterCard ? 0.25 : 0.18,
                            ),
                            tintColor.withValues(
                              alpha: isCenterCard ? 0.10 : 0.08,
                            ),
                            Colors.white.withValues(alpha: 0.04),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Layer 3: Enhanced left neighbor reflection (wider and stronger)
            if (leftNeighborColor != null && isCenterCard)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: width * 0.40, // Increased from 0.30
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(outerRadius),
                      bottomLeft: Radius.circular(outerRadius),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        leftNeighborColor!.withValues(
                          alpha: 0.40,
                        ), // Increased from 0.25
                        leftNeighborColor!.withValues(alpha: 0.20),
                        leftNeighborColor!.withValues(alpha: 0.0),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),

            // Layer 4: Enhanced right neighbor reflection (wider and stronger)
            if (rightNeighborColor != null && isCenterCard)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: width * 0.40, // Increased from 0.30
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(outerRadius),
                      bottomRight: Radius.circular(outerRadius),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        rightNeighborColor!.withValues(
                          alpha: 0.40,
                        ), // Increased from 0.25
                        rightNeighborColor!.withValues(alpha: 0.20),
                        rightNeighborColor!.withValues(alpha: 0.0),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),

            // Layer 5: Top highlight / specular reflection
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: height * 0.40,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(outerRadius),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(
                        alpha: isCenterCard ? 0.22 : 0.15,
                      ),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            // Layer 6: Inner card content with padding
            Padding(padding: EdgeInsets.all(glassPadding), child: child),

            // Layer 7: Border glow effect
            if (isCenterCard)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(outerRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.15),
                      blurRadius: 8,
                      spreadRadius: 0,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
              ),

            // Inner card content with padding
            Padding(padding: EdgeInsets.all(glassPadding), child: child),
          ],
        ),
      ),
    );
  }
}

// ─── Card Content (image + overlays) ─────────────────────────────────────────

class _CardContent extends StatelessWidget {
  final TrendingTalent talent;
  final double innerRadius;
  final bool isCenterCard;

  const _CardContent({
    required this.talent,
    required this.innerRadius,
    required this.isCenterCard,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(innerRadius),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 1.4.w,
        ),
        // Inner shadow effect
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 8,
            spreadRadius: -2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(innerRadius - 1),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            Image.asset(talent.imagePath, fit: BoxFit.cover),

            // Dark gradient overlay with increased transparency
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.5, 1.0],
                  colors: [
                    Colors.black.withValues(
                      alpha: 0.08,
                    ), // Increased transparency
                    Colors.transparent,
                    Colors.black.withValues(
                      alpha: 0.35,
                    ), // Increased transparency
                  ],
                ),
              ),
            ),

            // Stats badges
            Positioned(
              left: 8.w,
              top: 8.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatBadge(text: talent.views, isCenterCard: isCenterCard),
                  SizedBox(height: 4.h),
                  _StatBadge(text: talent.likes, isCenterCard: isCenterCard),
                ],
              ),
            ),

            // Name badge
            Positioned(
              bottom: 8.h,
              left: 8.w,
              right: 8.w,
              child: _NameBadge(
                name: talent.name,
                imagePath: talent.imagePath,
                isCenterCard: isCenterCard,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Stat Badge ──────────────────────────────────────────────────────────────

class _StatBadge extends StatelessWidget {
  final String text;
  final bool isCenterCard;

  const _StatBadge({required this.text, required this.isCenterCard});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r), // More compact
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 4.h,
          ), // More compact
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15), // More transparent
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.20),
              width: 1.0.w,
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 10.sp, // Smaller text
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Name Badge ──────────────────────────────────────────────────────────────

class _NameBadge extends StatelessWidget {
  final String name;
  final String imagePath;
  final bool isCenterCard;

  const _NameBadge({
    required this.name,
    required this.imagePath,
    required this.isCenterCard,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14.r), // More rounded
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCenterCard ? 10.w : 6.w,
            vertical: isCenterCard ? 3.h : 2.h, // Smaller height
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12), // More transparent
            borderRadius: BorderRadius.circular(14.r), // More rounded
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: isCenterCard ? 7.r : 5.r, // Smaller avatar
                backgroundImage: AssetImage(imagePath),
              ),
              SizedBox(width: isCenterCard ? 5.w : 2.w),
              Flexible(
                child: Text(
                  name,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: isCenterCard ? 10.sp : 7.sp, // Smaller text
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Dynamic Timer Badge with Countdown ──────────────────────────────────────

class _DynamicTimerBadge extends StatefulWidget {
  final Duration initialDuration;
  final bool isCenterCard;

  const _DynamicTimerBadge({
    required this.initialDuration,
    required this.isCenterCard,
  });

  @override
  State<_DynamicTimerBadge> createState() => _DynamicTimerBadgeState();
}

class _DynamicTimerBadgeState extends State<_DynamicTimerBadge>
    with SingleTickerProviderStateMixin {
  late Duration _remainingTime;
  Timer? _countdownTimer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.initialDuration;

    // Pulse animation for when time is running low
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      setState(() {
        if (_remainingTime.inSeconds > 0) {
          _remainingTime = Duration(seconds: _remainingTime.inSeconds - 1);

          // Start pulsing when less than 10 seconds remain
          if (_remainingTime.inSeconds <= 10 && _remainingTime.inSeconds > 0) {
            if (!_pulseController.isAnimating) {
              _pulseController.repeat(reverse: true);
            }
          } else {
            _pulseController.stop();
            _pulseController.value = 0;
          }
        } else {
          // Reset to initial duration when reaches 0
          _remainingTime = widget.initialDuration;
          _pulseController.stop();
          _pulseController.value = 0;
        }
      });
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isLowTime =
        _remainingTime.inSeconds <= 10 && _remainingTime.inSeconds > 0;

    return ScaleTransition(
      scale: _pulseAnimation,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12), // Stronger blur
          child: Container(
            // Fixed minimum width to prevent changing when digits change
            constraints: BoxConstraints(minWidth: 52.w),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: isLowTime
                  ? Colors.red.withValues(alpha: 0.25)
                  : Colors.white.withValues(alpha: 0.20), // Slightly increased
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isLowTime
                    ? Colors.red.withValues(alpha: 0.45)
                    : Colors.white.withValues(alpha: 0.30), // Stronger border
                width: 1.4.w,
              ),
              boxShadow: widget.isCenterCard
                  ? [
                      BoxShadow(
                        color: isLowTime
                            ? Colors.red.withValues(alpha: 0.20)
                            : Colors.white.withValues(alpha: 0.15),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                    ]
                  : null,
            ),
            child: Text(
              _formatDuration(_remainingTime),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: isLowTime ? Colors.red[100] : Colors.white,
                fontFeatures: const [
                  FontFeature.tabularFigures(), // Fixed-width numbers
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
