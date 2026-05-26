import 'package:flutter/material.dart';
import '../theme/custom_colors.dart';

class FontSizes {
  static const double extraSmall = 10.0;
  static const double small = 12.0;
  static const double medium = 14.0;
  static const double big = 16.0;
  static const double extraBig = 18.0;
  static const double moreExtra = 20.0;
}

class CustomText extends Text {
  CustomText.base(
    String text, {
    Key? key,
    double? fontSize = FontSizes.medium,
    Color? color = CustomColors.black,
    FontWeight? fontWeight,
    int? maxLines,
    TextAlign? textAlign,
    TextOverflow? textOverflow,
  }) : super(
          text.tr(),
          style: TextStyle(
            fontSize: fontSize,
            color: color,
            fontWeight: fontWeight,
          ),
          overflow: textOverflow,
          maxLines: maxLines,
          textAlign: textAlign,
          key: key,
        );

  CustomText.regular(
    String text, {
    Key? key,
    double? fontSize = FontSizes.medium,
    Color? color = CustomColors.black,
    FontWeight? fontWeight = FontWeight.w400,
    int? maxLines,
    TextAlign? textAlign,
    TextOverflow? textOverflow,
    TextDecoration? decoration,
    FontStyle? fontStyle,
    bool translate = true,
  }) : super(
          translate ? text.tr() : text,
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: fontWeight,
            decoration: decoration,
            fontStyle: fontStyle,
          ),
          maxLines: maxLines,
          key: key,
          textAlign: textAlign,
          overflow: textOverflow,
        );

  CustomText.medium(
    String text, {
    Key? key,
    double? fontSize = FontSizes.medium,
    Color? color = CustomColors.black,
    FontWeight? fontWeight = FontWeight.w500,
    int? maxLines,
    TextAlign? textAlign,
    TextOverflow? textOverflow,
    Map<String, String>? namedArgs,
  }) : super(
          text.tr(namedArgs: namedArgs),
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
          maxLines: maxLines,
          key: key,
          textAlign: textAlign,
          overflow: textOverflow,
        );

  CustomText.semiBold(
    String text, {
    Key? key,
    double? fontSize = FontSizes.medium,
    Color? color = CustomColors.color262626,
    FontWeight? fontWeight = FontWeight.w600,
    int? maxLines,
    TextAlign? textAlign,
    TextOverflow? textOverflow,
    Map<String, String>? namedArgs,
  }) : super(
          text.tr(namedArgs: namedArgs),
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
          maxLines: maxLines,
          key: key,
          textAlign: textAlign,
          overflow: textOverflow,
        );

  CustomText.bold(
    String text, {
    Key? key,
    double? fontSize = FontSizes.medium,
    Color? color = CustomColors.color262626,
    FontWeight? fontWeight = FontWeight.w700,
    int? maxLines,
    TextOverflow? textOverflow,
    TextAlign? textAlign,
  }) : super(
          text.tr(),
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
          maxLines: maxLines,
          textAlign: textAlign,
          key: key,
          overflow: textOverflow,
        );

  CustomText.custom(
    String text, {
    Key? key,
    TextStyle? style,
    int? maxLines,
    TextOverflow? textOverflow,
    TextAlign? textAlign,
  }) : super(
          text.tr(),
          style: style,
          maxLines: maxLines,
          textAlign: textAlign,
          key: key,
          overflow: textOverflow,
        );
}

// Simple translation extension helper to maintain compatibility
extension TrExtension on String {
  String tr({Map<String, String>? namedArgs}) {
    String value = this;
    if (namedArgs != null) {
      namedArgs.forEach((key, val) {
        value = value.replaceAll('{$key}', val);
      });
    }
    return value;
  }
}
