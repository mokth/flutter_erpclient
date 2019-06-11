import 'package:erpclient/utilities/textstyle-util.dart';
import 'package:flutter/material.dart';

class ButtonUtil {
  static RaisedButton getRaiseButton(action, caption, btnColor) {
    return RaisedButton(
      color: btnColor, //Color(0xff5DADE2),
      onPressed: action,
      child: Text(
        caption,
        style: TextStyleUtil.getButtonTextStyle(),
      ),
    );
  }
}
