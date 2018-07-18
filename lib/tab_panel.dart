import 'package:flutter/material.dart';

class Panels extends StatefulWidget {
  final AnimationController controller;

  Panels({this.controller});
  @override
  _PanelsState createState() => _PanelsState();
}

class _PanelsState extends State<Panels> {
  static const header_height = 32.0;


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
            color: Colors.blue[900],
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
              child: Container(
                child: Center(
                  child: Text('Front Panel'),
                ),
              )
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