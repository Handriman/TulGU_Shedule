import 'package:flutter/material.dart';

import 'schedule_classes.dart';
import 'schedule_transform.dart';
import 'search_deligate.dart';
import 'date_work.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<Schedule> data;
  late String group;
  bool isDark = false;

  @override
  void initState() {
    super.initState();
    group = '121111';

    data = getScheduleLocal(group);
    updateSchedule();

  }

  Future<void> updateSchedule() async {
    var scheduleString = await fetch(group);
    saveScheduleLocally(scheduleString, group);
    setState(() {
      data = getScheduleLocal(group);
    });
  }

  List<ListTile> lesson(ClassSchedule day) {
    List<ListTile> result = [];
    for (var i = 0; i < day.classes.length; i++) {
      result.add(ListTile(
        title: Text('${day.classes[i].time} | ${day.classes[i].location}'),
        leading: Column(
          children: [
            Text(day.classes[i].subject),
            Text(day.classes[i].teacher),
            Text(day.classes[i].type),
          ],
        ),
      ));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(

      appBar: AppBar(
        title: const Text('Расписание'),
        actions: [
          FutureBuilder<Schedule>(
            future: data,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return IconButton(
                  icon: const Icon(Icons.error),
                  onPressed: () {
                    // Обработка ошибки
                  },
                );
              } else if (snapshot.hasData) {
                final currentDate = DateTime.now();
                final today = DateTime(currentDate.year, currentDate.month, currentDate.day);
                Schedule filteredSchedule = Schedule(
                  schedule: snapshot.data!.schedule
                      .where((classSchedule) => classSchedule.date.compareTo(today) >= 0)
                      .toList(),);
                return IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: ScheduleSearchDelegate(schedueles: filteredSchedule.schedule),
                    );
                  },
                );
              } else {
                return Container();
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<Schedule>(
          future: data,
          builder: (BuildContext context, AsyncSnapshot<Schedule> snapshot) {
            if (snapshot.hasData) {
              Schedule schedule = snapshot.data!;

              // Фильтрация по дате
              final currentDate = DateTime.now();
              final today = DateTime(currentDate.year, currentDate.month, currentDate.day);
              Schedule filteredSchedule = Schedule(
                schedule: snapshot.data!.schedule
                    .where((classSchedule) => classSchedule.date.compareTo(today) >= 0)
                    .toList(),);

              return ListView.builder(
                itemCount: filteredSchedule.schedule.length,
                itemBuilder: (context, index) {
                  ClassSchedule classSchedule = filteredSchedule.schedule[index];
                  return ListTile(
                    title: Text('(${weekIvenOdd(filteredSchedule.schedule[index].date)}) ${filteredSchedule.schedule[index].date.day}.${filteredSchedule.schedule[index].date.month} ${getWeekDayString(filteredSchedule.schedule[index].date)}'),
                    subtitle: Column(
                      children: classSchedule.classes.map((classDetail) {
                        ClassSchedule classSchedule = schedule.schedule[index];
                        return ListTile(
                          title: Text(
                              '${classDetail.time} | ${classDetail.location}'),
                          subtitle: Text(
                              '${classDetail.subject} - ${classDetail.type}\n${classDetail.teacher}'),
                        );
                      }).toList(),
                    ),
                  );
                },
              );
            } else {
              return const CircularProgressIndicator();
            }
          }),
    );
  }
}
