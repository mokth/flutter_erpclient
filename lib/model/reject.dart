class Reject {
  final int id;
  final String reason;

  Reject({this.id, this.reason});

  Map<String, dynamic> toJson(Reject instance) =>
      <String, dynamic>{
      'id': instance.id, 
      'reason': instance.reason
  };
    
}
