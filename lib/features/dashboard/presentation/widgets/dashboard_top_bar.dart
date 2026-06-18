import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:skillioo/core/widgets/app_menu_screen.dart';
import 'package:skillioo/features/profile/presentation/profile.dart';
import 'package:skillioo/features/profile/presentation/widgets/select_location_screen.dart';

import '../../../../constants/app_constants.dart';
import '../../../../core/services/session_prefs.dart';
import '../../../../core/services/session_state_provider.dart';
import '../../../../core/widgets/custom_text.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../onboarding/domain/registration_models.dart';

class DashboardTopBar extends ConsumerWidget {
  const DashboardTopBar({
    super.key,
    this.onLocationSelected,
    this.onClearLocation,
    this.selectedCity,
  });

  final ValueChanged<String?>? onLocationSelected;
  final VoidCallback? onClearLocation;
  final String? selectedCity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionStateProvider);
    final isAnonymous = session.isAnonymous;
    // A logged-in user whose `isCreator` is still false hasn't completed
    // onboarding (no hiring rates, portfolio, etc). Treat them like an
    // anonymous user for the top-bar CTA — show "Create Profile" instead
    // of an empty avatar.
    final isCreator = session.profile?['isCreator'] as bool? ?? false;
    // A non-creator who completed the lightweight (hirer) profile flow.
    final isHirer =
        (session.profile?['profileType'] as String?) == ProfileType.hirer;
    final showCreateProfileCta = isAnonymous || !isCreator;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AppMenuScreen()),
              );
            },
            child: _IconButton(assetPath: AppAssets.menuPng),
          ),
          Row(
            children: [
              // Inline city chip is only shown next to the picker for
              // creators — non-creators have wider Logout + Create
              // Profile pills, so the chip renders below the top bar
              // instead (see DashboardScreen).
              if (!showCreateProfileCta &&
                  (selectedCity?.trim().isNotEmpty == true)) ...[
                SizedBox(width: 8.w),
                SelectedCityChip(
                  city: selectedCity!.trim(),
                  onClear: onClearLocation,
                ),
              ],
              SizedBox(width: 12.w),
              // Location picker is available to anyone logged in —
              // creators and non-creators alike.
              Visibility(
                visible: !isAnonymous,
                replacement: const SizedBox.shrink(),
                child: GestureDetector(
                  onTap: () async {
                    final city = await Navigator.of(context)
                        .push<String?>(
                          MaterialPageRoute(
                            builder: (context) => const SelectLocationScreen(),
                          ),
                        );
                    onLocationSelected?.call(city);
                  },
                  child: _IconButton(assetPath: AppAssets.locationPng),
                ),
              ),

              SizedBox(width: 12.w),
              if (isAnonymous) ...[
                _LoginButton(),
                SizedBox(width: 12.w),
                _CreateProfileButton(),
              ] else if (isHirer) ...[
                // Has a lightweight (hirer) profile — show the same
                // avatar circle creators get. Tapping opens the profile
                // section, but the profile image inside it stays
                // non-tappable: hirers have no profile-detail page.
                const _AvatarButton(allowProfileDetails: false),
              ] else if (showCreateProfileCta) ...[
                // Logged in, no profile yet — let them log out OR
                // finish creating their profile.
                _LogoutButton(),
                SizedBox(width: 12.w),
                _CreateProfileButton(),
              ] else ...[
                const _AddMenuButton(),
                SizedBox(width: 12.w),
                _AvatarButton(),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Wider "Selected Location" card used under the top bar for
/// non-creator users. Title row + pin/city/close row.
class SelectedLocationCard extends StatelessWidget {
  const SelectedLocationCard({
    super.key,
    required this.city,
    this.onClear,
  });

  final String city;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          'Selected Location',
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: Colors.white.withValues(alpha: 0.6),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Image.asset(
                AppAssets.locationPng,
                width: 20.w,
                height: 20.w,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: CustomText(
                  city,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              SizedBox(width: 12.w),
              GestureDetector(
                onTap: onClear,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Icon(
                    Icons.close,
                    size: 20.sp,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Pill chip showing the active location filter. Public so the
/// dashboard can render it under the top bar for non-creator users
/// (where the inline-with-picker placement would overflow).
class SelectedCityChip extends StatelessWidget {
  const SelectedCityChip({super.key, required this.city, this.onClear});

  final String city;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 140.w),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: 56.w),
            child: CustomText(
              city,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: onClear,
            child: Icon(
              Icons.close,
              size: 16.sp,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

enum _AddMenuAction { upload, createProfile }

/// Pill button shown to anonymous users — sends them to the start of
/// the auth flow. Visually identical to [_LogoutButton].
class _LoginButton extends StatelessWidget {
  const _LoginButton();

  @override
  Widget build(BuildContext context) {
    return _PillButton(
      label: 'Log In',
      onTap: () => GoRouter.of(context).go('/start'),
    );
  }
}

/// Pill button shown to logged-in users whose profile isn't complete.
/// Clears the session and bounces them to the start screen.
class _LogoutButton extends ConsumerWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _PillButton(
      label: 'Logout',
      onTap: () async {
        final router = GoRouter.of(context);
        await SessionPrefs.instance.clear();
        await ref.read(sessionStateProvider.notifier).refresh();
        router.go('/start');
      },
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: CustomText(
          label,
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _CreateProfileButton extends StatelessWidget {
  const _CreateProfileButton();

  @override
  Widget build(BuildContext context) {
    return GradientCtaButton(
      label: 'Create Profile',
      height: 36,
      borderRadius: BorderRadius.circular(24.r),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      onPressed: () {
        GoRouter.of(context).push('/profile-type');
      },
    );
  }
}

class _AddMenuButton extends StatelessWidget {
  const _AddMenuButton();

  Future<void> _showAddMenu(BuildContext context) async {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    final router = GoRouter.of(context);

    final isProfileCreated = await SessionPrefs.instance.isProfileCreated();
    if (!context.mounted) return;

    // If there is only one action, open Create Post directly.
    if (isProfileCreated) {
      router.push('/profile-create-post');
      return;
    }

    final items = <PopupMenuEntry<_AddMenuAction>>[
      const PopupMenuItem(
        value: _AddMenuAction.upload,
        child: _AddMenuItemRow(title: 'Upload'),
      ),
      if (!isProfileCreated)
        const PopupMenuItem(
          value: _AddMenuAction.createProfile,
          child: _AddMenuItemRow(title: 'Create Profile'),
        ),
    ];

    final value = await showMenu<_AddMenuAction>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height,
        offset.dx + size.width,
        offset.dy + size.height + 200,
      ),
      items: items,
      color: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(
          color: Colors.black.withValues(alpha: 0.1),
          width: 1.w,
        ),
      ),
    );

    if (value == null) return;

    switch (value) {
      case _AddMenuAction.upload:
        router.push('/profile-create-post');
        break;
      case _AddMenuAction.createProfile:
        router.push('/profile-type');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (btnContext) {
        return GestureDetector(
          onTap: () => _showAddMenu(btnContext),
          child: _IconButton(assetPath: AppAssets.addPng),
        );
      },
    );
  }
}

class _AddMenuItemRow extends StatelessWidget {
  final String title;

  const _AddMenuItemRow({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CustomText(
          title,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ],
    );
  }
}

class _IconButton extends StatelessWidget {
  final String assetPath;

  const _IconButton({required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.12),
      ),
      child: Center(
        child: Image.asset(assetPath, width: 24.w, height: 24.w),
      ),
    );
  }
}

class _AvatarButton extends StatelessWidget {
  const _AvatarButton({this.allowProfileDetails = true});

  /// Passed through to [ProfileSectionScreen] — hirers can't open the
  /// full profile-detail page, so the inner avatar stays non-tappable.
  final bool allowProfileDetails;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final navigator = Navigator.of(context);
        final profile = await SessionPrefs.instance.getProfile();
        if (!context.mounted) return;

        final nickName = profile?['nickName'] as String? ?? '';
        final displayName = profile?['name'] as String? ?? '';
        final first = (profile?['firstName'] as String? ?? '').trim();
        final last = (profile?['lastName'] as String? ?? '').trim();
        final fullName = '$first $last'.trim();
        final bio = profile?['bio'] as String? ?? '';
        final rawAvatarUrl =
            profile?['profilePhotoUrl'] as String? ??
            profile?['avatarUrl'] as String? ??
            '';
        final avatarUrl = rawAvatarUrl.startsWith('http://')
            ? rawAvatarUrl.replaceFirst('http://', 'https://')
            : rawAvatarUrl;

        navigator.push(
          MaterialPageRoute(
            builder: (context) => ProfileSectionScreen(
              name: displayName.isNotEmpty
                  ? displayName
                  : (nickName.isNotEmpty
                        ? nickName
                        : (fullName.isNotEmpty ? fullName : 'Profile')),
              role: '',
              avatarAssetPath: AppAssets.logoPng,
              avatarUrl: avatarUrl,
              bio: bio,
              allowProfileDetails: allowProfileDetails,
            ),
          ),
        );
      },
      child: Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.12),
        ),
        child: Center(
          child: ClipOval(
            child: FutureBuilder<Map<String, dynamic>?>(
              future: SessionPrefs.instance.getProfile(),
              builder: (context, snapshot) {
                final profile = snapshot.data;
                final rawAvatarUrl =
                    profile?['profilePhotoUrl'] as String? ??
                    profile?['avatarUrl'] as String? ??
                    '';
                final avatarUrl = rawAvatarUrl.startsWith('http://')
                    ? rawAvatarUrl.replaceFirst('http://', 'https://')
                    : rawAvatarUrl;
                if (avatarUrl.isNotEmpty) {
                  return Image.network(
                    avatarUrl,
                    width: 48.w,
                    height: 48.w,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        AppAssets.logoPng,
                        width: 48.w,
                        height: 48.w,
                        fit: BoxFit.cover,
                      );
                    },
                  );
                }
                return Image.asset(
                  AppAssets.logoPng,
                  width: 48.w,
                  height: 48.w,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
