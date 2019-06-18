class Relocate {
  final int id;
  final String icode;
  final String idesc;
  final int packsize;
  final double qty;
  final double stdqty;
  final String fromwh;
  final String towh;
  final String userid;
  final String status;
  final DateTime trxdate;
  final String qrcoderef;

  Relocate(
      {this.id,
      this.icode,
      this.idesc,
      this.packsize,
      this.qty,
      this.stdqty,
      this.fromwh,
      this.towh,
      this.userid,
      this.status,
      this.trxdate,
      this.qrcoderef});

  Map<String, dynamic> toJson(Relocate instance, String userid) =>
      <String, dynamic>{
        'id': instance.id,
        'icode': instance.icode,
        'idesc': instance.idesc,
        'packsize': instance.packsize,
        'qty': instance.qty,
        'stdqty': instance.stdqty,
        'fromwh': instance.fromwh,
        'towh': instance.towh,
        'userid': userid,
        'status': instance.status,
        'qrcoderef': instance.qrcoderef,
        'trxdate': instance.trxdate.toIso8601String()
      };

  factory Relocate.fromJson(Map<String, dynamic> json) {
    return Relocate(
      id: json['id'],
      trxdate: DateTime.parse(json['trxdate']),
      icode: json['icode'] as String,
      idesc: (json['idesc'] == null) ? "" : json['idesc'] as String,
      packsize: json['packsize'],
      qty: json['qty'],
      stdqty: json['stdqty'],
      fromwh: json["fromwh"] as String,
      towh: json["towh"] as String,
      qrcoderef: (json['qrcoderef'] == null) ? "" : json['qrcoderef'] as String,
      status: json["status"] as String,
    );
  }
}
