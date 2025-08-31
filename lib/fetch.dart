import 'dart:convert';
import 'classes.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<String> fetchString(String group, ) async {
  final url = Uri.parse('https://tulsu.ru/schedule/queries/GetSchedule.php');
  String type = '';
  // if (group.contains('-')) { type = 'AUD'; } else { type = 'GROUP_P'; }
  type = 'GROUP_P';
  final Map<String, String> requestBody = {
    'search_field': type,
    'search_value': group,
  };
  http.Response response = await http.post(url, body: requestBody);
  if (response.statusCode == 200) {
    String decodedString = utf8.decode(response.bodyBytes);

    return decodedString;
  } else {

    return '{}';
  }
}

Future<String> fetchProfString(String fullProfNa) async {
  final url = Uri.parse('https://tulsu.ru/schedule/queries/GetSchedule.php');
  String type = '';
  // if (group.contains('-')) { type = 'AUD'; } else { type = 'GROUP_P'; }
  type = 'PREP';
  final Map<String, String> requestBody = {
    'search_field': type,
    'search_value': fullProfNa,
  };
  http.Response response = await http.post(url, body: requestBody);
  if (response.statusCode == 200) {
    String decodedString = utf8.decode(response.bodyBytes);

    return decodedString;
  } else {
    https://tulsu.ru/schedule/queries/GetSchedule.php?search_field=PREP&search_value=%D0%9C%D0%B0%D1%82%D0%B2%D0%B5%D0%B5%D0%B2%20%D0%90%D0%BB%D0%B5%D0%BA%D1%81%D0%B0%D0%BD%D0%B4%D1%80%20%D0%92%D0%B0%D1%81%D0%B8%D0%BB%D1%8C%D0%B5%D0%B2%D0%B8%D1%87
    return '{}';
  }
}

Future<String> fetchProfName(String uncompleteProfName) async {
  final url = Uri.parse("https://tulsu.ru/schedule/queries/GetDictionaries.php?term=$uncompleteProfName");
  http.Response response = await http.get(url);
  if(response.statusCode == 200) {
    String decodedString = utf8.decode(response.bodyBytes);
    return decodedString;
  } else {
    return '{}';
  }

}

List<String> getProfNamesList(String decodedString) {
  List<dynamic> namesList = jsonDecode(decodedString);
  return namesList.map((e) => e['value'] as String).toList();
}


Map<String, List<Schedule>> getSortedMap(String unsortedString) {
  // Шаг 1: Распарсить JSON строку
  List<dynamic> scheduleList = jsonDecode(unsortedString);

  // Шаг 2: Преобразовать JSON данные в список Schedule
  List<Schedule> schedules = scheduleList.map((item) => Schedule.fromJson(item)).toList();

  // Шаг 3: Сгруппировать по дате
  Map<String, List<Schedule>> scheduleMap = {};
  for (var schedule in schedules) {
    if (!scheduleMap.containsKey(schedule.date)) {
      scheduleMap[schedule.date] = [];
    }
    scheduleMap[schedule.date]!.add(schedule);
  }

  // Шаг 4: Найти минимальную и максимальную даты
  DateTime minDate = parseDate(schedules.first.date);
  DateTime maxDate = parseDate(schedules.first.date);
  for (var schedule in schedules) {
    DateTime date = parseDate(schedule.date);
    if (date.isBefore(minDate)) minDate = date;
    if (date.isAfter(maxDate)) maxDate = date;
  }

  // Шаг 5: Добавить пустые даты в диапазоне от minDate до maxDate
  DateTime currentDate = minDate;
  while (currentDate.isBefore(maxDate.add(const Duration(days: 1)))) {
    String formattedDate = _formatDate(currentDate);
    if (!scheduleMap.containsKey(formattedDate)) {
      scheduleMap[formattedDate] = [];
    }
    currentDate = currentDate.add(const Duration(days: 1));
  }

  // Шаг 4: Отсортировать map по датам
  var sortedScheduleMap = Map.fromEntries(scheduleMap.entries.toList()
    ..sort((e1, e2) => parseDate(e1.key).compareTo(parseDate(e2.key))));

  return sortedScheduleMap;
}

String getSortedString(Map<String, List<Schedule>> sortedMap) {
  String sorted = jsonEncode(sortedMap.map((key, value) {
    return MapEntry(key, value.map((schedule) => schedule.toJson()).toList());
  }));
  return sorted;
}


String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
}

DateTime parseDate(String dateString) {
  List<String> parts = dateString.split('.');
  return DateTime(
    int.parse(parts[2]), // Год
    int.parse(parts[1]), // Месяц
    int.parse(parts[0]), // День
  );
}

Map<String, List<Schedule>> getMapFromString(String stringSchedule) {
  Map<String, dynamic> scheduleMap = jsonDecode(stringSchedule);
  Map<String, List<Schedule>> scheduleListMap = scheduleMap.map((key, value) {
    List<Schedule> schedules =
        List<Schedule>.from(value.map((item) => Schedule.fromJson(item)));
    return MapEntry(key, schedules);
  });
  return scheduleListMap;
}

Future<void> saveScheduleLocal(
    String group, Map<String, List<Schedule>> sortedListMap) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String sortedString = getSortedString(sortedListMap);
  prefs.setString(group, sortedString);
  // print(sortedString);
}

Future<Map<String, List<Schedule>>> getScheduleLocal(String group) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String? sortedString = prefs.getString(group);
  if (sortedString != null) {
    return getMapFromString(sortedString);
  } else {
    Map<String, List<Schedule>> sortedListMap = await getScheduleOnline(group);
    saveScheduleLocal(group, sortedListMap);
    String? sortedString = prefs.getString(group);
    return getMapFromString(sortedString!);
  }
}

Future<Map<String, List<Schedule>>> getScheduleOnline(String group) async{
  String unsortedString = await fetchString(group);
  return getSortedMap(unsortedString);
}

Future<Map<String, List<Schedule>>> getProfScheduleOnline(String profFullName) async{
  String unsortedString = await fetchProfString(profFullName);
  return getSortedMap(unsortedString);
}

// void updateSchedule(group) async{
//
//   String unsortedString = await fetchString(group);
//   Map<String, List<Schedule>> sortedListMap = getSortedMap(unsortedString);
//   saveScheduleLocal(group, sortedListMap);
//
// }