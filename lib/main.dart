// import 'dart:ui';

// import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'settings_page.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

import 'classes.dart';
import 'fetch.dart';
import 'day_widget.dart';

import 'groupSchedulePage.dart';
import 'HomePage.dart';

const List<String> list = <String>['Системная', 'Темная', 'Светлая'];
const List<Widget> wList = <Widget>[
  Icon(Icons.brightness_4),
  Icon(Icons.brightness_3_outlined),
  Icon(Icons.light_mode),
];

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;
  Color _themeColor = Colors.deepPurple;

  @override
  void initState()  {
    super.initState();
     _loadThemeSettings(); // Загружаем сохранённые настройки
  }

  // Добавляем геттеры
  ThemeMode get themeMode => _themeMode;
  Color get themeColor => _themeColor;

// Добавляем публичный метод для сохранения
  Future<void> saveThemeSettings() => _saveThemeSettings();



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useSystemColors: true,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: _themeColor),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        useSystemColors: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: _themeColor, brightness: Brightness.dark),
        brightness: Brightness.dark,
      ),
      themeMode: _themeMode,
      home: MyHomePage(
        title: 'Flutter Demo Home Page',
        outerTheme: _themeMode,
        color: _themeColor,
      ),

    );
  }

  Future<void> _loadThemeSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Загружаем цветовую схему
    int? colorValue = prefs.getInt('themeColor');
    if (colorValue != null) {
      _themeColor = Color(colorValue);
    }

    // Загружаем тему
    String? themeModeStr = prefs.getString('themeMode');
    if (themeModeStr != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (e) => e.toString() == themeModeStr,
        orElse: () => ThemeMode.system,
      );
    }

    setState(() {});
  }

  Future<void> _saveThemeSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeColor', _themeColor.value);
    await prefs.setString('themeMode', _themeMode.toString());
  }

  void changeColor(Color color) {
    setState(() {
      _themeColor = color;
    });
  }

  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }
}


