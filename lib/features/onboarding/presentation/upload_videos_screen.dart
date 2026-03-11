import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../constants/app_constants.dart';
import '../../../core/widgets/common_background.dart';
import '../application/registration_providers.dart';
import '../application/states/registration_state.dart';
import '../application/talent_type_provider.dart';

enum _UploadStepState { notes, list }

class UploadVideosScreen extends ConsumerStatefulWidget {
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
  ConsumerState<UploadVideosScreen> createState() => _UploadVideosScreenState();
}

class _UploadVideosScreenState extends ConsumerState<UploadVideosScreen> {
  _UploadStepState _state = _UploadStepState.notes;

  final List<File> _pickedVideos = <File>[];
  final List<String> _pickedVideoNames = <String>[];

  final List<File> _pickedImages = <File>[];
  final List<String> _pickedImageNames = <String>[];

  bool _isUploading = false;

  void _removeVideoAt(int index) {
    if (index < 0 || index >= _pickedVideos.length) return;
    setState(() {
      _pickedVideos.removeAt(index);
      _pickedVideoNames.removeAt(index);
      if (_pickedVideos.isEmpty && _pickedImages.isEmpty) {
        _state = _UploadStepState.notes;
      }
    });
  }

  void _removeImageAt(int index) {
    if (index < 0 || index >= _pickedImages.length) return;
    setState(() {
      _pickedImages.removeAt(index);
      _pickedImageNames.removeAt(index);
      if (_pickedVideos.isEmpty && _pickedImages.isEmpty) {
        _state = _UploadStepState.notes;
      }
    });
  }

  /// Copies [source] into the app's temp directory so the path remains
  /// valid even after the picker cache is cleared.
  Future<File> _stableCopy(File source, {required String prefix}) async {
    final dir = await getTemporaryDirectory();
    final ext = source.path.split('.').last;
    final dest = File(
      '${dir.path}/$prefix${DateTime.now().millisecondsSinceEpoch}.$ext',
    );
    return source.copy(dest.path);
  }

  @override
  void dispose() {
    super.dispose();
  }

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

