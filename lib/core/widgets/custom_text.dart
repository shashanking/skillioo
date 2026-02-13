import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String data;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;

  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final FontStyle? fontStyle;
  final double? height;
  final double? letterSpacing;
  final String? fontFamily;

  final TextDecoration? decoration;
  final Color? decorationColor;
  final TextDecorationStyle? decorationStyle;
  final double? decorationThickness;

  const CustomText(
    this.data, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.fontStyle,
    this.height,
    this.letterSpacing,
    this.fontFamily,
    this.decoration,
    this.decorationColor,
    this.decorationStyle,
    this.decorationThickness,
  });

  @override
  Widget build(BuildContext context) {
    final base = DefaultTextStyle.of(context).style;

    final effectiveStyle = base.copyWith(
      fontFamily: fontFamily ?? base.fontFamily ?? 'Outfit',
      color: color ?? base.color ?? Colors.white,
      fontSize: fontSize ?? base.fontSize,
      fontWeight: fontWeight ?? base.fontWeight,
      fontStyle: fontStyle ?? base.fontStyle,
      height: height ?? base.height,
      letterSpacing: letterSpacing ?? base.letterSpacing,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
    );

    return Text(
      data,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      style: effectiveStyle,
    );
  }
}
