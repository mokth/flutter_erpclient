class Utility {
  
  static String dateToString(DateTime date){
    if(date==null) return "";
    String month = date.month.toString().padLeft(2, '0');
    String year = date.year.toString().padLeft(4, '0');
    String day = date.day.toString().padLeft(2, '0');
    return  day + "-" + month + "-" + year;
  }

  static DateTime stringToDate(String sdate){
    //dd-mm-yyy
    List<String> data= sdate.split('-');
    if (data.length!=3)
      return null;
     int dd = int.parse(data[0]);
     int mm = int.parse(data[1]);
     int yy = int.parse(data[2]);
     
    return new DateTime(yy,mm,dd);
  }

}