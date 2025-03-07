// 🎯 Dart imports:
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

// 🌎 Project imports:
import 'package:fxtm/types/type_def.dart';

class CustomFormTextField extends StatefulWidget {
  const CustomFormTextField({
    required this.id,
    this.fieldKey,
    this.controller,
    this.inputFormatters,
    this.focusNode,
    this.placeHolderText,
    this.initialValue,
    this.label,
    this.onChanged,
    this.onReset,
    this.border,
    this.borderRadius,
    this.minHeight = 50.0,
    this.padding,
    this.horizontalPaddingValue = 5.0,
    this.verticalPaddingValue = 0,
    this.contentPadding = const EdgeInsets.symmetric(
      vertical: 15.0,
      horizontal: 12.0,
    ),
    this.hintFontSize = 17.0,
    this.hintTextColor = const Color.fromARGB(255, 174, 167, 147),
    this.valueFontSize = 17.0,
    this.valueFontWeight = FontWeight.normal,
    this.validators = const <Validator<String>>[],
    this.isRequired = false,
    this.textAlign = TextAlign.left,
    super.key,
  });

  final String id;
  final Key? fieldKey;
  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final String? placeHolderText;
  final String? initialValue;
  final String? label;
  final Function(String? value)? onChanged;
  final Function()? onReset;
  final BorderSide? border;
  final BorderRadius? borderRadius;
  final double minHeight;
  final EdgeInsets? padding;
  final double horizontalPaddingValue;
  final double verticalPaddingValue;
  final EdgeInsets contentPadding;
  final double hintFontSize;
  final Color hintTextColor;
  final double valueFontSize;
  final FontWeight? valueFontWeight;
  final bool isRequired;
  final List<Validator<String>> validators;
  final TextAlign textAlign;

  @override
  State<CustomFormTextField> createState() => _CustomFormTextFieldState();
}

class _CustomFormTextFieldState extends State<CustomFormTextField> {
  @override
  Widget build(BuildContext context) {
    final allValidators = List<Validator<String>>.from(widget.validators);

    if (widget.isRequired) {
      allValidators.add(FormBuilderValidators.required());
    }
    return Padding(
      padding:
          widget.padding ??
          EdgeInsets.symmetric(
            horizontal: widget.horizontalPaddingValue,
            vertical: widget.verticalPaddingValue,
          ),
      child: FormBuilderTextField(
        key: widget.fieldKey,
        controller: widget.controller,
        inputFormatters: widget.inputFormatters,
        focusNode: widget.focusNode,
        name: widget.id,
        onReset: widget.onReset,
        initialValue: widget.initialValue,
        enableInteractiveSelection: false,
        decoration: InputDecoration(
          label: widget.label != null ? Text(widget.label!) : null,
          labelStyle: const TextStyle(color: Colors.grey),
          hintText: widget.placeHolderText,
          hintStyle: TextStyle(
            color: widget.hintTextColor,
            fontSize: widget.hintFontSize,
          ),
          enabledBorder: _buildBorder(),
          focusedBorder: _buildBorder(),
          disabledBorder: _buildBorder(),
          contentPadding: widget.contentPadding,
          constraints: BoxConstraints(
            minHeight: widget.minHeight,
            maxHeight: 80.0,
          ),
        ),
        textAlign: widget.textAlign,
        textInputAction: TextInputAction.done,
        onChanged: widget.onChanged,
        cursorHeight: Platform.isIOS ? 17.0 : null,
        style: TextStyle(
          color: const Color.fromARGB(255, 251, 241, 212),
          fontSize: widget.valueFontSize,
          letterSpacing: 1.15,
        ),
        validator: FormBuilderValidators.compose(allValidators),
      ),
    );
  }

  InputBorder _buildBorder() {
    return OutlineInputBorder(
      borderSide: widget.border ?? BorderSide(color: Colors.grey.shade600),
      borderRadius:
          widget.borderRadius ?? const BorderRadius.all(Radius.circular(3.0)),
    );
  }
}
