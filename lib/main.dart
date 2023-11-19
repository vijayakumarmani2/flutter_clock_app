import 'package:flutter/material.dart';
import 'package:new_clock_app_1/tabs/calender.dart';
import 'package:new_clock_app_1/tabs/clock_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
late tz.TZDateTime _local;

Future<void> initializeLocalTimeZone() async {
  _local = await tz.TZDateTime.now(
      tz.local); // Example of asynchronous initialization
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

//  initializeLocalTimeZone();
  // Initialize the database factory
  // sqfliteFfiInitAsMockMethodCallHandler();
//  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  // sqflite_ffi.setupDylib('G:\Flutter\set_alarm\set_alarm_db\sqlite3.dll');

  databaseFactory = databaseFactoryFfi;

  var initializationSettingsAndroid =
      const AndroidInitializationSettings('@mipmap/ic_launcher');
  const IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String? payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }
  });
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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(100),
                child: AppBar(
                  backgroundColor: const Color.fromARGB(255, 255, 65, 179),
                  elevation: 0,
                  title: const Text("Clock App"),
                  bottom: const TabBar(
                      labelColor: Color.fromARGB(255, 255, 65, 179),
                      unselectedLabelColor: Colors.white,
                      indicatorSize: TabBarIndicatorSize.label,
                      indicator: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10)),
                          color: Color.fromARGB(255, 255, 228, 250)),
                      tabs: [
                        Tab(
                          child: Align(
                            alignment: Alignment.center,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.dashboard_customize, size: 14),
                                Text("Dashboard"),
                              ],
                            ),
                          ),
                        ),
                        Tab(
                          child: Align(
                            alignment: Alignment.center,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.calendar_month_rounded, size: 14),
                                Text("Calendar"),
                              ],
                            ),
                          ),
                        ),
                      ]),
                ),
              ),
              body: TabBarView(children: [
                ClockPage(),
                CalendarApp(),
              ]),
            )));
  }
}
