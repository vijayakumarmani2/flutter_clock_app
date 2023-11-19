import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_clock_app_1/data/theme_data.dart';
import 'package:intl/intl.dart';
import 'package:new_clock_app_1/tabs/alarm_page.dart';
import 'package:new_clock_app_1/tabs/calender.dart';
import 'package:new_clock_app_1/tabs/stop_watch.dart';
import 'package:new_clock_app_1/tabs/timer_screen.dart';
import 'package:sqflite/sqflite.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import 'clockview.dart';

class ClockPage extends StatefulWidget {
  @override
  _ClockPageState createState() => _ClockPageState();
}

class _ClockPageState extends State<ClockPage> {
  String selectedTimeZone1 = 'America/New_York';
  String selectedTimeZone2 = 'Europe/London';
  DateTime currentTime1 = DateTime.now();
  DateTime currentTime2 = DateTime.now();
  late Timer _timer;
  late Database database;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  //late Database _database;
  late Future<Database> _database;
  Map<DateTime, List<Event>> events = {};
  @override
  void initState() {
    super.initState();
    _database = initializeDatabase(); // Store the future in _database
    loadEvents();
    _openDatabase().then((db) {
      database = db;
      _loadSavedTimeZones();
    });
    // Define your holiday predicate to identify holidays
    bool isHoliday(DateTime day) {
      // Example: Mark December 25th as a holiday
      return day.month == 12 && day.day == 25;
    }

    // Update the times every second
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        currentTime1 = tz.TZDateTime.now(tz.getLocation(selectedTimeZone1));
        currentTime2 = tz.TZDateTime.now(tz.getLocation(selectedTimeZone2));
      });
    });
  }

  Future<void> fetchData_holidays() async {
    // Define your holiday predicate to identify holidays
    bool isHoliday(DateTime day) {
      // Example: Mark December 25th as a holiday
      return day.month == 12 && day.day == 25;
    }

    // Await the database future
    final Database database1 = await _database;
    final id = await database1.insert('events', {
      'title': "Holiday",
      'description': "Holiday",
      'date': DateTime(DateTime.now().year, 11, 12),
    });
  }

  Future<Database> initializeDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = databasePath + 'events.db';

    final database =
        await openDatabase(path, version: 1, onCreate: (db, version) {
      db.execute(
          '''
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

  Future<Database> _openDatabase() async {
    final database = await openDatabase(
      'timezone_database.db',
      version: 1,
      onCreate: (db, version) {
        db.execute(
          'CREATE TABLE selected_timezone(id INTEGER PRIMARY KEY, timezone1 TEXT, timezone2 TEXT)',
        );
      },
    );
    return database;
  }

  Future<void> _loadSavedTimeZones() async {
    final List<Map<String, dynamic>> results =
        await database.query('selected_timezone');
    if (results.isNotEmpty) {
      final savedTimeZone1 = results.first['timezone1'] as String;
      final savedTimeZone2 = results.first['timezone2'] as String;
      setState(() {
        selectedTimeZone1 = savedTimeZone1;
        selectedTimeZone2 = savedTimeZone2;
      });
    }
  }

  Future<void> _saveTimeZones(String timeZone1, String timeZone2) async {
    await database.delete('selected_timezone');
    await database.insert(
        'selected_timezone', {'timezone1': timeZone1, 'timezone2': timeZone2});
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var now = DateTime.now();

    var formattedDate = DateFormat('EEEE d MMMM').format(now);
    var timezoneString = now.timeZoneOffset.toString().split('.').first;
    var offsetSign = '';
    if (!timezoneString.startsWith('-')) offsetSign = '+';

    tz.initializeTimeZones();
    List<String> timeZones = tz.timeZoneDatabase.locations.keys.toList();

    String _formatTime(DateTime time) {
      final formatter = DateFormat('hh:mm a', 'en_US');
      return formatter.format(time);
    }

    void _showStopwatchDialog(BuildContext context) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Container(
                width: 275, // Adjust the width as needed
                child: StopWatchScreen()),
            title: Text("Stop Watch"),
          );
        },
      );
    }

    void _showTimerDialog(BuildContext context) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Container(
                width: 600, // Adjust the width as needed
                child: TimerScreen()),
            title: Text("Timer"),
          );
        },
      );
    }

    void _showTimeZoneDialog(BuildContext context, int timeZoneNumber) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Container(
              width: 275, // Adjust the width as needed
              child: DropdownButton<String>(
                value:
                    timeZoneNumber == 1 ? selectedTimeZone1 : selectedTimeZone2,
                items: timeZones.map((zone) {
                  return DropdownMenuItem<String>(
                    value: zone,
                    child: Text(zone),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    if (timeZoneNumber == 1) {
                      selectedTimeZone1 = newValue!;
                    } else {
                      selectedTimeZone2 = newValue!;
                    }
                    _saveTimeZones(selectedTimeZone1, selectedTimeZone2);
                  });
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ),
          );
        },
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      color: const Color.fromARGB(255, 255, 228, 250),
      child: Row(
        // crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Color.fromARGB(31, 255, 65, 179),
                  ),
                  height: 330,
                  width: 450,
                  child: const AlarmPage(),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  color: const Color.fromARGB(31, 255, 65, 179),
                  width: 450,
                  height: 120,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        'World Time',
                        style: TextStyle(
                            fontFamily: 'avenir',
                            fontWeight: FontWeight.w700,
                            color: CustomColors.primaryTextColor,
                            fontSize: 24),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {
                              _showTimeZoneDialog(context, 1);
                            },
                            child: Column(
                              children: [
                                Text(' $selectedTimeZone1',
                                    style: GoogleFonts.aBeeZee(
                                        fontSize: 14,
                                        color: const Color.fromARGB(
                                            255, 63, 63, 63))),
                                Text(
                                  "${_formatTime(currentTime1)}",
                                  style: GoogleFonts.aBeeZee(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 171, 91, 130)),
                                ),
                              ],
                            ),
                          ),
                          const VerticalDivider(
                            color: Color.fromARGB(255, 255, 255, 255),
                            width: 10,
                            thickness: 20,
                          ),
                          GestureDetector(
                            onTap: () {
                              _showTimeZoneDialog(context, 2);
                            },
                            child: Column(
                              children: [
                                Text(' $selectedTimeZone2',
                                    style: GoogleFonts.aBeeZee(
                                        fontSize: 14,
                                        color: const Color.fromARGB(
                                            255, 63, 63, 63))),
                                Text(
                                  "${_formatTime(currentTime2)}",
                                  style: GoogleFonts.aBeeZee(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 171, 91, 130)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const DigitalClockWidget(),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontFamily: 'avenir',
                          fontWeight: FontWeight.w300,
                          color: CustomColors.primaryTextColor,
                          fontSize: 25,
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  flex: 4,
                  fit: FlexFit.tight,
                  child: Align(
                    alignment: Alignment.center,
                    child: ClockView(
                      size: MediaQuery.of(context).size.height / 2,
                    ),
                  ),
                ),
                Flexible(
                  flex: 2,
                  fit: FlexFit.tight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Timezone',
                        style: TextStyle(
                            fontFamily: 'avenir',
                            fontWeight: FontWeight.w500,
                            color: CustomColors.primaryTextColor,
                            fontSize: 24),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.language,
                            color: CustomColors.primaryTextColor,
                          ),
                          SizedBox(width: 16),
                          Text(
                            'UTC' + offsetSign + timezoneString,
                            style: TextStyle(
                                fontFamily: 'avenir',
                                color: CustomColors.primaryTextColor,
                                fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(children: [
              Container(
                width: 450,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Color.fromARGB(31, 255, 65, 179),
                ),
                child: TableCalendar(
                  calendarFormat: _calendarFormat,
                  focusedDay: _focusedDay,
                  firstDay: DateTime(1990),
                  lastDay: DateTime(2050),
                  startingDayOfWeek: StartingDayOfWeek.sunday,
                  daysOfWeekVisible: true,
                  holidayPredicate: (DateTime day) {
                    // Mark December 25th and January 1st as holidays
                    return day.month == 11 && day.day == 12 ||
                        day.month == 12 && day.day == 25 ||
                        day.month == 1 && day.day == 1;
                  },
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  calendarStyle: const CalendarStyle(
                    isTodayHighlighted: true,
                    holidayTextStyle: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
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
                    markersMaxCount: 10, // Display only one marker per day
                    markersAlignment: Alignment.bottomCenter,
                    // Customize the appearance of holiday hints
                    markerDecoration: BoxDecoration(
                      color: Color.fromARGB(255, 3, 76, 32),
                      shape: BoxShape.circle,
                    ),
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
              SizedBox(
                height: 10,
              ),
              Container(
                  width: 450,
                  height: 100,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Color.fromARGB(31, 255, 65, 179),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                          style: ButtonStyle(
                            minimumSize: MaterialStateProperty.all(Size(
                                150, 50)), // Set the desired width and height
                            padding: MaterialStateProperty.all(EdgeInsets.all(
                                16)), // Adjust the padding for internal content
                          ),
                          onPressed: () {
                            _showStopwatchDialog(
                              context,
                            );
                          },
                          child: Text("Stop Watch")),
                      ElevatedButton(
                        style: ButtonStyle(
                          minimumSize: MaterialStateProperty.all(Size(
                              150, 50)), // Set the desired width and height
                          padding: MaterialStateProperty.all(EdgeInsets.all(
                              16)), // Adjust the padding for internal content
                        ),
                        onPressed: () {
                          _showTimerDialog(
                            context,
                          );
                        },
                        child: Text("Timer"),
                      ),
                    ],
                  )),
            ]),
          ),
        ],
      ),
    );
  }
}

class DigitalClockWidget extends StatefulWidget {
  const DigitalClockWidget({
    Key? key,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return DigitalClockWidgetState();
  }
}

class DigitalClockWidgetState extends State<DigitalClockWidget> {
  var formattedTime = DateFormat('HH:mm').format(DateTime.now());
  late Timer timer;

  @override
  void initState() {
    this.timer = Timer.periodic(Duration(seconds: 1), (timer) {
      var perviousMinute = DateTime.now().add(Duration(seconds: -1)).minute;
      var currentMinute = DateTime.now().minute;
      if (perviousMinute != currentMinute)
        setState(() {
          formattedTime = DateFormat('HH:mm').format(DateTime.now());
        });
    });
    super.initState();
  }

  @override
  void dispose() {
    this.timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('=====>digital clock updated');
    return Text(
      formattedTime,
      style: TextStyle(
          fontFamily: 'avenir',
          color: CustomColors.primaryTextColor,
          fontSize: 64),
    );
  }
}
