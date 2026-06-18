import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../constants/app_constants.dart';
import '../../../core/widgets/common_background.dart';
import '../../../core/widgets/gradient_cta_button.dart';
import '../application/registration_providers.dart';
import '../application/states/registration_state.dart';
import '../application/talent_type_provider.dart';

class ProfileUploadScreen extends ConsumerStatefulWidget {
  const ProfileUploadScreen({super.key});

  @override
  ConsumerState<ProfileUploadScreen> createState() =>
      _ProfileUploadScreenState();
}

class _ProfileUploadScreenState extends ConsumerState<ProfileUploadScreen> {
  File? _selectedFile;

  Future<File> _stableCopy(File source) async {
    final dir = await getTemporaryDirectory();
    final ext = source.path.split('.').last;
    final dest = File(
      '${dir.path}/skillioo_profile_${DateTime.now().millisecondsSinceEpoch}.$ext',
    );
    return source.copy(dest.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                SizedBox(height: 40.h),
                _buildProfileImage(),
                const Spacer(),
                _buildBottomRow(context),
                SizedBox(height: 24.h),
              ],
            ),
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
              GoRouter.of(context).go('/upload-videos');
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
              child: Image.asset(
                'assets/images/arrow-left.png',
                color: const Color(0xFFF5F5F5),
                width: 20.sp,
                height: 20.sp,
              ),
            ),
          ),
        ),
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
          'Upload Profile Photo',
          style: TextStyle(
            fontFamily: 'Neue',
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFF5F5F5),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Add a clear photo so people know it\'s you.',
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

  Widget _buildProfileImage() {
    if (_selectedFile != null) {
      return Center(
        child: Container(
          width: 170.w,
          height: 170.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: FileImage(_selectedFile!),
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }

    return Center(
      child: Image.asset(
        AppAssets.profileUploadPng,
        width: double.infinity,
        fit: BoxFit.contain,
      ),
    );
  }

  bool _isUploading = false;

  void _onUploadTap(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final file = await _stableCopy(File(picked.path));

    setState(() {
      _selectedFile = file;
      _isUploading = true;
    });

    // Upload as profile photo; imageDocumentId is set to same ID on success
    await ref
        .read(registrationNotifierProvider.notifier)
        .uploadProfilePhoto(file);

    if (!context.mounted) return;
    setState(() => _isUploading = false);

    final regState = ref.read(registrationNotifierProvider);
    if (regState.profilePhotoStatus == DocumentUploadStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            regState.errorMessage.isNotEmpty
                ? regState.errorMessage
                : 'Upload failed. Please try again.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (regState.profilePhotoStatus == DocumentUploadStatus.uploaded) {
      final type = ref.read(talentTypeProvider);
      final nextRoute = type == TalentType.professional
          ? '/professional-events'
          : '/skilled-social-links';
      GoRouter.of(context).go(nextRoute);
    }
  }

  Widget _buildBottomRow(BuildContext context) {
    ref.watch(registrationNotifierProvider);
    final isUploading = _isUploading;

    return GradientCtaButton(
      label: isUploading ? 'Uploading' : 'Upload',
      width: double.infinity,
      height: 54,
      leading: isUploading
          ? null
          : Image.asset(AppAssets.uploadIconPng, width: 18.w, height: 18.w),
      enabled: !isUploading,
      onPressed: isUploading ? null : () => _onUploadTap(context),
    );
  }
}
