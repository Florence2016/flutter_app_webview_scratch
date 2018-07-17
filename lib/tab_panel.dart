import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

String url = "https://";

class Panels extends StatefulWidget {
  final AnimationController controller;

  Panels({this.controller});
  @override
  _PanelsState createState() => _PanelsState();
}

class _PanelsState extends State<Panels> {
  TextEditingController searchBarController = TextEditingController();
  final webView = FlutterWebviewPlugin();

  static const header_height = 32.0;

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


  Animation<RelativeRect> getPanelAnimation(BoxConstraints constraints){
    final height = constraints.biggest.height;
    final backPanelHeight = height - header_height;
    final frontPanelHeight = -header_height;

    return RelativeRectTween(
      begin: RelativeRect.fromLTRB(0.0, backPanelHeight, 0.0, frontPanelHeight),
          end: RelativeRect.fromLTRB(0.0, 0.0, 0.0, 0.0)).animate(CurvedAnimation
      (parent: widget.controller, curve: Curves.linear));
  }

  Widget popPanels(BuildContext context, BoxConstraints constraints){

    final ThemeData theme = Theme.of(context);

    return Container(
      child: Stack(
        children: <Widget>[
          Container(
            color: theme.primaryColor,
            child: Center(
              child: Text("History Panel",
              style: TextStyle(
               fontSize: 24.0, color: Colors.white)
              ),
            ),
          ),
          PositionedTransition(
            rect: getPanelAnimation(constraints),
            child: Material(
             elevation: 12.0,
             borderRadius: BorderRadius.only(
               topLeft: Radius.circular(16.0),
               topRight: Radius.circular(16.0)),
              child: Column(
                children: <Widget>[
                Container(
                child: Text('Front Panel'),
                  
                ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: popPanels,
    );
  }
}
