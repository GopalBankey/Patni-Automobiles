import 'package:flutter/material.dart';
import 'package:numberplatefinder/utils/app_colors.dart';

class CustomTextFormField extends StatefulWidget {
  final String label;
  final String hint;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool readOnly;
  final int? maxLength;
  final Widget? prefix;

  const CustomTextFormField({
    super.key,
    required this.label,
    required this.hint,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    required this.controller,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.readOnly = false,
    this.maxLength,
    this.prefix
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late bool _obscureText;

  @override
  void initState() {
    _obscureText = widget.isPassword;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(

      maxLength: widget.maxLength,
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: _obscureText,
      readOnly: widget.readOnly,
      validator: widget.validator,
      style: TextStyle(fontSize: 16),
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,

        // isDense: true,
        // labelText: widget.label,
        hintText: widget.hint,
        prefix: widget.prefix  ,
        prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
        suffixIcon: widget.isPassword
            ? IconButton(
          icon: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        )
            : (widget.suffixIcon != null ? Icon(widget.suffixIcon) : null),
        // border: InputBorder.none,
        border:  OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none

           ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none

        ),
        errorBorder:  OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none

        ),
        counterText: ""
      ),
    );
  }
}
