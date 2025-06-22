// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
import 'dart:async';

class GlobalTimerManager {
  static Timer? _globalTimer;
  static void start(Future<void> Function() onTick) {
    if (_globalTimer?.isActive ?? false) return;
    _globalTimer = Timer.periodic(Duration(seconds: 60), (timer) => onTick());
  }
}

Future<void> startGlobalDataProcessor() async {
  GlobalTimerManager.start(() async {
    await processAndStoreDailyHistory();
    List<ActivityDurationStruct> todayDurations =
        await calculateDurationsFromLogs(FFAppState().postureLogs);
    FFAppState().globalActivityDurations = todayDurations;
  });
}
