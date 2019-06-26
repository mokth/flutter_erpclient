class Setting{
  int id;
  String url;
  String defwh;

  Setting();
  Setting.make(this.id,this.url,this.defwh);
  String toString()=>'$id $url';
}