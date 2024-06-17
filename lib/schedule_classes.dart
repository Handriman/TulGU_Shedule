// Класс для одного занятия
class ClassDetail {
  final String time;
  final String subject;
  final String type;
  final String location;
  final String teacher;

  ClassDetail({
    required this.time,
    required this.subject,
    required this.type,
    required this.location,
    required this.teacher,
  });

  factory ClassDetail.fromJson(Map<String, dynamic> json) {
    return ClassDetail(
        time: json['time'],
        subject: json['subject'],
        type: json['type'],
        location: json['location'],
        teacher: json['teacher']);
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'subject': subject,
      'type': type,
      'location': location,
      'teacher': teacher
    };
  }
}

// Класс расписания на один день
class ClassSchedule {
  final DateTime date;
  final List<ClassDetail> classes;

  ClassSchedule({
    required this.date,
    required this.classes,
  });

  factory ClassSchedule.fromJson(Map<String, dynamic> json) {
    var classList = json['classes'] as List;
    List<ClassDetail> classItems =
        classList.map((i) => ClassDetail.fromJson(i)).toList();
    var dat = DateTime.parse(json['date']);
    return ClassSchedule(date: DateTime(dat.year, dat.month, dat.day), classes: classItems);
  }

  Map<String, dynamic> toJson() {
    return {
      'date': '$date',
      'classes': classes.map((e) => e.toJson()).toList(),
    };
  }
}

// Класс для полного расписания
class Schedule {
  final List<ClassSchedule> schedule;

  Schedule({
    required this.schedule,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    var scheduleList = json['schedule'] as List;
    List<ClassSchedule> scheduleItems =
        scheduleList.map((e) => ClassSchedule.fromJson(e)).toList();

    return Schedule(schedule: scheduleItems);
  }

  Map<String, dynamic> toJson() {
    return {
      'schedule': schedule.map((e) => e.toJson()).toList(),
    };
  }
}
