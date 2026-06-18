import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../../../constants/app_constants.dart';
import '../../../core/widgets/common_background.dart';
import '../../../core/widgets/custom_text.dart';
import '../../../core/widgets/gradient_cta_button.dart';
import '../../../core/widgets/icon_button.dart';
import '../application/post_providers.dart';
import '../application/states/post_state.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  final String backFallbackRoute;

  const CreatePostScreen({super.key, this.backFallbackRoute = '/landing'});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _selectedFile;
  String _mediaType = 'post'; // 'post' or 'reel'
  bool _isVideo = false;
  VideoPlayerController? _previewController;

  @override
  void dispose() {
    _descriptionController.dispose();
    _previewController?.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (picked != null) {
      _previewController?.dispose();
      _previewController = null;
      setState(() {
        _selectedFile = File(picked.path);
        _isVideo = false;
        _mediaType = 'post';
      });
    }
  }

  Future<void> _pickVideo() async {
    final picked = await _picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 5),
    );
    if (picked != null) {
      _previewController?.dispose();
      final file = File(picked.path);
      final controller = VideoPlayerController.file(file);
      await controller.initialize();
      controller.setLooping(true);
      controller.setVolume(0);
      controller.play();

      setState(() {
        _selectedFile = file;
        _isVideo = true;
        _mediaType = 'reel';
        _previewController = controller;
      });
    }
  }

  Future<void> _takePhoto() async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (picked != null) {
      _previewController?.dispose();
      _previewController = null;
      setState(() {
        _selectedFile = File(picked.path);
        _isVideo = false;
        _mediaType = 'post';
      });
    }
  }

  Future<void> _recordVideo() async {
    final picked = await _picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(minutes: 5),
    );
    if (picked != null) {
      _previewController?.dispose();
      final file = File(picked.path);
      final controller = VideoPlayerController.file(file);
      await controller.initialize();
      controller.setLooping(true);
      controller.setVolume(0);
      controller.play();

      setState(() {
        _selectedFile = file;
        _isVideo = true;
        _mediaType = 'reel';
        _previewController = controller;
      });
    }
  }

  Future<void> _submitPost() async {
    if (_selectedFile == null) return;

    final effectiveMediaType = _isVideo ? 'reel' : _mediaType;

    final success = await ref
        .read(postNotifierProvider.notifier)
        .createPost(
          mediaFile: _selectedFile!,
          mediaType: effectiveMediaType,
          description: _descriptionController.text.trim().isNotEmpty
              ? _descriptionController.text.trim()
              : null,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${effectiveMediaType == 'reel' ? 'Reel' : 'Post'} created successfully!',
          ),
          backgroundColor: Colors.green,
        ),
      );
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else if (context.canPop()) {
        context.pop();
      } else {
        context.go(widget.backFallbackRoute);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final postState = ref.watch(postNotifierProvider);
    final isLoading =
        postState.createStatus == PostCreateStatus.uploadingMedia ||
        postState.createStatus == PostCreateStatus.creatingPost;

    ref.listen<PostState>(postNotifierProvider, (prev, next) {
      if (next.createStatus == PostCreateStatus.error &&
          next.errorMessage.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: CommonBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(isLoading),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.h),
                      _buildMediaPicker(),
                      SizedBox(height: 24.h),
                      _buildMediaTypeSelector(),
                      SizedBox(height: 24.h),
                      _buildDescriptionField(),
                      SizedBox(height: 32.h),
                      _buildSubmitButton(isLoading, postState),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isLoading) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      decoration: BoxDecoration(color: AppColors.glassWhite12),
      child: Row(
        children: [
          IconCircleButton(
            assetPath: 'assets/images/arrow-left.png',
            onTap: () {
              if (isLoading) return;
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(widget.backFallbackRoute);
              }
            },
          ),
          SizedBox(width: 24.w),
          CustomText(
            'Create Post',
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            fontFamily: 'Neue',
            color: AppColors.foundationBlack20,
          ),
        ],
      ),
    );
  }

  Widget _buildMediaPicker() {
    if (_selectedFile != null) {
      return _buildMediaPreview();
    }

    return Container(
      width: double.infinity,
      height: 300.h,
      decoration: BoxDecoration(
        color: AppColors.glassWhite12,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShaderMask(
            shaderCallback: (bounds) =>
                AppColors.ctaBorderGradient.createShader(bounds),
            child: Icon(
              Icons.add_photo_alternate_outlined,
              color: Colors.white,
              size: 64.sp,
            ),
          ),
          SizedBox(height: 16.h),
          CustomText(
            'Select media to post',
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            fontFamily: 'Outfit',
            color: AppColors.foundationBlack20,
          ),
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPickerButton(
                Icons.photo_library_outlined,
                'Photo',
                _pickImage,
              ),
              SizedBox(width: 16.w),
              _buildPickerButton(Icons.videocam_outlined, 'Video', _pickVideo),
              SizedBox(width: 16.w),
              _buildPickerButton(
                Icons.camera_alt_outlined,
                'Camera',
                _takePhoto,
              ),
              SizedBox(width: 16.w),
              _buildPickerButton(
                Icons.fiber_smart_record_outlined,
                'Record',
                _recordVideo,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPickerButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56.w,
            height: 56.w,
            padding: EdgeInsets.all(1.5.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.ctaBorderGradient,
            ),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF0D0D0D),
              ),
              child: ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.ctaBorderGradient.createShader(bounds),
                child: Icon(icon, color: Colors.white, size: 24.sp),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          CustomText(
            label,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            fontFamily: 'Outfit',
            color: AppColors.foundationBlack20,
          ),
        ],
      ),
    );
  }

  Widget _buildMediaPreview() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 350.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),
            color: Colors.black,
          ),
          clipBehavior: Clip.antiAlias,
          child: _isVideo && _previewController != null
              ? FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _previewController!.value.size.width,
                    height: _previewController!.value.size.height,
                    child: VideoPlayer(_previewController!),
                  ),
                )
              : Image.file(
                  _selectedFile!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
        ),
        Positioned(
          top: 12.h,
          right: 12.w,
          child: GestureDetector(
            onTap: () {
              _previewController?.dispose();
              _previewController = null;
              setState(() {
                _selectedFile = null;
                _isVideo = false;
              });
            },
            child: Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.6),
              ),
              child: Icon(Icons.close, color: Colors.white, size: 20.sp),
            ),
          ),
        ),
        if (_isVideo)
          Positioned(
            bottom: 12.h,
            left: 12.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.videocam, color: Colors.white, size: 16.sp),
                  SizedBox(width: 4.w),
                  CustomText(
                    'Video',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMediaTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          'Post Type',
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          fontFamily: 'Neue',
          color: AppColors.foundationBlack20,
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            _buildTypeChip('post', 'Post', Icons.photo),
            SizedBox(width: 12.w),
            _buildTypeChip('reel', 'Reel', Icons.videocam),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeChip(String value, String label, IconData icon) {
    final isSelected = _mediaType == value;
    return GestureDetector(
      onTap: () {
        if (_isVideo && value == 'post') return;
        setState(() => _mediaType = value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(1.5.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22.r),
          gradient: AppColors.ctaBorderGradient,
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 9.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            gradient: isSelected ? AppColors.ctaGradient : null,
            color: isSelected ? null : const Color(0xFF0D0D0D),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 18.sp),
              SizedBox(width: 8.w),
              CustomText(
                label,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'Outfit',
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          'Description',
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          fontFamily: 'Neue',
          color: AppColors.foundationBlack20,
        ),
        SizedBox(height: 12.h),
        Container(
          decoration: BoxDecoration(
            color: AppColors.glassWhite12,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: TextField(
            controller: _descriptionController,
            maxLines: 4,
            maxLength: 500,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.foundationBlack20,
            ),
            cursorColor: Colors.white,
            decoration: InputDecoration(
              hintText: 'Write something about your post...',
              hintStyle: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.foundationHint,
              ),
              counterStyle: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 12.sp,
                color: AppColors.foundationHint,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16.w),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(bool isLoading, PostState postState) {
    final canSubmit = _selectedFile != null && !isLoading;
    String buttonText = 'Create ${_mediaType == 'reel' ? 'Reel' : 'Post'}';
    if (postState.createStatus == PostCreateStatus.uploadingMedia) {
      buttonText = 'Uploading media...';
    } else if (postState.createStatus == PostCreateStatus.creatingPost) {
      buttonText = 'Creating post...';
    }

    return GradientCtaButton(
      label: buttonText,
      width: double.infinity,
      height: 56,
      borderRadius: BorderRadius.circular(48.r),
      enabled: canSubmit,
      onPressed: canSubmit ? _submitPost : null,
    );
  }
}
