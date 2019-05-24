class Warehouse{
  final String code;
  final String desc;
  
  Warehouse({this.code,this.desc});

   factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
      code: json['WarehouseCode'] as String,
      desc: json['WarehouseDesc'] as String);
  } 

}