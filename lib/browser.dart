import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_webview_scratch/util/settings.dart';
import 'package:flutter_app_webview_scratch/util/uri.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:url_launcher/url_launcher.dart';
import 'tab_panel.dart';

enum TabMenu {
  history,
  refresh,
  exit,
}

class NormalTab extends BrowserTab {
  final bool withJavascript;
  final bool clearCache;
  final bool clearCookies;
  final bool enableAppScheme;
  final String userAgent;
  final bool primary;
  final bool withZoom;
  final bool withLocalStorage;

  NormalTab({Key key,
    this.withJavascript,
    this.clearCache,
    this.clearCookies,
    this.enableAppScheme,
    this.userAgent,
    this.primary: true,
    this.withZoom,
    this.withLocalStorage,
    Uri uri})
      : super(key: key, uri: uri);

  @override _NormalTabState createState() => new _NormalTabState();
}

class _NormalTabState extends State<NormalTab> with SingleTickerProviderStateMixin{
  FlutterWebviewPlugin _webviewPlugin = new FlutterWebviewPlugin();
  TextEditingController _textController;

  AnimationController controller;

  Rect _rect;
  Timer _resizeTimer;

  @override
  void initState() {
    super.initState();
    _webviewPlugin.close();

    controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 100),value: 1.0);
  }

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
    _webviewPlugin.close();
    _webviewPlugin.dispose();
    controller.dispose();
  }

  bool get isPanelVisible{
    final AnimationStatus status = controller.status;
    return status == AnimationStatus.completed || status == AnimationStatus.forward;
  }

  @override
  Widget build(BuildContext context) {
    PreferredSizeWidget appBar = buildAppBar();

    _webviewPlugin.onUrlChanged.listen((String url) {
      widget.uri = Uri.parse(url);
      _textController.text = widget.uri.toString();
    });

    if(widget.uri != null) {
      if(_rect == null) {
        _rect = _buildRect(context, appBar);
        _webviewPlugin.launch(widget.uri.toString(),
            withJavascript: widget.withJavascript,
            clearCache: widget.clearCache,
            clearCookies: widget.clearCookies,
            enableAppScheme: widget.enableAppScheme,
            userAgent: widget.userAgent,
            rect: _rect,
            withZoom: widget.withZoom,
            withLocalStorage: widget.withLocalStorage);
      } else {
        Rect rect = _buildRect(context, appBar);

        if (_rect != rect) {
          _rect = rect;
          _resizeTimer?.cancel();
          _resizeTimer = new Timer(new Duration(milliseconds: 300), () {
            // avoid resizing to fast when build is called multiple time
            _webviewPlugin.resize(_rect);
          });
        }
      }

      return Scaffold(
        appBar: buildAppBar(),

      );
    }
    else return buildHomePage();

  }

  Widget buildHomePage() {
    return Scaffold(
      appBar: buildAppBar(),
      body: Panels(controller: controller)
    );
  }

  Widget buildAppBar() {
    _textController = new TextEditingController(text: (widget.uri == null) ? "" : widget.uri.toString());
    return AppBar(
      brightness: Brightness.light,
      backgroundColor: Colors.blue[900],
      titleSpacing: 0.0,
      leading: IconButton(
          icon: Icon(Icons.home, color: Colors.white,),
          onPressed: home
      ),
      title: TextField(
        maxLines: 1,
        keyboardType: TextInputType.url,
        controller: _textController,
        style: TextStyle(fontSize: 16.0,
            color: Colors.white
        ),
        decoration: InputDecoration.collapsed(
          border: InputBorder.none,
          hintText: "Search or enter URL",
          hintStyle: TextStyle(fontSize: 16.0, color: Colors.grey[300])
        ),
        onSubmitted: handleSubmitted,
      ),
      actions: <Widget>[
        new PopupMenuButton<TabMenu>(
          onSelected: (TabMenu result) {
            switch(result) {
              case TabMenu.history:
                history();
                break;

              case TabMenu.refresh:
                refresh();
                break;
              case TabMenu.exit:
                exit(0);
                break;
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<TabMenu>>[
           new PopupMenuItem<TabMenu>(
                value: TabMenu.history,
                child: new Text("History")
            ),
            new PopupMenuItem<TabMenu>(
                value: TabMenu.refresh,
                child: new Text("Refresh")
            ),
            new PopupMenuItem<TabMenu>(
                value: TabMenu.exit,
                child: new Text("Exit")
            ),
          ],
        ),
      ],
    );
  }

  Rect _buildRect(BuildContext context, PreferredSizeWidget appBar) {
    bool fullscreen = appBar == null;

    final mediaQuery = MediaQuery.of(context);
    final topPadding = widget.primary ? mediaQuery.padding.top : 0.0;
    num top =
    fullscreen ? 0.0 : appBar.preferredSize.height + topPadding;

    num height = mediaQuery.size.height - top;

    return new Rect.fromLTWH(0.0, top, mediaQuery.size.width, height);
  }


  Future handleSubmitted(String text) async {
    print(text);
    _textController.clear();

    if(text.isEmpty) {
      setState(() => widget.uri = null);
    } else {
      print(await canLaunch("https://"+text.replaceAll(" ", "")));
      if(await canLaunch(text.replaceAll(" ", ""))) {
        setState(() {
          widget.uri = Uri.parse(text.replaceAll(" ", ""));
        });
      } else {
        search(text);
      }
      _textController.text = widget.uri.toString();
    }
    print(widget.uri.toString());
  }

  void home() {
    setState(() => widget.uri = null);
    _webviewPlugin.close();
  }
/*
  void copy() async {
    await Clipboard.setData(new ClipboardData(text: widget.uri.toString()));
  }
*/
  void refresh() {
    if(widget.uri != null) {
      _webviewPlugin.reload();
    }
  }

  void history() {
    home();
    controller.fling(velocity: isPanelVisible? -1.0: 1.0);
  }

  void relaunch() {
    if(widget.uri != null) {
      _webviewPlugin.close();
      _webviewPlugin.launch(widget.uri.toString(),
          withJavascript: widget.withJavascript,
          clearCache: widget.clearCache,
          clearCookies: widget.clearCookies,
          enableAppScheme: widget.enableAppScheme,
          userAgent: widget.userAgent,
          rect: _rect,
          withZoom: widget.withZoom,
          withLocalStorage: widget.withLocalStorage);
    }
  }

  void search(String query) {
    setState(() =>
    widget.uri = Uri.parse("https://"+Settings.searchEngine+"/search?q="+query)
    );
    if(_rect != null)
      relaunch();
  }
}


