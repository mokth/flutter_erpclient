class Setting{
  int id;
  String url;

  Setting();
  Setting.make(this.id,this.url);
  String toString()=>'$id $url';
}