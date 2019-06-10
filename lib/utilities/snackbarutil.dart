
import 'package:flutter/material.dart';

class SnackBarUtil {
  
  static showSnackBar(String msg,scaffoldKey) {
    scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
      ),
    );
  }
}