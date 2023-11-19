import 'dart:async';
import 'package:flutter/material.dart';
import 'package:new_clock_app_1/rounded_button.dart';
import 'package:new_clock_app_1/wave_circle_animator.dart';
//import 'package:flutter_alarm_clock/app/numberpicker.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({Key? key}) : super(key: key);

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with SingleTickerProviderStateMixin {
  Duration _initialDuration = Duration(minutes: 0, seconds: 5);
  Duration _remainingDuration = Duration(minutes: 0, seconds: 5);
  bool _isActive = false;
  bool _isReset = true;
  late int _current_H_Value = 0;
  late int _current_M_Value = 0;
  late int _current_S_Value = 5;
  bool isToggled = false;

  final _isHours = true;

  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countDown,
    presetMillisecond: StopWatchTimer.getMilliSecFromSecond(0),
    onChange: (value) => print('onChange $value'),
    onChangeRawSecond: (value) => print('onChangeRawSecond $value'),
    onChangeRawMinute: (value) => print('onChangeRawMinute $value'),
    onStopped: () {
      print('onStopped');
    },
    onEnded: () {
      print('onEnded');
    },
  );

  final _scrollController = ScrollController();

  bool isPopupOpen = false;

  void openPopup() {
    setState(() {
      isPopupOpen = true;
    });
  }

  void closePopup() {
    if (_stopWatchTimer.isRunning) {
      showSnackBar('Stop the timer, then click the cancel button..');
    } else {
      setState(() {
        print(
            "....................................................................");
        Navigator.of(context).pop();
      });
    }
  }

  void showAlertDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Timer'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  // mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    //SizedBox(height: 10),
                    Scrollbar(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 32,
                            horizontal: 16,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              /// Display stop watch time
                              StreamBuilder<int>(
                                stream: _stopWatchTimer.rawTime,
                                initialData: _stopWatchTimer.rawTime.value,
                                builder: (context, snap) {
                                  final value = snap.data!;
                                  final displayTime =
                                      StopWatchTimer.getDisplayTime(value,
                                          hours: _isHours);
                                  return Column(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Text(displayTime,
                                            style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 227, 24, 153),
                                                fontSize: 40,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Text(
                                          isToggled
                                              ? '$_current_H_Value h  $_current_M_Value m  $_current_S_Value s'
                                              : '0 h  0 m  0 s',
                                          style: const TextStyle(
                                              fontSize: 16,
                                              color: Color.fromARGB(
                                                  194, 96, 2, 54),
                                              fontFamily: 'Helvetica',
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),

                              /// Button
                              Padding(
                                padding: const EdgeInsets.only(bottom: 0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Flexible(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4),
                                        child: RoundedButton(
                                            bgcolor:
                                                Color.fromARGB(200, 104, 1, 76),
                                            color: const Color.fromARGB(
                                                255, 255, 255, 255),
                                            onTap: _stopWatchTimer.onStartTimer,
                                            child: const Icon(Icons
                                                .play_circle_outline_outlined)),
                                      ),
                                    ),
                                    Flexible(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4),
                                        child: RoundedButton(
                                          color: Color.fromARGB(
                                              255, 255, 255, 255),
                                          onTap: _stopWatchTimer.onStopTimer,
                                          child: const Icon(
                                              Icons.stop_circle_outlined),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4),
                                        child: RoundedButton(
                                          color: Color.fromARGB(
                                              255, 255, 255, 255),
                                          onTap: _stopWatchTimer.onResetTimer,
                                          child: const Icon(Icons.restore),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              /// Lap time.
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: SizedBox(
                                  height: 100,
                                  child: StreamBuilder<List<StopWatchRecord>>(
                                    stream: _stopWatchTimer.records,
                                    initialData: _stopWatchTimer.records.value,
                                    builder: (context, snap) {
                                      final value = snap.data!;
                                      if (value.isEmpty) {
                                        return const SizedBox();
                                      }
                                      Future.delayed(
                                          const Duration(milliseconds: 100),
                                          () {
                                        _scrollController.animateTo(
                                            _scrollController
                                                .position.maxScrollExtent,
                                            duration: const Duration(
                                                milliseconds: 200),
                                            curve: Curves.easeOut);
                                      });
                                      print('Listen records. $value');
                                      return ListView.builder(
                                        controller: _scrollController,
                                        scrollDirection: Axis.vertical,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          final data = value[index];
                                          return Column(
                                            children: <Widget>[
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                child: Text(
                                                  '${index + 1} ${data.displayTime}',
                                                  style: const TextStyle(
                                                      fontSize: 17,
                                                      fontFamily: 'Helvetica',
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              const Divider(
                                                height: 1,
                                              )
                                            ],
                                          );
                                        },
                                        itemCount: value.length,
                                      );
                                    },
                                  ),
                                ),
                              ),

                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Flexible(
                                      child: Padding(
                                        padding: const EdgeInsets.all(0)
                                            .copyWith(right: 8),
                                        child: RoundedButton(
                                          color: Colors.deepPurpleAccent,
                                          onTap: _stopWatchTimer.onAddLap,
                                          child: const Text(
                                            'Lap',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: RoundedButton(
                                  color: Colors.pinkAccent,
                                  onTap: _stopWatchTimer.clearPresetTime,
                                  child: const Text(
                                    'Clear PresetTime',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    ElevatedButton(
                      onPressed: closePopup,
                      child: Text('Cancel'),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    _stopWatchTimer.rawTime.listen((value) =>
        print('rawTime $value ${StopWatchTimer.getDisplayTime(value)}'));
    _stopWatchTimer.minuteTime.listen((value) => print('minuteTime $value'));
    _stopWatchTimer.secondTime.listen((value) => print('secondTime $value'));
    _stopWatchTimer.records.listen((value) => print('records $value'));
    _stopWatchTimer.fetchStopped
        .listen((value) => print('stopped from stream'));
    _stopWatchTimer.fetchEnded.listen((value) => print('ended from stream'));

    /// Can be set preset time. This case is "00:01.23".
    // _stopWatchTimer.setPresetTime(mSec: 1234);
  }

  @override
  void dispose() async {
    super.dispose();
    await _stopWatchTimer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(0, 173, 58, 58),
      body: Column(
        children: [
          const WaveAnimation(
            size: 100,
            color: Color(0xFFFF869E),
            centerChild: Icon(
              Icons.rocket_launch_rounded,
              color: Colors.white,
              size: 38,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                //mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 260,
                    color: Color.fromARGB(0, 203, 31, 31),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Column(
                          children: [
                            Text('Hours',
                                style: Theme.of(context).textTheme.labelLarge),
                            NumberPicker(
                              value: _current_H_Value,
                              minValue: 00,
                              maxValue: 24,
                              step: 01,
                              haptics: true,
                              selectedTextStyle: TextStyle(
                                color: Color.fromARGB(250, 0, 0, 0),
                                fontWeight: FontWeight.bold,
                                fontSize: 35,
                              ),
                              textStyle: TextStyle(
                                color: Color.fromARGB(97, 53, 53, 53),
                                fontSize: 35,
                              ),
                              itemWidth: 60,
                              itemHeight: 40,
                              axis: Axis.vertical,
                              // decoration: BoxDecoration(
                              //   border: Border.all(
                              //       color:
                              //           Color.fromARGB(100, 255, 255, 255)),
                              //   borderRadius: BorderRadius.circular(0),
                              // ),
                              onChanged: (value1) =>
                                  setState(() => _current_H_Value = value1),
                            ),
                          ],
                        ),
                        SizedBox(width: 16),
                        Column(
                          children: [
                            Text('Minutes',
                                style: Theme.of(context).textTheme.labelLarge),
                            NumberPicker(
                              value: _current_M_Value,
                              minValue: 0,
                              maxValue: 59,
                              step: 1,
                              haptics: true,
                              selectedTextStyle: TextStyle(
                                color: Color.fromARGB(250, 0, 0, 0),
                                fontWeight: FontWeight.bold,
                                fontSize: 35,
                              ),
                              textStyle: TextStyle(
                                color: Color.fromARGB(97, 53, 53, 53),
                                fontSize: 35,
                              ),
                              itemWidth: 60,
                              itemHeight: 40,
                              axis: Axis.vertical,
                              // decoration: BoxDecoration(
                              //   border: Border.all(
                              //       color:
                              //           Color.fromARGB(100, 255, 255, 255)),
                              //   borderRadius: BorderRadius.circular(8),
                              // ),
                              onChanged: (value2) {
                                setState(() {
                                  print("Value selected: $_current_M_Value");
                                  _current_M_Value = value2;
                                });
                              },
                            ),
                          ],
                        ),
                        SizedBox(width: 16),
                        Column(
                          children: [
                            Text('Seconds',
                                style: Theme.of(context).textTheme.labelLarge),
                            NumberPicker(
                              value: _current_S_Value,
                              minValue: 0,
                              maxValue: 59,
                              step: 1,
                              haptics: true,
                              selectedTextStyle: TextStyle(
                                color: Color.fromARGB(250, 0, 0, 0),
                                fontWeight: FontWeight.bold,
                                fontSize: 35,
                              ),
                              textStyle: TextStyle(
                                color: Color.fromARGB(97, 53, 53, 53),
                                fontSize: 35,
                              ),
                              itemWidth: 60,
                              itemHeight: 40,
                              axis: Axis.vertical,
                              // decoration: BoxDecoration(
                              //   border: Border.all(
                              //       color:
                              //           Color.fromARGB(100, 255, 255, 255)),
                              //   borderRadius: BorderRadius.circular(8),
                              // ),
                              onChanged: (value) =>
                                  setState(() => _current_S_Value = value),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  //Divider(color: Colors.grey, height: 32),
                  //  Text('Current int value: $_current_H_Value : $_current_M_Value : $_current_S_Value'),
                  SizedBox(height: 16),
                  FloatingActionButton(
                      child: Text('Set', style: TextStyle(fontSize: 18)),
                      elevation: 2,
                      backgroundColor: Color.fromARGB(248, 54, 51, 54),
                      onPressed: () {
                        isToggled = true;
                        setDuration();
                        // openPopup();
                        // if (isPopupOpen) showAlertDialog();
                      }),
                ],
              ),
              VerticalDivider(
                  width: 15, color: Color.fromARGB(131, 255, 7, 168)),
              Expanded(
                child: Container(
                  color: Color.fromARGB(0, 0, 0, 1),
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 0,
                        ),
                        child: Column(
                          //  mainAxisAlignment: MainAxisAlignment.center,
                          //  crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            /// Display stop watch time
                            StreamBuilder<int>(
                              stream: _stopWatchTimer.rawTime,
                              initialData: _stopWatchTimer.rawTime.value,
                              builder: (context, snap) {
                                final value = snap.data!;
                                final displayTime =
                                    StopWatchTimer.getDisplayTime(value,
                                        hours: _isHours);
                                return Column(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Text(displayTime,
                                          style: TextStyle(
                                              color: Color.fromARGB(
                                                  186, 242, 41, 178),
                                              fontSize: 45,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Text(
                                        isToggled
                                            ? '$_current_H_Value h  $_current_M_Value m  $_current_S_Value s'
                                            : '0 h  0 m  0 s',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            color:
                                                Color.fromARGB(194, 96, 2, 54),
                                            fontFamily: 'Helvetica',
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            SizedBox(
                              height: 5,
                            ),

                            /// Button
                            Padding(
                              padding: const EdgeInsets.only(bottom: 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Flexible(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      child: RoundedButton(
                                          bgcolor: Color.fromARGB(
                                              117, 100, 100, 100),
                                          color: const Color.fromARGB(
                                              255, 255, 255, 255),
                                          onTap: _stopWatchTimer.onStartTimer,
                                          child: const Icon(Icons
                                              .play_circle_outline_outlined)),
                                    ),
                                  ),
                                  Flexible(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      child: RoundedButton(
                                        bgcolor:
                                            Color.fromARGB(117, 100, 100, 100),
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                        onTap: _stopWatchTimer.onStopTimer,
                                        child: const Icon(
                                            Icons.stop_circle_outlined),
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      child: RoundedButton(
                                        bgcolor:
                                            Color.fromARGB(117, 100, 100, 100),
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                        onTap: _stopWatchTimer.onResetTimer,
                                        child: const Icon(Icons.restore),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),

                            /// lap button
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Flexible(
                                    child: Padding(
                                      padding: const EdgeInsets.all(5)
                                          .copyWith(right: 8),
                                      child: RoundedButton(
                                          bgcolor: Color.fromARGB(
                                              117, 100, 100, 100),
                                          color: Color.fromARGB(
                                              255, 255, 255, 255),
                                          onTap: _stopWatchTimer.onAddLap,
                                          child: const Icon(
                                              Icons.flag_circle_rounded)),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            /// Lap time.
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: SizedBox(
                                height: 100,
                                child: StreamBuilder<List<StopWatchRecord>>(
                                  stream: _stopWatchTimer.records,
                                  initialData: _stopWatchTimer.records.value,
                                  builder: (context, snap) {
                                    final value = snap.data!;
                                    if (value.isEmpty) {
                                      return const SizedBox();
                                    }
                                    Future.delayed(
                                        const Duration(milliseconds: 100), () {
                                      _scrollController.animateTo(
                                          _scrollController
                                              .position.maxScrollExtent,
                                          duration:
                                              const Duration(milliseconds: 200),
                                          curve: Curves.easeOut);
                                    });
                                    print('Listen records. $value');
                                    return ListView.builder(
                                      controller: _scrollController,
                                      scrollDirection: Axis.vertical,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        final data = value[index];
                                        return Column(
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.all(8),
                                              child: Text(
                                                '${index + 1} ${data.displayTime}',
                                                style: const TextStyle(
                                                    fontSize: 17,
                                                    fontFamily: 'Helvetica',
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            const Divider(
                                              height: 1,
                                            )
                                          ],
                                        );
                                      },
                                      itemCount: value.length,
                                    );
                                  },
                                ),
                              ),
                            ),

                            SizedBox(
                              height: 5,
                            ),

                            /// clear
                            // Padding(
                            //   padding: const EdgeInsets.symmetric(horizontal: 4),
                            //   child: RoundedButton(
                            //     color: Colors.pinkAccent,
                            //     onTap: _stopWatchTimer.clearPresetTime,
                            //     child: const Text(
                            //       'Clear PresetTime',
                            //       style: TextStyle(color: Colors.white),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  void setDuration() {
    setState(() {
      _initialDuration = Duration(
          minutes: _current_M_Value,
          hours: _current_H_Value,
          seconds: _current_S_Value);
      _remainingDuration = _initialDuration;
      print(_remainingDuration);
      _stopWatchTimer.clearPresetTime();
      _stopWatchTimer.setPresetHoursTime(_current_H_Value);
      _stopWatchTimer.setPresetMinuteTime(_current_M_Value);
      _stopWatchTimer.setPresetSecondTime(_current_S_Value);
    });
  }

  void startTimer() {
    if (!_isActive && _remainingDuration.inSeconds > 0) {
      setState(() {
        _isActive = true;
        _isReset = false;
      });
      const oneSec = const Duration(seconds: 1);
      Timer.periodic(
        oneSec,
        (Timer timer) {
          if (_remainingDuration.inSeconds == 0) {
            timer.cancel();
            setState(() {
              _isActive = false;
            });
            showSnackBar('Timer Complete2');
          } else {
            setState(() {
              _remainingDuration = _remainingDuration - oneSec;
            });
          }
        },
      );
    }
  }

  void resetTimer() {
    setState(() {
      _remainingDuration = _initialDuration;
      _isReset = true;
    });
    const oneSec = const Duration(seconds: 1);
    Timer.periodic(
      oneSec,
      (Timer timer) {
        timer.cancel();
        setState(() {
          _isActive = false;
        });
        showSnackBar('Timer Complete!');
      },
    );
    showSnackBar('Timer Reset');
  }

  void resumeTimer() {
    if (!_isActive && !_isReset && _remainingDuration.inSeconds > 0) {
      setState(() {
        _isActive = true;
      });
      showSnackBar('Timer Resumed');
      startTimer();
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
