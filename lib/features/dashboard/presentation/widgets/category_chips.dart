import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategoryChips extends StatefulWidget {
  final List<String> categories;
  final Function(String?)? onCategoryChanged;

  const CategoryChips({
    super.key,
    required this.categories,
    this.onCategoryChanged,
  });

  @override
  State<CategoryChips> createState() => CategoryChipsState();
}

class CategoryChipsState extends State<CategoryChips> {
  int _selectedIndex = 0;
  final ScrollController _scrollController = ScrollController();

  // Per-chip keys for the scrollable categories (index >= 1). Used to
  // precisely scroll a selected chip into view via Scrollable.ensureVisible
  // instead of a fixed-width estimate (which mispositioned chips when the
  // labels had varying widths).
  final Map<int, GlobalKey> _chipKeys = {};

  GlobalKey _keyFor(int index) =>
      _chipKeys.putIfAbsent(index, () => GlobalKey());

  @override
  void didUpdateWidget(covariant CategoryChips oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Category list changed — stale keys would point at the wrong chips.
    if (oldWidget.categories.length != widget.categories.length) {
      _chipKeys.clear();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Snap selection back to the first chip ("All"). Used when the host
  /// resets — e.g. nav-bar tab change.
  void resetSelection() {
    if (_selectedIndex == 0) return;
    setState(() => _selectedIndex = 0);
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  /// Programmatically select the chip whose label matches [name].
  ///
  /// Match is case-insensitive and tolerant of word variants — "singing"
  /// will pick "Singer" via shared 4-char prefix ("sing"). Returns true if
  /// a chip was selected (and fires [widget.onCategoryChanged]).
  bool selectByName(String? name) {
    if (name == null || name.isEmpty) return false;
    final query = _normalize(name);
    if (query.isEmpty) return false;

    int? matchIndex;
    for (var i = 0; i < widget.categories.length; i++) {
      final chip = _normalize(widget.categories[i]);
      if (chip.isEmpty) continue;
      if (chip == query ||
          chip.contains(query) ||
          query.contains(chip) ||
          _sharedPrefix(chip, query) >= 4) {
        matchIndex = i;
        break;
      }
    }
    if (matchIndex == null) return false;

    setState(() => _selectedIndex = matchIndex!);
    widget.onCategoryChanged?.call(
      matchIndex == 0 ? null : widget.categories[matchIndex],
    );
    _scrollToSelected();
    return true;
  }

  String _normalize(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  int _sharedPrefix(String a, String b) {
    final n = a.length < b.length ? a.length : b.length;
    var i = 0;
    while (i < n && a[i] == b[i]) {
      i++;
    }
    return i;
  }

  void _scrollToSelected() {
    // "All" is pinned outside the scroll view — nothing to scroll.
    if (_selectedIndex == 0 || !_scrollController.hasClients) return;

    // The lazy ListView may not have built the target chip yet. Jump near
    // it with a rough estimate first so it gets a context, then precisely
    // center it once a frame has been laid out.
    final estimate = ((_selectedIndex - 1) * 120.w).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.jumpTo(estimate);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _chipKeys[_selectedIndex]?.currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        alignment: 0.5, // centre the selected chip in the viewport
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.categories;
    if (categories.isEmpty) return SizedBox(height: 40.h);

    return SizedBox(
      height: 40.h,
      child: Row(
        children: [
          // "All" is pinned to the left edge and never scrolls.
          Padding(
            padding: EdgeInsets.only(left: 16.w, right: 12.w),
            child: _buildChip(0),
          ),
          // Remaining categories scroll horizontally.
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.only(right: 16.w),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length - 1,
              itemBuilder: (context, i) {
                final index = i + 1; // skip "All" (index 0)
                return Padding(
                  padding: EdgeInsets.only(right: 12.w),
                  child: _buildChip(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(int index) {
    final isSelected = index == _selectedIndex;
    return GestureDetector(
      key: index == 0 ? null : _keyFor(index),
      onTap: () {
        setState(() => _selectedIndex = index);
        widget.onCategoryChanged?.call(
          index == 0 ? null : widget.categories[index],
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white
              : Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20.r),
        ),
        alignment: Alignment.center,
        child: Text(
          widget.categories[index],
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: isSelected ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }
}
