import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/custom_colors.dart';
import 'custom_text.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    this.labelText,
    required this.hintText,
    this.onChanged,
    this.isPassword = false,
    this.errorText,
    this.headerMaxLines,
    this.maxLines = 1,
    this.minLines,
    this.keyboardType = TextInputType.text,
    this.controller,
    this.currentNode,
    this.nextNode,
    this.tfMaxLength,
    this.onSubmit,
    this.autoFocus = false,
    this.action = TextInputAction.done,
    this.inputFormatters,
    this.hasBorder = true,
    this.bgColor = CustomColors.white,
    this.hintTextColor = CustomColors.gray,
    this.prefixIcon,
    this.showCounterText = false,
    this.height,
    this.onClear,
    this.borderRadius = 4,
    this.enable,
    this.textColor = CustomColors.black,
    this.contentPadding,
    this.suffixIcon,
    this.suffixIconConstraints,
    this.focusBorderColor,
  });

  final bool showCounterText;
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final Function()? onSubmit;
  final Function(String)? onChanged;
  final bool isPassword;
  final TextInputType? keyboardType;
  final int? headerMaxLines;
  final int? maxLines;
  final int? minLines;
  final TextEditingController? controller;
  final FocusNode? currentNode;
  final FocusNode? nextNode;
  final int? tfMaxLength;
  final bool autoFocus;
  final TextInputAction? action;
  final List<TextInputFormatter>? inputFormatters;
  final bool hasBorder;
  final Color bgColor;
  final Color hintTextColor;
  final Widget? prefixIcon;
  final double? height;
  final VoidCallback? onClear;
  final double borderRadius;
  final bool? enable;
  final Color textColor;
  final EdgeInsetsGeometry? contentPadding;
  final Widget? suffixIcon;
  final BoxConstraints? suffixIconConstraints;
  final Color? focusBorderColor;

  @override
  CustomTextFieldState createState() => CustomTextFieldState();
}

class CustomTextFieldState extends State<CustomTextField> {
  bool isHidePassword = true;
  String? errorMessage;
  late FocusNode currentNode;
  bool isShowClearAll = false;

  @override
  void initState() {
    currentNode = widget.currentNode ?? FocusNode();
    super.initState();
    currentNode.addListener(_handleFocusChange);

    if (widget.controller != null) {
      widget.controller!.addListener(_handleTextChange);
    }
  }

  @override
  void dispose() {
    if (widget.currentNode == null) {
      currentNode.dispose();
    } else {
      currentNode.removeListener(_handleFocusChange);
    }
    if (widget.controller != null) {
      widget.controller!.removeListener(_handleTextChange);
    }
    super.dispose();
  }

  void _handleFocusChange() {
    if (!mounted) return;
    setState(() {
      if (currentNode.hasFocus) {
        errorMessage = null;
        if (widget.controller?.text.isNotEmpty == true) {
          isShowClearAll = true;
        }
      } else {
        isShowClearAll = false;
      }
    });
  }

  void _handleTextChange() {
    if (!mounted) return;
    final hasFocus = currentNode.hasFocus;
    final hasText = widget.controller?.text.isNotEmpty == true;

    if (hasFocus && hasText) {
      if (!isShowClearAll) {
        setState(() => isShowClearAll = true);
      }
    } else {
      if (isShowClearAll) {
        setState(() => isShowClearAll = false);
      }
    }
  }

  Color _getColorForTextFieldBorder() {
    if (errorMessage != null) {
      return CustomColors.red;
    }
    if (currentNode.hasFocus == true) {
      return widget.focusBorderColor ?? CustomColors.colorEAECF0;
    }
    return CustomColors.colorEAECF0;
  }

  Color _getColorForTextFieldBG() {
    if (errorMessage != null) {
      return CustomColors.lightGray;
    }
    return widget.bgColor;
  }

  Widget? renderSuffixIcon() {
    if (widget.isPassword) {
      return GestureDetector(
        onTap: () {
          setState(() {
            isHidePassword = !isHidePassword;
          });
        },
        child: Icon(
          isHidePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: CustomColors.color6B7280,
          size: 20,
        ),
      );
    }

    if (widget.suffixIcon != null) {
      return widget.suffixIcon;
    }

    if (isShowClearAll) {
      return GestureDetector(
        onTap: () {
          widget.controller!.clear();
          widget.onClear?.call();
        },
        child: const Icon(
          Icons.cancel,
          size: 18,
          color: CustomColors.color9CA3AF,
        ),
      );
    }
    return widget.suffixIcon;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      height: widget.height,
      decoration: BoxDecoration(
        color: _getColorForTextFieldBG(),
        border: widget.hasBorder
            ? Border.all(color: _getColorForTextFieldBorder())
            : null,
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: TextField(
        enabled: widget.enable,
        autofocus: widget.autoFocus,
        controller: widget.controller,
        onChanged: widget.onChanged,
        focusNode: currentNode,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        textInputAction: widget.nextNode != null ? TextInputAction.next : widget.action,
        enableInteractiveSelection: true,
        obscureText: widget.isPassword == true ? isHidePassword : false,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        style: TextStyle(
          color: widget.textColor,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          counterText: widget.showCounterText ? null : '',
          floatingLabelBehavior: FloatingLabelBehavior.always,
          contentPadding: widget.contentPadding ?? const EdgeInsets.symmetric(vertical: 12),
          border: InputBorder.none,
          fillColor: Colors.transparent,
          hintStyle: TextStyle(
            color: widget.hintTextColor,
            fontWeight: FontWeight.normal,
            fontSize: 14,
          ),
          suffixStyle: const TextStyle(fontWeight: FontWeight.normal),
          labelStyle: const TextStyle(fontWeight: FontWeight.normal),
          isDense: true,
          filled: true,
          hintText: widget.hintText?.tr(),
          suffixIconConstraints: widget.suffixIconConstraints ??
              const BoxConstraints(
                maxWidth: 24,
                maxHeight: 24,
              ),
          suffixIcon: renderSuffixIcon(),
          prefixIconConstraints: widget.prefixIcon != null
              ? const BoxConstraints(
                  minHeight: 24,
                  minWidth: 24,
                )
              : const BoxConstraints(
                  maxWidth: 24,
                  maxHeight: 24,
                ),
          prefixIcon: widget.prefixIcon != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: widget.prefixIcon,
                )
              : const SizedBox(width: 8),
        ),
        onEditingComplete: () {
          if (widget.nextNode != null) {
            widget.nextNode!.requestFocus();
          } else {
            currentNode.unfocus();
          }
          if (widget.onSubmit != null) {
            widget.onSubmit!.call();
          }
        },
        maxLength: widget.tfMaxLength,
      ),
    );
  }
}
