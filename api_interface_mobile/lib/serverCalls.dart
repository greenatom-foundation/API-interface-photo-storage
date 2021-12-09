import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

//bool _conection = false;
final String _Adress = "185.43.6.193";//'185.43.6.193'; //
final String _getAddress = "http://185.43.6.193:5000/post";//'http://185.43.6.193:5000/get';
final String _postAddress = "http://185.43.6.193:5000/";//'http://185.43.6.193:5000/';

Future<http.Response> _getData(String id){
  try{
    return http.post(
        Uri.parse(_getAddress),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Connection':'keep-alive',
          'Keep-Alive-alive': 'max = 1000'
        },
        body: jsonEncode(<String, dynamic>{
          'id': id
        })
    );}
  catch(e){
    exceptionHandler(e);
    return null;
  }
}

Future<http.Response> _getAllData(){
  try{
    return http.post(
        Uri.parse(_getAddress+'all'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
    );}
  catch(e){
    exceptionHandler(e);
    return null;
  }
}

Future<bool> _sendData(File data) async{ //http.Response
  var request = new http.MultipartRequest("POST", Uri.parse(_postAddress));
  request.files.add(http.MultipartFile('file', data.readAsBytes().asStream(), data.lengthSync(), filename: data.path.split('/').last));
  var res = await request.send();
  //debugPrint('response: ' + res.statusCode.toString());
  if (res.statusCode == 204) {
    //print("Uploaded!");
    return true;
  }
  else{
    debugPrint("Bad answer");
    return false;
  }
  /*
  try{
    return http.post(
        Uri.parse(_postAddress),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode(<String, dynamic>{
          'id': id
        })
    );}
  catch(e){
    exceptionHandler(e);
    return null;
  }
   */
}


dataProvider({String id})async{
  try{
    final result = await InternetAddress.lookup(_Adress);
    if (result.isEmpty || result[0].rawAddress.isEmpty) {
      debugPrint("Lookup error");
      return {'exception':'lookup error'};
    }
    if (id!=null){
      var res = await _getData(id);
      //debugPrint(res.body.toString());
      return json.decode(res.body);
    }
    else{
      var res = await _getAllData();
      //debugPrint(res.body.toString());
      return json.decode(res.body);
    }
  }
  catch (e) {
    debugPrint("Exception: " + e.toString());
    return {'exception':e.toString()};
  }
/*
  try{
    final result = await InternetAddress.lookup(_Adress);
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      _conection = true;
    }
    else{
      _conection = false;
    }
    debugPrint('connected: '+_conection.toString());
    if(_conection){
      debugPrint('connected');
      var res = await _getData(id);
      debugPrint(res.body);
      return res.body;
    }
  }
  on SocketException catch(e){
    debugPrint('e');
    _conection = false;
  }
  return null;
 */
}

Future<bool> sendProvider(File data)async{
  try{
    final result = await InternetAddress.lookup(_Adress);
    if (result.isEmpty || result[0].rawAddress.isEmpty) {
      debugPrint("Lookup error");
      return false;
    }
    bool res = await _sendData(data);
    return res;
  }
  catch (e) {
    debugPrint("Exception: " + e.toString());
    return false;
  }
/*
  try{
    final result = await InternetAddress.lookup(_Adress);
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      _conection = true;
    }
    else{
      _conection = false;
    }
    debugPrint('connected: '+_conection.toString());
    if(_conection){
      debugPrint('connected');
      var res = await _getData(id);
      debugPrint(res.body);
      return res.body;
    }
  }
  on SocketException catch(e){
    debugPrint('e');
    _conection = false;
  }
  return null;
 */
}


exceptionHandler(dynamic e)async{
  debugPrint(e.toString());
}