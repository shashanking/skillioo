import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../constants/app_constants.dart';
import '../../../core/widgets/common_background.dart';
import '../application/social_links_provider.dart';

class SocialLinksScreen extends ConsumerStatefulWidget {
  const SocialLinksScreen({
    super.key,
    this.backFallbackRoute = '/professional-certificates',
    this.skipNextRoute = '/options',
    this.continueNextRoute = '/professional-bio',
    this.showStepIndicator = true,
  });

  final String backFallbackRoute;
  final String skipNextRoute;
  final String continueNextRoute;
  final bool showStepIndicator;

  @override
  ConsumerState<SocialLinksScreen> createState() => _SocialLinksScreenState();
}

class _SocialLinksScreenState extends ConsumerState<SocialLinksScreen> {
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];

  bool _showContinue = false;

  @override
  void initState() {
    super.initState();
    _addField();
    _addField();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_focusNodes.isNotEmpty) {
        _focusNodes.first.requestFocus();
      }
    });
  }

  void _addField() {
    final controller = TextEditingController();
    final focusNode = FocusNode();
    controller.addListener(_onChanged);
    _controllers.add(controller);
    _focusNodes.add(focusNode);
  }

  void _onChanged() {
    final anyText = _controllers.any((c) => c.text.trim().isNotEmpty);
    setState(() {
      _showContinue = anyText;
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.removeListener(_onChanged);
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: CommonBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h),
                    _buildTopBar(context),
                    SizedBox(height: 24.h),
                    _buildHeader(),
                    SizedBox(height: 24.h),
                    ..._buildInputs(),
                    SizedBox(height: 14.h),
                    _buildAddMoreButton(),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 24.h,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: _showContinue
                      ? _buildContinueButton(context)
                      : _buildBottomButtons(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            if (GoRouter.of(context).canPop()) {
              GoRouter.of(context).pop();
            } else {
              GoRouter.of(context).go(widget.backFallbackRoute);
            }
          },
          child: Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(124.r),
            ),
            child: Center(
              child: Icon(
                Icons.arrow_back,
                color: const Color(0xFFF5F5F5),
                size: 20.sp,
              ),
            ),
          ),
        ),
        if (widget.showStepIndicator)
          Text(
            'Step: 1 of 3',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFF5F5F5),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add Your Social Profile Links',
          style: TextStyle(
            fontFamily: 'Neue',
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFF5F5F5),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Include links to your social pages to complete your profile.',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFFF5F5F5),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildInputs() {
    final widgets = <Widget>[];
    for (var i = 0; i < _controllers.length; i++) {
      widgets.add(_buildInput(i));
      widgets.add(SizedBox(height: 12.h));
    }
    if (widgets.isNotEmpty) {
      widgets.removeLast();
    }
    return widgets;
  }

  Widget _buildInput(int index) {
    return Container(
      height: 56.h,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(48.r),
      ),
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textInputAction: index == _controllers.length - 1
            ? TextInputAction.done
            : TextInputAction.next,
        onSubmitted: (_) {
          final nextIndex = index + 1;
          if (nextIndex < _focusNodes.length) {
            _focusNodes[nextIndex].requestFocus();
          }
        },
        style: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: const Color(0xFFF5F5F5),
        ),
        cursorColor: Colors.white,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Link ${index + 1}',
          hintStyle: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.6),
          ),
          isCollapsed: true,
        ),
      ),
    );
  }

  Widget _buildAddMoreButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          _addField();
        });
      },
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        foregroundColor: const Color(0xFFF5F5F5),
      ),
      child: Text(
        'Add more',
        style: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
          color: const Color(0xFFF5F5F5),
        ),
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 54.h,
            child: TextButton(
              onPressed: () {
                GoRouter.of(context).go(widget.skipNextRoute);
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(48.r),
                ),
              ),
              child: Text(
                'Upload Later',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFF5F5F5),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: SizedBox(
            height: 54.h,
            child: TextButton(
              onPressed: () {
                if (_focusNodes.isNotEmpty) {
                  _focusNodes.first.requestFocus();
                }
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(48.r),
                ),
                backgroundColor: Colors.transparent,
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: AppColors.ctaGradient,
                  borderRadius: BorderRadius.circular(48.r),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        AppAssets.uploadIconPng,
                        width: 18.w,
                        height: 18.w,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Upload Now',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFF5F5F5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58.h,
      child: TextButton(
        onPressed: () {
          final values = _controllers
              .map((c) => c.text.trim())
              .where((v) => v.isNotEmpty)
              .toList();
          ref.read(socialLinksProvider.notifier).state = values;
          GoRouter.of(context).go(widget.continueNextRoute);
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(48.r),
          ),
          backgroundColor: Colors.transparent,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: AppColors.ctaGradient,
            borderRadius: BorderRadius.circular(48.r),
          ),
          child: Center(
            child: Text(
              'Continue',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFF5F5F5),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
