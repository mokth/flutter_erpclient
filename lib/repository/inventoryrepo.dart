import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:erpclient/model/user.dart';
import 'package:erpclient/base/apibase.dart';
import 'package:erpclient/model/warehouse.dart';
import 'package:erpclient/model/relocate.dart';

class InventoryRepository extends ApiBase {
  //get warehouse list
  Future<List<Warehouse>> getWarehouse() async {
    List<Warehouse> _warehouses = new List<Warehouse>();
    String token = await getToken();
    var response;
    String url =
        apiURL + "inventory/warehouse?\$select=WarehouseCode,WarehouseDesc";

    try {
      response = await http.get(url, headers: {
        'content-type': 'application/json',
        'Authorization': token
      });
    } catch (e) {
      print(e.toString());
      throw new Exception(
          "Error connecting to Server. Please check you mobile nextwork.");
    }
    dynamic resp = jsonDecode(response.body);

    dynamic data = resp;
    data.forEach((item) {
      // print(item);
      _warehouses.add(Warehouse.fromJson(item));
    });
    //print(data.length);

    return _warehouses;
  }

  //get relocate list, using odata method
  Future<List<Relocate>> getRelocates({bool showAll:false}) async {
    List<Relocate> _relocates = new List<Relocate>();
    String token = await getToken();
    User user = getAuthTokenInfo(token);
    String url="";
    if (showAll){
      url = apiURL +
            "inventory/relocates?\$filter=status eq 'NEW'";
    }else{
      url = apiURL +
            "inventory/relocates?\$filter=userid eq '" +
             user.id +
            "' and status eq 'NEW'";
    }
    

    var response;
    try {
      response = await http.get(url, headers: {
        'content-type': 'application/json',
        'Authorization': token
      });
      print(response.statusCode);
      if (response.statusCode != 200) {
        throw new Exception("Internal error happening at Server.");
      }
    } catch (e) {
      print(e.toString());
      throw new Exception(
          "Error connecting to Server. Please check you mobile nextwork.");
    }
    //print(response.body);
    dynamic resp = jsonDecode(response.body);

    dynamic data = resp;
    data.forEach((item) {
       //print(item);
      _relocates.add(Relocate.fromJson(item));
    });
    //print(data.length);

    return _relocates;
  }

  //delete relocate by id
  Future<String> deleteRelocate(int id) async {
    String token = await getToken();

    String url = apiURL + "inventory/" + id.toString();
    print(url);

    var response = await http.delete(url,
        headers: {'content-type': 'application/json', 'Authorization': token});
    print(response.statusCode);
    //print(response.body);
    dynamic resp = jsonDecode(response.body);
    print(resp);
    String msg;
    if (resp["ok"] == "yes") {
      msg = "Relocate Submitted";
    } else {
      msg = "Error submitting relocate....";
    }

    return msg;
  }

  //post relocate, save
  Future<String> postRelocate(Relocate relocate) async {
    String token = await getToken();
    User user = getAuthTokenInfo(token);
    String url = apiURL + "inventory/relocate";
    print(url);
  
    var response = await http.post(url,
        headers: {'content-type': 'application/json', 'Authorization': token},
        body: jsonEncode(relocate.toJson(relocate, user.id)));

    print(response.statusCode);
    //print(response.body);
    dynamic resp = jsonDecode(response.body);
    // print(resp);
    String msg;
    if (resp['value']["ok"] == "yes") {
      msg = "Relocate Submitted";
    } else {
      msg = "Error submitting relocate....";
    }

    return msg;
  }

  //post relocate, save
  Future<String> putRelocate(Relocate relocate) async {
    String token = await getToken();
    User user = getAuthTokenInfo(token);
    String url = apiURL + "inventory/update";
    print(url);
    var response = await http.put(url,
        headers: {'content-type': 'application/json', 'Authorization': token},
        body: jsonEncode(relocate.toJson(relocate, user.id)));

    print(response.statusCode);
    //print(response.body);
    dynamic resp = jsonDecode(response.body);
    // print(resp);
    String msg;
    if (resp['value']["ok"] == "yes") {
      msg = "Relocate Submitted";
    } else {
      msg = "Error submitting relocate....";
    }

    return msg;
  }

  //receice 
  Future<String> postReceive(String id) async {
    String token = await getToken();
    String url = apiURL + "inventory/receive/"+id;
    print(url);
  
    var response = await http.post(url,
        headers: {'content-type': 'application/json', 'Authorization': token});

    print(response.statusCode);
    //print(response.body);
    //print(response.body);
    if (response.body.isEmpty){
      return "Error receiving item...";
    }

    dynamic resp = jsonDecode(response.body);
    print(resp);
    
    print(resp["value"]);
    String msg =resp["value"]["msg"];
    // String msg;
    // if (resp['value']["ok"] == "yes") {
    //   msg = "Relocate Submitted";
    // } else {
    //   msg = "Error submitting relocate....";
    // }

    return msg;
  }

}
