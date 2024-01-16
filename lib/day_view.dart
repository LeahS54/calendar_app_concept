import 'package:flutter/material.dart';

class DayViewScreen extends StatefulWidget {
  const DayViewScreen({super.key});

  @override
  _DayViewScreenState createState() => _DayViewScreenState();
}

class _DayViewScreenState extends State<DayViewScreen> {
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
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.blue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Today',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            '${_getWeekdayName(_selectedDate.weekday - 1)}, ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
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
              Expanded(
                child: InkWell(
                  onTap: () => _onGridCellTap(hour),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.white,
                    child: _buildEventDetails(hour),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildEventDetails(int hour) {
    DateTime dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      hour,
    );

    List<Widget> eventWidgets = [];
    List<DayWeekEvent> events = _events[dateTime] ?? [];
    for (DayWeekEvent event in events) {
      if (event.startTime.hour <= hour && hour < event.endTime.hour) {
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    'Time: ${event.startTime.hour}:00 - ${event.endTime.hour}:00',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
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

  void _onEventTap(DayWeekEvent event) {
    showDialog(
      context: context,
      builder: (context) {
        DateTime newStartTime = event.startTime;

        return AlertDialog(
          title: const Text('Edit Event'),
          content: Column(
            children: [
              TextFormField(
                initialValue: event.title,
                decoration: const InputDecoration(labelText: 'Event Title'),
                onChanged: (value) {
                  event.title = value;
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Start Time:'),
                  InkWell(
                    onTap: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(event.startTime),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          newStartTime = DateTime(
                            event.startTime.year,
                            event.startTime.month,
                            event.startTime.day,
                            pickedTime.hour,
                          );
                        });
                      }
                    },
                    child: Text('${newStartTime.hour}:00'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (event.title.isNotEmpty) {
                    setState(() {
                      _editEvent(event, event.title, newStartTime,
                          newStartTime.add(const Duration(hours: 1)));
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

  void _onGridCellTap(int hour) {
    DateTime dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      hour,
    );

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

  void _addEvent(DateTime dateTime, String title) {
    DateTime startDateTime = dateTime;
    DateTime endDateTime = dateTime.add(const Duration(hours: 1));

    if (_events.containsKey(dateTime)) {
      _events[dateTime]!.add(DayWeekEvent(title, startDateTime, endDateTime));
    } else {
      _events[dateTime] = [DayWeekEvent(title, startDateTime, endDateTime)];
    }
  }

  void _editEvent(
      DayWeekEvent event, String title, DateTime startTime, DateTime endTime) {
    event.title = title;
    event.startTime = startTime;
    event.endTime = endTime;
  }

  String _getWeekdayName(int day) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[day];
  }
}

class DayWeekEvent {
  String title;
  DateTime startTime;
  DateTime endTime;

  DayWeekEvent(this.title, this.startTime, this.endTime);
}
