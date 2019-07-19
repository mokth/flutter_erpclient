import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';

class Utility {
  
  static String dateToString(DateTime date){
    if(date==null) return "";
    // String month = date.month.toString().padLeft(2, '0');
    // String year = date.year.toString().padLeft(4, '0');
    // String day = date.day.toString().padLeft(2, '0');
    // return  day + "-" + month + "-" + year;
    return new DateFormat("dd-MM-yyyy").format(date);
  }

  static String dateToStringFormat(DateTime date,String format ){
    if(date==null) return "";
    return new DateFormat(format).format(date);
  }

  static String dateToTimeString(DateTime date){
    if(date==null) return "";
    
    return new DateFormat("hh:mma").format(date);
  }

   static String dateToStringWithTime(DateTime date){
    if(date==null) return "";
    return new DateFormat("dd-MM-yyyy hh:mma").format(date);
    //return formatDate(date, [dd, '-', mm, '-', dd,' ',hh,':',nn,' ',am]);
        // String month = date.month.toString().padLeft(2, '0');
        // String year = date.year.toString().padLeft(4, '0');
        // String day = date.day.toString().padLeft(2, '0');
        // String hh = date.hour.toString().padLeft(2, '0');
        // String mm = date.minute.toString().padLeft(2, '0');    
      //  return  day + "-" + month + "-" + year+" "+hh+":"+mm;
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
    
   