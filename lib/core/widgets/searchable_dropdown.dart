import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A pill-styled, type-to-search field.
///
/// Unlike a plain dropdown, the full list never drops down on tap —
/// suggestions appear only once the user starts typing, matched by
/// prefix (typing "N" surfaces entries starting with "N").
class SearchableDropdown<T extends Object> extends StatefulWidget {
  const SearchableDropdown({
    super.key,
    required this.items,
    required this.hint,
    required this.labelOf,
    required this.onSelected,
    this.enabled = true,
  });

  final List<T> items;
  final String hint;
  final String Function(T) labelOf;
  final ValueChanged<T> onSelected;
  final bool enabled;

  @override
  State<SearchableDropdown<T>> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T extends Object>
    extends State<SearchableDropdown<T>> {
  // Captured from the field so the suggestion overlay matches its width.
  double _fieldWidth = 0;

  @override
  Widget build(BuildContext context) {
    return Autocomplete<T>(
      displayStringForOption: widget.labelOf,
      optionsBuilder: (TextEditingValue value) {
        if (!widget.enabled) return const Iterable.empty();
        final query = value.text.trim().toLowerCase();
        // Empty query → no overlay; the whole list never drops down.
        if (query.isEmpty) return const Iterable.empty();
        return widget.items.where(
          (item) => widget.labelOf(item).toLowerCase().startsWith(query),
        );
      },
      onSelected: widget.onSelected,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return LayoutBuilder(
          builder: (context, constraints) {
            _fieldWidth = constraints.maxWidth;
            return _PillField(
              controller: controller,
              focusNode: focusNode,
              hint: widget.hint,
              enabled: widget.enabled,
            );
          },
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            color: const Color(0xFF1E1E1E),
            elevation: 6,
            borderRadius: BorderRadius.circular(16.r),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 220.h,
                minWidth: _fieldWidth,
                maxWidth: _fieldWidth,
              ),
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return InkWell(
                    onTap: () => onSelected(option),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      child: Text(
                        widget.labelOf(option),
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFFF5F5F5),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PillField extends StatelessWidget {
  const _PillField({
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.enabled,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.h,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              enabled: enabled,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFF5F5F5),
              ),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                hintText: hint,
                hintStyle: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
          Icon(
            Icons.search,
            size: 18.sp,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ],
      ),
    );
  }
}
