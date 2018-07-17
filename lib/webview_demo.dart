import 'package:flutter/material.dart';
import 'package:flutter_app_webview_scratch/tab_panel.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

String url = "https://";
TextEditingController searchBarController = TextEditingController();
void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Webview Sample',
      theme: new ThemeData(),
      routes: {
        "/":(_) => BackdropPage(),
        "/webview": (_) => WebviewScaffold(
          url: url,
          appBar: AppBar(
            backgroundColor: Colors.blue[800],
            title: Center(
              child: TextFormField(
                style: new TextStyle(
                    color: Colors.white,
                    fontSize: 18.0
                ),
                controller: searchBarController,
              ),
            ),


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

class BackdropPage extends StatefulWidget {
  @override
  _BackdropPageState createState() => _BackdropPageState();
}

class _BackdropPageState extends State<BackdropPage> with SingleTickerProviderStateMixin{
  
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 100),
    value: 1.0);

    searchBarController.addListener((){
       url = searchBarController.text;
    });
  }
  @override
  void dispose() {
    super.dispose();
    controller.dispose();
    searchBarController.dispose();
  }

  bool get isPanelVisible{
    final AnimationStatus status = controller.status;
    return status == AnimationStatus.completed || status == AnimationStatus.forward;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        title: Directionality(textDirection: Directionality.of(context),
            child: TextField(
              key: Key('SearchBarTextField'),
              keyboardType: TextInputType.text,
              style: new TextStyle(
                  color: Colors.white,
                  fontSize: 18.0
              ),
              controller:  searchBarController,
            )
        ),
        elevation: 5.0,
        leading: IconButton(
          onPressed: (){
          controller.fling(velocity: isPanelVisible? -1.0: 1.0);
          },
            icon: AnimatedIcon(
                icon: AnimatedIcons.arrow_menu,
              progress: controller.view,
            ),
        ),
        actions: <Widget>[
          new IconButton( icon: new Icon(Icons.search),
            onPressed: (){
              Navigator.of(context).pushNamed("/webview");
            },
          ),
        ],
      ),
      body: Panels(controller: controller),

    );
  }
}