  Widget _buildFilesList() {
    final hasVideos = _pickedVideos.isNotEmpty;
    final hasImages = _pickedImages.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selected media',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFF5F5F5),
          ),
        ),
        SizedBox(height: 12.h),
        _buildSectionHeader(
          'Videos',
          hasVideos ? '${_pickedVideos.length}' : '0',
        ),
        SizedBox(height: 8.h),
        if (!hasVideos)
          _buildEmptyRow('No videos selected')
        else
          for (int i = 0; i < _pickedVideoNames.length; i++)
            _buildFileRow(
              _pickedVideoNames[i],
              onRemove: _isUploading ? null : () => _removeVideoAt(i),
            ),
        SizedBox(height: 16.h),
        _buildSectionHeader(
          'Photos',
          hasImages ? '${_pickedImages.length}' : '0',
        ),
        SizedBox(height: 8.h),
        if (!hasImages)
          _buildEmptyRow('No photos selected')
        else
          for (int i = 0; i < _pickedImageNames.length; i++)
            _buildFileRow(
              _pickedImageNames[i],
              onRemove: _isUploading ? null : () => _removeImageAt(i),
            ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
        Text(
          count,
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyRow(String text) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: Colors.white.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  Widget _buildFileRow(String file, {VoidCallback? onRemove}) {
    return Container(
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFF5F5F5),
              ),
            ),
          ),
          if (onRemove != null) ...[
            SizedBox(width: 12.w),
            GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.white.withValues(alpha: 0.85),
                  size: 16.sp,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            if (_state == _UploadStepState.list) {
              setState(() {
                _state = _UploadStepState.notes;
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
          'Upload Skill Videos and Photos',
          style: TextStyle(
            fontFamily: 'Neue',
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFF5F5F5),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Upload videos and photos that highlight what you can do.',
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
    return SizedBox(
      width: double.infinity,
      height: 54.h,
      child: TextButton(
        onPressed: () async {
          await _showPickerSheet(context);
          if (!mounted) return;
          if (_pickedVideos.isNotEmpty || _pickedImages.isNotEmpty) {
            setState(() => _state = _UploadStepState.list);
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

  Widget _buildBottomSingleCta(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 54.h,
            child: TextButton(
              onPressed: _isUploading
                  ? null
                  : () async {
                      await _showPickerSheet(context);
                      if (!mounted) return;
                      setState(() {});
                    },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(48.r),
                ),
                backgroundColor: Colors.white.withValues(alpha: 0.12),
              ),
              child: Center(
                child: Text(
                  'Select more',
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
        SizedBox(width: 12.w),
        Expanded(
          child: SizedBox(
            height: 54.h,
            child: TextButton(
              onPressed: _isUploading
                  ? null
                  : () async {
                      final talentType = ref.read(talentTypeProvider);
                      final isProfessional =
                          talentType == TalentType.professional;

                      if (_pickedVideos.isEmpty && _pickedImages.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isProfessional
                                  ? 'Please select at least 1 video and 1 photo to continue.'
                                  : 'Please select at least one video or photo to continue.',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      if (isProfessional) {
                        if (_pickedVideos.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please select at least 1 video to continue.',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          if (!context.mounted) return;
                          await _showPickerSheet(context, forceVideo: true);
                          if (!context.mounted) return;
                          setState(() {});
                          if (_pickedVideos.isEmpty) return;
                        }

                        if (_pickedImages.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please select at least 1 photo to continue.',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          if (!context.mounted) return;
                          await _showPickerSheet(context, forcePhoto: true);
                          if (!context.mounted) return;
                          setState(() {});
                          if (_pickedImages.isEmpty) return;
                        }
                      }

                      setState(() => _isUploading = true);

                      for (final v in _pickedVideos) {
                        await ref
                            .read(registrationNotifierProvider.notifier)
                            .uploadVideo(v);
                        if (!context.mounted) return;
                        final updated = ref.read(registrationNotifierProvider);
                        if (updated.videoStatus == DocumentUploadStatus.error) {
                          setState(() => _isUploading = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                updated.errorMessage.isNotEmpty
                                    ? updated.errorMessage
                                    : 'Video upload failed. Please try again.',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                      }

                      for (final img in _pickedImages) {
                        await ref
                            .read(registrationNotifierProvider.notifier)
                            .uploadImage(img);
                        if (!context.mounted) return;
                        final updated = ref.read(registrationNotifierProvider);
                        if (updated.imageStatus == DocumentUploadStatus.error) {
                          setState(() => _isUploading = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                updated.errorMessage.isNotEmpty
                                    ? updated.errorMessage
                                    : 'Photo upload failed. Please try again.',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                      }

                      if (!context.mounted) return;
                      setState(() => _isUploading = false);
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
                  child: _isUploading
                      ? SizedBox(
                          width: 22.w,
                          height: 22.w,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
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
          ),
        ),
      ],
    );
  }

  Future<void> _showPickerSheet(
    BuildContext context, {
    bool forceVideo = false,
    bool forcePhoto = false,
  }) async {
    if (forceVideo) {
      await _pickVideo(context);
      return;
    }
    if (forcePhoto) {
      await _pickPhotos(context);
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF111111),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _sheetItem(
                  ctx,
                  title: 'Add videos',
                  icon: Icons.videocam_outlined,
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    await _pickVideo(context);
                  },
                ),
                SizedBox(height: 12.h),
                _sheetItem(
                  ctx,
                  title: 'Add photos',
                  icon: Icons.photo_outlined,
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    await _pickPhotos(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sheetItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white.withValues(alpha: 0.9)),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFF5F5F5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickVideo(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickVideo(source: ImageSource.gallery);
    if (picked == null) return;

    final rawFile = File(picked.path);
    final fileSize = await rawFile.length();
    const maxBytes = 50 * 1024 * 1024;
    if (fileSize > maxBytes && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Video is too large. Please choose a file under 50 MB.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final file = await _stableCopy(rawFile, prefix: 'skillioo_video_');
    if (!mounted) return;
    setState(() {
      _pickedVideos.add(file);
      _pickedVideoNames.add(picked.name);
      _state = _UploadStepState.list;
    });
  }

  Future<void> _pickPhotos(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    if (picked.isEmpty) return;

    for (final p in picked) {
      final file = await _stableCopy(File(p.path), prefix: 'skillioo_image_');
      if (!mounted) return;
      setState(() {
        _pickedImages.add(file);
        _pickedImageNames.add(p.name);
        _state = _UploadStepState.list;
      });
    }
  }
}
