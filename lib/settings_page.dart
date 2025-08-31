import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? group;
  final TextEditingController searchController = TextEditingController();

  ThemeMode themeMode = ThemeMode.system;
  Color tempColor = Colors.deepPurple;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      group = prefs.getString('group_number') ?? '';
      searchController.text = group ?? '';
      themeMode = MyApp.of(context).themeMode;
      tempColor = MyApp.of(context).themeColor;
    });
  }

  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('group_number', searchController.text);
    await MyApp.of(context).saveThemeSettings();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Настройки"),
      ),
      body: ListView(
        children: [

          // --- Группа ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.surfaceContainer,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0), bottomLeft: Radius.circular(5.0), bottomRight: Radius.circular(5.0)),
              ),
              child: ListTile(
                dense: false,
                leading: const Icon(Icons.group),
                title: const Text("Номер группы"),
                subtitle: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: TextField(

                    controller: searchController,
                    decoration:  InputDecoration(
                      hintText: "например: 70349аф",
                      border:  OutlineInputBorder(
                        borderSide: BorderSide(
                          color: scheme.error,

                        ),
                        borderRadius:  const BorderRadius.all(Radius.circular(25)),

                      ),
                      filled: true,
                      fillColor: scheme.surfaceContainerLow,
                      isDense: false,
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 10),

                    ),
                  ),
                ),
              ),
            ),
          ),
          // const Divider(),

          // --- Тема ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.surfaceContainer,
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: ListTile(
                leading: const Icon(Icons.brightness_6),
                title: const Text("Тема"),
                subtitle: Text(
                  themeMode == ThemeMode.system
                      ? "Системная"
                      : themeMode == ThemeMode.dark
                      ? "Тёмная"
                      : "Светлая",
                ),
                trailing: DropdownButton<ThemeMode>(
                  value: themeMode,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Row(
                        children: [
                          Icon(Icons.brightness_auto_outlined),
                          Text(" Системная"),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Row(
                        children: [
                          Icon(Icons.brightness_2_outlined),
                          Text(" Тёмная"),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Row(
                        children: [
                          Icon(Icons.brightness_7_rounded),
                          Text(" Светлая"),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (mode) {
                    if (mode != null) {
                      setState(() {
                        themeMode = mode;
                        MyApp.of(context).changeTheme(themeMode);
                        MyApp.of(context).saveThemeSettings();
                      });
                    }
                  },
                ),
              ),
            ),
          ),
          // const Divider(),

          // --- Цветовая схема ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.surfaceContainer,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(5.0), topRight: Radius.circular(5.0), bottomLeft: Radius.circular(20.0), bottomRight: Radius.circular(20.0)),
              ),
              child: ListTile(

                leading: const Icon(Icons.color_lens),
                title: const Text("Цвет приложения"),
                subtitle: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Wrap(
                    spacing: 8,
                    children: [
                      for (final color in [
                        Colors.deepPurple,
                        Colors.deepOrangeAccent,
                        Colors.yellow,
                        Colors.pink,
                        Colors.green,
                        Colors.blue
                      ])
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              tempColor = color;
                              MyApp.of(context).changeColor(tempColor);
                              MyApp.of(context).saveThemeSettings();
                            });
                          },
                          child: CircleAvatar(
                            backgroundColor: color,
                            radius: tempColor == color ? 18 : 14,
                            child: tempColor == color
                                ? const Icon(Icons.check, color: Colors.white, size: 18)
                                : null,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // const Divider(),

          // --- Кнопка сохранения ---
          Padding(
            padding: const EdgeInsets.all(20),
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: scheme.primary,
                minimumSize: const Size.fromHeight(56), // высокая, выразительная кнопка
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16), // мягкие углы
                ),
              ),
              onPressed: () {
                _saveSettings();
                Navigator.pop(context, searchController.text);
              },
              icon: const Icon(Icons.save),
              label: const Text("Сохранить изменения"),
            ),
          ),



        ],
      ),
    );
  }
}
