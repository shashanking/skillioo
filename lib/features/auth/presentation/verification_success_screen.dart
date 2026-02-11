import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../constants/app_constants.dart';
import '../../../core/widgets/common_background.dart';

class VerificationSuccessScreen extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String nextRoute;
  final Duration delay;

  const VerificationSuccessScreen({
    super.key,
    required this.title,
    this.subtitle,
    required this.nextRoute,
    this.delay = const Duration(milliseconds: 1500),
  });

  @override
  State<VerificationSuccessScreen> createState() =>
      _VerificationSuccessScreenState();
}

class _VerificationSuccessScreenState extends State<VerificationSuccessScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(widget.delay, () {
        if (!mounted) return;
        GoRouter.of(context).go(widget.nextRoute);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CommonBackground(
        child: SafeArea(
          child: Center(
            child: SizedBox(
              width: 295.w,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 124.w,
                    height: 124.w,
                    child: Image.asset(
                      AppAssets.verifiedPng,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Neue',
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.33,
                      color: const Color(0xFFF5F5F5),
                    ),
                  ),
                  if (widget.subtitle != null) ...[
                    SizedBox(height: 8.h),
                    Text(
                      widget.subtitle!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFF5F5F5),
                      ),
                    ),
                  ],
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: 200.w,
                    height: 200.w,
                    child: Image.asset(
                      AppAssets.loaderGif,
                      fit: BoxFit.contain,
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
