
class Schedule {
  String date;
  String time;
  String discipline;
  String kow;
  String aud;
  String? prep;
  List<Map<String, String>> groups;
  String classType;

  Schedule({
    required this.date,
    required this.time,
    required this.discipline,
    required this.kow,
    required this.aud,
    this.prep,
    required this.groups,
    required this.classType,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      date: json['DATE_Z'],
      time: json['TIME_Z'],
      discipline: json['DISCIP'],
      kow: json['KOW'],
      aud: json['AUD'],
      prep: json['PREP'],
      groups: List<Map<String, String>>.from(json['GROUPS'].map((group) => Map<String, String>.from(group))),
      classType: json['CLASS'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'DATE_Z': date,
      'TIME_Z': time,
      'DISCIP': discipline,
      'KOW': kow,
      'AUD': aud,
      'PREP': prep,
      'GROUPS': groups,
      'CLASS': classType,
    };
  }
}
