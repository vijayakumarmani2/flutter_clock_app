import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:sqflite/sqflite.dart';
// Import the sqflite_common_ffi package
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class Event {
  final int id;
  final String title;
  final String description;
  final DateTime date;

  Event(
      {required this.id,
      required this.title,
      required this.description,
      required this.date});
}

class CalendarApp extends StatefulWidget {
  @override
  _CalendarAppState createState() => _CalendarAppState();
}

class _CalendarAppState extends State<CalendarApp> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  //late Database _database;

  Map<DateTime, List<Event>> events = {};

  late Future<Database> _database; // Change the type to Future<Database>

  @override
  void initState() {
    super.initState();
    // Initialize sqflite_common_ffi
    sqfliteFfiInit();

    // Set the databaseFactory to use the FFI implementation
    databaseFactory = databaseFactoryFfi;
    _database = initializeDatabase(); // Store the future in _database
    loadEvents();
  }

  Future<Database> initializeDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = databasePath + 'events.db';

    final database =
        await openDatabase(path, version: 1, onCreate: (db, version) {
      db.execute('''
        CREATE TABLE events(
          id INTEGER PRIMARY KEY,
          title TEXT,
          description TEXT,
          date TEXT
        )
      ''');
    });

    return database; // Return the database as a Future
  }

  void loadEvents() async {
    final Database database =
        await _database; // Wait for the database to initialize
    final List<Map<String, dynamic>> maps = await database.query('events');

    for (var map in maps) {
      final event = Event(
        id: map['id'],
        title: map['title'],
        description: map['description'],
        date: DateTime.parse(map['date']),
      );
      events.update(
          event.date, (existingEvents) => (existingEvents)..add(event),
          ifAbsent: () => [event]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: TableCalendar(
                calendarFormat: _calendarFormat,
                focusedDay: _focusedDay,
                firstDay: DateTime(1990),
                lastDay: DateTime(2050),
                startingDayOfWeek: StartingDayOfWeek.sunday,
                daysOfWeekVisible: true,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                calendarStyle: const CalendarStyle(
                  isTodayHighlighted: true,
                  weekNumberTextStyle: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color.fromARGB(255, 165, 22, 108),
                    height: 1.3333333333333333,
                  ),
                  weekendTextStyle: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color.fromARGB(245, 252, 0, 0),
                    height: 1.3333333333333333,
                  ),
                  markersMaxCount: 20,
                  canMarkersOverflow: true,
                  selectedTextStyle: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color.fromARGB(255, 255, 255, 255),
                    height: 1.3333333333333333,
                  ),
                  outsideTextStyle: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color.fromARGB(190, 240, 102, 205),
                    height: 1.3333333333333333,
                  ),
                  todayTextStyle: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color.fromARGB(255, 253, 253, 253),
                  ),
                  // outsideWeekendStyle: TextStyle(
                  //   fontFamily: 'Montserrat',
                  //   fontWeight: FontWeight.w600,
                  //   fontSize: 12,
                  //   color: const Color(0xfff0efcd),
                  //   height: 1.3333333333333333,
                  // ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: true,
                  titleCentered: true,
                  formatButtonDecoration: BoxDecoration(
                    color: const Color.fromARGB(220, 59, 24, 11),
                    borderRadius: BorderRadius.circular(22.0),
                  ),
                  formatButtonTextStyle: const TextStyle(
                      color: Color.fromARGB(255, 146, 146, 146)),
                  formatButtonShowsNext: false,
                  titleTextStyle: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w200,
                      color: Color.fromARGB(236, 226, 16, 156)),
                  leftChevronIcon: const Icon(Icons.chevron_left,
                      color: Color.fromARGB(255, 27, 27, 27)),
                  rightChevronIcon: const Icon(Icons.chevron_right,
                      color: Color.fromARGB(255, 27, 27, 27)),
                ),
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarBuilders: CalendarBuilders(
                  selectedBuilder: (context, date, events) => Container(
                    margin: const EdgeInsets.all(10.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: const RadialGradient(
                        center: Alignment(-0.54, -1.0),
                        radius: 1.137,
                        colors: [
                          Color.fromARGB(213, 255, 176, 255),
                          Color.fromARGB(217, 205, 2, 144),
                        ],
                        stops: [0.0, 1.0],
                      ),
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: Text(
                      date.day.toString(),
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: const Color(0xff000000),
                      ),
                    ),
                  ),
                  todayBuilder: (context, date, events) => Container(
                    margin: const EdgeInsets.all(10.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        gradient: const RadialGradient(
                          center: Alignment(-0.54, -1.0),
                          radius: 1.137,
                          colors: [
                            Color.fromARGB(80, 255, 176, 255),
                            Color.fromARGB(80, 205, 2, 144),
                          ],
                          stops: [0.0, 1.0],
                        ),
                        borderRadius: BorderRadius.circular(30.0)),
                    child: Text(
                      date.day.toString(),
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: const Color(0xff000000),
                        height: 1.3333333333333333,
                      ),
                    ),
                  ),
                ),
                eventLoader: (date) => events[date] ?? [],
              ),
            ),
          ),
          Expanded(
            child: Container(
                width: 400,
                padding: const EdgeInsets.all(0),
                child:
                    EventList(selectedDay: _selectedDay, database: _database)),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEvent(
                database: _database,
                selectedDay: _selectedDay,
              ),
            ),
          ).then((value) {
            if (value == true) {
              loadEvents();
              setState(() {});
            }
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class EventList extends StatelessWidget {
  final DateTime selectedDay;
  final Future<Database> database;

  EventList({required this.selectedDay, required this.database});
  String getMonthName(DateTime selectedDate) {
    final DateFormat formatter = DateFormat.MMMM();
    return formatter.format(selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "${selectedDay.day}",
          style: TextStyle(
              fontSize: 30,
              color: Color.fromARGB(255, 255, 255, 255),
              fontWeight: FontWeight.bold),
        ),
        Text(
          '${getMonthName(selectedDay.toLocal())} ${selectedDay.year}',
          style: TextStyle(
              fontSize: 30,
              color: Color.fromARGB(255, 27, 27, 27),
              fontWeight: FontWeight.normal),
        ),
        Divider(
          color: Color.fromARGB(147, 55, 55, 56),
        ),
        FutureBuilder<Database>(
          future: database,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData) {
                return Text('No data available.');
              } else {
                return _buildEventList(selectedDay, snapshot.data!);
              }
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ],
    );
  }

  Widget _buildEventList(DateTime selectedDay, Database database) {
    return FutureBuilder<List<Event>>(
      future: _loadEventsForDay(selectedDay, database),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('No events for this day.');
        } else {
          final events = snapshot.data!;
          return Column(
            children: events.map((event) {
              return ListTile(
                title: Text(event.title),
                subtitle: Text(event.description),
              );
            }).toList(),
          );
        }
      },
    );
  }

  Future<List<Event>> _loadEventsForDay(DateTime day, Database database) async {
    final List<Map<String, dynamic>> eventMaps = await database.query(
      'events',
      where: 'date = ?',
      whereArgs: [day.toUtc().toIso8601String()],
    );

    final events = eventMaps.map((eventMap) {
      return Event(
        id: eventMap['id'] as int,
        title: eventMap['title'] as String,
        description: eventMap['description'] as String,
        date: DateTime.parse(eventMap['date'] as String),
      );
    }).toList();

    return events;
  }
}

class AddEvent extends StatefulWidget {
  final Future<Database> database;
  final DateTime selectedDay;

  AddEvent({required this.database, required this.selectedDay});

  @override
  _AddEventState createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Event'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(labelText: 'Event Title'),
          ),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(labelText: 'Event Description'),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = _titleController.text;
              final description = _descriptionController.text;
              final date =
                  widget.selectedDay; // Set the date to the selected day

              final database =
                  await widget.database; // Await the database future

              final id = await database.insert('events', {
                'title': title,
                'description': description,
                'date': date.toUtc().toIso8601String(),
              });

              if (id > 0) {
                Navigator.pop(context, true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Failed to add the event.'),
                ));
              }
            },
            child: Text('Add Event'),
          ),
        ],
      ),
    );
  }
}
