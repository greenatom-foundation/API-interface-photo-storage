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
  String _data = 'empty';
  Map _finalRes = {};
  Map _listData = {};
  Uint8List _image;

  _search(String s){
    if(_finalRes.isNotEmpty && s.length>0){
      _listData = {};
      for (var el in _finalRes.keys){
        if (_finalRes[el]["PK_ID"].toString().toLowerCase().contains(s) || _finalRes[el]["V_NAME"].toString().toLowerCase().contains(s))
          _listData[el] = _finalRes[el];
      }
      setState(() {});
    }
  }

  _getData() async {
    var res =  await dataProvider();
    _finalRes = res;
    _listData = Map.from(_finalRes);
    setState(() {});
  }

  _getImage(String id)async{
    var res =  await dataProvider(id: id);
    if (res['file']!=null){
      debugPrint('contains file');
      await showDialog(context: context, builder: (BuildContext context) => SimpleDialog(
        children: [
          Image.memory(base64Decode(res['file'])),
        ],
      ));
    }
    //debugPrint('res: '+res.toString());
    //_finalRes = res;
    //_listData = Map.from(_finalRes);
    setState(() {});
  }

  Widget _listBuilder(){
    var _mas = _listData.keys.toList();
    return Expanded(
        flex: 4,
        child: AnimatedOpacity(
          opacity: _listData.keys.length == 0?0:1,
          duration: Duration(seconds: 2),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: _listData.keys.length == 0?Container():ListView.builder(
              itemCount: _mas.length,
              itemBuilder: (context, i){
                return GestureDetector(
                  onTap: (){
                    _getImage(_listData[_mas[i]]['PK_ID']);
                    //debugPrint('open: '+_listData[_mas[i]]['PK_ID']);
                  },
                  child: Card(
                    color: Theme.of(context).primaryColor,
                    elevation: 8.0,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ID: '+_listData[_mas[i]]['PK_ID'], style: buttonTxt,),
                          Text('NAME: '+_listData[_mas[i]]['V_NAME'], style: buttonTxt,)
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Проверка изображений', style: headerTxt),
            GestureDetector(
              onTap: (){
                _getData();
              },
              child: Container(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.update),
              ),
            )
          ],
        ),
      ),
      body: Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 48,),
              Text(
                'Введите ID искомой записи',
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: TextFormField(
                  onChanged: (s){
                    _search(s);
                  },
                ),
              ),
              Text('Data: ' + _data),
              SizedBox(height: 12,),
              _listBuilder(),
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
  int _sendingLeft = -1;
  File _data;
  DateTime _startStamp, _endStamp;
  int _counterGood = 0, _counterBad = 0;

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
                    _sendingLeft = -1;
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
                alignment: Alignment.bottomRight,
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

  Widget _scriningData(){
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 2.0)),
      width: MediaQuery.of(context).size.width*.8,
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(border: Border(right: BorderSide(color: Colors.black, width: 1.0))),
              height: 40,
              child: Text("Good: " + _counterGood.toString()),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(border: Border(right: BorderSide(color: Colors.black, width: 1.0))),
              height: 40,
              child: Text("Bad: " + _counterBad.toString()),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4),
              alignment: Alignment.centerLeft,
              height: 40,
              child: Text(_sendingLeft==0?"Time: " + _endStamp.difference(_startStamp).toString():"Wait"),
            ),
          ),
        ],
      ),
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
    if(await sendProvider(_data))
        _counterGood++;
    else
        _counterBad++;
    setState(() {
      _sendingLeft--;
      if (_sendingLeft == 0){
        _endStamp = DateTime.now();
      }
    });
  }

  void sendData({int count = 1}){
    _counterGood = 0;
    _counterBad = 0;
    setState(() {
      _sendingLeft = count;
      _startStamp = DateTime.now();
    });
    for (int i = 0; i < count; ++i)
      _addData();
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
              _sendingLeft != -1?_scriningData():SizedBox(),
              _sendingLeft != -1?SizedBox(height: 12,):SizedBox(),
              _imageBox(),
              MaterialButton(
                minWidth: MediaQuery.of(context).size.width*.9,
                padding: EdgeInsets.symmetric(vertical: 6), color: Theme.of(context).primaryColor.withOpacity(0.7),
                onPressed: (){
                  sendData();
                }, child: Text('Загрузить изображение на сервер', style: buttonTxt),),
              MaterialButton(
                minWidth: MediaQuery.of(context).size.width*.9,
                padding: EdgeInsets.symmetric(vertical: 6), color: Theme.of(context).primaryColor.withOpacity(0.8),
                onPressed: (){
                  sendData(count: 10);
                }, child: Text('Загрузить 10 изображений на сервер', style: buttonTxt),),
              MaterialButton(
                minWidth: MediaQuery.of(context).size.width*.9,
                padding: EdgeInsets.symmetric(vertical: 6), color: Theme.of(context).primaryColor.withOpacity(0.9),
                onPressed: (){
                  sendData(count: 100);
                }, child: Text('Загрузить 100 изображений на сервер', style: buttonTxt),),
            ],
          ),
        ),
      ),
    );
  }
}