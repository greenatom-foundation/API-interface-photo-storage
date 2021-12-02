import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'serverCalls.dart';
import "dart:io";
import "dart:ui";
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Запрос данных с сервера',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: startPage(),
      ),
    );
  }
}

class startPage extends StatefulWidget {
  @override
  _startPage createState() => _startPage();
}

class _startPage extends State<startPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          MaterialButton(
            color: Theme.of(context).primaryColor,
            height: 60,
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>addDataPage()));
            }, child: Text("Интерфейс загрузки изображений"),),
          MaterialButton(
            color: Theme.of(context).primaryColor.withOpacity(0.5),
            height: 60,
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>showDataPage()));
            }, child: Text("Интерфейс проверки изображений"),),
        ],
      ),
    );
  }
}


class showDataPage extends StatefulWidget {
  @override
  _showDataPageState createState() => _showDataPageState();
}

class _showDataPageState extends State<showDataPage> {
  String id = '';
  String _data = 'empty';
  Uint8List _image;
  _getData() async {
    var res = await dataProvider(id);
    setState(() {
      try {
        Map finRes = Map.from(res);
        if (finRes.keys.contains('name'))
          _data = finRes['name'];
        if (finRes.keys.contains('file'))
          debugPrint('file: ' + finRes['file'].toString());
      }
      catch (e) {
        debugPrint('error');
        if (res.toString().toLowerCase().length > 300) {
          debugPrint('too big content');
          _data = 'too bid unsupported content';
        }
        else
          _data = res.toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Проверка изображений'),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                width: 80,
                height: 80,
                color: Colors.lightGreen,
                alignment: Alignment.center,
                child: _image!=null?Image.memory(_image, width: 80, height: 80,):Text('empty image', textAlign: TextAlign.center,),
              ), //151db191-759a-42f2-99d7-0594eaf18d5e
              Text(
                'Введите ID искомой записи',
              ),
              TextFormField(
                initialValue: id,
                onChanged: (s){
                  id = s;
                },
              ),
              Text('Data: ' + _data),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getData,
        tooltip: 'Increment',
        child: Icon(Icons.find_in_page_rounded),
      ),
    );
  }
}


class addDataPage extends StatefulWidget {
  @override
  _addDataPage createState() => _addDataPage();
}

class _addDataPage extends State<addDataPage> {
  String status = 'Выбрать';
  File _data;

  _getImage(ImageSource source)async{
    final _picked = await ImagePicker().pickImage(source: source, preferredCameraDevice: CameraDevice.rear);
    if (_picked!=null){
      _data =  File(_picked.path);
      status = _picked.path;
    }
    else{
      _data = null;
      status = 'Выбрать';
    }
  }

  _addData() async{
    sendProvider(_data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Загрузка изображений"),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Выберите изображение из галереи',
              ),
              MaterialButton(onPressed: ()async{
                  await _getImage(ImageSource.gallery);
                  setState(() {});
                }, child: Text(status), height: 40, color: Theme.of(context).primaryColor,),
              MaterialButton(
                height: 20, color: Theme.of(context).primaryColor.withOpacity(0.7),
                onPressed: (){
                  _addData();
                }, child: Text('Загрузить одно изображение на сервер'),),
              MaterialButton(
                height: 20, color: Theme.of(context).primaryColor.withOpacity(0.8),
                onPressed: (){
                  for (int i = 0; i<10; ++i)
                    _addData();
                }, child: Text('Загрузить 10 изображений на сервер'),),
              MaterialButton(
                height: 20, color: Theme.of(context).primaryColor.withOpacity(0.9),
                onPressed: (){
                  for (int i = 0; i<100; ++i)
                    _addData();
                }, child: Text('Загрузить 100 изображений на сервер'),),
            ],
          ),
        ),
      ),
    );
  }
}