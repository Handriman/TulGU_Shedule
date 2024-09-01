
// import 'dart:ui';

// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'classes.dart';
import 'fetch.dart';
import 'day_widget.dart';

const List<String> list = <String>['Системная', 'Темная', 'Светлая'];
const List<Widget> wList = <Widget>[
  Icon(Icons.brightness_4),
  Icon(Icons.brightness_3_outlined),
  Icon(Icons.light_mode),
];

void main() {
  runApp( const MyApp());
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
  void initState() {
    super.initState();
    _loadThemeSettings(); // Загружаем сохранённые настройки
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _themeColor),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
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

class MyHomePage extends StatefulWidget {
  MyHomePage(
      {super.key,
      required this.title,
      required this.outerTheme,
      required this.color});

  final String title;
  ThemeMode outerTheme;
  Color color;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<Map<String, List<Schedule>>>? data;
  Map<String, List<Schedule>>? filteredData;
  Map<String, List<Schedule>>? onlineData;
  String? group;
  bool isDark = false;
  TextEditingController searchController = TextEditingController();
  final TextEditingController _controller = TextEditingController();
  String dropdownValue = list.first;
  late Color tempColor;

  List<bool> _selectedTheme = <bool>[true, false, false];

  @override
  void initState() {
    tempColor = widget.color;
    isDark = true;
    _controller.addListener(_onTextChanged);
    super.initState();
    loadGroup();
    filteredData = {};
  }

  void _onTextChanged() {
    final unfiltered = filteredData;
    filteredData = {};
    // print('changed');
    setState(() {
      for (var day in unfiltered!.keys) {
        List<Schedule> ou = [];
        for (var lesson in unfiltered[day]!) {
          final prep = lesson.prep ?? "Неизвестно";
          if (lesson.discipline.toLowerCase().contains(_controller.text) ||
              lesson.kow.toLowerCase().contains(_controller.text) ||
              prep.toLowerCase().contains(_controller.text)) {
            ou.add(lesson);
          }
        }
        if (ou.isNotEmpty) {
          filteredData![day] = ou;
        } else if (day.contains(_controller.text)) {
          filteredData![day] = unfiltered[day]!;
        }
      }
    });
  }

  Future<void> loadGroup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final getGroup = prefs.getString('group_number');
    if (getGroup != null) {
      group = getGroup;
      searchController.text = group!;
      data = getScheduleLocal(group!);
      updateSchedule();
    } else {
      showSearchDialog();
    }
  }

  Future<void> saveGroup(String newGroup) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('group_number', newGroup);
  }

  Future<void> updateSchedule() async {
    if (group == null) return;

    try {
      var schedule = await getScheduleOnline(group!);
      await saveScheduleLocal(group!, schedule);
      setState(() {
        onlineData = schedule;
        data = getScheduleLocal(group!);
      });
    } catch (error) {
      // Если ошибка при обновлении расписания, просто используем локальные данные
      setState(() {
        data = getScheduleLocal(group!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (MyApp.of(context)._themeMode) {
      case ThemeMode.system:
        _selectedTheme = [true, false, false];
        isDark = MediaQuery.of(context).platformBrightness == Brightness.dark
            ? true
            : false;

      case ThemeMode.dark:
        isDark = true;
        _selectedTheme = [false, true, false];
      case ThemeMode.light:
        _selectedTheme = [false, false, true];
        isDark = false;
    }

    return Scaffold(
      appBar: AppBar(
        // scrolledUnderElevation: 3,
        shadowColor: Theme.of(context).colorScheme.shadow,

        title: Row(
          children: [
            // const Text('Расписание'),
            // Padding(padding: EdgeInsets.all(10)),
            Expanded(

              child: TextField(
                decoration:  InputDecoration(

                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceTint.withOpacity(0.1),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  hintText: "Найди нужные пары!",

                ),
                controller: _controller,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              if (group != null) {
                updateSchedule();
              }
            },
            icon: const Icon(
              Icons.refresh,
            ),
          ),
          IconButton(
            onPressed: showSearchDialog,
            style: const ButtonStyle(),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: group == null
          ? const Center(child: Text('Введите группу'))
          : FutureBuilder<Map<String, List<Schedule>>>(
              future: data,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No schedule available'));
                } else {
                  // final sc = snapshot.data!;
                  if (_controller.text.isEmpty) {
                    filteredData = filterToday(snapshot.data!);
                  }

                  final keys = filteredData!.keys.toList();

                  return ListView.builder(
                    itemCount: filteredData!.keys.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: buildDay(filteredData!, keys, index, isDark,
                            MyApp.of(context)._themeColor),
                      );
                    },
                  );
                }
              },
            ),
    );
  }

  Map<String, List<Schedule>> filterToday(
      Map<String, List<Schedule>> unfilteredDate) {
    final today = DateTime.now();

    return Map.fromEntries(unfilteredDate.entries.where((element) =>
        today.isBefore(parseDate(element.key)) ||
        today == parseDate(element.key)));
  }

  void showSearchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Введите номер группы'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                // Добавьте mainAxisSize для правильной компоновки
                children: [
                  TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      isDense: true,
                      // contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      hintText: 'например: 70349аф',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ToggleButtons(
                        direction: Axis.horizontal,
                        isSelected: _selectedTheme,
                        onPressed: (int index) {
                          setState(() {
                            for (int i = 0; i < _selectedTheme.length; i++) {
                              _selectedTheme[i] = i == index;
                              if (i == index) {
                                final theme = list[i];
                                if (theme == "Системная") {
                                  MyApp.of(context)
                                      .changeTheme(ThemeMode.system);
                                  isDark = MediaQuery.of(context)
                                              .platformBrightness ==
                                          Brightness.dark
                                      ? true
                                      : false;
                                } else if (theme == "Темная") {
                                  MyApp.of(context).changeTheme(ThemeMode.dark);
                                  isDark = true;
                                } else if (theme == "Светлая") {
                                  MyApp.of(context)
                                      .changeTheme(ThemeMode.light);
                                  isDark = false;
                                }
                                // Сохранение состояния темы
                                MyApp.of(context)._saveThemeSettings();
                              }
                            }
                          });
                        },
                        borderRadius:
                            const BorderRadius.all(Radius.circular(25)),
                        constraints: const BoxConstraints(
                          minHeight: 40.0,
                          minWidth: 80.0,
                        ),
                        children: wList,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),

                  // Выбор цветовой схемы
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          Radio<Color>(
                            value: Colors.deepPurple,
                            groupValue: tempColor,
                            onChanged: (color) {
                              tempColor = color!;

                              MyApp.of(context).changeColor(tempColor);
                            },
                          ),
                          const SizedBox(width: 8),
                          // Добавляем отступ между радио-кнопкой и контейнером
                          Container(
                            decoration: const BoxDecoration(
                              color: Colors.deepPurple,
                              shape: BoxShape.circle,
                            ),
                            width: 25,
                            height: 25,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Radio<Color>(
                            value: Colors.deepOrangeAccent,
                            groupValue: tempColor,
                            onChanged: (color) {
                              tempColor = color!;

                              MyApp.of(context).changeColor(tempColor);
                            },
                          ),
                          const SizedBox(width: 8),
                          // Добавляем отступ между радио-кнопкой и контейнером
                          Container(
                            decoration: const BoxDecoration(
                              color: Colors.deepOrangeAccent,
                              shape: BoxShape.circle,
                            ),
                            width: 25,
                            height: 25,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Radio<Color>(
                            value: Colors.yellow,
                            groupValue: tempColor,
                            onChanged: (color) {
                              tempColor = color!;

                              MyApp.of(context).changeColor(tempColor);
                            },
                          ),
                          const SizedBox(width: 8),
                          // Добавляем отступ между радио-кнопкой и контейнером
                          Container(
                            decoration: const BoxDecoration(
                              color: Colors.yellow,
                              shape: BoxShape.circle,
                            ),
                            width: 25,
                            height: 25,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          Radio<Color>(
                            value: Colors.pink,
                            groupValue: tempColor,
                            onChanged: (color) {
                              tempColor = color!;

                              MyApp.of(context).changeColor(tempColor);
                            },
                          ),
                          const SizedBox(width: 8),
                          // Добавляем отступ между радио-кнопкой и контейнером
                          Container(
                            decoration: const BoxDecoration(
                              color: Colors.pink,
                              shape: BoxShape.circle,
                            ),
                            width: 25,
                            height: 25,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Radio<Color>(
                            value: Colors.green,
                            groupValue: tempColor,
                            onChanged: (color) {
                              tempColor = color!;

                              MyApp.of(context).changeColor(tempColor);
                            },
                          ),
                          const SizedBox(width: 8),
                          // Добавляем отступ между радио-кнопкой и контейнером
                          Container(
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            width: 25,
                            height: 25,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Radio<Color>(
                            value: Colors.blue,
                            groupValue: tempColor,
                            onChanged: (color) {
                              tempColor = color!;

                              MyApp.of(context).changeColor(tempColor);
                            },
                          ),
                          const SizedBox(width: 8),
                          // Добавляем отступ между радио-кнопкой и контейнером
                          Container(
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            width: 25,
                            height: 25,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Отмена'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      group = searchController.text;
                      saveGroup(group!);
                      data = getScheduleLocal(group!);
                      updateSchedule();
                      MyApp.of(context)._saveThemeSettings();
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Сохранить'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget showSettings() {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: const InputDecoration(hintText: 'группа'),
            ),
            DropdownButton<String>(
              value: dropdownValue,
              onChanged: (String? value) {
                // This is called when the user selects an item.
                setState(() {
                  dropdownValue = value!;
                });
              },
              items: list.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
