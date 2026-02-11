import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/trending_talent_model.dart';
import 'custom_trending_carousel_components.dart';

class CustomTrendingCarousel extends StatefulWidget {
  final List<TrendingTalent> talents;

  const CustomTrendingCarousel({super.key, required this.talents});

  @override
  State<CustomTrendingCarousel> createState() => _CustomTrendingCarouselState();
}

class _CarouselCardTransform extends StatelessWidget {
  final double dx;
  final double dy;
  final double opacity;
  final double scale;
  final Widget child;

  const _CarouselCardTransform({
    required this.dx,
    required this.dy,
    required this.opacity,
    required this.scale,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(dx, dy),
      child: Opacity(
        opacity: opacity,
        child: Transform.scale(scale: scale, child: child),
      ),
    );
  }
}

class _CustomTrendingCarouselState extends State<CustomTrendingCarousel> {
  static const int _virtualMultiplier = 1000;

  late final PageController _pageController;
  Timer? _autoScrollTimer;
  Timer? _countdownTimer;
  bool _isUserInteracting = false;

  int _currentVirtualPage = 0;
  late List<Duration> _remaining;

  int get _itemCount => widget.talents.length;
  int get _virtualCount => _itemCount * _virtualMultiplier;
  int get _initialPage => (_virtualMultiplier ~/ 2) * _itemCount;

  @override
  void initState() {
    super.initState();
    _currentVirtualPage = _initialPage;
    _pageController = PageController(
      initialPage: _initialPage,
      viewportFraction: 0.78,
    );

    _remaining = widget.talents
        .map((t) => t.initialDuration)
        .toList(growable: false);

    _startAutoScroll();
    _startCountdown();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _countdownTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_isUserInteracting && mounted) {
        _animateToVirtualPage(_currentVirtualPage + 1);
      }
    });
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _remaining = List<Duration>.generate(_remaining.length, (i) {
          final d = _remaining[i];
          if (d <= Duration.zero) return Duration.zero;
          return d - const Duration(seconds: 1);
        }, growable: false);
      });
    });
  }

  void _resetCurrentTimer() {
    final currentRealIndex = _realIndex(_currentVirtualPage);
    setState(() {
      _remaining = List<Duration>.from(_remaining)
        ..[currentRealIndex] = widget.talents[currentRealIndex].initialDuration;
    });
  }

  void _animateToVirtualPage(int virtualPage) {
    _pageController.animateToPage(
      virtualPage,
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeInOutCubic,
    );
  }

  int _realIndex(int virtualIndex) {
    return ((virtualIndex % _itemCount) + _itemCount) % _itemCount;
  }

  String _format(Duration d) {
    final totalSeconds = d.inSeconds.clamp(0, 24 * 60 * 60);
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString()}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200.h,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollStartNotification) {
            if (notification.dragDetails != null) {
              _isUserInteracting = true;
              _autoScrollTimer?.cancel();
            }
          } else if (notification is ScrollEndNotification) {
            _isUserInteracting = false;
            _startAutoScroll();
          }
          return false;
        },
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: _virtualCount,
              onPageChanged: (v) {
                setState(() => _currentVirtualPage = v);
                _resetCurrentTimer();
              },
              itemBuilder: (context, index) {
                return const SizedBox.shrink();
              },
            ),
            IgnorePointer(
              child: AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  final page = _pageController.hasClients
                      ? (_pageController.page ?? _currentVirtualPage.toDouble())
                      : _currentVirtualPage.toDouble();
                  final centerVirtual = page.round();

                  return Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      _buildCardForVirtual(
                        context: context,
                        page: page,
                        virtualIndex: centerVirtual - 1,
                      ),
                      _buildCardForVirtual(
                        context: context,
                        page: page,
                        virtualIndex: centerVirtual + 1,
                      ),
                      _buildCardForVirtual(
                        context: context,
                        page: page,
                        virtualIndex: centerVirtual,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardForVirtual({
    required BuildContext context,
    required double page,
    required int virtualIndex,
  }) {
    final realIdx = _realIndex(virtualIndex);
    final talent = widget.talents[realIdx];
    final pageOffset = (page - virtualIndex).clamp(-2.0, 2.0);
    final abs = pageOffset.abs().clamp(0.0, 1.0);

    final isCenter = abs < 0.5;
    final scale = lerpDouble(1.0, 0.85, abs);
    final opacity = lerpDouble(1.0, 0.80, abs);

    final dx = (-pageOffset) * 120.w;
    final dy = lerpDouble(30.h, 30.h, abs);

    final timerText = _format(_remaining[realIdx]);

    return _CarouselCardTransform(
      dx: dx,
      dy: dy,
      opacity: opacity,
      scale: scale,
      child: isCenter
          ? TrendingTalentCenterStackCard(talent: talent, timerText: timerText)
          : TrendingTalentSimpleCard(talent: talent),
    );
  }

  double lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }
}
