import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/custom_text.dart';

class CustomFollowSnackbar {
  static OverlayEntry? _overlayEntry;

  static void show(
    BuildContext context, {
    required String name,
    required String imagePath,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Remove any existing snackbar
    hide();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 100.h,
        left: 20.w,
        right: 20.w,
        child: Material(
          color: Colors.transparent,
          child: _SnackbarContent(
            name: name,
            imagePath: imagePath,
            onClose: () => hide(),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    // Auto-hide after duration
    Future.delayed(duration, () => hide());
  }

  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

class _SnackbarContent extends StatefulWidget {
  final String name;
  final String imagePath;
  final VoidCallback onClose;

  const _SnackbarContent({
    required this.name,
    required this.imagePath,
    required this.onClose,
  });

  @override
  State<_SnackbarContent> createState() => _SnackbarContentState();
}

class _SnackbarContentState extends State<_SnackbarContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutBack,
          ),
        );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.r),
                color: Colors.white.withValues(alpha: 0.1),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1.w,
                ),
              ),
              child: Row(
                children: [
                  // Profile image
                  // Container(
                  //   width: 48.w,
                  //   height: 48.w,
                  //   decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.circular(12.r),
                  //     border: Border.all(
                  //       color: const Color(0xFF00D9FF),
                  //       width: 1.5.w,
                  //     ),
                  //   ),
                  //   child: ClipRRect(
                  //     borderRadius: BorderRadius.circular(10.r),
                  //     child: Image.asset(widget.imagePath, fit: BoxFit.cover),
                  //   ),
                  // ),

                  // SizedBox(width: 16.w),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomText(
                          'Following',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        SizedBox(height: 4.h),
                        CustomText(
                          widget.name,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),

                  // Close button
                  GestureDetector(
                    onTap: widget.onClose,
                    child: Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1.w,
                        ),
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
