import 'package:flutter/material.dart';
import 'package:project_calender/models/event.dart';

Future<void> showEventDialog(
  BuildContext context, {
  DateTime? date,
  void Function()? onStartTimeTapped,
  void Function()? onEndTimeTapped,
  void Function(String)? onTitleChanged,
  void Function()? onSaved,
  TextEditingController? startTimeInput,
  TextEditingController? endTimeInput,
}) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      startTimeInput!.text = '';
      endTimeInput!.text = '';
      return AlertDialog(
        title: const Text('Create Event'),
        content: Column(
          children: [
            TextField(
              controller: startTimeInput,
              readOnly: true,
              decoration: const InputDecoration(label: Text('Start Time')),
              onTap: onStartTimeTapped,
            ),
            TextField(
              controller: endTimeInput,
              readOnly: true,
              decoration: const InputDecoration(label: Text('End Time')),
              onTap: onEndTimeTapped,
            ),
            TextFormField(
              onChanged: onTitleChanged,
              decoration: const InputDecoration(labelText: 'Event Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: onSaved,
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}

Future<void> showEventDetailsDialog(
  BuildContext context,
  Event event, {
  void Function()? onStartTimeTapped,
  void Function()? onEndTimeTapped,
  void Function(String)? onTitleChanged,
  void Function()? onSaved,
  TextEditingController? startTimeInput,
  TextEditingController? endTimeInput,
}) async {
  String editedStartTime = event.startTime;
  String editedEndTime = event.endTime;
  String editedDescription = event.description;

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Event Details'),
        content: Column(
          children: [
            InkWell(
              onTap: onStartTimeTapped,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Start Time',
                ),
                child: Text(editedStartTime),
              ),
            ),
            InkWell(
              onTap: onEndTimeTapped,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'End Time',
                ),
                child: Text(editedEndTime),
              ),
            ),
            TextFormField(
              onChanged: onTitleChanged,
              initialValue: editedDescription,
              decoration: const InputDecoration(labelText: 'Event Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: onSaved,
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}
