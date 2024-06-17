import 'package:intl/intl.dart';

String getWeekDayString(DateTime date) {
  var weekday = date.weekday;
  switch (weekday) {
    case 1: return 'пн';
    case 2: return 'вт';
    case 3: return 'ср';
    case 4: return 'чт';
    case 5: return 'пт';
    case 6: return 'сб';
    default: return 'вс';
  }
}

int numOfWeeks(int year) {
  DateTime dec28 = DateTime(year, 12, 28);
  int dayOfDec28 = int.parse(DateFormat("D").format(dec28));
  return ((dayOfDec28 - dec28.weekday + 10) / 7).floor();
}

/// Calculates week number from a date as per https://en.wikipedia.org/wiki/ISO_week_date#Calculation
String weekIvenOdd(DateTime date) {
  int dayOfYear = int.parse(DateFormat("D").format(date));
  int woy =  ((dayOfYear - date.weekday + 10) / 7).floor();
  if (woy < 1) {
    woy = numOfWeeks(date.year - 1);
  } else if (woy > numOfWeeks(date.year)) {
    woy = 1;
  }
  if(woy.isEven) { return 'чт'; } else { return 'нч'; }
}