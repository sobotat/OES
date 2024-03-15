
import 'package:flutter/material.dart';
import 'package:oes/ui/assets/templates/IconItem.dart';

class DateTimeItem extends StatelessWidget {
  const DateTimeItem({
    required this.icon,
    required this.text,
    required this.datetime,
    required this.onDateTimeChanged,
    super.key
  });

  final IconData icon;
  final String text;
  final DateTime datetime;
  final Function(DateTime datetime) onDateTimeChanged;

  Future<DateTime?> pickDateTime(DateTime dateTime, BuildContext context) async {
    DateTime? date = await showDialog(context: context, builder: (context) => DatePickerDialog(
      firstDate: DateTime.utc(2000),
      lastDate: DateTime.utc(3000),
      initialDate: dateTime,));
    if (date == null) return null;
    if (!context.mounted) return null;

    TimeOfDay? time = await showDialog(context: context, builder: (context) => TimePickerDialog(
      initialTime: TimeOfDay.fromDateTime(dateTime),));
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  String formatDateTime(DateTime dateTime) {
    return "${dateTime.day}.${dateTime.month}.${dateTime.year} ${dateTime.hour}:${dateTime.minute < 10 ? "0" : ""}${dateTime.minute}";
  }

  @override
  Widget build(BuildContext context) {
    return IconItem(
      icon: Icon(icon),
      body: Row(
        children: [
          Text("$text: ".padRight(22), style: const TextStyle(fontWeight: FontWeight.bold),),
          Text(formatDateTime(datetime)),
        ],
      ),
      onClick: (context) {
        pickDateTime(datetime, context).then((value) {
          if (value == null) return;
          onDateTimeChanged(value);
        });
      },
    );
  }
}
