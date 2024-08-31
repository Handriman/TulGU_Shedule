import 'package:flutter/material.dart';
import 'package:schedule_v2/fetch.dart';
import 'classes.dart';

final week = {
  1: "понедельник",
  2: "вторник",
  3: "среда",
  4: "четверг",
  5: "пятница",
  6: "суббота",
  7: "воскресенье",
};


final lightColors = {

  "Практические занятия": Colors.lightGreen.shade100,
  "Практические занятия по иностранному языку (английский)": Colors.lightGreen.shade100,
  "Практические занятия по иностранному языку (французский)": Colors.lightGreen.shade100,
  "Практические занятия по иностранному языку (немецкий)": Colors.lightGreen.shade100,
  "Практ. клинические (14 чел)": Colors.lightGreen.shade100,
  "Практ. клинические": Colors.lightGreen.shade100,
  "Лаб.  занятия - 17": Colors.orange.shade100,
  "Лаб.  занятия - 14": Colors.orange.shade100,
  "Лабораторные работы": Colors.orange.shade100,
  "Лаборат. занятия Лечебного факультета":Colors.orange.shade100,
  "Лекционные занятия": Colors.lightBlue.shade100,
  "Лекции 170 чел": Colors.lightBlue.shade100,
  "Практика": Colors.red.shade100,
  "зч": Colors.red.shade100,
  "ДЗ по практике": Colors.red.shade100,
  "ДЗ": Colors.red.shade100,
  "Экзамен": Colors.red.shade100,
  "КР": Colors.red.shade100,
  "КП": Colors.red.shade100,
  "Консультации": Colors.red.shade100,

};

final darkColors = {
  "Практические занятия": Color(0xFF4C5E4C),
  "Практические занятия по иностранному языку (английский)": Color(0xFF4C5E4C),
  "Практические занятия по иностранному языку (французский)": Color(0xFF4C5E4C),
  "Практические занятия по иностранному языку (немецкий)": Color(0xFF4C5E4C),
  "Практ. клинические (14 чел)": Color(0xFF4C5E4C),
  "Практ. клинические": Color(0xFF4C5E4C),
  "Лаб.  занятия - 17": Color(0xFF6E5643),
  "Лаб.  занятия - 14": Color(0xFF6E5643),
  "Лабораторные работы": Color(0xFF6E5643),
  "Лаборат. занятия Лечебного факультета":Color(0xFF6E5643),
  "Лекционные занятия": Color(0xFF3C5675),
  "Лекции 170 чел": Color(0xFF3C5675),
  "Практика": Color(0xFF752F2F),
  "зч":  Color(0xFF752F2F),
  "ДЗ по практике":  Color(0xFF752F2F),
  "ДЗ":  Color(0xFF752F2F),
  "Экзамен":  Color(0xFF752F2F),
  "КР":  Color(0xFF752F2F),
  "КП":  Color(0xFF752F2F),
  "Консультации":Color(0xFF752F2F),
};


Color? colorize(String type, bool isDark) {

  if(isDark){
    return darkColors[type];
  } else {
    return lightColors[type];
  }



}




List<Widget> buildDay(Map<String, List<Schedule>> schedule, List<String> keys, int index, bool isDark, Color color){

  List<Widget> output = [];
  final ls = schedule[keys[index]];
  output.add(buildDate(keys, index, isDark, color));
  for (var les in ls!) {
    output.add(lesson(les, isDark));
  }


  return output;


}



Widget lesson(Schedule schedule, bool isDark) {


  // final detail = "${schedule.discipline}\n${schedule.kow}\n${schedule.prep ?? "Неизвестно"}";

  final detail = "${schedule.discipline}\n${schedule.kow}\n${schedule.prep ?? "Неизвестно"}";
  final color = colorize(schedule.kow, isDark); // Оптимизация: сохранение цвета в переменную

  // return ListTile(
  //
  //   title: Container(
  //     padding: const EdgeInsets.only(left: 10, top: 10, right: 10),
  //     decoration:  BoxDecoration(
  //       color: colorize(schedule.kow, isDark),
  //       borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
  //     ),
  //
  //     child: Text("${schedule.time} | ${schedule.aud}"),
  //   ),
  //   subtitle: Container(
  //     padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
  //     decoration:  BoxDecoration(
  //       color: colorize(schedule.kow, isDark),
  //       borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))
  //     ),
  //     child: Text(detail),
  //   ),
  // );

  return ListTile(
    title: DecoratedBox( // Используем DecoratedBox вместо Container
      decoration: BoxDecoration(

        color: color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding( // Добавляем Padding для отступов
        padding: const EdgeInsets.only(left: 10, top: 10, right: 10),
        child: Text("${schedule.time} | ${schedule.aud}"),
      ),
    ),
    subtitle: DecoratedBox(
      decoration: BoxDecoration(

        color: color,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
        child: Text(detail),
      ),
    ),
  );

}




bool isWeekEven(DateTime date) {
  // Создаем объект для первой недели года
  DateTime startOfYear = DateTime(date.year, 1, 1);

  // Находим первый понедельник года (можно настроить на любой день)
  while (startOfYear.weekday != DateTime.monday) {
    startOfYear = startOfYear.add(Duration(days: 1));
  }

  // Рассчитываем разницу в днях между началом года и текущей датой
  int differenceInDays = date.difference(startOfYear).inDays;

  // Номер недели с учетом того, что неделя начинается с понедельника
  int weekNumber = (differenceInDays / 7).ceil();

  // Проверяем, является ли номер недели четным
  return weekNumber % 2 == 0;
}

String getNiceDate(String sdate){
  // final s = sdate.split('.');
  DateTime date = parseDate(sdate);
  if(isWeekEven(date)){
    return "(чт) ${sdate.substring(0,6)} ${week[date.weekday]}";
  } else {
    return "(нч) ${sdate.substring(0,6)} ${week[date.weekday]}";
  }


}



Widget buildDate(List<String> keys, int index, bool isDark, Color color){



  // Оптимизация: сохранение схемы цветов в переменной
  final colorScheme = ColorScheme.fromSeed(
    brightness: isDark ? Brightness.dark : Brightness.light,
    seedColor: color,
  );

  // Оптимизация: вычисление цвета с учетом прозрачности
  final backgroundColor = isDark
      ? colorScheme.primary.withAlpha(50)
      : colorScheme.primary.withAlpha(30);

  return ListTile(
    title: DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(20)), // Сделали const
      ),
      child: Padding(
        padding: const EdgeInsets.all(5), // Используем Padding вместо Container
        child: Center(
          child: Text(getNiceDate(keys[index])),
        ),
      ),
    ),
  );


  // final colorScheme = ColorScheme.fromSeed(brightness: isDark ? Brightness.dark : Brightness.light, seedColor: color);
  // return ListTile(
  //
  //   title: Container(
  //     padding: EdgeInsets.all(5),
  //     decoration: BoxDecoration(
  //       color: isDark ? colorScheme.primary.withAlpha(50) : colorScheme.primary.withAlpha(30),
  //       borderRadius: BorderRadius.all(Radius.circular(20)),
  //     ),
  //     child: Center(
  //       child: Text(getNiceDate(keys[index])),
  //     ),
  //   ),
  // );




}