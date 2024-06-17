import 'package:flutter/material.dart';
import 'package:schedule_v2/schedule_classes.dart';

class ScheduleSearchDelegate extends SearchDelegate<ClassDetail> {
  final List<ClassSchedule> schedueles;

  ScheduleSearchDelegate({
    required this.schedueles,
  });

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(
            context,
            ClassDetail(
                time: 'time',
                subject: 'subject',
                type: 'type',
                location: 'location',
                teacher: 'teacher'));
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = schedueles
        .expand((schedule) => schedule.classes
            .map((classDetail) => MapEntry(schedule.date, classDetail)))
        .where((entry) =>
            entry.value.time.contains(query) ||
            entry.value.subject.toLowerCase().contains(query.toLowerCase()) ||
            entry.value.type.toLowerCase().contains(query.toLowerCase()) ||
            entry.value.location.toLowerCase().contains(query.toLowerCase()) ||
            entry.value.teacher.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(results[index].value.subject),
          subtitle: Text(
              '${results[index].value.time} - ${results[index].value.location}\nДата: ${results[index].key}\n${results[index].value.teacher}'),
          onTap: () {
            close(context, results[index].value);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = schedueles
        .expand((schedule) => schedule.classes
            .map((classDetail) => MapEntry(schedule.date, classDetail)))
        .where((entry) =>
            entry.value.time.contains(query) ||
            entry.value.subject.toLowerCase().contains(query.toLowerCase()) ||
            entry.value.type.toLowerCase().contains(query.toLowerCase()) ||
            entry.value.location.toLowerCase().contains(query.toLowerCase()) ||
            entry.value.teacher.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestions[index].value.subject),
          subtitle: Text(
              '${suggestions[index].value.time} - ${suggestions[index].value.location}\nДата: ${suggestions[index].key}\n${suggestions[index].value.teacher}'),
          onTap: () {
            if(suggestions[index].value.subject.toLowerCase().contains(query.toLowerCase())) { query = suggestions[index].value.subject; }
            else if(suggestions[index].value.teacher.toLowerCase().contains(query.toLowerCase())) { query = suggestions[index].value.teacher; }
            else {query = suggestions[index].value.subject;}

            showResults(context);
          },
        );
      },
    );
  }
}
