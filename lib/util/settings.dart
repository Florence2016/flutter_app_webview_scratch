import 'dart:core';


class Settings {
  static final Settings _settings = new Settings._internal();

  factory Settings() => _settings;

  Settings._internal();

  static Settings get instance => _settings;

  static String searchEngine = SearchEngines["Searchlock"];
}

Map<String, dynamic> SearchEngines = {
  "Google": "google.com",
  "Bing": "bing.com",
  "Yahoo!": "yahoo.com",
  "Searchlock": "searchlock.com",
};