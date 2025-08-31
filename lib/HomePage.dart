import 'package:flutter/material.dart';

import 'main.dart';
import 'groupSchedulePage.dart';


Widget mainPage(BuildContext context, String title, ThemeMode outerTheme, Color color) {
  return Scaffold(

    body: MyHomePage(title: title, outerTheme: outerTheme, color: color),
    bottomNavigationBar: BottomNavigationBar(items: [
          BottomNavigationBarItem(icon: Icon(Icons.abc), label: "Текст 1"),
          BottomNavigationBarItem(icon: Icon(Icons.ac_unit), label: "Teкст 2"),
        ]),


  );
}