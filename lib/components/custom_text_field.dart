import 'package:flutter/material.dart';
import 'package:roadanomalies_root/styles.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final Icon prefixIcon;
  final TextEditingController textController;
  final String? Function(String?)? validator;
  final bool obscureText;

  const CustomTextField(
      {Key? key,
      required this.hintText,
      required this.prefixIcon,
      required this.textController,
      this.validator, this.obscureText=false})
      : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _isVisible;

  @override
  void initState() {
    _isVisible = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: txtStl16w300,
      obscureText: widget.obscureText ? _isVisible : false,
      controller: widget.textController,
      validator: widget.validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
          suffixIcon: widget.obscureText ?  IconButton(
            icon: Icon(
              // Based on passwordVisible state choose the icon
              _isVisible
                  ? Icons.visibility
                  : Icons.visibility_off,
              color: Colors.white,
            ),
            onPressed: () {
              // Update the state i.e. toogle the state of passwordVisible variable
              setState(() {
                _isVisible = !_isVisible;
              });
            },
          ) : null ,
          prefixIcon: widget.prefixIcon,
          fillColor: Colors.white,
          focusColor: Colors.white,
          hintText: widget.hintText,
          hintStyle:
              txtStl14w400.copyWith(color: Colors.white.withOpacity(0.5)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(5)),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(5)),
          disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(5)),
          border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(5))),
    );
  }
}
