class PrSchMasFG {
  final int uid;
  final DateTime trxDate;
  final String scheCode;
  final int relNo;
  final String status;
  final String icode;
  final String idesc;
  final double fgQty;
  final double reject;
  final double scrap;
  final String stdUOM;
  final String fgLotNo;
  final String frWH;
  final String toWH;
  final String userid;
  final String prdOperator;

  PrSchMasFG(
      {this.uid,
      this.trxDate,
      this.scheCode,
      this.relNo,
      this.status,
      this.icode,
      this.idesc,
      this.fgQty,
      this.reject,
      this.scrap,
      this.stdUOM,
      this.fgLotNo,
      this.frWH,
      this.toWH,
      this.userid,
      this.prdOperator});

  Map<String, dynamic> toJson(PrSchMasFG instance, String userid) =>
      <String, dynamic>{
        'uid': instance.uid,
        'trxDate': instance.trxDate.toIso8601String(),
        'scheCode': instance.scheCode,
        'relNo': instance.relNo,
        'status': instance.status,
        'icode': instance.icode,
        'idesc': instance.idesc,
        'fgQty': instance.fgQty,
        'reject': instance.reject,
        'scrap': instance.scrap,
        'stdUOM': instance.stdUOM,
        'fgLotNo': instance.fgLotNo,
        'frWH': instance.frWH,
        'toWH': instance.toWH,
        'userid': userid,
        'prdOperator': instance.prdOperator
      };

  factory PrSchMasFG.fromJson(Map<String, dynamic> json) {
    return PrSchMasFG(
      uid: json["uid"],
      trxDate: DateTime.parse(json["trxDate"]),
      scheCode: json["scheCode"] as String,
      relNo: json["relNo"],
      status: json["status"] as String,
      icode: json["iCode"] as String,
      idesc: json["iDesc"] as String,
      fgQty: json["fgQty"],
      reject: json["reject"],
      scrap: json["scrap"],
      stdUOM: (json["stdUOM"]==null)?"":json["stdUOM"] as String,
      fgLotNo: (json["fgLotNo"]==null)?"":json["fgLotNo"] as String,
      frWH: ( json["frWH"]==null)?"":json["frWH"] as String,
      toWH: (json["toWH"]==null)?"":json["toWH"]as String,
      userid: (json["userID"]==null)?"":json["userID"] as String,
      prdOperator:(json['operator'] == null) ?"":json["operator"] as String
      
    );
  }
}
