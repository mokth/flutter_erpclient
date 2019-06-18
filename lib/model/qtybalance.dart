class QtyBalance {
  final String warehouse;
  final String lotno;
  final String status;
  final String uom;
  final double qty;
  final DateTime trxdate;

  QtyBalance(
      {this.warehouse,
      this.lotno,
      this.status,
      this.uom,
      this.qty,
      this.trxdate});
  
  factory QtyBalance.fromJson(Map<String, dynamic> json) {
    return QtyBalance(
      warehouse:json['warehouse'],
      trxdate: DateTime.parse(json['trxdate']),
      lotno: json['lotno'] as String,
      uom: (json['uom']==null)?"": json['uom']as String,
      qty: json['qty'],     
      status: json["status"] as String,
    );
  }
}
