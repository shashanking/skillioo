import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../constants/app_constants.dart';
import '../../../core/widgets/common_background.dart';

enum _UploadStepState { notes, preview, list }

class UploadVideosScreen extends StatefulWidget {
  const UploadVideosScreen({
    super.key,
    this.backFallbackRoute = '/talent-subcategory',
    this.skipNextRoute = '/options',
    this.uploadSuccessRoute = '/profile-upload',
    this.showStepIndicator = true,
  });

  final String backFallbackRoute;
  final String skipNextRoute;
  final String uploadSuccessRoute;
  final bool showStepIndicator;

  @override
  State<UploadVideosScreen> createState() => _UploadVideosScreenState();
}

class _UploadVideosScreenState extends State<UploadVideosScreen> {
  _UploadStepState _state = _UploadStepState.notes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: CommonBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),
                _buildTopBar(context),
                SizedBox(height: 24.h),
                _buildHeader(),
                SizedBox(height: 24.h),
                if (_state == _UploadStepState.notes)
                  _buildNotesCard()
                else if (_state == _UploadStepState.preview)
                  _buildPreviewCard()
                else
                  _buildFilesList(),
                const Spacer(),
                if (_state == _UploadStepState.notes)
                  _buildBottomButtonsInitial(context)
                else
                  _buildBottomSingleCta(context),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Center(
      child: Container(
        width: double.infinity,
        height: 260.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          gradient: const LinearGradient(
            colors: [Color(0xFF4D1CFF), Color(0xFF0B0B0F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AppAssets.professionalJpg),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(color: Colors.black.withValues(alpha: 0.25)),
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                size: 36.sp,
                color: const Color(0xFF111111),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilesList() {
    final files = ['SingingVideo.mp4', 'SingingConcertSnap.mp4'];

    return Column(
      children: [
        for (final file in files)
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.insert_drive_file_outlined,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 20.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    file,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFF5F5F5),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            if (_state == _UploadStepState.preview) {
              setState(() {
                _state = _UploadStepState.notes;
              });
              return;
            }
            if (_state == _UploadStepState.list) {
              setState(() {
                _state = _UploadStepState.preview;
              });
              return;
            }
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
            'Step: 3 of 3',
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
          'Upload Skill Videos or Attachments',
          style: TextStyle(
            fontFamily: 'Neue',
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFF5F5F5),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Upload a video and any extra files that highlight what you can do.',
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

  Widget _buildNotesCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notes:',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFF5F5F5),
            ),
          ),
          SizedBox(height: 8.h),
          _buildBullet('Max video or document size should be 50 - 200 MB.'),
          SizedBox(height: 4.h),
          _buildBullet('Supported formats for video - mp4, mov, webm.'),
          SizedBox(height: 4.h),
          _buildBullet(
            'Supported formats for documents - docx, pdf, drive, doc.',
          ),
        ],
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '\u2022',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 14.sp,
            color: const Color(0xFFF5F5F5),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFF5F5F5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtonsInitial(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 54.h,
            child: TextButton(
              onPressed: () {
                // Skip upload for now and go to next major step
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
                // For now, move to preview state to mimic upload animation
                setState(() {
                  _state = _UploadStepState.preview;
                });
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
                    'Upload Now',
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
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSingleCta(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54.h,
      child: TextButton(
        onPressed: () {
          if (_state == _UploadStepState.preview) {
            setState(() {
              _state = _UploadStepState.list;
            });
            return;
          }
          // Final state: navigate to success/next route
          GoRouter.of(context).go(widget.uploadSuccessRoute);
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
              'Upload Now',
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
