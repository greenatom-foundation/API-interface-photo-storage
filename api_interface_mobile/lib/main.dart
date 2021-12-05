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


TextStyle buttonTxt = TextStyle(fontSize: 16, color: Colors.white,);
TextStyle headerTxt = TextStyle(fontSize: 20, color: Colors.white);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Запрос данных с сервера',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(title: Text("AtomHack: team #10", style: headerTxt, textAlign: TextAlign.center,), centerTitle: true,),
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
          Expanded(child: SizedBox(), flex: 2,),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Image.asset('assets/atomLogo.png'),
          ),
          Expanded(child: SizedBox(), flex: 1,),
          MaterialButton(
            color: Theme.of(context).primaryColor,
            height: 60,
            minWidth: MediaQuery.of(context).size.width*0.9,
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>addDataPage()));
            }, child: Text("Интерфейс загрузки изображений", style: buttonTxt,),),
          Expanded(child: SizedBox(), flex: 1,),
          MaterialButton(
            minWidth: MediaQuery.of(context).size.width*0.9,
            color: Theme.of(context).primaryColor.withOpacity(0.5),
            height: 60,
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>showDataPage()));
            }, child: Text("Интерфейс проверки изображений", style: buttonTxt),),
          Expanded(child: SizedBox(), flex: 3,),
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
        title: Text('Проверка изображений', style: headerTxt),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
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
  File _data;

  Widget _imageBox(){
    if (_data != null)
      return Container(
        width: MediaQuery.of(context).size.width*.8,
        height: MediaQuery.of(context).size.width*.8,
        color: Theme.of(context).primaryColor,
        child: Stack(
          children: [
            Image.file(_data),
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                child: Container(
                  width: 40,
                  height: 40,
                  child: Icon(Icons.delete_forever, color: Colors.grey, size: 36,),
                ),
                onTap: (){
                  setState(() {
                    _data = null;
                  });
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: MediaQuery.of(context).size.width*.8,
                height: 40,
                alignment: Alignment.bottomCenter,
                child: Text("Preview", style: buttonTxt,),
              ),
            ),
          ],
        ),
      );
    return MaterialButton(onPressed: ()async{
        await _getImage(ImageSource.gallery);
        setState(() {});
      }, child: Text("Выбрать", style: buttonTxt.copyWith(fontSize: 16)), height: 40, color: Theme.of(context).primaryColor,
    );
  }

  _getImage(ImageSource source)async{
    final _picked = await ImagePicker().pickImage(source: source, preferredCameraDevice: CameraDevice.rear);
    if (_picked!=null){
      _data =  File(_picked.path);
    }
    else{
      _data = null;
    }
  }

  _addData() async{
    sendProvider(_data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Загрузка изображений", style: headerTxt,),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _imageBox(),
              MaterialButton(
                minWidth: MediaQuery.of(context).size.width*.9,
                padding: EdgeInsets.symmetric(vertical: 6), color: Theme.of(context).primaryColor.withOpacity(0.7),
                onPressed: (){
                  _addData();
                }, child: Text('Загрузить изображение на сервер', style: buttonTxt),),
              MaterialButton(
                minWidth: MediaQuery.of(context).size.width*.9,
                padding: EdgeInsets.symmetric(vertical: 6), color: Theme.of(context).primaryColor.withOpacity(0.8),
                onPressed: (){
                  for (int i = 0; i<10; ++i)
                    _addData();
                }, child: Text('Загрузить 10 изображений на сервер', style: buttonTxt),),
              MaterialButton(
                minWidth: MediaQuery.of(context).size.width*.9,
                padding: EdgeInsets.symmetric(vertical: 6), color: Theme.of(context).primaryColor.withOpacity(0.9),
                onPressed: (){
                  for (int i = 0; i<100; ++i)
                    _addData();
                }, child: Text('Загрузить 100 изображений на сервер', style: buttonTxt),),
            ],
          ),
        ),
      ),
    );
  }
}