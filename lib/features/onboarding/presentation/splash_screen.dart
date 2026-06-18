import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../constants/app_constants.dart';
import '../../../core/services/session_prefs.dart';
import '../../../core/services/session_state_provider.dart';
import '../../onboarding/domain/document_service.dart';
import '../../profile/domain/profile_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _showPng = false;

  late final ImageProvider _gifProvider;
  late final ImageProvider _pngProvider;

  @override
  void initState() {
    super.initState();
    _gifProvider = const AssetImage(AppAssets.logoGif);
    _pngProvider = const AssetImage(AppAssets.logoPng);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(_pngProvider, context);
      _checkSessionAndNavigate();
    });
  }

  Future<void> _checkSessionAndNavigate() async {
    await Future.delayed(const Duration(milliseconds: 3300));
    if (!mounted) return;

    setState(() {
      _showPng = true;
    });

    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    final isLoggedIn = await SessionPrefs.instance.isLoggedIn();
    if (!mounted) return;

    if (isLoggedIn) {
      await _bootstrapProfileState();
      // Sync merged profile data (portfolioId, photo URL, profileType) into
      // Riverpod so dashboard/top-bar consumers see the correct state on
      // first load without requiring a manual refresh.
      await ref.read(sessionStateProvider.notifier).refresh();
      // Only fully-onboarded creators land on the dashboard. Anyone whose
      // profile isn't completed yet (isCreator: false) goes to /options
      // so they can finish onboarding.
      final profile = await SessionPrefs.instance.getProfile();
      final isCreator = profile?['isCreator'] as bool? ?? false;
      if (!mounted) return;
      context.go(isCreator ? '/landing' : '/options');
    } else {
      context.go('/start');
    }
  }

  Future<void> _bootstrapProfileState() async {
    try {
      final accessToken = await SessionPrefs.instance.getAccessToken();
      final profileId = await SessionPrefs.instance.getProfileId();
      if (accessToken.isEmpty || profileId.isEmpty) return;

      final service = ProfileService();
      final response = await service.getProfile(
        profileId: profileId,
        accessToken: accessToken,
      );

      final success = response['success'] as bool? ?? false;
      if (!success) {
        await SessionPrefs.instance.setProfileCreated(false);
        return;
      }

      await SessionPrefs.instance.setProfileCreated(true);

      final data = response['data'] as Map<String, dynamic>? ?? {};

      // Normalize possible backend shapes:
      // 1) data: { name, nickName, portfolioId, bio, isSubscribed, profilePictureId }
      // 2) data: { profile: { groupName, nickName, portfolioId, bio, isSubscribed }, profilePictureId }
      final nestedProfile = data['profile'] as Map<String, dynamic>?;
      final merged = <String, dynamic>{};

      if (nestedProfile != null) {
        final groupName = nestedProfile['groupName'] as String?;
        if (groupName != null && groupName.isNotEmpty) {
          merged['name'] = groupName;
        }
        final nickName = nestedProfile['nickName'] as String?;
        if (nickName != null && nickName.isNotEmpty) {
          merged['nickName'] = nickName;
        }
        final portfolioId = nestedProfile['portfolioId'] as String?;
        if (portfolioId != null && portfolioId.isNotEmpty) {
          merged['portfolioId'] = portfolioId;
        }
        final bio = nestedProfile['bio'] as String?;
        if (bio != null) merged['bio'] = bio;
        final isSubscribed = nestedProfile['isSubscribed'];
        if (isSubscribed != null) merged['isSubscribed'] = isSubscribed;
      } else {
        final name = data['name'] as String?;
        if (name != null && name.isNotEmpty) merged['name'] = name;
        final nickName = data['nickName'] as String?;
        if (nickName != null && nickName.isNotEmpty) {
          merged['nickName'] = nickName;
        }
        final portfolioId = data['portfolioId'] as String?;
        if (portfolioId != null && portfolioId.isNotEmpty) {
          merged['portfolioId'] = portfolioId;
        }
        final bio = data['bio'] as String?;
        if (bio != null) merged['bio'] = bio;
        final isSubscribed = data['isSubscribed'];
        if (isSubscribed != null) merged['isSubscribed'] = isSubscribed;
      }

      final firstName =
          (data['firstName'] as String?) ??
          (nestedProfile?['firstName'] as String?);
      if (firstName != null) merged['firstName'] = firstName;
      final lastName =
          (data['lastName'] as String?) ??
          (nestedProfile?['lastName'] as String?);
      if (lastName != null) merged['lastName'] = lastName;

      final nestedPortfolio =
          nestedProfile?['portfolio'] as Map<String, dynamic>?;
      final dataPortfolio = data['portfolio'] as Map<String, dynamic>?;

      final rawTotalEvents =
          data['totalEvents'] ??
          nestedProfile?['totalEvents'] ??
          dataPortfolio?['totalEvents'] ??
          nestedPortfolio?['totalEvents'];
      int? totalEvents;
      if (rawTotalEvents is int) {
        totalEvents = rawTotalEvents;
      } else if (rawTotalEvents is double) {
        totalEvents = rawTotalEvents.toInt();
      } else if (rawTotalEvents is String) {
        totalEvents = int.tryParse(rawTotalEvents);
      }
      if (totalEvents != null) merged['totalEvents'] = totalEvents;

      if ((merged['name'] as String?) == null ||
          (merged['name'] as String?)?.isEmpty == true) {
        final computedName = [
          (merged['firstName'] as String?) ?? '',
          (merged['lastName'] as String?) ?? '',
        ].where((e) => e.trim().isNotEmpty).join(' ');
        if (computedName.isNotEmpty) {
          merged['name'] = computedName;
        }
      }

      // profilePictureId can be null OR { id: '...' } OR string-like
      final rawPic = data['profilePictureId'];
      if (rawPic is Map<String, dynamic>) {
        final picId = rawPic['id'] as String?;
        if (picId != null && picId.isNotEmpty) {
          merged['profilePictureId'] = picId;
        }
      } else if (rawPic is String && rawPic.isNotEmpty) {
        merged['profilePictureId'] = rawPic;
      }

      if (merged.isNotEmpty) {
        await SessionPrefs.instance.mergeProfile(merged);
      }

      await _bootstrapProfilePhotoUrl(
        accessToken: accessToken,
        profileId: profileId,
      );
    } catch (_) {
      // No-op: we don't block navigation on profile fetch failures.
    }
  }

  Future<void> _bootstrapProfilePhotoUrl({
    required String accessToken,
    required String profileId,
  }) async {
    try {
      final docService = DocumentService();
      final profile = await SessionPrefs.instance.getProfile();
      final expectedPicId = profile?['profilePictureId'] as String? ?? '';
      if (expectedPicId.isEmpty) return;

      final response = await docService.getDocumentsByIds(
        ids: [expectedPicId],
        accessToken: accessToken,
      );

      final success = response['success'] as bool? ?? false;
      final data = response['data'];
      if (!success || data is! List) return;

      final picked = data
          .cast<dynamic>()
          .whereType<Map<String, dynamic>>()
          .firstWhere(
            (e) => e['id'] == expectedPicId,
            orElse: () => <String, dynamic>{},
          );

      final url = picked['url'] as String? ?? '';
      if (url.isEmpty) return;

      final normalizedUrl = url.startsWith('http://')
          ? url.replaceFirst('http://', 'https://')
          : url;
      await SessionPrefs.instance.mergeProfile({
        'profilePhotoUrl': normalizedUrl,
      });
    } catch (_) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: Center(
          child: Hero(
            tag: 'logo',
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: Image(
                key: ValueKey<bool>(_showPng),
                image: _showPng ? _pngProvider : _gifProvider,
                width: _showPng ? 180.0 : null,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
