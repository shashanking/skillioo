import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../constants/app_constants.dart';
import '../../../../core/localization/locale_extension.dart';
import '../../../../core/services/session_prefs.dart';
import '../../../../core/widgets/common_background.dart';
import '../../../../core/widgets/custom_text.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/icon_button.dart';
import '../../../onboarding/domain/document_service.dart';
import '../../domain/profile_update_service.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _groupNameController;
  late final TextEditingController _eventsCountController;

  bool _isSaving = false;
  bool _isUploadingPhoto = false;
  String _profilePhotoUrl = '';
  String _profileType = '';
  List<Map<String, dynamic>> _socialFollows = [];

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _groupNameController = TextEditingController();
    _eventsCountController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFromSession();
    });
  }

  Future<void> _loadFromSession() async {
    final profile = await SessionPrefs.instance.getProfile();
    if (!mounted) return;

    final portfolio = profile?['portfolio'] as Map<String, dynamic>? ?? {};
    final nestedProfile = profile?['profile'] as Map<String, dynamic>? ?? {};

    _profileType = (profile?['profileType'] as String? ??
            nestedProfile['profileType'] as String? ??
            '')
        .toUpperCase();

    final firstName = profile?['firstName'] as String? ?? '';
    final lastName = profile?['lastName'] as String? ?? '';
    final fullName = profile?['name'] as String? ?? '';
    final groupName = profile?['groupName'] as String? ??
        nestedProfile['groupName'] as String? ??
        '';

    String resolvedFirst = firstName;
    String resolvedLast = lastName;
    if (resolvedFirst.isEmpty && resolvedLast.isEmpty && fullName.isNotEmpty) {
      final parts = fullName.trim().split(RegExp(r'\s+'));
      if (parts.isNotEmpty) {
        resolvedFirst = parts.first;
        if (parts.length > 1) {
          resolvedLast = parts.sublist(1).join(' ');
        }
      }
    }

    // Events count — check multiple locations
    final totalEvents = profile?['totalEvents'] ??
        profile?['eventsDone'] ??
        portfolio['totalEvents'] ??
        nestedProfile['totalEvents'];

    _firstNameController.text = resolvedFirst;
    _lastNameController.text = resolvedLast;
    _groupNameController.text = groupName;
    _eventsCountController.text = (totalEvents is int)
        ? totalEvents.toString()
        : (totalEvents is num)
            ? totalEvents.toInt().toString()
            : (totalEvents is String ? totalEvents : '');

    // Social follows
    final rawFollows = profile?['follows'] ??
        portfolio['follows'] ??
        portfolio['socialMediaFollow'] ??
        profile?['socialMediaFollows'];
    if (rawFollows is List) {
      _socialFollows = rawFollows
          .whereType<Map<String, dynamic>>()
          .toList();
    }

    final rawUrl = profile?['profilePhotoUrl'] as String? ?? '';
    _profilePhotoUrl = rawUrl.startsWith('http://')
        ? rawUrl.replaceFirst('http://', 'https://')
        : rawUrl;

    if (_profilePhotoUrl.isEmpty) {
      final accessToken = await SessionPrefs.instance.getAccessToken();
      final profilePictureId = profile?['profilePictureId'] as String? ?? '';
      if (accessToken.isNotEmpty && profilePictureId.isNotEmpty) {
        try {
          final docService = DocumentService();
          final response = await docService.getDocumentsByIds(
            ids: [profilePictureId],
            accessToken: accessToken,
          );
          final success = response['success'] as bool? ?? false;
          final docs = response['data'];
          if (success && docs is List) {
            final picked = docs
                .cast<dynamic>()
                .whereType<Map<String, dynamic>>()
                .firstWhere(
                  (e) => e['id'] == profilePictureId,
                  orElse: () => <String, dynamic>{},
                );
            final url = picked['url'] as String? ?? '';
            if (url.isNotEmpty) {
              _profilePhotoUrl = url.startsWith('http://')
                  ? url.replaceFirst('http://', 'https://')
                  : url;
              await SessionPrefs.instance.mergeProfile({
                'profilePhotoUrl': _profilePhotoUrl,
              });
            }
          }
        } catch (_) {}
      }
    }

    setState(() {});
  }

  Future<void> _onChangeProfilePicture() async {
    if (_isUploadingPhoto) return;
    final accessToken = await SessionPrefs.instance.getAccessToken();
    final profileId = await SessionPrefs.instance.getProfileId();
    if (accessToken.isEmpty || profileId.isEmpty) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() {
      _isUploadingPhoto = true;
    });

    try {
      // 1. Upload document with type PROFILE_PHOTO
      final docService = DocumentService();
      final uploadResponse = await docService.uploadDocument(
        file: File(picked.path),
        type: 'PROFILE_PHOTO',
        accessToken: accessToken,
      );

      final uploadSuccess = uploadResponse['success'] as bool? ?? false;
      if (!uploadSuccess) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              uploadResponse['message'] as String? ??
                  'Failed to upload photo',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final docData = uploadResponse['data'] as Map<String, dynamic>? ?? {};
      final doc = docData['document'] as Map<String, dynamic>? ?? {};
      final docId = doc['id'] as String? ?? '';
      final rawUrl = doc['url'] as String? ?? '';
      final url = rawUrl.startsWith('http://')
          ? rawUrl.replaceFirst('http://', 'https://')
          : rawUrl;

      if (docId.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to get document ID'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // 2. Update profile with new profile picture document ID
      final profileService = ProfileUpdateService();
      await profileService.updateProfile(
        accessToken: accessToken,
        body: {
          'id': profileId,
          'profileDocumentId': docId,
        },
      );

      // 3. Save URL locally
      if (url.isNotEmpty) {
        _profilePhotoUrl = url;
        await SessionPrefs.instance.mergeProfile({
          'profilePhotoUrl': url,
          'profilePictureId': docId,
        });
      }

      if (!mounted) return;
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingPhoto = false;
        });
      }
    }
  }

  Future<void> _onSave() async {
    if (_isSaving) return;

    final accessToken = await SessionPrefs.instance.getAccessToken();
    final profileId = await SessionPrefs.instance.getProfileId();
    if (accessToken.isEmpty || profileId.isEmpty) return;

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final groupName = _groupNameController.text.trim();
    final totalEvents = int.tryParse(_eventsCountController.text.trim()) ?? 0;

    setState(() {
      _isSaving = true;
    });

    try {
      final body = <String, dynamic>{
        'id': profileId,
        'totalEvents': totalEvents,
      };
      if (_profileType == 'GROUP') {
        body['groupName'] = groupName;
      } else {
        body['firstName'] = firstName;
        body['lastName'] = lastName;
      }

      final service = ProfileUpdateService();
      final response = await service.updateProfile(
        accessToken: accessToken,
        body: body,
      );

      final status = response['status'] as int? ?? 0;
      final success = response['success'] as bool? ?? (status == 200);
      if (!success) {
        if (!mounted) return;
        // Extract detailed error from API response
        String errorMsg = response['message'] as String? ?? 'Failed to update profile';
        final errors = response['errorSourse'] ?? response['errorSource'] ?? response['errors'];
        if (errors is List && errors.isNotEmpty) {
          final details = errors.map((e) {
            if (e is Map) return e['message'] as String? ?? e.toString();
            return e.toString();
          }).join('. ');
          if (details.isNotEmpty) errorMsg = details;
        }
        debugPrint('EditProfile: save error response=$response');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final sessionUpdates = <String, dynamic>{
        'totalEvents': totalEvents,
      };
      if (_profileType == 'GROUP') {
        sessionUpdates['groupName'] = groupName;
        sessionUpdates['name'] = groupName;
      } else {
        sessionUpdates['firstName'] = firstName;
        sessionUpdates['lastName'] = lastName;
        sessionUpdates['name'] =
            [firstName, lastName].where((e) => e.isNotEmpty).join(' ');
      }
      await SessionPrefs.instance.mergeProfile(sessionUpdates);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).maybePop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  static String _formatFollowers(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _groupNameController.dispose();
    _eventsCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.tr;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: CommonBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
                decoration: BoxDecoration(color: AppColors.glassWhite12),
                child: Row(
                  children: [
                    IconCircleButton(
                      assetPath: 'assets/images/arrow-left.png',
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                    SizedBox(width: 24.w),
                    CustomText(
                      tr.editProfile,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Neue',
                      color: AppColors.foundationBlack20,
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 24.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile picture
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 140.w,
                              height: 140.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.glassWhite48,
                                  width: 3,
                                ),
                                image: DecorationImage(
                                  image: _profilePhotoUrl.isNotEmpty
                                      ? NetworkImage(_profilePhotoUrl)
                                      : const AssetImage(
                                              AppAssets.professionalProfileJpg,
                                            )
                                            as ImageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(height: 12.h),
                            GestureDetector(
                              onTap: _onChangeProfilePicture,
                              child: CustomText(
                                tr.changeProfilePicture,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.accentCyan,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 32.h),
                      if (_profileType == 'GROUP') ...[
                        _buildTextField(
                          label: 'Group Name',
                          controller: _groupNameController,
                        ),
                        SizedBox(height: 20.h),
                      ] else ...[
                        _buildTextField(
                          label: tr.firstName,
                          controller: _firstNameController,
                        ),
                        SizedBox(height: 20.h),
                        _buildTextField(
                          label: tr.lastName,
                          controller: _lastNameController,
                        ),
                        SizedBox(height: 20.h),
                      ],
                      // Events Count
                      _buildTextField(
                        label: tr.eventsCount,
                        controller: _eventsCountController,
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 32.h),
                      // Accounts Binded
                      CustomText(
                        tr.accountsBinded,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Neue',
                        color: AppColors.foundationBlack20,
                      ),
                      SizedBox(height: 16.h),
                      Wrap(
                        spacing: 24.w,
                        runSpacing: 16.h,
                        children: [
                          ..._socialFollows.map((f) {
                            final platform =
                                (f['socialMedia'] as String? ?? '')
                                    .toUpperCase();
                            final followers = f['followers'] as int? ?? 0;
                            String icon;
                            switch (platform) {
                              case 'INSTAGRAM':
                                icon = 'assets/images/instagram.png';
                                break;
                              case 'FACEBOOK':
                                icon = 'assets/images/facebook.png';
                                break;
                              default:
                                icon = 'assets/images/facebook.png';
                            }
                            return _buildSocialItem(
                              icon: Image.asset(icon, width: 24.w, height: 24.w),
                              label: '${_formatFollowers(followers)} ${tr.followers}',
                            );
                          }),
                          _buildAddAccountItem(),
                        ],
                      ),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),
              // Save Button
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                child: GradientCtaButton(
                  label: _isSaving ? tr.saving : tr.saveChanges,
                  onPressed: _isSaving ? null : _onSave,
                  width: double.infinity,
                  borderRadius: BorderRadius.circular(48.r),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          label,
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
          fontFamily: 'Neue',
          color: AppColors.foundationBlack20,
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.glassWhite12,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.foundationBlack20,
            ),
            cursorColor: AppColors.accentCyan,
            decoration: const InputDecoration(
              border: InputBorder.none,
              isCollapsed: true,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialItem({required Widget icon, required String label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: icon),
        SizedBox(height: 6.h),
        CustomText(
          label,
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.foundationBlack20,
        ),
      ],
    );
  }

  Widget _buildAddAccountItem() {
    return GestureDetector(
      onTap: () => context.push('/profile-add-account'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.add, color: AppColors.foundationBlack20, size: 24.sp),
          SizedBox(height: 6.h),
          CustomText(
            ref.tr.addAccount,
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.foundationBlack20,
          ),
        ],
      ),
    );
  }
}

