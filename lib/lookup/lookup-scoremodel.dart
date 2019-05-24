import 'package:flutter/cupertino.dart';
import 'package:scoped_model/scoped_model.dart';

class ScopedLookup<T> extends Model {
  T result;  
  final TextEditingController ctrl;  
  ScopedLookup(this.ctrl);

  setResult(T lookupResult,String displayText) {
    result = lookupResult;
    ctrl.text =displayText;
    notifyListeners();
  }
}