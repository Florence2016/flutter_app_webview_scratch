import 'package:flutter/material.dart';
//import 'package:url_launcher/url_launcher.dart';
//import 'dart:async';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

String url = "https://";

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Webview Sample',
      theme: new ThemeData(),
      routes: {
        "/":(_) => MyHomePage(),
        "/webview": (_) => WebviewScaffold(
            url: url,
          appBar: AppBar(
            title: Text("Webview"),
          ),
          withJavascript: true,
          withLocalStorage: true,
          withZoom: true,
        )
      },
      //home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final webView = FlutterWebviewPlugin();
  TextEditingController searchBarController = TextEditingController(text: url);

  @override
  void initState() {
    super.initState();
    webView.close();

    searchBarController.addListener((){
      url = searchBarController.text;
    });
  }

  @override
  void dispose() {
    webView.dispose();
    searchBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      appBar: AppBar(
        title: Text('Seachbar Demo'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(10.0),
              child: TextField(
                controller: searchBarController,
              ),
            ),
            RaisedButton(
              child: Text('Open Webview'),
              onPressed: (){
                Navigator.of(context).pushNamed("/webview");
              },
            )
          ],
        ),
      ),
    );
  }
}
