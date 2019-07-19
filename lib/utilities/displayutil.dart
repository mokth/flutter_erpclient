import 'package:flutter/material.dart';

class DisplayUtil {

  static TextStyle inputTextStyle() {
    return TextStyle(
      fontSize: 14.0,
      color: Colors.blue,
    );
  }

  static Text listHeaderText(String title,
      {TextAlign textAlign: TextAlign.start,
      fontWeight: FontWeight.normal,
      fontSize: 15.0}) {
    return Text(
      title,
      textAlign: textAlign,
      style: TextStyle(
          fontSize: fontSize, fontWeight: fontWeight, color: Colors.white),
    );
  }

  static Text listItemText(String title,
      {TextAlign textAlign: TextAlign.start,
      color: Colors.black,
      fontWeight: FontWeight.normal,
      fontSize: 15.0}) {
    return Text(
      title,
      maxLines: 1,
      textAlign: textAlign,
      style: TextStyle(fontSize: fontSize, fontWeight: fontWeight, color: color),
    );
  }

  static InputDecoration inputDecorationEx(String hintText) {
    return InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(fontSize: 15.0, color: Colors.lightBlue),
        filled: true,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: 1.0, color: Colors.teal),
        ),
        disabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: 1.0, color: Colors.teal),
        ),
        contentPadding: EdgeInsets.fromLTRB(5, 3, 5, 2),
        fillColor: Colors.white);
  }

  static Widget formEditInput(String label, TextEditingController controler,
      {bool enable: true,
      keyboardType: TextInputType.text,
      needValidation: true,
      textAlign: TextAlign.start}) {
    return Stack(
      children: <Widget>[
        Container(
          margin: EdgeInsets.all(0),
          padding: EdgeInsets.all(0),
          child: Text(
            label,
            textAlign: textAlign,
            style: TextStyle(
              color: Colors.blueGrey[900],
              fontSize: 14.0,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.all(0),
          padding: EdgeInsets.fromLTRB(0, 15, 0, 3),
          child: TextFormField(
            textAlign: textAlign,
            keyboardType: keyboardType,
            enabled: enable,
            style: DisplayUtil.inputTextStyle(),
            decoration: DisplayUtil.inputDecorationEx(''),
            controller: controler,
            validator: (value) {
              if (needValidation) {
                if (value.isEmpty) {
                  return "*";
                }
              }
            },
          ),
        ),
      ],
    );
  }
}
