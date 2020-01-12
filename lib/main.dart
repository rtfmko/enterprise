import 'package:enterprise/pages/page_main.dart' as prefix0;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'dart:io';
import 'package:enterprise/pages/page_main.dart';
import 'package:enterprise/pages/page_news.dart';
import 'package:enterprise/pages/page_profile.dart';
import 'package:enterprise/pages/page_settings.dart';

void main() => runApp(App());

class App extends StatefulWidget {
  AppState createState() => AppState();
}

class AppState extends State<App> {
  int _currentIndex = 0;

  Widget callPage(int currentIndex) {
    switch (currentIndex) {
      case 0:
        return PageMain();
      case 1:
        return PageNews();
      case 2:
        return PageProfile();
      case 3:
        return PageSettings();
        break;
      default:
        return PageMain();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: new Scaffold(
            appBar: new AppBar(title: new Text('Enterprise')),
            body: callPage(_currentIndex),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              type: BottomNavigationBarType.fixed,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              items: [
                BottomNavigationBarItem(
                    icon: Icon(Icons.home), title: Text('головна')),
                BottomNavigationBarItem(
                    icon: Icon(Icons.rss_feed), title: Text('новини')),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person), title: Text('профіль')),
                BottomNavigationBarItem(
                    icon: Icon(Icons.settings), title: Text('налаштування'))
              ],
            )));
  }
}

class AppBody extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AppBodyState();
}

class AppBodyState extends State {
  final _formKey = GlobalKey<FormState>();
  final serverIPController = TextEditingController();
  final serverUserController = TextEditingController();
  final serverPasswordController = TextEditingController();
  final serverDBController = TextEditingController();

  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _read());
  }

  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(10.0),
        child: new Form(
            key: _formKey,
            child: new Column(
              children: <Widget>[
                new Text(
                  'server IP:',
                  style: TextStyle(fontSize: 20.0),
                  textAlign: TextAlign.left,
                ),
                new TextFormField(
                    validator: (value) {
                      if (value.isEmpty) return 'не вказаний server IP';
                    },
                    controller: serverIPController),
                new Text(
                  'Server User:',
                  style: TextStyle(fontSize: 20.0),
                ),
                new TextFormField(
                    validator: (value) {
                      if (value.isEmpty) return 'не вказаний server User';
                    },
                    controller: serverUserController),
                new Text(
                  'Server Password:',
                  style: TextStyle(fontSize: 20.0),
                ),
                new TextFormField(
                    validator: (value) {
                      if (value.isEmpty) return 'не вказаний server Password';
                    },
                    controller: serverPasswordController,
                    obscureText: true),
                new Text(
                  'server Database:',
                  style: TextStyle(fontSize: 20.0),
                ),
                new TextFormField(
                  validator: (value) {
                    if (value.isEmpty) return 'не вказана server Database';
                  },
                  controller: serverDBController,
                ),
                new SizedBox(height: 20.0),
                new RaisedButton(
                  onPressed: () {
                    if (_formKey.currentState.validate()) _save();
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text('Налаштування збережено'),
                      backgroundColor: Colors.green,
                    ));
                  },
                  child: Text('Save'),
                  color: Colors.blue,
                  textColor: Colors.white,
                ),
                new FlatButton(
                  onPressed: () {
                    _makePostRequest();
                  },
                  child: Text('Send'),
                  color: Colors.blueGrey,
                )
              ],
            )));
  }

  _read() async {
    final prefs = await SharedPreferences.getInstance();
    serverIPController.text = prefs.getString("serverIP") ?? "";
    serverUserController.text = prefs.getString("serverUser") ?? "";
    serverPasswordController.text = prefs.getString("serverPassword") ?? "";
    serverDBController.text = prefs.getString("serverDB") ?? "";
  }

  _save() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("serverIP", serverIPController.text);
    prefs.setString("serverUser", serverUserController.text);
    prefs.setString("serverPassword", serverPasswordController.text);
    prefs.setString("serverDB", serverDBController.text);
  }

  _makePostRequest() async {
    // set up POST request arguments
    String url = 'http://' +
        serverIPController.text +
        '/' +
        serverDBController.text +
        '/hs/m/time';

    final username = serverUserController.text;
    final password = serverPasswordController.text;
    final credentials = '$username:$password';
    final stringToBase64 = utf8.fuse(base64);
    final encodedCredentials = stringToBase64.encode(credentials);
    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: "Basic $encodedCredentials",
    };

//      String json = '{"title": "Hello", "body": "body text", "userId": 1}';

    // make POST request
//      Response response = await post(url, headers: headers, body: json);
    Response response = await post(url, headers: headers);
    // check the status code for the result
    int statusCode = response.statusCode;
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(statusCode.toString()),
      backgroundColor: Colors.green,
    ));
    // this API passes back the id of the new item added to the body
    String body = response.body;
    // {
    //   "title": "Hello",
    //   "body": "body text",
    //   "userId": 1,
    //   "id": 101
    // }
  }
}
