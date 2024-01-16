import 'package:flutter/material.dart';
import 'package:project_calender/day_view.dart';

class WeekViewScreen extends StatefulWidget {
  const WeekViewScreen({
    super.key,
  });

  @override
  _WeekViewScreenState createState() => _WeekViewScreenState();
}

class _WeekViewScreenState extends State<WeekViewScreen> {
  final DateTime _selectedDate = DateTime.now();
  final Map<DateTime, List<DayWeekEvent>> _events = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildCalendarHeader(),
          Expanded(
            child: _buildCalendarGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    List<Widget> dayHeaders = [
      const SizedBox(
        width: 60,
      )
    ];

    for (int i = 0; i < 7; i++) {
      DateTime currentDate =
          _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1 - i));
      dayHeaders.add(
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(8),
            color: currentDate.day == DateTime.now().day
                ? Colors.blue
                : Colors.grey[300],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getWeekdayName(currentDate.weekday - 1),
                  style: const TextStyle(fontSize: 12),
                ),
                Text('${currentDate.day}'),
              ],
            ),
          ),
        ),
      );
    }

    return Row(children: dayHeaders);
  }

  Widget _buildCalendarGrid() {
    return ListView(
      children: [
        for (int hour = 0; hour < 24; hour++)
          Row(
            children: [
              Container(
                width: 60,
                padding: const EdgeInsets.all(8),
                color: Colors.grey[300],
                child: Text('$hour:00'),
              ),
              for (int day = 0; day < 7; day++)
                Expanded(
                  child: InkWell(
                    onTap: () => _onGridCellTap(hour, day),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.white,
                      child: _buildEventDetails(hour, day),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildEventDetails(int hour, int day) {
    DateTime date = _selectedDate.add(Duration(days: day));
    DateTime dateTime = DateTime(date.year, date.month, date.day, hour);

    List<Widget> eventWidgets = [];
    List<DayWeekEvent> events = _events[dateTime] ?? [];
    for (DayWeekEvent event in events) {
      if (event.startTime.hour == hour) {
        eventWidgets.add(
          InkWell(
            onTap: () => _onEventTap(event),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.all(4),
              margin: const EdgeInsets.only(bottom: 4),
              child: Text(
                event.title,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: eventWidgets,
    );
  }

  void _onGridCellTap(int hour, int day) {
    DateTime date = _selectedDate.add(Duration(days: day));
    DateTime dateTime = DateTime(date.year, date.month, date.day, hour);

    showDialog(
      context: context,
      builder: (context) {
        String eventTitle = '';
        return AlertDialog(
          title: const Text('Create Event'),
          content: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Event Title'),
                onChanged: (value) {
                  eventTitle = value;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (eventTitle.isNotEmpty) {
                    setState(() {
                      _addEvent(dateTime, eventTitle);
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onEventTap(DayWeekEvent event) {
    showDialog(
      context: context,
      builder: (context) {
        String editedTitle = event.title;
        return AlertDialog(
          title: const Text('Edit Event'),
          content: Column(
            children: [
              TextFormField(
                initialValue: event.title,
                decoration: const InputDecoration(labelText: 'Event Title'),
                onChanged: (value) {
                  editedTitle = value;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (editedTitle.isNotEmpty) {
                    setState(() {
                      event.title = editedTitle;
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addEvent(DateTime dateTime, String title) {
    if (_events.containsKey(dateTime)) {
      _events[dateTime]!.add(DayWeekEvent(title, dateTime, dateTime));
    } else {
      _events[dateTime] = [DayWeekEvent(title, dateTime, dateTime)];
    }
  }

  String _getWeekdayName(int day) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[day];
  }
}

// class WeekEvent {
//   DateTime startTime;
//   String title;

//   WeekEvent(this.startTime, this.title);
// }
