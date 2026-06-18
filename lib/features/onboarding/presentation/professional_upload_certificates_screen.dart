import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';

import '../../../constants/app_constants.dart';
import '../../../core/services/session_prefs.dart';
import '../../../core/widgets/common_background.dart';
import '../../../core/widgets/gradient_cta_button.dart';
import '../../profile/domain/profile_update_service.dart';
import '../application/registration_providers.dart';

enum _CertificatesState { notes, list }

class ProfessionalUploadCertificatesScreen extends ConsumerStatefulWidget {
  const ProfessionalUploadCertificatesScreen({
    super.key,
    this.backFallbackRoute = '/professional-events',
    this.skipNextRoute = '/options',
    this.uploadSuccessRoute = '/professional-certificates-success',
    this.showStepIndicator = true,
  });

  final String backFallbackRoute;
  final String skipNextRoute;
  final String uploadSuccessRoute;
  final bool showStepIndicator;

  @override
  ConsumerState<ProfessionalUploadCertificatesScreen> createState() =>
      _ProfessionalUploadCertificatesScreenState();
}

class _ProfessionalUploadCertificatesScreenState
    extends ConsumerState<ProfessionalUploadCertificatesScreen> {
  _CertificatesState _state = _CertificatesState.notes;

  final List<String> _pickedFileNames = <String>[];
  final List<String> _pickedFilePaths = <String>[];

  bool _isUploading = false;

  Future<File> _stableCopy(File source) async {
    final dir = await getTemporaryDirectory();
    final ext = source.path.split('.').last;
    final dest = File(
      '${dir.path}/skillioo_cert_${DateTime.now().millisecondsSinceEpoch}.$ext',
    );
    return source.copy(dest.path);
  }

  Future<void> _pickAndUploadSingle(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpeg', 'jpg', 'png'],
      allowMultiple: false,
    );

    final picked = result?.files.single;
    if (picked == null || picked.path == null) return;

    final stableFile = await _stableCopy(File(picked.path!));

    if (!mounted) return;
    setState(() {
      _pickedFileNames.add(picked.name);
      _pickedFilePaths.add(stableFile.path);
      _state = _CertificatesState.list;
      _isUploading = true;
    });

    final docId = await ref
        .read(registrationNotifierProvider.notifier)
        .uploadEvent(stableFile);

    if (!context.mounted) return;
    setState(() => _isUploading = false);

    final updated = ref.read(registrationNotifierProvider);
    if (docId == null || docId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            updated.errorMessage.isNotEmpty
                ? updated.errorMessage
                : 'Upload failed. Please try again.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // When used from profile, link to profile immediately and show success
    if (!widget.showStepIndicator) {
      try {
        final token = await SessionPrefs.instance.getAccessToken();
        debugPrint(
          'CertUpload: linking docId=$docId '
          'allIds=${updated.eventsDoneDocumentIds} '
          'hasToken=${token.isNotEmpty}',
        );
        if (token.isNotEmpty) {
          final service = ProfileUpdateService();
          final linkResp = await service.updateProfile(
            accessToken: token,
            body: {
              'portfolio': {
                'eventsDoneDocumentIds': updated.eventsDoneDocumentIds,
              },
            },
          );
          debugPrint('CertUpload: link response=$linkResp');
        }
      } catch (e) {
        debugPrint('Link certificate to profile error: $e');
      }
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Certificate uploaded successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showPreview(String filePath, String fileName) {
    final isImage =
        fileName.toLowerCase().endsWith('.jpg') ||
        fileName.toLowerCase().endsWith('.jpeg') ||
        fileName.toLowerCase().endsWith('.png');

    if (!isImage) {
      // Open PDF in native viewer
      OpenFilex.open(filePath);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(child: Image.file(File(filePath))),
            ),
            Positioned(
              top: 40.h,
              right: 20.w,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
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
                    Text(
                      'Note:',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFF5F5F5),
                      ),
                    ),
                    SizedBox(height: 8.h),

                    if (_state == _CertificatesState.notes)
                      _buildNotesCard()
                    else
                      _buildUploadedFiles(),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 24.h,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: _state == _CertificatesState.notes
                      ? _buildBottomButtons(context)
                      : _buildUploadNowCta(context),
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
            if (_state == _CertificatesState.list) {
              setState(() {
                _state = _CertificatesState.notes;
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
              child: Image.asset(
                'assets/images/arrow-left.png',
                color: const Color(0xFFF5F5F5),
                width: 20.sp,
                height: 20.sp,
              ),
            ),
          ),
        ),
        if (widget.showStepIndicator)
          Text(
            'Step: 2 of 4',
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
          'Upload Skill Certificates',
          style: TextStyle(
            fontFamily: 'Neue',
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFF5F5F5),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Share any skill-related certs that boost your profile.',
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
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBullet('Max file size 10 - 50 MB.'),
          SizedBox(height: 4.h),
          _buildBullet('Supported format pdf, jpeg.'),
          SizedBox(height: 4.h),
          _buildBullet(
            'You can also upload event certificates or any proof of event.',
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

  Widget _buildBottomButtons(BuildContext context) {
    return GradientCtaButton(
      label: 'Upload Now',
      width: double.infinity,
      height: 54,
      leading: Image.asset(AppAssets.uploadIconPng, width: 18.w, height: 18.w),
      enabled: !_isUploading,
      onPressed: _isUploading ? null : () => _pickAndUploadSingle(context),
    );
  }

  Widget _buildUploadedFiles() {
    final items = _pickedFileNames;

    return Column(
      children: [
        for (int i = 0; i < items.length; i++)
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 16.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => _showPreview(_pickedFilePaths[i], items[i]),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: _buildFilePreview(_pickedFilePaths[i], items[i]),
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Icon(
                      Icons.insert_drive_file_outlined,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: 18.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        items[i],
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFF5F5F5),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (_isUploading) return;
                        setState(() {
                          _pickedFileNames.removeAt(i);
                          _pickedFilePaths.removeAt(i);
                          if (_pickedFileNames.isEmpty) {
                            _state = _CertificatesState.notes;
                          }
                        });
                        ref
                            .read(registrationNotifierProvider.notifier)
                            .removeEventDocument(i);
                      },
                      child: Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                        size: 20.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFilePreview(String filePath, String fileName) {
    final isImage =
        fileName.toLowerCase().endsWith('.jpg') ||
        fileName.toLowerCase().endsWith('.jpeg') ||
        fileName.toLowerCase().endsWith('.png');

    if (isImage) {
      return Container(
        height: 120.h,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: FileImage(File(filePath)),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    // PDF preview
    return Container(
      height: 120.h,
      width: double.infinity,
      color: Colors.black.withValues(alpha: 0.15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.picture_as_pdf_rounded,
            color: Colors.redAccent,
            size: 40.sp,
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              'PDF',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Colors.redAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadNowCta(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 54.h,
            child: GradientCtaButton(
              onPressed: _isUploading
                  ? null
                  : () => _pickAndUploadSingle(context),

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
          child: GradientCtaButton(
            height: 54,
            borderRadius: BorderRadius.circular(48.r),
            onPressed: _isUploading
                ? null
                : () {
                    // From profile: just pop back (upload+link already done per-file)
                    if (!widget.showStepIndicator) {
                      if (GoRouter.of(context).canPop()) {
                        GoRouter.of(context).pop();
                      } else {
                        GoRouter.of(context).go('/landing');
                      }
                      return;
                    }

                    GoRouter.of(context).go(widget.uploadSuccessRoute);
                  },
            child: _isUploading
                ? SizedBox(
                    width: 22.w,
                    height: 22.w,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.showStepIndicator
                            ? Icons.upload
                            : Icons.check,
                        color: const Color(0xFFF5F5F5),
                        size: 18.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        widget.showStepIndicator ? 'Upload' : 'Done',
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
      ],
    );
  }
}
