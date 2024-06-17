import 'dart:convert';

import 'schedule_classes.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<String> fetch(String group) async {
  final data = {'search_field': 'GROUP_P', 'search_value': group};

  final response = await http
      .get(Uri.parse('http://handri.pythonanywhere.com/get_data/$group'));


  final response1 = await http.post(
    Uri.parse('https://tulsu.ru/schedule/queries/GetSchedule.php'),
    body: data,

  );

  print(response1.body);

  if (response.statusCode == 200) {
    return response.body;
  } else {
    throw Exception('Failed to load schedule');
  }
}

Future<void> saveScheduleLocally(String scheduleString, String group) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(group, scheduleString);
  } catch (e) {
    print('Загрузить в локальное хранилище не получилось');
  }
}

Future<Map<String, dynamic>> loadScheduleLocally(String group) async {
  // получаем экземпляр SP

  final prefs = await SharedPreferences.getInstance();
  // загружаем локальное расписание

  final String? scheduleString = prefs.getString(group);
  // проверяем, есть ли локальное расписание

  if (scheduleString != null) {
    return jsonDecode(scheduleString);
  } else {
    throw Exception('No local schedule found');
  }
}

Future<Schedule> getScheduleLocal(group) async {
  try {
    var scheduleMap = await loadScheduleLocally(group);

    final Schedule test = Schedule.fromJson(scheduleMap);

    return test;
  } catch (e) {
    var scheduleString = await fetch(group);
    saveScheduleLocally(scheduleString, group);
    var scheduleMap = await loadScheduleLocally(group);
    return Schedule.fromJson(scheduleMap);
  }
}

Future<Schedule> getSchedule(String group) async {
  final jsonString = await fetch(group);

  // Декодируем JSON строку в Map
  Map<String, dynamic> jsonMap = jsonDecode(jsonString);

  // Преобразуем Map в объект Schedule
  return Schedule.fromJson(jsonMap);
}
