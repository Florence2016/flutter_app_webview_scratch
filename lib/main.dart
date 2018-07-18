import 'package:flutter/material.dart';
import 'package:flutter_app_webview_scratch/browser.dart';
import 'package:flutter_app_webview_scratch/util/settings.dart';


void main() => runApp(new MyApp());

Settings settings = new Settings();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Browser(title: 'Flutter Browser'),
    );
  }
}

class Browser extends StatefulWidget {
  Browser({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _BrowserState createState() => new _BrowserState();
}

class _BrowserState extends State<Browser> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
     body: new NormalTab(),
    );
  }



}