import 'package:flutter/material.dart';

import '../model/prd-operator.dart';

import 'lookup-scoremodel.dart';
import 'operator-list.dart';

class OperatorLookupDialog {

 static showPrdOperator(BuildContext context,ScopedLookup<PrdOperator> scopeOperator,List<PrdOperator> prdoperator) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => _prdoperatorLookup(scopeOperator,prdoperator));
  }

  static Widget _prdoperatorLookup(ScopedLookup<PrdOperator> scopeOperator,List<PrdOperator> prdoperator) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: new OperatorList(prdoperator, scopeOperator),
    );
  }
}