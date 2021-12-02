import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

bool _conection = false;
final String _Adress = 'http://185.43.6.193:5000/';
final String _getAddress = 'http://185.43.6.193:5000/get';
final String _postAddress = 'http://185.43.6.193:5000/';

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

Future<http.Response> _sendData(File data) async{
  var request = new http.MultipartRequest("POST", Uri.parse(_postAddress));
  await request.files.add(await http.MultipartFile('file', data.readAsBytes().asStream(), data.lengthSync(), filename: data.path.split('/').last));

  debugPrint('data: ' + data.toString());
  await request.send().then((response) {
    if (response.statusCode == 200) print("Uploaded!");
  });
  debugPrint('request: ' + request.toString());
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


dataProvider(String id)async{
  var res = await _getData(id);
  debugPrint(res.body.toString());
  return json.decode(res.body);
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

sendProvider(File data)async{
  _sendData(data);
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