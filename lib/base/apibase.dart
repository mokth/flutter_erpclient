import 'package:corsac_jwt/corsac_jwt.dart';
import 'package:erpclient/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'datahelper.dart';

abstract class ApiBase {
  //http://localhost:59036/api/customer/odata/search
 //final String _baseUrl = Uri.encodeFull("http://localhost:59036/api/");
 final String _baseUrl = Uri.encodeFull("http://42.1.62.223/mytechAPI/api/");
 final String _erpUrl = Uri.encodeFull("https://www.wincom2cloud.com/erpv4/");
 final DataHelperSingleton _datahlp = DataHelperSingleton.getInstance();
 String _erpAPIUrl; 
  
  String get apiURL {
     
    return _datahlp.getERPApiURL();// _baseUrl;
    //return "http://10.1.8.15/erpapi/api/";
  }

  String get erpURL {
    return _erpUrl;
  }

  Map jsonHeader() {
    var map = new Map<String, String>();
    map["'content-type'"] = "'application/json'";
    return map;
  }

  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    return;
  }

  Future<void> persistToken(String token) async {
    /// write to keystore/keychain
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('token', token);
    return;
  }

  Future<bool> hasToken() async {
    print("ada token");
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    return token != null;
  }

  Future<String> getToken() async {
    //print("ada token");
    final prefs = await SharedPreferences.getInstance();
    String token = "";
    try {
      String authtoken = prefs.getString('token');
      //Map<String,dynamic> jsonObj = jsonDecode(token);

      token = "Bearer " + authtoken; //jsonObj["auth_token"];
    } catch (Exception) {}

    return token;
  }

  int decodeToken(String token) {
    int code = 0;
    try {
      var validator = new JWTValidator();

      var decodedToken = new JWT.parse(token);

      print("decode");
      Set<String> error = validator.validate(decodedToken);
      print(error);
      code = error.length;
    } catch (e) {
      print(e.toString());
      code = 99;
    }

    return code;
  }

  User getAuthTokenInfo(String token) {
    User user;
    token= token.replaceFirst("Bearer ", "");
    try {
      var dtoken = new JWT.parse(token);
      String rol = dtoken.getClaim('rol');
      String role = dtoken.getClaim('role');
      String id = dtoken.getClaim('id');
      String name = dtoken.getClaim('sub');
      String fname = dtoken.getClaim('fullname');
      String comp = dtoken.getClaim('comp');
      String branch = dtoken.getClaim('branch');
      String loc = dtoken.getClaim('loc');
      user = User(
          id: id,
          name: name,
          fullname: fname,
          rol: rol,
          role: role,
          compCode: comp,
          branchCode: branch,
          locCode: loc);
    } catch (e) {
      print(e);
      user = null;
    }
    return user;
  }

  Future<String> getTokenOnly() async {
    String token = "";
    try {
      final prefs = await SharedPreferences.getInstance();
      String authToken = prefs.getString('token');
      token = (authToken == null) ? "" : authToken;
      // token = jsonObj["auth_token"];
    } catch (e) {
      token = "";
      print(e.toString());
    }

    return token;
  }
}
