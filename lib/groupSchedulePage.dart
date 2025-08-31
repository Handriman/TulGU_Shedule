import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'dart:convert';

import 'main.dart';
import 'classes.dart';
import 'fetch.dart';
import 'day_widget.dart';
import 'settings_page.dart';

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

  // Map<String, List<Schedule>>? onlineData;
  Map<String, List<Schedule>>? _lastData;

  String? profName;

  String? group;
  bool isDark = false;
  TextEditingController searchController = TextEditingController();
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _profController = TextEditingController();
  String dropdownValue = list.first;
  late Color tempColor;

  List<bool> _selectedTheme = <bool>[true, false, false];
  String currentVersion = 'v1.5.0';
  String? latestVersion;

  SnackBar? _offlineBanner;

  bool isOfflineBanner = false;
  Timer? debounce;

  Color? _seedColorSnack;

  int _selectedIndex = 0;
  String tempString = '';

  bool _refreshing = false;

  @override
  void initState() {
    tempColor = widget.color;

    isDark = true;
    _controller.addListener(_debaunceSearch);
    _profController.addListener(_debaunceProfScheduleSearch);
    super.initState();
    loadGroup();
    _checkForUpdate();
    filteredData = {};
    _seedColorSnack = MyApp.of(context).themeColor;
  }

  _checkForUpdate() async {
    final response = await http.get(Uri.parse(
        'https://api.github.com/repos/Handriman/TulGU_Shedule/releases/latest'));

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      setState(() {
        latestVersion = jsonResponse['tag_name'];
      });

      if (latestVersion != null && latestVersion != currentVersion) {
        _showUpdateBanner();
      }
    }
  }

  void _showOfflineBanner() {
    final scheme = Theme.of(context).colorScheme;

    _offlineBanner = SnackBar(
      content: Text(
        'Ошибка обновления.\nИспользую сохранённое расписание!',
        style: TextStyle(color: scheme.onErrorContainer),
      ),
      backgroundColor: scheme.errorContainer,
      action: SnackBarAction(
        onPressed: () => setState(() => _offlineBanner = null), // убрать баннер
        label: 'Ок',
      ),
    );
  }

  void _testSnack() {
    if (isOfflineBanner == true) {
      // var scheme = isDark ? ColorScheme.fromSeed(seedColor: _seedColorSnack!, brightness: Brightness.dark) : ColorScheme.fromSeed(seedColor: _seedColorSnack!, brightness: Brightness.light) ;

      final messanger = ScaffoldMessenger.of(context);
      messanger.removeCurrentSnackBar();
      messanger.showSnackBar(
        SnackBar(
          content: const Text(
            'Ошибка обновления.\nИспользую сохранённое расписание!',
            // style: TextStyle(color: scheme.onErrorContainer),
          ),
          // backgroundColor: scheme.errorContainer,
          action: SnackBarAction(
              label: "Ок",
              onPressed: ScaffoldMessenger.of(context).hideCurrentSnackBar),
          duration: const Duration(minutes: 10),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
    }
  }

  void _showUpdateBanner() {
    // ScaffoldMessenger.of(context).showMaterialBanner(
    //   MaterialBanner(content: Text('Доступна новая версия $latestVersion!'),
    //       actions: <Widget>[
    //         TextButton(onPressed: _launchURL, child: Text('Обновить')),
    //         TextButton(onPressed: ScaffoldMessenger.of(context).hideCurrentMaterialBanner, child: Text('Закрыть')),
    //       ]
    //   )
    // );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 10),
        content: Text('Доступна новая версия $latestVersion!'),
        action: SnackBarAction(
          label: 'Обновить',
          onPressed: _launchURL,
        ),
      ),
    );
  }

  _launchURL() async {
    final Uri url =
        Uri.parse('https://github.com/Handriman/TulGU_Shedule/releases');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  void _debaunceSearch() {
    if (debounce?.isActive ?? false) debounce!.cancel();

    debounce = Timer(const Duration(milliseconds: 250), () {
      _onTextChanged();
    });
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

  Future<List<String>> _getSuggestion(String pattern) async {
    final decodedString = await fetchProfName(pattern);
    return getProfNamesList(decodedString);
  }

  Future<void> _debaunceProfScheduleSearch() async {
    if (debounce?.isActive ?? false) debounce!.cancel();
    debounce = Timer(const Duration(milliseconds: 250), () async {
      setState(() {
        tempString = _profController.text;
      });
    });
  }

  Future<void> loadGroup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final getGroup = prefs.getString('group_number');
    if (getGroup != null) {
      group = getGroup;
      searchController.text = group!;
      data = getScheduleLocal(group!);
      data!.then((value) {
        if (mounted) {
          setState(() {
            _lastData = value;
            filteredData = filterToday(value);
          });
        }
      });
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

    setState(() => _refreshing = true);

    // final cachedDataFuture = getScheduleLocal(group!);
    // setState(() {
    //   data = cachedDataFuture;
    // });

    try {
      var schedule = await getScheduleOnline(group!);
      data = Future.value(schedule);
      await saveScheduleLocal(group!, schedule);
      setState(() {
        _offlineBanner = null;
        isOfflineBanner = false;
        _testSnack();
        _lastData = schedule; // <<< обновляем initialData
        data = getScheduleLocal(group!);
        // onlineData = schedule;
      });
    } catch (error) {
      // Если ошибка при обновлении расписания, просто используем локальные данные
      setState(() {
        _showOfflineBanner();
        isOfflineBanner = true;
        _testSnack();
        data = getScheduleLocal(group!);
      });
    } finally {
      setState(() => _refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _pages = [
      groupScheduleList(),
      profScheduleList(),
    ];

    List<PreferredSizeWidget> _appBars = [
      groupAppBar(),
      profAppBar(),
    ];

    switch (MyApp.of(context).themeMode) {
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

    ColorScheme barColorScheme = ColorScheme.fromSeed(
        seedColor: MyApp.of(context).themeColor,
        brightness: isDark ? Brightness.dark : Brightness.light);

    return Scaffold(
      appBar: _appBars[_selectedIndex],
      body: _pages[_selectedIndex],
      // bottomNavigationBar: _offlineBanner,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          // BottomNavigationBarItem(icon: Icon(Icons.event), label: "Моё расписание"),
          BottomNavigationBarItem(
              icon: Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                    decoration: BoxDecoration(
                      color: _selectedIndex == 0
                          ? barColorScheme.secondaryContainer
                          : null,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.event,
                    ),
                  ),
                  SizedBox(height: 2),
                  // Text("Моё расписание")
                ],
              ),
              label: "Моё расписание"),
          BottomNavigationBarItem(
              icon: Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                    decoration: BoxDecoration(
                      color: _selectedIndex == 1
                          ? barColorScheme.secondaryContainer
                          : null,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.person_search,
                    ),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  // Text("Преподаватели"),
                ],
              ),
              label: "Преподаватели"),
        ],
        // showSelectedLabels: false,
        // showUnselectedLabels: false,
        selectedFontSize: 14.0,
        unselectedFontSize: 14.0,
        enableFeedback: true,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        loadGroup();
      } else {
        data = null;
        profName = null;
        _profController.clear();
      }
    });
  }

  Map<String, List<Schedule>> filterToday(
      Map<String, List<Schedule>> unfilteredDate) {
    final today = DateTime.now();

    return Map.fromEntries(unfilteredDate.entries.where((element) =>
        today.isBefore(parseDate(element.key)) ||
        today.difference(parseDate(element.key)).inDays == 0));
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

                      MyApp.of(context).saveThemeSettings();
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

  PreferredSizeWidget groupAppBar() {
    return AppBar(
      // scrolledUnderElevation: 3,
      shadowColor: Theme.of(context).colorScheme.shadow,

      title: Row(
        children: [
          // const Text('Расписание'),
          // Padding(padding: EdgeInsets.all(10)),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor:
                    Theme.of(context).colorScheme.surfaceTint.withOpacity(0.1),
                border: const OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                ),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                hintText: "Найди нужные пары!",
              ),
              controller: _controller,
            ),
          ),
        ],
      ),
      bottom: _refreshing
          ? const PreferredSize(
              preferredSize: Size.fromHeight(2),
              child: LinearProgressIndicator())
          : null,
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
        // IconButton(
        //   onPressed: showSearchDialog,
        //   style: const ButtonStyle(),
        //   icon: const Icon(Icons.settings),
        // ),
        IconButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            );
            if (result != null && result is String) {
              setState(() {
                group = result;
                data = getScheduleLocal(group!);
                updateSchedule();
              });
            }
          },
          style: const ButtonStyle(),
          icon: const Icon(Icons.settings),
        ),
      ],
    );
  }

  Widget groupScheduleList() {
    return group == null
        ? const Center(child: Text('Введите группу'))
        : FutureBuilder<Map<String, List<Schedule>>>(
            initialData: _lastData,
            future: data,
            builder: (context, snapshot) {
              final map = snapshot.data;
              if (map == null) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return const Center(child: Text('No schedule available'));
              }

              if (_controller.text.isEmpty) {
                filteredData = filterToday(map);
              }

              // if (snapshot.connectionState == ConnectionState.waiting) {
              //   return const Center(child: CircularProgressIndicator());
              // } else if (snapshot.hasError) {
              //   return Center(child: Text('Error: ${snapshot.error}'));
              // } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              //   return const Center(child: Text('No schedule available'));
              // } else {
              //   // final sc = snapshot.data!;
              //   if (_controller.text.isEmpty) {
              //     filteredData = filterToday(snapshot.data!);
              //   }
              //
              final keys = filteredData!.keys.toList();

              return ListView.builder(
                itemCount: filteredData!.keys.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: buildDay(filteredData!, keys, index, isDark,
                        MyApp.of(context).themeColor),
                  );
                },
              );
              // }
            },
          );
  }

  Widget profScheduleList() {
    return profName == null
        ? const Center(child: Text('Введите имя преподавателя'))
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

                filteredData = filterToday(snapshot.data!);

                final keys = filteredData!.keys.toList();

                return ListView.builder(
                  itemCount: filteredData!.keys.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: buildProfDay(filteredData!, keys, index, isDark,
                          MyApp.of(context).themeColor),
                    );
                  },
                );
              }
            },
          );
  }

  PreferredSizeWidget profAppBar() {
    return AppBar(
      shadowColor: Theme.of(context).colorScheme.shadow,
      title: TypeAheadField<String>(
        controller: _profController,
        suggestionsCallback: (pattern) async {
          return await _getSuggestion(pattern);
        },
        itemBuilder: (context, suggestion) {
          return ListTile(
            title: Text(suggestion),
          );
        },
        onSelected: (suggestion) {
          _profController.text = suggestion;
          profName = suggestion;
          data = getProfScheduleOnline(suggestion);
        },
        builder: (context, controller, focusNode) {
          return TextField(
            controller: controller,
            focusNode: focusNode,
            decoration: InputDecoration(
              filled: true,
              fillColor:
                  Theme.of(context).colorScheme.surfaceTint.withOpacity(0.1),
              border: const OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.all(Radius.circular(25)),
              ),
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              hintText: "Вводи имя преподавателя",
            ),
          );
        },
      ),
    );
  }
}
