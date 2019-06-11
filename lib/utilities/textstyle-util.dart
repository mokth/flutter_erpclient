import 'package:flutter/material.dart';

class TextStyleUtil {
  static TextStyle getButtonTextStyle() {
    return TextStyle(
        color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.w700);
  }

  static InputDecoration getFormFieldInputDecoration(caption) {
    return InputDecoration(
        labelText: caption,
        filled: true, 
        fillColor: Colors.white);
  }
}
