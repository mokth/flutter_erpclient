class PrdOperator{
  final String code;
  final String name;
  
  PrdOperator({this.code,this.name});

   factory PrdOperator.fromJson(Map<String, dynamic> json) {
    return PrdOperator(
      code: json['Code'] as String,
      name: json['Name'] as String);
  } 

}