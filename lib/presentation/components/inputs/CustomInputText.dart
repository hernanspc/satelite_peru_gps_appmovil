import 'package:flutter/material.dart';

class CustomInputText extends StatelessWidget {
  final String labelText;
  // final String hintText;
  final TextEditingController? controller;
  final int? maxLines;
  final bool isMultiline;
  final bool readOnly;
  final Function()? onTap;
  final bool autofocus;
  final IconData? suffixIcon;

  const CustomInputText({
    Key? key,
    required this.labelText,
    // required this.hintText,
    this.controller,
    this.maxLines,
    this.isMultiline = false,
    this.readOnly = false,
    this.onTap,
    this.autofocus = true,
    this.suffixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(13.0),
          bottomLeft: Radius.circular(13.0),
          topLeft: Radius.circular(13.0),
          topRight: Radius.circular(13.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 20, top: 0),
        child: TextField(
          controller: controller,
          style: const TextStyle(
            fontFamily: 'WorkSans',
            fontSize: 16,
            color: Colors.black,
          ),
          autofocus: autofocus,
          keyboardType:
              isMultiline ? TextInputType.multiline : TextInputType.text,
          maxLines: maxLines,
          decoration: InputDecoration(
            // hintText: hintText,
            labelText: labelText,
            suffixIcon: suffixIcon == null ? null : Icon(suffixIcon),
            border: InputBorder.none,
            helperStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.grey[400],
            ),
            labelStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              letterSpacing: 0.2,
              color: Colors.grey[400],
            ),
          ),
          readOnly: readOnly,
          onTap: onTap,
        ),
      ),
    );
  }
}
