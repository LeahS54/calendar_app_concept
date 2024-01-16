import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:project_calender/day_view.dart';
import 'package:project_calender/models/event.dart';
import 'package:project_calender/week_view.dart';

enum FilterType { Day, Week, Month }

class MyCalendar extends StatefulWidget {
  const MyCalendar({super.key});

  @override
  _MyCalendarState createState() => _MyCalendarState();
}

class _MyCalendarState extends State<MyCalendar> {
  DateTime _selectedDate = DateTime.now();
  final Map<DateTime, List<Event>> _events = {};
  FilterType _selectedFilter = FilterType.Month;
  List<String> daysValue = ['Mon', 'Tue', 'Wed', 'Thur', 'Fri', 'Sat', 'Sun'];
  TextEditingController startTimeInput = TextEditingController();
  TextEditingController endTimeInput = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Calendar'),
        actions: [
          _buildFilterDropdown(),
        ],
      ),
      body: _selectedFilter == FilterType.Month
          ? Column(
              children: [_buildHeader(), _buildDaysValue(), _buildMonthView()],
            )
          : _selectedFilter == FilterType.Day
              ? const DayViewScreen()
              : _selectedFilter == FilterType.Week
                  ? const WeekViewScreen()
                  : const SizedBox(),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            setState(() {
              _selectedDate = _selectedDate.subtract(_getDurationForFilter());
            });
          },
        ),
        Text(
          _getMonthYearString(),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            setState(() {
              _selectedDate = _selectedDate.add(_getDurationForFilter());
            });
          },
        ),
      ],
    );
  }

  Widget _buildFilterDropdown() {
    return DropdownButton<FilterType>(
      value: _selectedFilter,
      onChanged: (FilterType? newValue) {
        setState(() {
          _selectedFilter = newValue!;
        });
      },
      items: FilterType.values
          .map<DropdownMenuItem<FilterType>>((FilterType value) {
        return DropdownMenuItem<FilterType>(
          value: value,
          child: Text(_getFilterText(value)),
        );
      }).toList(),
    );
  }

  Widget _buildDaysValue() {
    int columns = 7;

    return SizedBox(
      height: 30,
      child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
          ),
          itemBuilder: (context, index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  daysValue[index],
                  style: const TextStyle(
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            );
          },
          itemCount: columns),
    );
  }

  Widget _buildMonthView() {
    int columns = 7;

    return Expanded(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
        ),
        itemBuilder: (context, index) {
          final day = _selectedDate
              .subtract(Duration(days: _selectedDate.weekday - 1))
              .add(Duration(days: index));

          return InkWell(
            onTap: () => _showEventDialog(context, date: day),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    day.day.toString(),
                    style: TextStyle(
                      fontWeight: day.month == _selectedDate.month
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  if (_events.containsKey(day) && _events[day]!.isNotEmpty)
                    Expanded(
                      child: ListView(
                        children: _events[day]!.map((event) {
                          return _buildEventButton(event);
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
        itemCount: columns * 6,
      ),
    );
  }

  Widget _buildEventButton(Event event) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: kIsWeb
          ? ElevatedButton(
              onPressed: () {
                _showEventDetailsDialog(context, event);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
              ),
              child: Column(
                children: [
                  Text(
                    event.description,
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  Text(
                    "${event.startTime} - ${event.endTime} ",
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ],
              ),
            )
          : InkWell(
              onTap: () {
                _showEventDetailsDialog(context, event);
              },
              child: Container(
                width: 50,
                color: Colors.blue,
                child: Column(
                  children: [
                    Text(
                      event.description,
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  String _getMonthYearString() {
    return '${_selectedDate.month}/${_selectedDate.year}';
  }

  Future<void> _showEventDialog(BuildContext context, {DateTime? date}) async {
    String selectedStartTime = '';
    String selectedEndTime = '';

    String description = '';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        startTimeInput.text = '';
        endTimeInput.text = '';
        return AlertDialog(
          title: const Text('Create Event'),
          content: Column(
            children: [
              TextField(
                controller: startTimeInput,
                readOnly: true,
                decoration: const InputDecoration(label: Text('Start Time')),
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    initialTime: TimeOfDay.now(),
                    context: context,
                  );

                  if (pickedTime != null) {
                    print(pickedTime.format(context));
                    selectedStartTime = pickedTime.format(context);

                    setState(() {
                      startTimeInput.text = selectedStartTime;
                    });
                  } else {
                    print("Time is not selected");
                  }
                },
              ),
              TextField(
                controller: endTimeInput,
                readOnly: true,
                decoration: const InputDecoration(label: Text('End Time')),
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    initialTime: TimeOfDay.now(),
                    context: context,
                  );

                  if (pickedTime != null) {
                    print(pickedTime.format(context));
                    selectedEndTime = pickedTime.format(context);

                    setState(() {
                      endTimeInput.text = selectedEndTime;
                    });
                  } else {
                    print("Time is not selected");
                  }
                },
              ),
              TextFormField(
                onChanged: (value) {
                  setState(() {
                    description = value;
                  });
                },
                decoration:
                    const InputDecoration(labelText: 'Event Description'),
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
              onPressed: () {
                if (date != null) {
                  setState(() {
                    _events.update(
                      date,
                      (value) => [
                        ...value,
                        Event(
                            startTime: selectedStartTime,
                            endTime: selectedEndTime,
                            description: description,
                            originalDate: date)
                      ],
                      ifAbsent: () => [
                        Event(
                            startTime: selectedStartTime,
                            endTime: selectedEndTime,
                            description: description,
                            originalDate: date)
                      ],
                    );
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEventDetailsDialog(
      BuildContext context, Event event) async {
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
                onTap: () async {
                  TimeOfDay? selectedStartTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(
                      hour: int.parse(editedStartTime.split(':')[0]),
                      minute: int.parse(editedStartTime.split(':')[1]),
                    ),
                  );

                  if (selectedStartTime != null) {
                    setState(() {
                      editedStartTime =
                          '${selectedStartTime.hour}:${selectedStartTime.minute}';
                    });
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Start Time',
                  ),
                  child: Text(editedStartTime),
                ),
              ),
              InkWell(
                onTap: () async {
                  TimeOfDay? selectedEndTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(
                      hour: int.parse(editedEndTime.split(':')[0]),
                      minute: int.parse(editedEndTime.split(':')[1]),
                    ),
                  );

                  if (selectedEndTime != null) {
                    setState(() {
                      editedEndTime =
                          '${selectedEndTime.hour}:${selectedEndTime.minute}';
                    });
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'End Time',
                  ),
                  child: Text(editedEndTime),
                ),
              ),
              TextFormField(
                onChanged: (value) {
                  setState(() {
                    editedDescription = value;
                  });
                },
                initialValue: editedDescription,
                decoration:
                    const InputDecoration(labelText: 'Event Description'),
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
              onPressed: () {
                setState(() {
                  event.startTime = editedStartTime;
                  event.endTime = editedEndTime;
                  event.description = editedDescription;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  String _getFilterText(FilterType filter) {
    switch (filter) {
      case FilterType.Day:
        return 'Day';
      case FilterType.Week:
        return 'Week';
      case FilterType.Month:
        return 'Month';
    }
  }

  Duration _getDurationForFilter() {
    return Duration(
        days: DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day);
  }
}
