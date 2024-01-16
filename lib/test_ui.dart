import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class Event {
  String title;
  DateTime startTime;
  DateTime endTime;
  String description;

  Event({
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.description,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CalendarApp(),
    );
  }
}

class CalendarApp extends StatefulWidget {
  const CalendarApp({super.key});

  @override
  _CalendarAppState createState() => _CalendarAppState();
}

class _CalendarAppState extends State<CalendarApp> {
  late DateTime selectedDate;
  late List<Event> events;
  late CalendarView currentView;
  TextEditingController eventTitleController = TextEditingController();
  TextEditingController eventDescriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    events = [
      Event(
        title: "Meeting",
        startTime: DateTime.now().add(const Duration(hours: 9)),
        endTime: DateTime.now().add(const Duration(hours: 10)),
        description: "Discuss project",
      ),
    ];
    currentView = CalendarView.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                setState(() {
                  selectedDate = currentView == CalendarView.month
                      ? DateTime(selectedDate.year, selectedDate.month - 1, 1)
                      : selectedDate = currentView == CalendarView.week
                          ? selectedDate.subtract(const Duration(days: 7))
                          : selectedDate.subtract(const Duration(days: 1));
                });
              },
            ),
            DropdownButton<CalendarView>(
              value: currentView,
              onChanged: (CalendarView? newValue) {
                setState(() {
                  currentView = newValue!;
                  if (currentView == CalendarView.month) {
                    selectedDate =
                        DateTime(selectedDate.year, selectedDate.month, 1);
                  }
                });
              },
              items: CalendarView.values
                  .map<DropdownMenuItem<CalendarView>>(
                    (CalendarView value) => DropdownMenuItem<CalendarView>(
                      value: value,
                      child: Text(value.toString().split('.').last),
                    ),
                  )
                  .toList(),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () {
                setState(() {
                  selectedDate = currentView == CalendarView.month
                      ? DateTime(selectedDate.year, selectedDate.month + 1, 1)
                      : selectedDate = currentView == CalendarView.week
                          ? selectedDate.add(const Duration(days: 7))
                          : selectedDate.add(const Duration(days: 1));
                });
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildCalendarHeader(),
          _buildCalendarView(),
        ],
      ),
      floatingActionButton: currentView == CalendarView.month
          ? null
          : FloatingActionButton(
              onPressed: () => _showEventDialog(context),
              child: const Icon(Icons.add),
            ),
    );
  }

  Widget _buildCalendarHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _getHeaderText(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _getHeaderText() {
    return "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";
  }

  Widget _buildCalendarView() {
    switch (currentView) {
      case CalendarView.day:
        return _buildDayView();
      case CalendarView.week:
        return _buildWeekView();
      case CalendarView.month:
        return _buildMonthView();
    }
  }

  Widget _buildDayView() {
    return Column(
      children: [
        const Text(
          'Day View',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        _buildEventsList(selectedDate),
      ],
    );
  }

  Widget _buildWeekView() {
    DateTime startDate =
        selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
    DateTime endDate = startDate.add(const Duration(days: 6));

    return Column(
      children: [
        const Text(
          'Week View',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        _buildWeekGrid(startDate, endDate),
        _buildEventsList(selectedDate),
      ],
    );
  }

  Widget _buildMonthView() {
    DateTime firstDayOfMonth =
        DateTime(selectedDate.year, selectedDate.month, 1);
    int daysInMonth =
        DateTime(selectedDate.year, selectedDate.month + 1, 0).day;

    return Column(
      children: [
        const Text(
          'Month View',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        _buildMonthGrid(firstDayOfMonth, daysInMonth),
      ],
    );
  }

  Widget _buildWeekGrid(DateTime startDate, DateTime endDate) {
    List<Widget> days = [];

    for (DateTime day = startDate;
        day.isBefore(endDate.add(const Duration(days: 1)));
        day = day.add(const Duration(days: 1))) {
      days.add(
        Expanded(
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
            ),
            child: Text('${day.day}'),
          ),
        ),
      );
    }

    return Row(
      children: days,
    );
  }

  Widget _buildMonthGrid(DateTime firstDayOfMonth, int daysInMonth) {
    List<Widget> weeks = [];
    int weekday = firstDayOfMonth.weekday;
    int currentDay = 1;

    while (currentDay <= daysInMonth) {
      List<Widget> days = [];
      for (int i = 1; i <= 7; i++) {
        if (currentDay <= daysInMonth && (i >= weekday || weeks.isNotEmpty)) {
          days.add(
            Expanded(
              child: SizedBox(
                height: 60,
                width: 80,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDate = DateTime(
                          selectedDate.year, selectedDate.month, currentDay);
                      _showEventDialog(context);
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Column(
                      children: [
                        Text('$currentDay'),
                        _buildEventsList(DateTime(
                            selectedDate.year, selectedDate.month, currentDay)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
          currentDay++;
        } else {
          days.add(
            Expanded(
              child: SizedBox(
                height: 60,
                width: 80,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: const Column(
                    children: [Text(' ')],
                  ),
                ),
              ),
            ),
          );
        }
      }

      weeks.add(
        Row(
          children: days,
        ),
      );
    }

    return Column(
      children: weeks,
    );
  }

  Widget _buildEventsList(DateTime date) {
    List<Event> dateEvents = events
        .where((event) =>
            event.startTime.year == date.year &&
            event.startTime.month == date.month &&
            event.startTime.day == date.day)
        .toList();

    return Column(
      children: dateEvents.map((event) {
        return GestureDetector(
          onTap: () {
            _showEventDialog(context, event: event);
          },
          child: Container(
            color: Colors.blue,
            child: Column(
              children: [
                Text(event.title),
                Text(
                    "${event.startTime.hour}:${event.startTime.minute} - ${event.endTime.hour}:${event.endTime.minute}"),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _showEventDialog(BuildContext context, {Event? event}) async {
    eventTitleController.text = event?.title ?? '';
    eventDescriptionController.text = event?.description ?? '';

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(event == null ? 'Create Event' : 'Edit Event'),
          content: Column(
            children: [
              TextField(
                controller: eventTitleController,
                decoration: const InputDecoration(labelText: 'Event Title'),
              ),
              TextField(
                controller: eventDescriptionController,
                decoration:
                    const InputDecoration(labelText: 'Event Description'),
              ),
              const SizedBox(height: 10),
              Text('Event Date: ${_getHeaderText()}'),
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
              onPressed: () {
                setState(() {
                  if (event == null) {
                    events.add(
                      Event(
                        title: eventTitleController.text,
                        startTime: selectedDate,
                        endTime: selectedDate.add(const Duration(hours: 1)),
                        description: eventDescriptionController.text,
                      ),
                    );
                  } else {
                    event.title = eventTitleController.text;
                    event.description = eventDescriptionController.text;
                  }
                });
                Navigator.of(context).pop();
              },
              child: Text(event == null ? 'Create' : 'Save'),
            ),
          ],
        );
      },
    );
  }
}

enum CalendarView {
  day,
  week,
  month,
}
