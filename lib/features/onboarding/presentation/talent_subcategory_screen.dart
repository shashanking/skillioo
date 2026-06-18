import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/common_background.dart';
import '../../../core/widgets/gradient_cta_button.dart';
import '../../../core/services/session_prefs.dart';
import '../application/talent_subcategory_provider.dart';
import '../application/talent_category_provider.dart';
import '../application/category_provider.dart';
import '../domain/category_models.dart';

class TalentSubcategoryScreen extends ConsumerStatefulWidget {
  const TalentSubcategoryScreen({super.key});

  @override
  ConsumerState<TalentSubcategoryScreen> createState() =>
      _TalentSubcategoryScreenState();
}

class _TalentSubcategoryScreenState
    extends ConsumerState<TalentSubcategoryScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _showContinue = false;
  bool _isSubmitting = false;
  List<SubCategory> _subCategories = [];

  @override
  void initState() {
    super.initState();
    _loadSubCategories();
    // Keyboard stays hidden until user taps the input field
    _controller.addListener(_onChanged);
  }

  Future<void> _loadSubCategories() async {
    try {
      final categoryId = ref.read(selectedCategoryIdProvider);
      if (categoryId == null) {
        setState(() {
        });
        return;
      }

      final service = ref.read(categoryServiceProvider);
      final token = await SessionPrefs.instance.getAccessToken();
      if (token.isNotEmpty) {
        service.setAuthToken(token);
      }

      final response = await service.getSubCategories(categoryId);
      final status = response['status'] as int? ?? 0;
      if (status == 200) {
        final data = response['data'] as List<dynamic>? ?? [];
        setState(() {
          _subCategories = data
              .map((json) => SubCategory.fromJson(json as Map<String, dynamic>))
              .toList();
        });
      } else {
        setState(() {
        });
      }
    } catch (e) {
      setState(() {
      });
    }
  }

  void _onChanged() {
    final value = _controller.text.trim();
    setState(() {
      _showContinue = value.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = _controller.text.trim();
    final suggestions = text.isEmpty
        ? _subCategories.map((c) => c.name).toList()
        : _subCategories
              .where((c) => c.name.toLowerCase().startsWith(text.toLowerCase()))
              .map((c) => c.name)
              .toList();
    final shouldShowSuggestions = suggestions.isNotEmpty;

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
                    SizedBox(height: 32.h),
                    _buildInput(),
                    if (shouldShowSuggestions) ...[
                      SizedBox(height: 24.h),
                      _buildSuggestions(suggestions),
                    ],
                  ],
                ),
              ),
              if (_showContinue) _buildContinueButton(context),
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
              GoRouter.of(context).go('/talent-category');
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
          'Step: 2 of 3',
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
          'Enter Talent Sub-Category',
          style: TextStyle(
            fontFamily: 'Neue',
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFF5F5F5),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Tell us your sub-category — like classical singer, baller.',
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

  Widget _buildInput() {
    return Container(
      height: 56.h,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24.r),
      ),
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        textInputAction: TextInputAction.done,
        style: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: const Color(0xFFF5F5F5),
        ),
        cursorColor: Colors.white,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'For ex - Batsman',
          hintStyle: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.6),
          ),
          isCollapsed: true,
        ),
        inputFormatters: [LengthLimitingTextInputFormatter(60)],
      ),
    );
  }

  Widget _buildSuggestions(List<String> suggestions) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxHeight: 200.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final s = suggestions[index];
          return GestureDetector(
            onTap: () {
              _controller.text = s;
              _controller.selection = TextSelection.fromPosition(
                TextPosition(offset: s.length),
              );
              FocusScope.of(context).unfocus();
              setState(() {
                _showContinue = true;
              });
            },
            child: Container(
              height: 64,
              alignment: Alignment.centerLeft,
              child: Text(
                s,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFF5F5F5),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 24.h,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: SizedBox(
          width: double.infinity,
          height: 58.h,
          child: GradientCtaButton(
            label: _isSubmitting ? 'Please wait...' : 'Continue',
            width: double.infinity,
            height: 58,
            enabled: !_isSubmitting,
            onPressed: _isSubmitting ? null : () => _onContinue(context),
          ),
        ),
      ),
    );
  }

  /// Trims, collapses whitespace and Title-Cases a sub-category name so
  /// it's stored consistently (e.g. "  classical  SINGER " →
  /// "Classical Singer").
  String _formatName(String raw) {
    final cleaned = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (cleaned.isEmpty) return cleaned;
    return cleaned
        .split(' ')
        .map((w) => w.isEmpty
            ? w
            : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }

  Future<void> _onContinue(BuildContext context) async {
    if (_isSubmitting) return;
    final formatted = _formatName(_controller.text);
    if (formatted.isEmpty) return;

    final categoryId = ref.read(selectedCategoryIdProvider);
    if (categoryId == null) return;

    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    final existing = _subCategories
        .where((c) => c.name.toLowerCase() == formatted.toLowerCase())
        .firstOrNull;

    String subName;

    if (existing != null) {
      subName = existing.name;
    } else {
      // New sub-category — create it on the backend under this category.
      setState(() => _isSubmitting = true);
      try {
        final service = ref.read(categoryServiceProvider);
        final token = await SessionPrefs.instance.getAccessToken();
        if (token.isNotEmpty) service.setAuthToken(token);

        final response = await service.createSubCategory(
          name: formatted,
          categoryId: categoryId,
        );
        final status = response['status'] as int?;
        final success = response['success'] as bool? ??
            (status == 200 || status == 201);
        final data = response['data'];

        if (!success || data is! Map) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text(
                "Couldn't create the sub-category. Please try again.",
              ),
              backgroundColor: Colors.red,
            ),
          );
          if (mounted) setState(() => _isSubmitting = false);
          return;
        }

        subName = (data['name'] as String?) ?? formatted;
      } catch (_) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              "Couldn't create the sub-category. Please try again.",
            ),
            backgroundColor: Colors.red,
          ),
        );
        if (mounted) setState(() => _isSubmitting = false);
        return;
      }
      if (mounted) setState(() => _isSubmitting = false);
    }

    if (!mounted) return;
    ref.read(talentSubcategoryProvider.notifier).state = subName;
    router.go('/upload-videos');
  }
}
