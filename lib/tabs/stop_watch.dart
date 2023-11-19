import 'dart:async';

import 'package:flutter/material.dart';
import 'package:new_clock_app_1/rounded_button.dart';
import 'package:new_clock_app_1/wave_circle_animator.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class StopWatchScreen extends StatefulWidget {
  const StopWatchScreen({Key? key}) : super(key: key);

  @override
  _StopWatchScreenState createState() => _StopWatchScreenState();
}

class _StopWatchScreenState extends State<StopWatchScreen> {
  final _isHours = true;

  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countUp,
    onChange: (value) => print('onChange $value'),
    onChangeRawSecond: (value) => print('onChangeRawSecond $value'),
    onChangeRawMinute: (value) => print('onChangeRawMinute $value'),
    onStopped: () {
      print('onStop');
    },
    onEnded: () {
      print('onEnded');
    },
  );

  final _scrollController = ScrollController();

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
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 32,
                horizontal: 16,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const WaveAnimation(
                      size: 100,
                      color: Color(0xFFFF869E),
                      centerChild: Icon(
                        Icons.rocket_launch_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),

                    /// Display stop watch time
                    StreamBuilder<int>(
                      stream: _stopWatchTimer.rawTime,
                      initialData: _stopWatchTimer.rawTime.value,
                      builder: (context, snap) {
                        final value = snap.data!;
                        final displayTime = StopWatchTimer.getDisplayTime(value,
                            hours: _isHours);
                        return Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                displayTime,
                                style: const TextStyle(
                                    fontSize: 40,
                                    fontFamily: 'Helvetica',
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(8),
                              child: Text(
                                "HH : MM : SS . Ms",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Helvetica',
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    /// Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: RoundedButton(
                                bgcolor: Color.fromARGB(117, 100, 100, 100),
                                color: const Color.fromARGB(255, 255, 255, 255),
                                onTap: _stopWatchTimer.onStartTimer,
                                child: const Icon(
                                    Icons.play_circle_outline_outlined)),
                          ),
                        ),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: RoundedButton(
                              bgcolor: Color.fromARGB(117, 100, 100, 100),
                              color: Color.fromARGB(255, 255, 255, 255),
                              onTap: _stopWatchTimer.onStopTimer,
                              child: const Icon(Icons.stop_circle_outlined),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: RoundedButton(
                              bgcolor: Color.fromARGB(117, 100, 100, 100),
                              color: Color.fromARGB(255, 255, 255, 255),
                              onTap: _stopWatchTimer.onResetTimer,
                              child: const Icon(Icons.restore),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // lap btn
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Flexible(
                            child: Padding(
                              padding:
                                  const EdgeInsets.all(5).copyWith(right: 8),
                              child: RoundedButton(
                                  bgcolor: Color.fromARGB(117, 100, 100, 100),
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  onTap: _stopWatchTimer.onAddLap,
                                  child: const Icon(Icons.flag_circle_rounded)),
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
                              return const SizedBox.shrink();
                            }
                            Future.delayed(const Duration(milliseconds: 100),
                                () {
                              _scrollController.animateTo(
                                  _scrollController.position.maxScrollExtent,
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeOut);
                            });
                            print('Listen records. $value');
                            return ListView.builder(
                              controller: _scrollController,
                              scrollDirection: Axis.vertical,
                              itemBuilder: (BuildContext context, int index) {
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
                                            fontWeight: FontWeight.bold),
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
